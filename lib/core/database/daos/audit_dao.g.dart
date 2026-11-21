// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_dao.dart';

// ignore_for_file: type=lint
mixin _$AuditDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $AssetTransfersTable get assetTransfers => attachedDatabase.assetTransfers;
  $AssetTransactionsTable get assetTransactions =>
      attachedDatabase.assetTransactions;
  $AssetTransactionRevisionsTable get assetTransactionRevisions =>
      attachedDatabase.assetTransactionRevisions;
  $CategoriesTable get categories => attachedDatabase.categories;
  $RecurringCashflowRulesTable get recurringCashflowRules =>
      attachedDatabase.recurringCashflowRules;
  $CashflowEntriesTable get cashflowEntries => attachedDatabase.cashflowEntries;
  $CashflowEntryRevisionsTable get cashflowEntryRevisions =>
      attachedDatabase.cashflowEntryRevisions;
  AuditDaoManager get managers => AuditDaoManager(this);
}

class AuditDaoManager {
  final _$AuditDaoMixin _db;
  AuditDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
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
  $$AssetTransactionRevisionsTableTableManager get assetTransactionRevisions =>
      $$AssetTransactionRevisionsTableTableManager(
        _db.attachedDatabase,
        _db.assetTransactionRevisions,
      );
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
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
