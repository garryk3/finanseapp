// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuations_dao.dart';

// ignore_for_file: type=lint
mixin _$ValuationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $AssetValuationsTable get assetValuations => attachedDatabase.assetValuations;
  ValuationsDaoManager get managers => ValuationsDaoManager(this);
}

class ValuationsDaoManager {
  final _$ValuationsDaoMixin _db;
  ValuationsDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$AssetValuationsTableTableManager get assetValuations =>
      $$AssetValuationsTableTableManager(
        _db.attachedDatabase,
        _db.assetValuations,
      );
}
