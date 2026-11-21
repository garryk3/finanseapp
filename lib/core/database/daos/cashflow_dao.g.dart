// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cashflow_dao.dart';

// ignore_for_file: type=lint
mixin _$CashflowDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AssetTransfersTable get assetTransfers => attachedDatabase.assetTransfers;
  $AssetTransactionsTable get assetTransactions =>
      attachedDatabase.assetTransactions;
  $RecurringCashflowRulesTable get recurringCashflowRules =>
      attachedDatabase.recurringCashflowRules;
  $CashflowEntriesTable get cashflowEntries => attachedDatabase.cashflowEntries;
  $CashflowEntryRevisionsTable get cashflowEntryRevisions =>
      attachedDatabase.cashflowEntryRevisions;
  CashflowDaoManager get managers => CashflowDaoManager(this);
}

class CashflowDaoManager {
  final _$CashflowDaoMixin _db;
  CashflowDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
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
  $$RecurringCashflowRulesTableTableManager get recurringCashflowRules =>
      $$RecurringCashflowRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurringCashflowRules,
      );
  $$CashflowEntriesTableTableManager get cashflowEntries =>
      $$CashflowEntriesTableTableManager(
        _db.attachedDatabase,
        _db.cashflowEntries,
      );
  $$CashflowEntryRevisionsTableTableManager get cashflowEntryRevisions =>
      $$CashflowEntryRevisionsTableTableManager(
        _db.attachedDatabase,
        _db.cashflowEntryRevisions,
      );
}
