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
}
