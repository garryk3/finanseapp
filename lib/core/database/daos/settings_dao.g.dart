// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
}
