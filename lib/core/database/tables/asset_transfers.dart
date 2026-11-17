import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';

/// Служебная группа двух ног перевода (data_schema §4).
///
/// Денежные поля не дублируются; группа остаётся после soft delete обеих ног
/// для аудита.
@DataClassName('AssetTransferRow')
class AssetTransfers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();

  TextColumn get updatedAt => text().map(const UtcTimestampConverter())();
}
