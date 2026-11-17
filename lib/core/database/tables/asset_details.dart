import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/subgroups.dart';

/// Детали счёта; ровно одна detail-строка на актив (data_schema §3).
@DataClassName('AccountDetailRow')
@TableIndex(name: 'account_details_bank', columns: {#bankId})
class AccountDetails extends Table {
  IntColumn get assetId => integer().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get bankId => integer().references(
    Subgroups,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get annualRate => text().map(const DecimalConverter())();

  TextColumn get startDate => text().map(const LocalDateConverter())();

  TextColumn get endDate => text().map(const LocalDateConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {assetId};
}

/// Детали инвестиции.
@DataClassName('InvestmentDetailRow')
@TableIndex(name: 'investment_details_broker', columns: {#brokerId})
class InvestmentDetails extends Table {
  IntColumn get assetId => integer().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get brokerId => integer().references(
    Subgroups,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  @override
  Set<Column> get primaryKey => {assetId};
}

/// Детали квартиры; адрес и цена покупки опциональны, цена в валюте актива.
@DataClassName('PropertyDetailRow')
class PropertyDetails extends Table {
  IntColumn get assetId => integer().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get address => text().nullable()();

  IntColumn get purchasePriceMinor => integer().nullable().customConstraint(
    'CHECK (purchase_price_minor IS NULL OR purchase_price_minor >= 0)',
  )();

  @override
  Set<Column> get primaryKey => {assetId};
}
