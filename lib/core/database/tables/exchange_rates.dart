import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';

/// Курс валюты на дату; RUB всегда 1 и строк кэша не получает (data_schema §6).
@DataClassName('ExchangeRateRow')
@TableIndex(
  name: 'exchange_rates_currency_date',
  columns: {#currencyCode, #date},
)
class ExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get currencyCode => text().references(
    Currencies,
    #code,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get date => text().map(const LocalDateConverter())();

  TextColumn get rateToRub => text().map(const DecimalConverter())();

  TextColumn get source => text()
      .map(const ExchangeRateSourceConverter())
      .customConstraint("NOT NULL CHECK (source IN ('cbr', 'manual'))")();

  TextColumn get fetchedAt => text().map(const UtcTimestampConverter())();

  @override
  List<Set<Column>> get uniqueKeys => [
    {currencyCode, date},
  ];
}
