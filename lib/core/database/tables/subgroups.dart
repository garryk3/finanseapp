import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';

/// Справочник банков и брокеров (data_schema §6).
///
/// `normalizedName` вычисляется в Dart (trim + collapse whitespace + lowercase)
/// и нужен только для уникальности; UI показывает `name`.
@DataClassName('SubgroupRow')
@TableIndex(name: 'subgroups_kind_name', columns: {#kind, #name})
class Subgroups extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get kind => text()
      .map(const SubgroupKindConverter())
      .customConstraint("NOT NULL CHECK (kind IN ('bank', 'broker'))")();

  TextColumn get name => text()();

  TextColumn get normalizedName => text()();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();

  @override
  List<Set<Column>> get uniqueKeys => [
    {kind, normalizedName},
  ];
}
