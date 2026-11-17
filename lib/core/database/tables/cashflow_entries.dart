import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/asset_transactions.dart';
import 'package:finanseapp/core/database/tables/categories.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';

/// Запись денежного потока; current projection с soft delete (data_schema §5).
@DataClassName('CashflowEntryRow')
@TableIndex(name: 'cashflow_occurred', columns: {#occurredOn, #id})
@TableIndex(name: 'cashflow_kind_occurred', columns: {#kind, #occurredOn})
@TableIndex(
  name: 'cashflow_category_occurred',
  columns: {#categoryId, #occurredOn},
)
@TableIndex(
  name: 'cashflow_currency_occurred',
  columns: {#currencyCode, #occurredOn},
)
@TableIndex(
  name: 'cashflow_property_occurred',
  columns: {#propertyId, #occurredOn},
)
@TableIndex(
  name: 'cashflow_account_occurred',
  columns: {#accountId, #occurredOn},
)
@TableIndex(name: 'cashflow_asset_tx', columns: {#assetTransactionId})
@TableIndex(
  name: 'cashflow_deleted_occurred',
  columns: {#deletedAt, #occurredOn},
)
class CashflowEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get kind => text()
      .map(const CashflowKindConverter())
      .customConstraint("NOT NULL CHECK (kind IN ('income', 'expense'))")();

  IntColumn get categoryId => integer().references(
    Categories,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get amountMinor =>
      integer().customConstraint('NOT NULL CHECK (amount_minor > 0)')();

  TextColumn get currencyCode => text().references(
    Currencies,
    #code,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get occurredOn => text().map(const LocalDateConverter())();

  TextColumn get rateToRub => text().map(const DecimalConverter())();

  IntColumn get amountRubMinor =>
      integer().customConstraint('NOT NULL CHECK (amount_rub_minor > 0)')();

  BoolColumn get affectsBalance => boolean()();

  TextColumn get comment => text().nullable()();

  @ReferenceName('propertyEntries')
  IntColumn get propertyId => integer().nullable().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  @ReferenceName('accountEntries')
  IntColumn get accountId => integer().nullable().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get assetTransactionId => integer().nullable().references(
    AssetTransactions,
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
    'CHECK (NOT (property_id IS NOT NULL AND account_id IS NOT NULL))',
    'CHECK (affects_balance = 0 OR account_id IS NOT NULL)',
    'CHECK (affects_balance = 1 OR asset_transaction_id IS NULL)',
  ];
}
