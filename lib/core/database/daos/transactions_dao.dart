import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/asset_transactions.dart';
import 'package:finanseapp/core/database/tables/asset_transaction_revisions.dart';
import 'package:finanseapp/core/database/tables/asset_transfers.dart';
import 'package:finanseapp/core/database/revision_snapshots.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';

part 'transactions_dao.g.dart';

/// Вход операции по активу: суммы уже в minor units в валюте актива.
///
/// `amountRubMinor` считает вызывающий repository через `MoneyMath` до записи
/// (TX-ASSET-TX-CREATE, шаг 2).
final class AssetTransactionInput {
  const AssetTransactionInput({
    required this.assetId,
    required this.kind,
    required this.amountMinor,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRubMinor,
    this.currencyCode,
    this.comment,
  });

  final int assetId;
  final AssetTransactionKind kind;
  final int amountMinor;

  /// Валюта операции (M1); `null` — валюта актива.
  final String? currencyCode;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final int amountRubMinor;
  final String? comment;
}

/// Вход перевода: суммы каждой ноги в валюте своего счёта.
final class TransferInput {
  const TransferInput({
    required this.fromAccountId,
    required this.toAccountId,
    required this.fromAmountMinor,
    required this.toAmountMinor,
    required this.occurredOn,
    required this.fromRateToRub,
    required this.toRateToRub,
    required this.fromAmountRubMinor,
    required this.toAmountRubMinor,
    this.comment,
  });

  final int fromAccountId;
  final int toAccountId;
  final int fromAmountMinor;
  final int toAmountMinor;
  final LocalDate occurredOn;
  final Decimal fromRateToRub;
  final Decimal toRateToRub;
  final int fromAmountRubMinor;
  final int toAmountRubMinor;
  final String? comment;
}

