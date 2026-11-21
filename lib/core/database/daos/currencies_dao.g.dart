// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currencies_dao.dart';

// ignore_for_file: type=lint
mixin _$CurrenciesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $ExchangeRatesTable get exchangeRates => attachedDatabase.exchangeRates;
  $AssetsTable get assets => attachedDatabase.assets;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AssetTransfersTable get assetTransfers => attachedDatabase.assetTransfers;
  $AssetTransactionsTable get assetTransactions =>
      attachedDatabase.assetTransactions;
  $RecurringCashflowRulesTable get recurringCashflowRules =>
      attachedDatabase.recurringCashflowRules;
  $CashflowEntriesTable get cashflowEntries => attachedDatabase.cashflowEntries;
  $GoalsTable get goals => attachedDatabase.goals;
  CurrenciesDaoManager get managers => CurrenciesDaoManager(this);
}

class CurrenciesDaoManager {
  final _$CurrenciesDaoMixin _db;
  CurrenciesDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db.attachedDatabase, _db.exchangeRates);
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
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
}
