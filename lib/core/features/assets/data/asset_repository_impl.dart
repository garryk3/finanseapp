import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/assets_dao.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/database/daos/valuations_dao.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_value_calculator.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_mapper.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Реализация активов: счета (5.1); инвестиции/квартиры — 5.2/5.4.
final class AssetRepositoryImpl implements AssetRepository {
  const AssetRepositoryImpl(
    this._assetsDao,
    this._transactionsDao,
    this._valuationsDao,
    this._currenciesDao,
  );

  final AssetsDao _assetsDao;
  final TransactionsDao _transactionsDao;
  final ValuationsDao _valuationsDao;
  final CurrenciesDao _currenciesDao;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      _assetsDao
          .watchAll(includeArchived: includeArchived)
          .asyncMap(_snapshotsOf);

  @override
  Stream<AssetSnapshot?> watchById(int id) => _assetsDao
      .watchById(id)
      .asyncMap((row) async => row == null ? null : _snapshotOf(row));

  @override
  Future<AssetSnapshot> getById(int id) async =>
      _snapshotOf(await _assetsDao.getById(id));

  @override
  Future<int> create(AssetDraft draft) async {
    switch (draft) {
      case AccountDraft account:
        _validateAccountDraft(account);
        return _assetsDao.create(
          name: account.name.trim(),
          kind: AssetKind.account,
          currencyCode: account.currencyCode,
          openingValueMinor: account.openingValue.minorUnits,
          account: AccountDetailsCompanion.insert(
            bankId: account.bankId,
            annualRate: account.annualRate,
            startDate: account.startDate,
            endDate: Value(account.endDate),
          ),
        );
      case InvestmentDraft investment:
        _validateInvestmentDraft(investment);
        return _assetsDao.create(
          name: investment.name.trim(),
          kind: AssetKind.investment,
          currencyCode: investment.currencyCode,
          openingValueMinor: investment.openingValue.minorUnits,
          investment: InvestmentDetailsCompanion.insert(
            brokerId: investment.brokerId,
          ),
        );
      case PropertyDraft property:
        _validatePropertyDraft(property);
        return _assetsDao.create(
          name: property.name.trim(),
          kind: AssetKind.property,
          currencyCode: property.currencyCode,
          openingValueMinor: property.openingValue.minorUnits,
          property: PropertyDetailsCompanion.insert(
            address: Value(
              property.address?.trim().isEmpty ?? true
                  ? null
                  : property.address!.trim(),
            ),
            purchasePriceMinor: Value(property.purchasePrice?.minorUnits),
          ),
        );
    }
  }

  @override
  Future<void> update(int id, AssetDraft draft) async {
    switch (draft) {
      case AccountDraft account:
        _validateAccountDraft(account);
        await _assetsDao.updateAccount(
          assetId: id,
          name: account.name.trim(),
          currencyCode: account.currencyCode,
          openingValueMinor: account.openingValue.minorUnits,
          bankId: account.bankId,
          annualRate: account.annualRate,
          startDate: account.startDate,
          endDate: account.endDate,
        );
      case InvestmentDraft investment:
        _validateInvestmentDraft(investment);
        await _assetsDao.updateInvestment(
          assetId: id,
          name: investment.name.trim(),
          currencyCode: investment.currencyCode,
          openingValueMinor: investment.openingValue.minorUnits,
          brokerId: investment.brokerId,
        );
      case PropertyDraft property:
        _validatePropertyDraft(property);
        await _assetsDao.updateProperty(
          assetId: id,
          name: property.name.trim(),
          currencyCode: property.currencyCode,
          openingValueMinor: property.openingValue.minorUnits,
          address: property.address,
          purchasePriceMinor: property.purchasePrice?.minorUnits,
        );
    }
  }

  @override
  Future<void> deleteIfUnused(int id) => _assetsDao.deleteIfUnused(id);

