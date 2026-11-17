import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';

/// Финансовая цель; удаление только soft (data_schema §6).
@DataClassName('GoalRow')
@TableIndex(name: 'goals_status_deleted', columns: {#status, #deletedAt})
@TableIndex(name: 'goals_target_date', columns: {#targetDate})
@TableIndex(name: 'goals_currency', columns: {#currencyCode})
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get category => text()
      .map(const GoalCategoryConverter())
      .customConstraint(
        "NOT NULL CHECK (category IN ('accounts', 'investments'))",
      )();

  IntColumn get targetAmountMinor =>
      integer().customConstraint('NOT NULL CHECK (target_amount_minor > 0)')();

  TextColumn get currencyCode => text().references(
    Currencies,
    #code,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get status => text()
      .map(const GoalStatusConverter())
      .customConstraint(
        "NOT NULL CHECK (status IN ('active', 'achieved', 'closed'))",
      )();

  TextColumn get targetDate =>
      text().map(const LocalDateConverter()).nullable()();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();

  TextColumn get updatedAt => text().map(const UtcTimestampConverter())();

  TextColumn get deletedAt =>
      text().map(const UtcTimestampConverter()).nullable()();
}
