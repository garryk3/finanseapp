// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_dao.dart';

// ignore_for_file: type=lint
mixin _$AssetsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $SubgroupsTable get subgroups => attachedDatabase.subgroups;
  $AccountDetailsTable get accountDetails => attachedDatabase.accountDetails;
  $InvestmentDetailsTable get investmentDetails =>
      attachedDatabase.investmentDetails;
  $PropertyDetailsTable get propertyDetails => attachedDatabase.propertyDetails;
  $InvestmentLockedAmountsTable get investmentLockedAmounts =>
      attachedDatabase.investmentLockedAmounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $RecurringCashflowRulesTable get recurringCashflowRules =>
      attachedDatabase.recurringCashflowRules;
  $AssetTransfersTable get assetTransfers => attachedDatabase.assetTransfers;
  $AssetTransactionsTable get assetTransactions =>
      attachedDatabase.assetTransactions;
  $CashflowEntriesTable get cashflowEntries => attachedDatabase.cashflowEntries;
  AssetsDaoManager get managers => AssetsDaoManager(this);
}

class AssetsDaoManager {
  final _$AssetsDaoMixin _db;
  AssetsDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$SubgroupsTableTableManager get subgroups =>
      $$SubgroupsTableTableManager(_db.attachedDatabase, _db.subgroups);
  $$AccountDetailsTableTableManager get accountDetails =>
      $$AccountDetailsTableTableManager(
        _db.attachedDatabase,
        _db.accountDetails,
      );
  $$InvestmentDetailsTableTableManager get investmentDetails =>
      $$InvestmentDetailsTableTableManager(
        _db.attachedDatabase,
        _db.investmentDetails,
      );
  $$PropertyDetailsTableTableManager get propertyDetails =>
      $$PropertyDetailsTableTableManager(
        _db.attachedDatabase,
        _db.propertyDetails,
      );
  $$InvestmentLockedAmountsTableTableManager get investmentLockedAmounts =>
      $$InvestmentLockedAmountsTableTableManager(
        _db.attachedDatabase,
        _db.investmentLockedAmounts,
      );
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$RecurringCashflowRulesTableTableManager get recurringCashflowRules =>
      $$RecurringCashflowRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurringCashflowRules,
      );
  $$AssetTransfersTableTableManager get assetTransfers =>
      $$AssetTransfersTableTableManager(
        _db.attachedDatabase,
        _db.assetTransfers,
      );
  $$AssetTransactionsTableTableManager get assetTransactions =>
      $$AssetTransactionsTableTableManager(
        _db.attachedDatabase,
        _db.assetTransactions,
      );
  $$CashflowEntriesTableTableManager get cashflowEntries =>
      $$CashflowEntriesTableTableManager(
        _db.attachedDatabase,
        _db.cashflowEntries,
      );
}