/// Операции по активам: create/revise/softDelete и перевод двумя ногами.
///
/// Любая ошибка откатывает и current projection, и ревизию
/// (TX-ASSET-TX-CREATE / TX-TRANSFER-SAVE).
@DriftAccessor(
  tables: [
    Assets,
    AssetTransactions,
    AssetTransactionRevisions,
    AssetTransfers,
  ],
)
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  /// Все операции (включая soft-deleted) для батч-сборки снапшотов.
  Future<List<AssetTransactionRow>> allRows() =>
      select(assetTransactions).get();

  /// Удалённые операции для аудита и восстановления (13.1).
  Stream<List<AssetTransactionRow>> watchDeleted() {
    final query = select(assetTransactions)
      ..where((t) => t.deletedAt.isNotNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.deletedAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.watch();
  }

  /// Журнал операций с фильтрами (6.1: базовые; UI — 6.3).
  Stream<List<AssetTransactionRow>> watchFiltered(TransactionFilter filter) {
    final query =
        select(assetTransactions).join([
            innerJoin(assets, assets.id.equalsExp(assetTransactions.assetId)),
          ])
          ..where(assetTransactions.deletedAt.isNull())
          ..orderBy([
            OrderingTerm.desc(assetTransactions.occurredOn),
            OrderingTerm.desc(assetTransactions.id),
          ]);
    final period = filter.period;
    if (period != null) {
      query.where(
        assetTransactions.occurredOn.isBiggerOrEqualValue(
              period.start.toIsoString(),
            ) &
            assetTransactions.occurredOn.isSmallerOrEqualValue(
              period.end.toIsoString(),
            ),
      );
    }
    if (filter.assetId != null) {
      query.where(assetTransactions.assetId.equals(filter.assetId!));
    }
    if (filter.kind != null) {
      query.where(assetTransactions.kind.equalsValue(filter.kind!));
    }
    if (filter.assetKind != null) {
      query.where(assets.kind.equalsValue(filter.assetKind!));
    }
    if (filter.currencyCode != null) {
      // M8: валюта операции, а NULL означает валюту актива.
      final code = filter.currencyCode!;
      query.where(
        assetTransactions.currencyCode.equals(code) |
            (assetTransactions.currencyCode.isNull() &
                assets.currencyCode.equals(code)),
      );
    }
    if (filter.limit != null) query.limit(filter.limit!);
    return query.watch().map(
      (rows) => [for (final row in rows) row.readTable(assetTransactions)],
    );
  }

  Stream<List<AssetTransactionRow>> watchByAsset(int assetId) {
    final query = select(assetTransactions)
      ..where((t) => t.assetId.equals(assetId) & t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredOn),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.watch();
  }

  Future<AssetTransactionRow> getById(int id) async => _requireTransaction(id);

  Future<List<AssetTransactionRevisionRow>> revisions(int transactionId) {
    final query = select(assetTransactionRevisions)
      ..where((r) => r.transactionId.equals(transactionId))
      ..orderBy([(r) => OrderingTerm.asc(r.revisionNo)]);
    return query.get();
  }

  /// Создаёт операцию и ревизию `create` с идентичным snapshot.
  Future<int> create(AssetTransactionInput input) => transaction(() async {
    _validateOperation(input);
    _requireNotFuture(input.occurredOn);
    if (_isTransferKind(input.kind)) {
      throw _validation('kind', 'validationTransferThroughTransferCommand');
    }
    final asset = await _requireAsset(input.assetId);
    _requireTransactionAllowed(asset);

    await _assertProjectedBalance(
      asset: asset,
      occurredOn: input.occurredOn,
      kind: input.kind,
      amountMinor: input.amountMinor,
    );

    final now = attachedDatabase.clock();
    final id = await into(assetTransactions).insert(
      AssetTransactionsCompanion.insert(
        assetId: input.assetId,
        kind: input.kind,
        amountMinor: input.amountMinor,
        currencyCode: Value(input.currencyCode),
        occurredOn: input.occurredOn,
        rateToRub: input.rateToRub,
        amountRubMinor: input.amountRubMinor,
        revisionNo: 1,
        createdAt: now,
        updatedAt: now,
        comment: Value(input.comment),
      ),
    );
    await _writeRevision(
      await _requireTransaction(id),
      RevisionAction.create,
      now,
    );
    return id;
  });

  /// Добавляет ревизию `edit` и обновляет current projection.
  Future<void> revise(int id, AssetTransactionInput input) =>
      transaction(() async {
        _validateOperation(input);
        _requireNotFuture(input.occurredOn);
        if (_isTransferKind(input.kind)) {
          throw _validation('kind', 'validationTransferThroughTransferCommand');
        }
        final current = await _requireTransaction(id);
        if (current.transferId != null) {
          throw _conflict('validationTransferLegDirectEdit');
        }
        if (current.deletedAt != null) {
          throw _conflict('validationTransactionDeleted');
        }
        final asset = await _requireAsset(input.assetId);
        _requireTransactionAllowed(asset);

        await _assertProjectedBalance(
          asset: asset,
          occurredOn: input.occurredOn,
          kind: input.kind,
          amountMinor: input.amountMinor,
          excludeTransactionId: id,
        );
        if (current.assetId != input.assetId) {
          // Удаление операции со старого счёта не должно ломать его историю.
          await _assertHistoryBalance(
            assetId: current.assetId,
            exclude: {id},
            pending: const [],
          );
        }

        final now = attachedDatabase.clock();
        await (update(assetTransactions)..where((t) => t.id.equals(id))).write(
          AssetTransactionsCompanion(
            assetId: Value(input.assetId),
            kind: Value(input.kind),
            amountMinor: Value(input.amountMinor),
            currencyCode: Value(input.currencyCode),
            occurredOn: Value(input.occurredOn),
            rateToRub: Value(input.rateToRub),
            amountRubMinor: Value(input.amountRubMinor),
            comment: Value(input.comment),
            revisionNo: Value(current.revisionNo + 1),
            updatedAt: Value(now),
          ),
        );
        await _writeRevision(
          await _requireTransaction(id),
          RevisionAction.edit,
          now,
        );
      });

  /// Мягко удаляет операцию, сохраняя строку и delete-ревизию.
  Future<void> softDelete(int id) => transaction(() async {
    final current = await _requireTransaction(id);
    if (current.transferId != null) {
      throw _conflict('validationTransferLegDirectEdit');
    }
    if (current.deletedAt != null) {
      throw _conflict('validationTransactionDeleted');
    }
    await _assertHistoryBalance(
      assetId: current.assetId,
      exclude: {id},
      // Удаление = история без этой строки: отсутствие кредита сразу
      // отражается в последующих точках баланса.
      pending: const [],
    );
    final now = attachedDatabase.clock();
    await (update(assetTransactions)..where((t) => t.id.equals(id))).write(
      AssetTransactionsCompanion(
        revisionNo: Value(current.revisionNo + 1),
        updatedAt: Value(now),
        deletedAt: Value(now),
      ),
    );
    await _writeRevision(
      await _requireTransaction(id),
      RevisionAction.delete,
      now,
    );
  });

  /// Восстанавливает soft-deleted операцию (или обе ноги перевода) с
  /// restore-ревизией и повторной проверкой баланса/связей.
  Future<void> restore(int id) => transaction(() async {
    final current = await _requireTransaction(id);
    if (current.deletedAt == null) {
      throw _conflict('validationTransactionAlreadyActive');
    }
    if (current.transferId != null) {
      await _restoreTransfer(current.transferId!);
      return;
    }
    final asset = await _requireAsset(current.assetId);
    await _assertProjectedBalance(
      asset: asset,
      occurredOn: current.occurredOn,
      kind: current.kind,
      amountMinor: current.amountMinor,
      excludeTransactionId: id,
    );
    final now = attachedDatabase.clock();
    await (update(assetTransactions)..where((t) => t.id.equals(id))).write(
      AssetTransactionsCompanion(
        revisionNo: Value(current.revisionNo + 1),
        updatedAt: Value(now),
        deletedAt: const Value(null),
      ),
    );
    await _writeRevision(
      await _requireTransaction(id),
      RevisionAction.restore,
      now,
    );
    await attachedDatabase.cashflowDao.restoreFromAsset(id);
  });

  Future<void> restoreTransfer(int transferId) => _restoreTransfer(transferId);

  Future<void> _restoreTransfer(int transferId) async {
    final legs = await _transferLegs(transferId, includeDeleted: true);
    if (legs.length != 2) throw _conflict('validationTransferCorrupted');
    if (legs.every((leg) => leg.deletedAt == null)) {
      throw _conflict('validationTransactionAlreadyActive');
    }
    if (legs.any((leg) => leg.deletedAt == null)) {
      throw _conflict('validationTransferCorrupted');
    }
    final outLeg = _legOfKind(legs, AssetTransactionKind.transferOut);
    await _assertProjectedBalance(
      asset: await _requireAsset(outLeg.assetId),
      occurredOn: outLeg.occurredOn,
      kind: outLeg.kind,
      amountMinor: outLeg.amountMinor,
      excludeTransactionId: outLeg.id,
    );
    final now = attachedDatabase.clock();
    for (final leg in legs) {
      await (update(
        assetTransactions,
      )..where((t) => t.id.equals(leg.id))).write(
        AssetTransactionsCompanion(
          revisionNo: Value(leg.revisionNo + 1),
          updatedAt: Value(now),
          deletedAt: const Value(null),
        ),
      );
    }
    await (update(assetTransfers)..where((t) => t.id.equals(transferId))).write(
      AssetTransfersCompanion(updatedAt: Value(now)),
    );
    for (final leg in await _transferLegs(transferId, includeDeleted: true)) {
      await _writeRevision(leg, RevisionAction.restore, now);
    }
  }

  /// Создаёт группу перевода и обе ноги с create-ревизиями.
  Future<int> createTransfer(TransferInput input) => transaction(() async {
    await _validateTransfer(input);
    final from = await _requireAsset(input.fromAccountId);
    await _assertProjectedBalance(
      asset: from,
      occurredOn: input.occurredOn,
      kind: AssetTransactionKind.transferOut,
      amountMinor: input.fromAmountMinor,
    );
    final now = attachedDatabase.clock();
    final transferId = await into(assetTransfers)
        .insert(AssetTransfersCompanion.insert(createdAt: now, updatedAt: now));

    await into(assetTransactions).insert(
      _legCompanion(
        input: input,
        transferId: transferId,
        assetId: input.fromAccountId,
        kind: AssetTransactionKind.transferOut,
        amountMinor: input.fromAmountMinor,
        rateToRub: input.fromRateToRub,
        amountRubMinor: input.fromAmountRubMinor,
        now: now,
      ),
    );
    await into(assetTransactions).insert(
      _legCompanion(
        input: input,
        transferId: transferId,
        assetId: input.toAccountId,
        kind: AssetTransactionKind.transferIn,
        amountMinor: input.toAmountMinor,
        rateToRub: input.toRateToRub,
        amountRubMinor: input.toAmountRubMinor,
        now: now,
      ),
    );

    for (final leg in await _transferLegs(transferId)) {
      await _writeRevision(leg, RevisionAction.create, now);
    }
    return transferId;
  });

  /// Обновляет обе ноги одним draft, добавляя по edit-ревизии.
  Future<void> reviseTransfer(int transferId, TransferInput input) =>
      transaction(() async {
        await _validateTransfer(input);
        final legs = await _transferLegs(transferId, includeDeleted: true);
        if (legs.length != 2) throw _conflict('validationTransferCorrupted');
        final outLeg = _legOfKind(legs, AssetTransactionKind.transferOut);
        final inLeg = _legOfKind(legs, AssetTransactionKind.transferIn);
        if (outLeg.deletedAt != null || inLeg.deletedAt != null) {
          throw _conflict('validationTransferDeleted');
        }
        for (final assetId in {
          outLeg.assetId,
          inLeg.assetId,
          input.fromAccountId,
          input.toAccountId,
        }) {
          final pending = <_PendingOperation>[
            if (assetId == input.fromAccountId)
              _PendingOperation(
                kind: AssetTransactionKind.transferOut,
                amountMinor: input.fromAmountMinor,
                occurredOn: input.occurredOn,
                id: outLeg.id,
              ),
            if (assetId == input.toAccountId)
              _PendingOperation(
                kind: AssetTransactionKind.transferIn,
                amountMinor: input.toAmountMinor,
                occurredOn: input.occurredOn,
                id: inLeg.id,
              ),
          ];
          await _assertHistoryBalance(
            assetId: assetId,
            exclude: {outLeg.id, inLeg.id},
            pending: pending,
          );
        }

        final now = attachedDatabase.clock();
        await (update(assetTransfers)..where((t) => t.id.equals(transferId)))
            .write(AssetTransfersCompanion(updatedAt: Value(now)));

        await _updateLeg(
          leg: outLeg,
          assetId: input.fromAccountId,
          amountMinor: input.fromAmountMinor,
          rateToRub: input.fromRateToRub,
          amountRubMinor: input.fromAmountRubMinor,
          occurredOn: input.occurredOn,
          comment: input.comment,
          now: now,
        );
        await _updateLeg(
          leg: inLeg,
          assetId: input.toAccountId,
          amountMinor: input.toAmountMinor,
          rateToRub: input.toRateToRub,
          amountRubMinor: input.toAmountRubMinor,
          occurredOn: input.occurredOn,
          comment: input.comment,
          now: now,
        );

        for (final leg in await _transferLegs(transferId)) {
          await _writeRevision(leg, RevisionAction.edit, now);
        }
      });

  /// Мягко удаляет обе ноги и добавляет delete-ревизии; группа остаётся.
  Future<void> softDeleteTransfer(int transferId) => transaction(() async {
    final legs = await _transferLegs(transferId, includeDeleted: true);
    if (legs.length != 2) throw _conflict('validationTransferCorrupted');
    final deletedLegs = legs.where((leg) => leg.deletedAt != null).length;
    if (deletedLegs > 0) {
      // Полностью или частично удалённый перевод повторно не удаляется.
      throw _conflict('validationTransferDeleted');
    }
    for (final leg in legs) {
      await _assertHistoryBalance(
        assetId: leg.assetId,
        exclude: legs.map((leg) => leg.id).toSet(),
        pending: const [],
      );
    }
    final now = attachedDatabase.clock();
    for (final leg in legs) {
      await (update(
        assetTransactions,
      )..where((t) => t.id.equals(leg.id))).write(
        AssetTransactionsCompanion(
          revisionNo: Value(leg.revisionNo + 1),
          updatedAt: Value(now),
          deletedAt: Value(now),
        ),
      );
    }
    await (update(assetTransfers)..where((t) => t.id.equals(transferId))).write(
      AssetTransfersCompanion(updatedAt: Value(now)),
    );

    for (final leg in await _transferLegs(transferId, includeDeleted: true)) {
      await _writeRevision(leg, RevisionAction.delete, now);
    }
  });

  /// BR-VAL-5: дата операции не может быть в будущем (локальная «сегодня»).
  void _requireNotFuture(LocalDate date) {
    if (date.compareTo(attachedDatabase.today()) > 0) {
      throw _validation('occurredOn', 'validationDateInFuture');
    }
  }

  /// Проверяет, что баланс счёта не станет отрицательным ни в одной точке
  /// истории после применения [pending] и исключения [exclude].
  ///
  /// Операции упорядочиваются по `(occurredOn, id)`, как в CALC-010; удаление
  /// моделируется операцией противоположного знака на месте удаляемой строки.
  Future<void> _assertHistoryBalance({
    required int assetId,
    required Set<int> exclude,
    required List<_PendingOperation> pending,
  }) async {
    final asset = await _requireAsset(assetId);
    if (asset.kind != AssetKind.account) return;

    final query = select(assetTransactions)
      ..where((t) => t.assetId.equals(asset.id) & t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.asc(t.occurredOn),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (exclude.isNotEmpty) {
      query.where((t) => t.id.isNotIn(exclude));
    }
    final rows = await query.get();

    final operations =
        <_PendingOperation>[
          ...pending,
          for (final row in rows)
            _PendingOperation(
              kind: row.kind,
              amountMinor: row.amountMinor,
              occurredOn: row.occurredOn,
              id: row.id,
            ),
        ]..sort((left, right) {
          final byDate = left.occurredOn.compareTo(right.occurredOn);
          return byDate != 0 ? byDate : left.id.compareTo(right.id);
        });

    var balance = asset.openingValueMinor;
    for (final operation in operations) {
      balance += _signedDelta(operation.kind, operation.amountMinor);
      if (balance < 0) {
        throw const DomainException(
          DomainErrorCode.negativeBalance,
          fieldErrors: {'amount': 'validationNegativeBalance'},
        );
      }
    }
  }

  /// Баланс счёта на конец [date] с учётом opening и всех активных операций.
  ///
  /// Один SQL-запрос; soft-deleted операции исключены. Нужен для начисления
  /// процентов по вкладу (BR-RC-9).
  Future<int> balanceAsOfMinor(int assetId, LocalDate date) async {
    final row = await customSelect(
      'SELECT a.opening_value_minor + COALESCE(SUM('
      "CASE WHEN t.kind IN ('deposit', 'transferIn') THEN t.amount_minor "
      'ELSE -t.amount_minor END), 0) AS balance '
      'FROM assets a LEFT JOIN asset_transactions t '
      'ON t.asset_id = a.id AND t.deleted_at IS NULL AND t.occurred_on <= ?2 '
      'WHERE a.id = ?1 GROUP BY a.id',
      variables: [Variable<int>(assetId), Variable<String>(date.toIsoString())],
    ).getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'assetId': 'validationAssetNotFound'},
      );
    }
    return row.read<int>('balance');
  }

  static int _signedDelta(AssetTransactionKind kind, int amountMinor) =>
      kind == AssetTransactionKind.deposit ||
          kind == AssetTransactionKind.transferIn
      ? amountMinor
      : -amountMinor;

  Future<void> _validateTransfer(TransferInput input) async {
    _requireNotFuture(input.occurredOn);
    if (input.fromAccountId == input.toAccountId) {
      throw _validation('toAccountId', 'validationTransferAccountsEqual');
    }
    _requirePositive(input.fromAmountMinor, 'amount');
    _requirePositive(input.toAmountMinor, 'destinationAmount');
    _requirePositive(input.fromAmountRubMinor, 'amountRub');
    _requirePositive(input.toAmountRubMinor, 'destinationAmountRub');
    if (input.fromRateToRub <= Decimal.zero ||
        input.toRateToRub <= Decimal.zero) {
      throw _validation('rate', 'validationRatePositive');
    }

    final from = await _requireAsset(input.fromAccountId);
    final to = await _requireAsset(input.toAccountId);
    if (from.kind != AssetKind.account || to.kind != AssetKind.account) {
      throw _validation('assetId', 'validationTransferRequiresAccounts');
    }
  }

  static void _validateOperation(AssetTransactionInput input) {
    _requirePositive(input.amountMinor, 'amount');
    _requirePositive(input.amountRubMinor, 'amountRub');
    if (input.rateToRub <= Decimal.zero) {
      throw _validation('rate', 'validationRatePositive');
    }
  }

  Future<void> _updateLeg({
    required AssetTransactionRow leg,
    required int assetId,
    required int amountMinor,
    required Decimal rateToRub,
    required int amountRubMinor,
    required LocalDate occurredOn,
    required String? comment,
    required DateTime now,
  }) async {
    await (update(assetTransactions)..where((t) => t.id.equals(leg.id))).write(
      AssetTransactionsCompanion(
        assetId: Value(assetId),
        amountMinor: Value(amountMinor),
        rateToRub: Value(rateToRub),
        amountRubMinor: Value(amountRubMinor),
        occurredOn: Value(occurredOn),
        comment: Value(comment),
        revisionNo: Value(leg.revisionNo + 1),
        updatedAt: Value(now),
      ),
    );
  }

  AssetTransactionsCompanion _legCompanion({
    required TransferInput input,
    required int transferId,
    required int assetId,
    required AssetTransactionKind kind,
    required int amountMinor,
    required Decimal rateToRub,
    required int amountRubMinor,
    required DateTime now,
  }) => AssetTransactionsCompanion.insert(
    assetId: assetId,
    kind: kind,
    amountMinor: amountMinor,
    occurredOn: input.occurredOn,
    rateToRub: rateToRub,
    amountRubMinor: amountRubMinor,
    transferId: Value(transferId),
    revisionNo: 1,
    createdAt: now,
    updatedAt: now,
    comment: Value(input.comment),
  );

  /// Вставляет одну версию операции в историю `(occurredOn, id)` и проверяет
  /// отсутствие отрицательного баланса в любой точке (CALC-010).
  Future<void> _assertProjectedBalance({
    required AssetRow asset,
    required LocalDate occurredOn,
    required AssetTransactionKind kind,
    required int amountMinor,
    int? excludeTransactionId,
  }) => _assertHistoryBalance(
    assetId: asset.id,
    exclude: excludeTransactionId == null ? const {} : {excludeTransactionId},
    pending: [
      _PendingOperation(
        kind: kind,
        amountMinor: amountMinor,
        occurredOn: occurredOn,
        // Новая строка получает максимальный id; при edit — свой.
        id: excludeTransactionId ?? 0x7FFFFFFFFFFFFFFF,
      ),
    ],
  );

  Future<AssetRow> _requireAsset(int id) async {
    final row = await (select(
      assets,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'assetId': 'validationAssetNotFound'},
      );
    }
    return row;
  }

  static void _requireTransactionAllowed(AssetRow asset) {
    if (asset.kind == AssetKind.property) {
      throw _validation('assetId', 'validationTransactionAssetKind');
    }
  }

  Future<AssetTransactionRow> _requireTransaction(int id) async {
    final row = await (select(
      assetTransactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'transactionId': 'validationTransactionNotFound'},
      );
    }
    return row;
  }

  Future<List<AssetTransactionRow>> _transferLegs(
    int transferId, {
    bool includeDeleted = false,
  }) {
    final query = select(assetTransactions)
      ..where(
        (t) =>
            t.transferId.equals(transferId) &
            (includeDeleted ? const Constant(true) : t.deletedAt.isNull()),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.get();
  }

  AssetTransactionRow _legOfKind(
    List<AssetTransactionRow> legs,
    AssetTransactionKind kind,
  ) {
    final matches = legs.where((leg) => leg.kind == kind).toList();
    if (matches.length != 1) throw _conflict('validationTransferCorrupted');
    return matches.single;
  }

  Future<void> _writeRevision(
    AssetTransactionRow row,
    RevisionAction action,
    DateTime changedAt,
  ) => into(assetTransactionRevisions).insert(
    AssetTransactionRevisionsCompanion.insert(
      transactionId: row.id,
      revisionNo: row.revisionNo,
      action: action,
      snapshotJson: encodeRevisionSnapshot(
        assetTransactionSnapshotFields(
          id: row.id,
          assetId: row.assetId,
          kind: row.kind,
          amountMinor: row.amountMinor,
          currencyCode: row.currencyCode,
          occurredOn: row.occurredOn,
          rateToRub: row.rateToRub,
          amountRubMinor: row.amountRubMinor,
          comment: row.comment,
          transferId: row.transferId,
          revisionNo: row.revisionNo,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
      ),
      changedAt: changedAt,
    ),
  );

  static bool _isTransferKind(AssetTransactionKind kind) =>
      kind == AssetTransactionKind.transferOut ||
      kind == AssetTransactionKind.transferIn;

  static void _requirePositive(int value, String field) {
    if (value <= 0) throw _validation(field, 'validationAmountPositive');
  }

  static DomainException _validation(String field, String key) =>
      DomainException(DomainErrorCode.validation, fieldErrors: {field: key});

  static DomainException _conflict(String key) => DomainException(
    DomainErrorCode.conflict,
    fieldErrors: {'operation': key},
  );
}

/// Операция для симуляции истории баланса (существующая или ожидаемая).
final class _PendingOperation {
  const _PendingOperation({
    required this.kind,
    required this.amountMinor,
    required this.occurredOn,
    required this.id,
  });

  final AssetTransactionKind kind;
  final int amountMinor;
  final LocalDate occurredOn;
  final int id;
}
