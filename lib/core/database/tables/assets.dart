import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';

/// Общие поля актива; ровно одна detail-строка задаёт вид (data_schema §3).
@DataClassName('AssetRow')
@TableIndex(name: 'assets_kind_archived', columns: {#kind, #archivedAt})
@TableIndex(name: 'assets_currency', columns: {#currencyCode})
@TableIndex(name: 'assets_archived_name', columns: {#archivedAt, #name})
class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get kind => text()
      .map(const AssetKindConverter())
      .customConstraint(
        "NOT NULL CHECK (kind IN ('account', 'investment', 'property'))",
      )();

  TextColumn get currencyCode => text().references(
    Currencies,
    #code,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get openingValueMinor =>
      integer().customConstraint('NOT NULL CHECK (opening_value_minor >= 0)')();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();

  TextColumn get archivedAt =>
      text().map(const UtcTimestampConverter()).nullable()();
}
