import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/assets.dart';

/// Абсолютная оценка инвестиции/квартиры на конец дня (data_schema §3).
@DataClassName('AssetValuationRow')
@TableIndex(
  name: 'asset_valuations_asset_effective',
  columns: {#assetId, #effectiveOn},
)
@TableIndex(name: 'asset_valuations_effective', columns: {#effectiveOn})
@TableIndex(
  name: 'asset_valuations_asset_created',
  columns: {#assetId, #createdAt},
)
class AssetValuations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get assetId => integer().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get effectiveOn => text().map(const LocalDateConverter())();

  IntColumn get valueMinor =>
      integer().customConstraint('NOT NULL CHECK (value_minor >= 0)')();

  TextColumn get rateToRub => text().map(const DecimalConverter())();

  IntColumn get valueRubMinor =>
      integer().customConstraint('NOT NULL CHECK (value_rub_minor >= 0)')();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();
}
