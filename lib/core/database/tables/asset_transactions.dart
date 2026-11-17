import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/asset_transfers.dart';

/// Операция по активу; current projection с soft delete (data_schema §4).
///
/// Частичный unique-индекс активной пары ног перевода создаётся в
/// `AppDatabase` runtime-DDL.
@DataClassName('AssetTransactionRow')
@TableIndex(
  name: 'asset_transactions_asset_occurred',
  columns: {#assetId, #occurredOn, #id},
)
@TableIndex(name: 'asset_transactions_occurred', columns: {#occurredOn})
@TableIndex(name: 'asset_transactions_kind', columns: {#kind})
@TableIndex(name: 'asset_transactions_transfer', columns: {#transferId})
@TableIndex(
  name: 'asset_transactions_deleted_occurred',
  columns: {#deletedAt, #occurredOn},
)
class AssetTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get assetId => integer().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get kind => text()
      .map(const AssetTransactionKindConverter())
      .customConstraint(
        "NOT NULL CHECK (kind IN ('deposit', 'withdrawal', 'transferOut', 'transferIn'))",
      )();

  IntColumn get amountMinor =>
      integer().customConstraint('NOT NULL CHECK (amount_minor > 0)')();

  TextColumn get occurredOn => text().map(const LocalDateConverter())();

  TextColumn get rateToRub => text().map(const DecimalConverter())();

  IntColumn get amountRubMinor =>
      integer().customConstraint('NOT NULL CHECK (amount_rub_minor > 0)')();

  TextColumn get comment => text().nullable()();

  IntColumn get transferId => integer().nullable().references(
    AssetTransfers,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get revisionNo =>
      integer().customConstraint('NOT NULL CHECK (revision_no >= 1)')();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();

  TextColumn get updatedAt => text().map(const UtcTimestampConverter())();

  TextColumn get deletedAt =>
      text().map(const UtcTimestampConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
    // transfer-ноги обязаны иметь группу, обычные операции — нет.
    "CHECK ((kind IN ('transferOut', 'transferIn') AND transfer_id IS NOT NULL) "
        "OR (kind IN ('deposit', 'withdrawal') AND transfer_id IS NULL))",
  ];
}
