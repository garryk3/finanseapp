import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/categories.dart';
import 'package:finanseapp/core/database/tables/cashflow_entries.dart';
import 'package:finanseapp/core/database/tables/cashflow_entry_revisions.dart';
import 'package:finanseapp/core/database/revision_snapshots.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';

part 'cashflow_dao.g.dart';

/// Вход записи денежного потока; связанные пары создаёт 7.2 через команду.
final class CashflowEntryInput {
  const CashflowEntryInput({
    required this.kind,
    required this.categoryId,
    required this.amountMinor,
    required this.currencyCode,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRubMinor,
    required this.affectsBalance,
    this.comment,
    this.propertyId,
    this.accountId,
    this.assetTransactionId,
  });

  final CashflowKind kind;
  final int categoryId;
  final int amountMinor;
  final String currencyCode;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final int amountRubMinor;
  final bool affectsBalance;
  final String? comment;
  final int? propertyId;
  final int? accountId;
  final int? assetTransactionId;
}

/// Доходы и расходы с ревизиями; связь с операцией актива — 7.2.
@DriftAccessor(
  tables: [Assets, Categories, CashflowEntries, CashflowEntryRevisions],
)
class CashflowDao extends DatabaseAccessor<AppDatabase>
    with _$CashflowDaoMixin {
  CashflowDao(super.db);

  /// Журнал с фильтрами (7.1/7.3); поиск по комментарию — в repository.
  Stream<List<CashflowEntryRow>> watchFiltered(CashflowFilter filter) {
    final query = select(cashflowEntries)
      ..where((e) => e.deletedAt.isNull())
      ..orderBy([
        (e) => OrderingTerm.desc(e.occurredOn),
        (e) => OrderingTerm.desc(e.id),
      ]);
    if (filter.period != null) {
      query.where(
        (e) =>
            e.occurredOn.isBiggerOrEqualValue(
              filter.period!.start.toIsoString(),
            ) &
            e.occurredOn.isSmallerOrEqualValue(
              filter.period!.end.toIsoString(),
            ),
      );
    }
    if (filter.kind != null) {
      query.where((e) => e.kind.equalsValue(filter.kind!));
    }
    if (filter.categoryId != null) {
      query.where((e) => e.categoryId.equals(filter.categoryId!));
    }
    if (filter.currencyCode != null) {
      query.where((e) => e.currencyCode.equals(filter.currencyCode!));
    }
    if (filter.propertyId != null) {
      query.where((e) => e.propertyId.equals(filter.propertyId!));
    }
    if (filter.accountId != null) {
      query.where((e) => e.accountId.equals(filter.accountId!));
    }
    return query.watch();
  }

  Stream<List<CashflowEntryRow>> watchAll({CashflowKind? kind}) {
    final query = select(cashflowEntries)
      ..where((e) => e.deletedAt.isNull())
      ..orderBy([
        (e) => OrderingTerm.desc(e.occurredOn),
        (e) => OrderingTerm.desc(e.id),
      ]);
    if (kind != null) {
      query.where((e) => e.kind.equalsValue(kind));
    }
    return query.watch();
  }

  Future<CashflowEntryRow> getById(int id) => _requireEntry(id);

  Future<List<CashflowEntryRevisionRow>> revisions(int entryId) {
    final query = select(cashflowEntryRevisions)
      ..where((r) => r.entryId.equals(entryId))
      ..orderBy([(r) => OrderingTerm.asc(r.revisionNo)]);
    return query.get();
  }

  Future<int> create(CashflowEntryInput input) => transaction(() async {
    await _validate(input);
    final now = attachedDatabase.clock();
    final id = await into(cashflowEntries).insert(
      CashflowEntriesCompanion.insert(
        kind: input.kind,
        categoryId: input.categoryId,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        occurredOn: input.occurredOn,
        rateToRub: input.rateToRub,
        amountRubMinor: input.amountRubMinor,
        affectsBalance: input.affectsBalance,
        revisionNo: 1,
        createdAt: now,
        updatedAt: now,
        comment: Value(input.comment),
        propertyId: Value(input.propertyId),
        accountId: Value(input.accountId),
        assetTransactionId: Value(input.assetTransactionId),
      ),
    );
    await _writeRevision(await _requireEntry(id), RevisionAction.create, now);
    return id;
  });

  Future<void> revise(int id, CashflowEntryInput input) =>
      transaction(() async {
        final current = await _requireEntry(id);
        _requireUnlinked(current);
        if (current.deletedAt != null) {
          throw _conflict('validationEntryDeleted');
        }
        await _validate(input);
        final now = attachedDatabase.clock();
        await (update(cashflowEntries)..where((e) => e.id.equals(id))).write(
          CashflowEntriesCompanion(
            kind: Value(input.kind),
            categoryId: Value(input.categoryId),
            amountMinor: Value(input.amountMinor),
            currencyCode: Value(input.currencyCode),
            occurredOn: Value(input.occurredOn),
            rateToRub: Value(input.rateToRub),
            amountRubMinor: Value(input.amountRubMinor),
            affectsBalance: Value(input.affectsBalance),
            comment: Value(input.comment),
            propertyId: Value(input.propertyId),
            accountId: Value(input.accountId),
            revisionNo: Value(current.revisionNo + 1),
            updatedAt: Value(now),
          ),
        );
        await _writeRevision(await _requireEntry(id), RevisionAction.edit, now);
      });

  Future<void> softDelete(int id) => transaction(() async {
    final current = await _requireEntry(id);
    _requireUnlinked(current);
    if (current.deletedAt != null) {
      throw _conflict('validationEntryDeleted');
    }
    final now = attachedDatabase.clock();
    await (update(cashflowEntries)..where((e) => e.id.equals(id))).write(
      CashflowEntriesCompanion(
        revisionNo: Value(current.revisionNo + 1),
        updatedAt: Value(now),
        deletedAt: Value(now),
      ),
    );
    await _writeRevision(await _requireEntry(id), RevisionAction.delete, now);
  });

  /// Активная запись, связанная с операцией по активу (BR-IE-9).
  Future<CashflowEntryRow?> findLinked(int assetTransactionId) =>
      (select(cashflowEntries)..where(
            (e) =>
                e.assetTransactionId.equals(assetTransactionId) &
                e.deletedAt.isNull(),
          ))
          .getSingleOrNull();

  /// Ревизия связанной записи из команды операции (BR-IE-15).
  Future<void> reviseFromAsset(int id, CashflowEntryInput input) =>
      transaction(() async {
        final current = await _requireEntry(id);
        if (current.assetTransactionId == null) {
          throw _conflict('validationCashflowNotLinked');
        }
        if (current.deletedAt != null) {
          throw _conflict('validationEntryDeleted');
        }
        await _validate(input);
        final now = attachedDatabase.clock();
        await (update(cashflowEntries)..where((e) => e.id.equals(id))).write(
          CashflowEntriesCompanion(
            kind: Value(input.kind),
            categoryId: Value(input.categoryId),
            amountMinor: Value(input.amountMinor),
            currencyCode: Value(input.currencyCode),
            occurredOn: Value(input.occurredOn),
            rateToRub: Value(input.rateToRub),
            amountRubMinor: Value(input.amountRubMinor),
            affectsBalance: Value(input.affectsBalance),
            comment: Value(input.comment),
            propertyId: Value(input.propertyId),
            accountId: Value(input.accountId),
            revisionNo: Value(current.revisionNo + 1),
            updatedAt: Value(now),
          ),
        );
        await _writeRevision(await _requireEntry(id), RevisionAction.edit, now);
      });

  /// Ревизия записи с изменением/снятием связи с операцией (7.2).
  Future<void> reviseWithLink(
    int id,
    CashflowEntryInput input,
    int? assetTransactionId,
  ) => transaction(() async {
    final current = await _requireEntry(id);
    if (current.deletedAt != null) {
      throw _conflict('validationEntryDeleted');
    }
    await _validate(input);
    final now = attachedDatabase.clock();
    await (update(cashflowEntries)..where((e) => e.id.equals(id))).write(
      CashflowEntriesCompanion(
        kind: Value(input.kind),
        categoryId: Value(input.categoryId),
        amountMinor: Value(input.amountMinor),
        currencyCode: Value(input.currencyCode),
        occurredOn: Value(input.occurredOn),
        rateToRub: Value(input.rateToRub),
        amountRubMinor: Value(input.amountRubMinor),
        affectsBalance: Value(input.affectsBalance),
        comment: Value(input.comment),
        propertyId: Value(input.propertyId),
        accountId: Value(input.accountId),
        assetTransactionId: Value(assetTransactionId),
        revisionNo: Value(current.revisionNo + 1),
        updatedAt: Value(now),
      ),
    );
    await _writeRevision(await _requireEntry(id), RevisionAction.edit, now);
  });

  /// Мягкое удаление связанной записи из команды операции (BR-IE-14).
  Future<void> softDeleteFromAsset(int id) => transaction(() async {
    final current = await _requireEntry(id);
    if (current.assetTransactionId == null) {
      throw _conflict('validationCashflowNotLinked');
    }
    if (current.deletedAt != null) {
      throw _conflict('validationEntryDeleted');
    }
    final now = attachedDatabase.clock();
    await (update(cashflowEntries)..where((e) => e.id.equals(id))).write(
      CashflowEntriesCompanion(
        revisionNo: Value(current.revisionNo + 1),
        updatedAt: Value(now),
        deletedAt: Value(now),
      ),
    );
    await _writeRevision(await _requireEntry(id), RevisionAction.delete, now);
  });

  Future<void> _validate(CashflowEntryInput input) async {
    if (input.occurredOn.compareTo(attachedDatabase.today()) > 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'occurredOn': 'validationDateInFuture'},
      );
    }
    if (input.amountMinor <= 0 || input.amountRubMinor <= 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'amount': 'validationAmountPositive'},
      );
    }
    if (input.rateToRub <= Decimal.zero) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'rate': 'validationRatePositive'},
      );
    }
    if (input.propertyId != null && input.accountId != null) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'accountId': 'validationPropertyAndAccountExclusive'},
      );
    }
    if (input.affectsBalance && input.accountId == null) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'accountId': 'validationBalanceRequiresAccount'},
      );
    }

    final category = await (select(
      categories,
    )..where((c) => c.id.equals(input.categoryId))).getSingleOrNull();
    if (category == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'categoryId': 'validationCategoryNotFound'},
      );
    }
    if (category.kind != input.kind) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'categoryId': 'validationCategoryKindMismatch'},
      );
    }
    if (category.archivedAt != null) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'categoryId': 'validationCategoryArchived'},
      );
    }

    if (input.propertyId != null) {
      final property = await _requireAsset(input.propertyId!);
      if (property.kind != AssetKind.property) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'propertyId': 'validationPropertyKind'},
        );
      }
    }
    if (input.accountId != null) {
      final account = await _requireAsset(input.accountId!);
      if (account.kind != AssetKind.account) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'accountId': 'validationAccountKind'},
        );
      }
      if (account.currencyCode != input.currencyCode) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
        );
      }
    }
  }

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

  Future<CashflowEntryRow> _requireEntry(int id) async {
    final row = await (select(
      cashflowEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'entryId': 'validationEntryNotFound'},
      );
    }
    return row;
  }

  static void _requireUnlinked(CashflowEntryRow row) {
    if (row.assetTransactionId != null) {
      throw _conflict('validationLinkedCashflowDeferred');
    }
  }

  Future<void> _writeRevision(
    CashflowEntryRow row,
    RevisionAction action,
    DateTime changedAt,
  ) => into(cashflowEntryRevisions).insert(
    CashflowEntryRevisionsCompanion.insert(
      entryId: row.id,
      revisionNo: row.revisionNo,
      action: action,
      snapshotJson: encodeRevisionSnapshot(
        cashflowSnapshotFields(
          id: row.id,
          kind: row.kind,
          categoryId: row.categoryId,
          amountMinor: row.amountMinor,
          currencyCode: row.currencyCode,
          occurredOn: row.occurredOn,
          rateToRub: row.rateToRub,
          amountRubMinor: row.amountRubMinor,
          affectsBalance: row.affectsBalance,
          comment: row.comment,
          propertyId: row.propertyId,
          accountId: row.accountId,
          assetTransactionId: row.assetTransactionId,
          revisionNo: row.revisionNo,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
      ),
      changedAt: changedAt,
    ),
  );

  static DomainException _conflict(String key) => DomainException(
    DomainErrorCode.conflict,
    fieldErrors: {'operation': key},
  );
}
