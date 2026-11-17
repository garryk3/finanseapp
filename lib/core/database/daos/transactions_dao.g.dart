// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $AssetTransfersTable get assetTransfers => attachedDatabase.assetTransfers;
  $AssetTransactionsTable get assetTransactions =>
      attachedDatabase.assetTransactions;
  $AssetTransactionRevisionsTable get assetTransactionRevisions =>
      attachedDatabase.assetTransactionRevisions;
  TransactionsDaoManager get managers => TransactionsDaoManager(this);
}

class TransactionsDaoManager {
  final _$TransactionsDaoMixin _db;
  TransactionsDaoManager(this._db);
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
}
