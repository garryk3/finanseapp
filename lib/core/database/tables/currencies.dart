import 'package:drift/drift.dart';

/// Валюты справочника; PK — код, RUB не отключается (data_schema §6).
@DataClassName('CurrencyRow')
class Currencies extends Table {
  TextColumn get code => text().customConstraint('NOT NULL')();

  TextColumn get name => text()();

  TextColumn get normalizedName => text()();

  IntColumn get fractionDigits => integer().customConstraint(
    'NOT NULL CHECK (fraction_digits BETWEEN 0 AND 8)',
  )();

  BoolColumn get isPreset => boolean().withDefault(const Constant(false))();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {code};
}
