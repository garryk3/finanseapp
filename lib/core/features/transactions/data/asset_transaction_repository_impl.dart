import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_mapper.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_classification.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';

/// Операции по активам: amountRub и связанная классификация — одной транзакцией.
final class AssetTransactionRepositoryImpl
    implements AssetTransactionRepository {
  const AssetTransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<AssetTransaction>> watch(TransactionFilter filter) {
    final search = filter.query.trim().toLowerCase();
    return _db.transactionsDao
        .watchFiltered(
          TransactionFilter(
            period: filter.period,
            assetId: filter.assetId,
            kind: filter.kind,
            assetKind: filter.assetKind,
            currencyCode: filter.currencyCode,
            // Поиск по комментарию — Unicode (кириллица), SQLite LOWER не
            // умеет; при поиске читаем набор целиком и фильтруем в Dart.
            limit: search.isEmpty ? filter.limit : null,
          ),
        )
        .asyncMap((rows) => _mapRows(rows, search: search));
  }

  @override
  Stream<List<AssetTransaction>> watchDeleted() =>
      _db.transactionsDao.watchDeleted().asyncMap((rows) async {
        final assets = {
          for (final row in await _db.select(_db.assets).get()) row.id: row,
        };
        return [
          for (final row in rows)
            mapAssetTransaction(row, assets[row.assetId]!.currencyCode),
        ];
      });

  Future<List<AssetTransaction>> _mapRows(
    List<AssetTransactionRow> rows, {
    String search = '',
  }) async {
    final assets = {
      for (final row in await _db.select(_db.assets).get()) row.id: row,
    };
    return [
      for (final row in rows)
        if (search.isEmpty ||
            (row.comment ?? '').toLowerCase().contains(search))
          mapAssetTransaction(row, assets[row.assetId]!.currencyCode),
    ];
  }

  @override
  Future<AssetTransaction> getById(int id) async {
    final row = await _db.transactionsDao.getById(id);
    final asset = await _db.assetsDao.getById(row.assetId);
    final linked = await _db.cashflowDao.findLinked(id);
    return mapAssetTransaction(
      row,
      asset.currencyCode,
      cashflowEntryId: linked?.id,
    );
  }

  @override
  Future<int> create(AssetTransactionDraft draft) => _db.transaction(() async {
    final id = await _createTransaction(draft);
    final classification = draft.classification;
    if (classification != null) {
      await _createLinked(id, draft, classification);
    }
    return id;
  });

  @override
  Future<void> revise(int id, AssetTransactionDraft draft) =>
      _db.transaction(() async {
        final linked = await _db.cashflowDao.findLinked(id);
        await _reviseTransaction(id, draft);
        final classification = draft.classification;
        if (classification != null) {
          if (linked == null) {
            await _db.cashflowDao.create(
              await _linkedInput(draft, classification, assetTransactionId: id),
            );
          } else {
            await _db.cashflowDao.reviseFromAsset(
              linked.id,
              await _linkedInput(draft, classification),
            );
          }
        } else if (linked != null) {
          await _db.cashflowDao.softDeleteFromAsset(linked.id);
        }
      });

  @override
  Future<void> restore(int id) => _db.transactionsDao.restore(id);

  @override
  Future<void> restoreTransfer(int transferId) =>
      _db.transactionsDao.restoreTransfer(transferId);

  @override
  Future<void> softDelete(int id) => _db.transaction(() async {
    final linked = await _db.cashflowDao.findLinked(id);
    await _db.transactionsDao.softDelete(id);
    if (linked != null) {
      await _db.cashflowDao.softDeleteFromAsset(linked.id);
    }
  });

  @override
  Future<int> transfer(TransferDraft draft) async {
    final from = await _db.assetsDao.getById(draft.fromAccountId);
    final to = await _db.assetsDao.getById(draft.toAccountId);
    return _db.transactionsDao.createTransfer(
      TransferInput(
        fromAccountId: draft.fromAccountId,
        toAccountId: draft.toAccountId,
        fromAmountMinor: draft.amount.minorUnits,
        toAmountMinor: draft.destinationAmount.minorUnits,
        occurredOn: draft.occurredOn,
        fromRateToRub: draft.fromRateToRub,
        toRateToRub: draft.toRateToRub,
        fromAmountRubMinor: await _rubMinor(
          draft.amount,
          from.currencyCode,
          draft.fromRateToRub,
        ),
        toAmountRubMinor: await _rubMinor(
          draft.destinationAmount,
          to.currencyCode,
          draft.toRateToRub,
        ),
        comment: draft.comment,
      ),
    );
  }

  @override
  Future<void> reviseTransfer(int transferId, TransferDraft draft) async {
    final from = await _db.assetsDao.getById(draft.fromAccountId);
    final to = await _db.assetsDao.getById(draft.toAccountId);
    await _db.transactionsDao.reviseTransfer(
      transferId,
      TransferInput(
        fromAccountId: draft.fromAccountId,
        toAccountId: draft.toAccountId,
        fromAmountMinor: draft.amount.minorUnits,
        toAmountMinor: draft.destinationAmount.minorUnits,
        occurredOn: draft.occurredOn,
        fromRateToRub: draft.fromRateToRub,
        toRateToRub: draft.toRateToRub,
        fromAmountRubMinor: await _rubMinor(
          draft.amount,
          from.currencyCode,
          draft.fromRateToRub,
        ),
        toAmountRubMinor: await _rubMinor(
          draft.destinationAmount,
          to.currencyCode,
          draft.toRateToRub,
        ),
        comment: draft.comment,
      ),
    );
  }

  @override
  Future<void> softDeleteTransfer(int transferId) =>
      _db.transactionsDao.softDeleteTransfer(transferId);

  Future<int> _createTransaction(AssetTransactionDraft draft) async {
    final asset = await _db.assetsDao.getById(draft.assetId);
    _requireBalanceKind(draft.kind);
    if (draft.classification != null && asset.kind != AssetKind.account) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'classification': 'validationClassificationAccountOnly'},
      );
    }
    return _db.transactionsDao.create(
      AssetTransactionInput(
        assetId: draft.assetId,
        kind: draft.kind,
        amountMinor: draft.amount.minorUnits,
        occurredOn: draft.occurredOn,
        rateToRub: draft.rateToRub,
        amountRubMinor: await _rubMinor(
          draft.amount,
          asset.currencyCode,
          draft.rateToRub,
        ),
        comment: draft.comment,
      ),
    );
  }

  Future<void> _reviseTransaction(int id, AssetTransactionDraft draft) async {
    final asset = await _db.assetsDao.getById(draft.assetId);
    _requireBalanceKind(draft.kind);
    if (draft.classification != null && asset.kind != AssetKind.account) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'classification': 'validationClassificationAccountOnly'},
      );
    }
    await _db.transactionsDao.revise(
      id,
      AssetTransactionInput(
        assetId: draft.assetId,
        kind: draft.kind,
        amountMinor: draft.amount.minorUnits,
        occurredOn: draft.occurredOn,
        rateToRub: draft.rateToRub,
        amountRubMinor: await _rubMinor(
          draft.amount,
          asset.currencyCode,
          draft.rateToRub,
        ),
        comment: draft.comment,
      ),
    );
  }

  Future<void> _createLinked(
    int id,
    AssetTransactionDraft draft,
    TransactionClassification classification,
  ) async {
    _requireClassificationKind(draft.kind, classification.kind);
    await _db.cashflowDao.create(
      await _linkedInput(draft, classification, assetTransactionId: id),
    );
  }

  Future<CashflowEntryInput> _linkedInput(
    AssetTransactionDraft draft,
    TransactionClassification classification, {
    int? assetTransactionId,
  }) async {
    final asset = await _db.assetsDao.getById(draft.assetId);
    _requireClassificationKind(draft.kind, classification.kind);
    final input = CashflowEntryInput(
      kind: classification.kind,
      categoryId: classification.categoryId,
      amountMinor: draft.amount.minorUnits,
      currencyCode: asset.currencyCode,
      occurredOn: draft.occurredOn,
      rateToRub: draft.rateToRub,
      amountRubMinor: await _rubMinor(
        draft.amount,
        asset.currencyCode,
        draft.rateToRub,
      ),
      affectsBalance: true,
      comment: draft.comment,
      accountId: asset.id,
      assetTransactionId: assetTransactionId,
    );
    return input;
  }

  Future<int> _rubMinor(
    Money amount,
    String currencyCode,
    Decimal rateToRub,
  ) async {
    final row = await _db.currenciesDao.find(currencyCode);
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'currencyCode': 'validationCurrencyNotFound'},
      );
    }
    final currency = Currency(
      code: row.code,
      name: row.name,
      fractionDigits: row.fractionDigits,
      isPreset: row.isPreset,
      isEnabled: row.isEnabled,
    );
    final rub = Currency(
      code: 'RUB',
      name: 'Рубль',
      fractionDigits: 2,
      isPreset: true,
      isEnabled: true,
    );
    return MoneyMath.fromDecimal(
      MoneyMath.toDecimal(amount, currency) * rateToRub,
      rub,
    ).minorUnits;
  }

  static void _requireBalanceKind(AssetTransactionKind kind) {
    if (kind == AssetTransactionKind.transferIn ||
        kind == AssetTransactionKind.transferOut) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'kind': 'validationTransferThroughTransferCommand'},
      );
    }
  }

  static void _requireClassificationKind(
    AssetTransactionKind kind,
    CashflowKind classification,
  ) {
    final matches =
        (kind == AssetTransactionKind.deposit &&
            classification == CashflowKind.income) ||
        (kind == AssetTransactionKind.withdrawal &&
            classification == CashflowKind.expense);
    if (!matches) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'classification': 'validationClassificationKindMismatch'},
      );
    }
  }
}
