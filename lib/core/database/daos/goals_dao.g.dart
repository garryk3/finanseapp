// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_dao.dart';

// ignore_for_file: type=lint
mixin _$GoalsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AssetsTable get assets => attachedDatabase.assets;
  $GoalsTable get goals => attachedDatabase.goals;
  $GoalAssetsTable get goalAssets => attachedDatabase.goalAssets;
  GoalsDaoManager get managers => GoalsDaoManager(this);
}

class GoalsDaoManager {
  final _$GoalsDaoMixin _db;
  GoalsDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
  $$GoalAssetsTableTableManager get goalAssets =>
      $$GoalAssetsTableTableManager(_db.attachedDatabase, _db.goalAssets);
}
