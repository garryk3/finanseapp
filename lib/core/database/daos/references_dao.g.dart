// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'references_dao.dart';

// ignore_for_file: type=lint
mixin _$ReferencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubgroupsTable get subgroups => attachedDatabase.subgroups;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $AccountDetailsTable get accountDetails => attachedDatabase.accountDetails;
  $InvestmentDetailsTable get investmentDetails =>
      attachedDatabase.investmentDetails;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AssetTransfersTable get assetTransfers => attachedDatabase.assetTransfers;
  $AssetTransactionsTable get assetTransactions =>
      attachedDatabase.assetTransactions;
  $CashflowEntriesTable get cashflowEntries => attachedDatabase.cashflowEntries;
  ReferencesDaoManager get managers => ReferencesDaoManager(this);
}

class ReferencesDaoManager {
  final _$ReferencesDaoMixin _db;
  ReferencesDaoManager(this._db);
  $$SubgroupsTableTableManager get subgroups =>
      $$SubgroupsTableTableManager(_db.attachedDatabase, _db.subgroups);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
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
  $$CashflowEntriesTableTableManager get cashflowEntries =>
      $$CashflowEntriesTableTableManager(
        _db.attachedDatabase,
        _db.cashflowEntries,
      );
}