  @override
  Future<void> archive(int id) => _assetsDao.archive(id);

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) async {
    final counts = await _assetsDao.referenceCounts(id);
    return AssetReferenceCounts(
      transactions: counts.transactions,
      valuations: counts.valuations,
      goals: counts.goals,
      cashflow: counts.cashflow,
      recurringRules: counts.recurring,
    );
  }

  @override
  Future<void> recordValuation(AssetValuationDraft draft) async {
    final asset = await _assetsDao.getById(draft.assetId);
    final currencyCode = _valuationCurrency(asset, draft.value);
    final currencyRow = await _currenciesDao.find(draft.value.currencyCode);
    if (currencyRow == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'currencyCode': 'validationCurrencyNotFound'},
      );
    }
    final decimalValue = MoneyMath.toDecimal(
      draft.value,
      Currency(
        code: currencyRow.code,
        name: currencyRow.name,
        fractionDigits: currencyRow.fractionDigits,
        isPreset: currencyRow.isPreset,
        isEnabled: currencyRow.isEnabled,
      ),
    );
    final valueRub = MoneyMath.fromDecimal(
      decimalValue * draft.rateToRub,
      _currencyOf('RUB'),
    );
    await _valuationsDao.create(
      assetId: draft.assetId,
      effectiveOn: draft.effectiveOn,
      valueMinor: draft.value.minorUnits,
      currencyCode: currencyCode,
      rateToRub: draft.rateToRub,
      valueRubMinor: valueRub.minorUnits,
    );
  }

  /// M1/M2: `NULL` для валюты актива; чужая валюта — только инвестиции.
  static String? _valuationCurrency(AssetRow asset, Money value) {
    if (value.currencyCode == asset.currencyCode) return null;
    if (asset.kind != AssetKind.investment) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
      );
    }
    return value.currencyCode;
  }

  Future<AssetSnapshot> _snapshotOf(AssetRow row) async {
    final transactions = await _transactionsFor(row.id, row.currencyCode);
    final valuations = await _valuationsFor(row.id, row.currencyCode);
    final account = row.kind == AssetKind.account
        ? await _assetsDao.accountDetailsFor(row.id)
        : null;
    final investment = row.kind == AssetKind.investment
        ? await _assetsDao.investmentDetailsFor(row.id)
        : null;
    final property = row.kind == AssetKind.property
        ? await _assetsDao.propertyDetailsFor(row.id)
        : null;
    return _buildSnapshot(
      row,
      transactions,
      valuations,
      account: account,
      investment: investment,
      property: property,
    );
  }

  /// Батч-сборка: три запроса вместо N+1 на каждое изменение таблиц.
  Future<List<AssetSnapshot>> _snapshotsOf(List<AssetRow> rows) async {
    final transactions = await _transactionsDao.allRows();
    final valuations = await _valuationsDao.allRows();
    final accounts = {
      for (final detail in await _assetsDao.allAccountDetails())
        detail.assetId: detail,
    };
    final investments = {
      for (final detail in await _assetsDao.allInvestmentDetails())
        detail.assetId: detail,
    };
    final properties = {
      for (final detail in await _assetsDao.allPropertyDetails())
        detail.assetId: detail,
    };
    final currencyByAsset = {for (final row in rows) row.id: row.currencyCode};
    final transactionsByAsset = <int, List<AssetTransaction>>{};
    for (final row in transactions) {
      if (row.deletedAt != null) continue;
      final code = currencyByAsset[row.assetId];
      if (code == null) continue;
      transactionsByAsset
          .putIfAbsent(row.assetId, () => [])
          .add(mapAssetTransaction(row, code));
    }
    final valuationsByAsset = <int, List<AssetValuation>>{};
    for (final row in valuations) {
      final code = currencyByAsset[row.assetId];
      if (code == null) continue;
      valuationsByAsset
          .putIfAbsent(row.assetId, () => [])
          .add(_valuationFrom(row, code));
    }
    return [
      for (final row in rows)
        _buildSnapshot(
          row,
          transactionsByAsset[row.id] ?? const [],
          valuationsByAsset[row.id] ?? const [],
          account: accounts[row.id],
          investment: investments[row.id],
          property: properties[row.id],
        ),
    ];
  }

  AssetSnapshot _buildSnapshot(
    AssetRow row,
    List<AssetTransaction> transactions,
    List<AssetValuation> valuations, {
    AccountDetailRow? account,
    InvestmentDetailRow? investment,
    PropertyDetailRow? property,
  }) {
    final opening = Money(
      minorUnits: row.openingValueMinor,
      currencyCode: row.currencyCode,
    );
    switch (row.kind) {
      case AssetKind.account:
        if (account == null) {
          throw const DomainException(
            DomainErrorCode.notFound,
            fieldErrors: {'assetId': 'validationAssetNotFound'},
          );
        }
        final asset = AccountAsset(
          id: row.id,
          name: row.name,
          currencyCode: row.currencyCode,
          openingValue: opening,
          createdAt: row.createdAt,
          archivedAt: row.archivedAt,
          bankId: account.bankId,
          annualRate: account.annualRate,
          startDate: account.startDate,
          endDate: account.endDate,
        );
        return AssetSnapshot(
          asset: asset,
          currentValue: AssetValueCalculator.account(asset, transactions),
        );
      case AssetKind.investment:
        if (investment == null) {
          throw const DomainException(
            DomainErrorCode.notFound,
            fieldErrors: {'assetId': 'validationAssetNotFound'},
          );
        }
        final asset = InvestmentAsset(
          id: row.id,
          name: row.name,
          currencyCode: row.currencyCode,
          openingValue: opening,
          createdAt: row.createdAt,
          archivedAt: row.archivedAt,
          brokerId: investment.brokerId,
        );
        final balances = AssetValueCalculator.investmentBalances(
          asset,
          valuations,
          transactions,
        );
        return AssetSnapshot(
          asset: asset,
          currentValue: balances.first,
          currencyBalances: balances,
        );
      case AssetKind.property:
        final asset = PropertyAsset(
          id: row.id,
          name: row.name,
          currencyCode: row.currencyCode,
          openingValue: opening,
          createdAt: row.createdAt,
          archivedAt: row.archivedAt,
          address: property?.address,
          purchasePrice: property?.purchasePriceMinor == null
              ? null
              : Money(
                  minorUnits: property!.purchasePriceMinor!,
                  currencyCode: row.currencyCode,
                ),
        );
        return AssetSnapshot(
          asset: asset,
          currentValue: AssetValueCalculator.property(asset, valuations),
        );
    }
  }

  Future<List<AssetValuation>> _valuationsFor(
    int assetId,
    String currencyCode,
  ) async {
    final rows = await _valuationsDao.watchByAsset(assetId).first;
    return [for (final row in rows) _valuationFrom(row, currencyCode)];
  }

  @override
  Future<List<AssetValuation>> valuations(int id) async {
    final row = await _assetsDao.getById(id);
    return _valuationsFor(id, row.currencyCode);
  }

  Future<List<AssetTransaction>> _transactionsFor(
    int assetId,
    String currencyCode,
  ) async {
    final rows = await _transactionsDao.watchByAsset(assetId).first;
    return [for (final row in rows) mapAssetTransaction(row, currencyCode)];
  }

  static AssetValuation _valuationFrom(
    AssetValuationRow row,
    String currencyCode,
  ) => AssetValuation(
    id: row.id,
    assetId: row.assetId,
    effectiveOn: row.effectiveOn,
    value: Money(
      minorUnits: row.valueMinor,
      currencyCode: row.currencyCode ?? currencyCode,
    ),
    rateToRub: row.rateToRub,
    valueRub: Money(minorUnits: row.valueRubMinor, currencyCode: 'RUB'),
    createdAt: row.createdAt,
  );

  static void _validateAccountDraft(AccountDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'name': 'validationNameRequired'},
      );
    }
    if (draft.openingValue.isNegative) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'openingValue': 'validationAmountNegative'},
      );
    }
    if (draft.annualRate < Decimal.zero ||
        draft.annualRate > Decimal.fromInt(100)) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'annualRate': 'validationRateRange'},
      );
    }
    if (draft.endDate != null &&
        draft.endDate!.compareTo(draft.startDate) < 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'endDate': 'validationDateRangeInvalid'},
      );
    }
  }

  static void _validateInvestmentDraft(InvestmentDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'name': 'validationNameRequired'},
      );
    }
    if (draft.openingValue.isNegative) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'openingValue': 'validationAmountNegative'},
      );
    }
  }

  static void _validatePropertyDraft(PropertyDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'name': 'validationNameRequired'},
      );
    }
    if (draft.openingValue.isNegative ||
        (draft.purchasePrice?.isNegative ?? false)) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'openingValue': 'validationAmountNegative'},
      );
    }
  }

  static Currency _currencyOf(String code) => Currency(
    code: code,
    name: code,
    fractionDigits: 2,
    isPreset: true,
    isEnabled: true,
  );
}
