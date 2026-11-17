import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';

/// Key-value настройки приложения (data_schema §6).
///
/// Секреты и временные backup-пути здесь не хранятся.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text().customConstraint('NOT NULL')();

  TextColumn get value => text()();

  TextColumn get updatedAt => text().map(const UtcTimestampConverter())();

  @override
  Set<Column> get primaryKey => {key};
}
