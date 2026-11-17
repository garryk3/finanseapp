import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';

/// Категории доходов и расходов; unique среди активных (data_schema §6).
///
/// Частичный unique-индекс `(kind, normalized_name) WHERE archived_at IS NULL`
/// создаётся в `AppDatabase` runtime-DDL.
@DataClassName('CategoryRow')
@TableIndex(
  name: 'categories_kind_archived_name',
  columns: {#kind, #archivedAt, #name},
)
@TableIndex(name: 'categories_archived', columns: {#archivedAt})
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get kind => text()
      .map(const CashflowKindConverter())
      .customConstraint("NOT NULL CHECK (kind IN ('income', 'expense'))")();

  TextColumn get name => text()();

  TextColumn get normalizedName => text()();

  TextColumn get colorKey => text().nullable()();

  TextColumn get iconKey => text().nullable()();

  BoolColumn get isPreset => boolean().withDefault(const Constant(false))();

  TextColumn get archivedAt =>
      text().map(const UtcTimestampConverter()).nullable()();
}
