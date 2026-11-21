import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';

/// Доходы и расходы: original+RUB snapshot, ревизии и поиск (7.1).
final class CashflowRepositoryImpl implements CashflowRepository {
  const CashflowRepositoryImpl(this._dao, this._currenciesDao, this._db);

  final CashflowDao _dao;
  final CurrenciesDao _currenciesDao;
  final AppDatabase _db;

  @override
  Stream<List<CashflowEntry>> watch(CashflowFilter filter) {
    final search = filter.query.trim().toLowerCase();
    return _dao
        .watchFiltered(
          CashflowFilter(
            period: filter.period,
            kind: filter.kind,
            categoryId: filter.categoryId,
            currencyCode: filter.currencyCode,
            propertyId: filter.propertyId,
            accountId: filter.accountId,
          ),
        )
        .map(
          (rows) => [
            for (final row in rows)
              if (search.isEmpty ||
                  (row.comment ?? '').toLowerCase().contains(search))
                _map(row),
          ],
        );
  }

  @override
  Stream<List<CashflowEntry>> watchDeleted() =>
      _dao.watchDeleted().map((rows) => rows.map(_map).toList(growable: false));

  @override
  Future<CashflowEntry> getById(int id) async => _map(await _dao.getById(id));

  @override
  Future<int> create(CashflowEntryDraft draft) async =>
      _dao.create(await _input(draft));

  @override
  Future<int> createLinked(
    CashflowEntryDraft draft, {
    required int assetTransactionId,
  }) async =>
      _dao.create(await _input(draft, assetTransactionId: assetTransactionId));

  @override
  Future<void> revise(int id, CashflowEntryDraft draft) async =>
      _dao.revise(id, await _input(draft));

  @override
  Future<void> softDelete(int id) => _dao.softDelete(id);

  @override
  Future<void> restore(int id) async {
    final entry = await _dao.getById(id);
    final assetTransactionId = entry.assetTransactionId;
    if (assetTransactionId != null) {
      await _db.transactionsDao.restore(assetTransactionId);
      return;
    }
    await _dao.restore(id);
  }

  Future<CashflowEntryInput> _input(
    CashflowEntryDraft draft, {
    int? assetTransactionId,
  }) async {
    final currency = await _currencyOf(draft.amount.currencyCode);
    final rub = _rub;
    final amountRub = MoneyMath.fromDecimal(
      MoneyMath.toDecimal(draft.amount, currency) * draft.rateToRub,
      rub,
    );
    return CashflowEntryInput(
      kind: draft.kind,
      categoryId: draft.categoryId,
      amountMinor: draft.amount.minorUnits,
      currencyCode: draft.amount.currencyCode,
      occurredOn: draft.occurredOn,
      rateToRub: draft.rateToRub,
      amountRubMinor: amountRub.minorUnits,
      affectsBalance: draft.affectsBalance,
      comment: draft.comment,
      propertyId: draft.propertyId,
      accountId: draft.accountId,
      assetTransactionId: assetTransactionId,
    );
  }

  Future<Currency> _currencyOf(String code) async {
    final row = await _currenciesDao.find(code);
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'currencyCode': 'validationCurrencyNotFound'},
      );
    }
    return Currency(
      code: row.code,
      name: row.name,
      fractionDigits: row.fractionDigits,
      isPreset: row.isPreset,
      isEnabled: row.isEnabled,
    );
  }

  static const _rub = Currency(
    code: 'RUB',
    name: 'Рубль',
    fractionDigits: 2,
    isPreset: true,
    isEnabled: true,
  );

  static CashflowEntry _map(CashflowEntryRow row) => CashflowEntry(
    id: row.id,
    kind: row.kind,
    categoryId: row.categoryId,
    amount: Money(minorUnits: row.amountMinor, currencyCode: row.currencyCode),
    occurredOn: row.occurredOn,
    rateToRub: row.rateToRub,
    amountRub: Money(minorUnits: row.amountRubMinor, currencyCode: 'RUB'),
    affectsBalance: row.affectsBalance,
    revisionNo: row.revisionNo,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    comment: row.comment,
    propertyId: row.propertyId,
    accountId: row.accountId,
    assetTransactionId: row.assetTransactionId,
    recurringRuleId: row.recurringRuleId,
    deletedAt: row.deletedAt,
  );
}
