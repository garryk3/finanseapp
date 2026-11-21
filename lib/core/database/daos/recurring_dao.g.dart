// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_dao.dart';

// ignore_for_file: type=lint
mixin _$RecurringDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $RecurringCashflowRulesTable get recurringCashflowRules =>
      attachedDatabase.recurringCashflowRules;
  $AssetTransfersTable get assetTransfers => attachedDatabase.assetTransfers;
  $AssetTransactionsTable get assetTransactions =>
      attachedDatabase.assetTransactions;
  $CashflowEntriesTable get cashflowEntries => attachedDatabase.cashflowEntries;
  RecurringDaoManager get managers => RecurringDaoManager(this);
}

class RecurringDaoManager {
  final _$RecurringDaoMixin _db;
  RecurringDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
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
