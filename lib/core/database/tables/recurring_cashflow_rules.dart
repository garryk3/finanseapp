import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/categories.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';

/// Правило ежемесячного дохода/расхода или автоначисления процентов (BR-RC-1).
///
/// `fixed` — пользовательское правило с фиксированной суммой;
/// `deposit_interest` — автоправило вклада: сумма вычисляется генератором от
/// фактического баланса, поэтому `amount_minor` пуст (BR-RC-9).
/// `last_generated_period` ('YYYY-MM') — инкрементальный маркер catch-up,
/// у актуальных правил приложения нет записи о прошлых периодах (BR-RC-11).
@DataClassName('RecurringCashflowRuleRow')
@TableIndex(name: 'recurring_deleted', columns: {#deletedAt})
@TableIndex(name: 'recurring_account', columns: {#accountId})
@TableIndex(name: 'recurring_property', columns: {#propertyId})
class RecurringCashflowRules extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get strategy => text()
      .map(const RecurringStrategyConverter())
      .customConstraint(
        "NOT NULL CHECK (strategy IN ('fixed', 'deposit_interest'))",
      )();

  TextColumn get kind => text()
      .map(const CashflowKindConverter())
      .customConstraint("NOT NULL CHECK (kind IN ('income', 'expense'))")();

  IntColumn get categoryId => integer().references(
    Categories,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get amountMinor => integer().nullable().customConstraint(
    'CHECK (amount_minor IS NULL OR amount_minor > 0)',
  )();

  TextColumn get currencyCode => text().references(
    Currencies,
    #code,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  @ReferenceName('recurringAccountRules')
  IntColumn get accountId => integer().nullable().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  @ReferenceName('recurringPropertyRules')
  IntColumn get propertyId => integer().nullable().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  BoolColumn get affectsBalance => boolean()();

  TextColumn get startDate => text().map(const LocalDateConverter())();

  TextColumn get endDate => text().map(const LocalDateConverter()).nullable()();

  TextColumn get comment => text().nullable()();

  TextColumn get lastGeneratedPeriod => text().nullable()();

  TextColumn get createdAt => text().map(const UtcTimestampConverter())();

  TextColumn get updatedAt => text().map(const UtcTimestampConverter())();

  TextColumn get deletedAt =>
      text().map(const UtcTimestampConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
    'CHECK (NOT (property_id IS NOT NULL AND account_id IS NOT NULL))',
    'CHECK (affects_balance = 0 OR account_id IS NOT NULL)',
    'CHECK (end_date IS NULL OR start_date <= end_date)',
    "CHECK ((strategy = 'fixed' AND amount_minor IS NOT NULL) OR "
        "(strategy = 'deposit_interest' AND amount_minor IS NULL))",
    "CHECK (strategy = 'fixed' OR (kind = 'income' AND "
        'account_id IS NOT NULL AND affects_balance = 1))',
  ];
}
