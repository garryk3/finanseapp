import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';

/// Заблокированная сумма инвестиции по валюте (data_schema §11, schema v4).
///
/// Одна отметка на валюту; PK `(assetId, currencyCode)`. Сумма строго
/// положительна, ноль означает отсутствие отметки (строка удаляется).
@DataClassName('InvestmentLockedAmountRow')
class InvestmentLockedAmounts extends Table {
  IntColumn get assetId => integer().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get currencyCode => text().references(
    Currencies,
    #code,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get amountMinor =>
      integer().customConstraint('NOT NULL CHECK (amount_minor > 0)')();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();

  TextColumn get updatedAt => text().map(const UtcTimestampConverter())();

  @override
  Set<Column> get primaryKey => {assetId, currencyCode};
}
