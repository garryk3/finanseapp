import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/assets_dao.dart';
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
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Реализация активов: счета (5.1); инвестиции/квартиры — 5.2/5.4.
final class AssetRepositoryImpl implements AssetRepository {
  const AssetRepositoryImpl(
    this._assetsDao,
    this._transactionsDao,
    this._valuationsDao,
  );

  final AssetsDao _assetsDao;
  final TransactionsDao _transactionsDao;
  final ValuationsDao _valuationsDao;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      _assetsDao
          .watchAll(includeArchived: includeArchived)
          .asyncMap((rows) => Future.wait(rows.map(_snapshotOf)));

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
      case PropertyDraft():
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'kind': 'validationAssetKindUnsupported'},
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
      case PropertyDraft():
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'kind': 'validationAssetKindUnsupported'},
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
    );
  }

  @override
  Future<void> recordValuation(AssetValuationDraft draft) async {
    final decimalValue = MoneyMath.toDecimal(
      draft.value,
      _currencyOf(draft.value.currencyCode),
    );
    final valueRub = MoneyMath.fromDecimal(
      decimalValue * draft.rateToRub,
      _currencyOf('RUB'),
    );
    await _valuationsDao.create(
      assetId: draft.assetId,
      effectiveOn: draft.effectiveOn,
      valueMinor: draft.value.minorUnits,
      rateToRub: draft.rateToRub,
      valueRubMinor: valueRub.minorUnits,
    );
  }

  Future<AssetSnapshot> _snapshotOf(AssetRow row) async {
    final transactions = await _transactionsFor(row.id, row.currencyCode);
    final valuations = await _valuationsFor(row.id, row.currencyCode);
    final opening = Money(
      minorUnits: row.openingValueMinor,
      currencyCode: row.currencyCode,
    );

    switch (row.kind) {
      case AssetKind.account:
        final details = await _assetsDao.accountDetailsFor(row.id);
        if (details == null) {
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
          bankId: details.bankId,
          annualRate: details.annualRate,
          startDate: details.startDate,
          endDate: details.endDate,
        );
        return AssetSnapshot(
          asset: asset,
          currentValue: AssetValueCalculator.account(asset, transactions),
        );
      case AssetKind.investment:
        final details = await _assetsDao.investmentDetailsFor(row.id);
        if (details == null) {
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
          brokerId: details.brokerId,
        );
        return AssetSnapshot(
          asset: asset,
          currentValue: AssetValueCalculator.investment(
            asset,
            valuations,
            transactions,
          ),
        );
      case AssetKind.property:
        final asset = PropertyAsset(
          id: row.id,
          name: row.name,
          currencyCode: row.currencyCode,
          openingValue: opening,
          createdAt: row.createdAt,
          archivedAt: row.archivedAt,
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
    return [
      for (final row in rows)
        AssetValuation(
          id: row.id,
          assetId: row.assetId,
          effectiveOn: row.effectiveOn,
          value: Money(minorUnits: row.valueMinor, currencyCode: currencyCode),
          rateToRub: row.rateToRub,
          valueRub: Money(minorUnits: row.valueRubMinor, currencyCode: 'RUB'),
          createdAt: row.createdAt,
        ),
    ];
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
    return [
      for (final row in rows)
        AssetTransaction(
          id: row.id,
          assetId: row.assetId,
          kind: row.kind,
          amount: Money(
            minorUnits: row.amountMinor,
            currencyCode: currencyCode,
          ),
          occurredOn: row.occurredOn,
          rateToRub: row.rateToRub,
          amountRub: Money(minorUnits: row.amountRubMinor, currencyCode: 'RUB'),
          revisionNo: row.revisionNo,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          comment: row.comment,
          transferId: row.transferId,
          deletedAt: row.deletedAt,
        ),
    ];
  }

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

  static Currency _currencyOf(String code) => Currency(
    code: code,
    name: code,
    fractionDigits: 2,
    isPreset: true,
    isEnabled: true,
  );
}
