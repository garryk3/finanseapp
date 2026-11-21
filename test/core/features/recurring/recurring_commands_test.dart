import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/data/recurring_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_catchup_service.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_commands.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late RecurringRepositoryImpl repository;
  late RecurringCommands commands;

  setUp(() {
    db = openTestDatabase();
    repository = RecurringRepositoryImpl(db.recurringDao);
    final generator = RecurringGenerator(
      db: db,
      rateRepository: ExchangeRateRepositoryImpl(
        db.currenciesDao,
        CbrExchangeRateClient(),
      ),
      currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
    );
    commands = RecurringCommands(
      repository: repository,
      catchup: RecurringCatchupService(generator: generator).catchUp,
      today: LocalDate(2026, 11, 17),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('save создаёт правило и сразу догоняет первый платёж', () async {
    final property = await createProperty(db);
    final category = await categoryId(db, CashflowKind.expense);

    final result = await commands.save(
      kind: CashflowKind.expense,
      categoryId: category,
      amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
      propertyId: property,
      affectsBalance: false,
      startDate: LocalDate(2026, 9, 15),
    );

    expect(result, isA<Success<int>>());
    final rule = (await repository.watchActive().first).single;
    expect(rule.propertyId, property);
    expect(rule.lastGeneratedPeriod, '2026-11');
    final entries = await db.select(db.cashflowEntries).get();
    expect(entries, hasLength(3));
    expect(
      entries.map((entry) => entry.recurringRuleId),
      everyElement(rule.id),
    );
  });

  test('нулевая сумма и перевёрнутые даты не создают правило', () async {
    final category = await categoryId(db, CashflowKind.expense);

    final zero = await commands.save(
      kind: CashflowKind.expense,
      categoryId: category,
      amount: const Money(minorUnits: 0, currencyCode: 'RUB'),
      currencyCode: 'RUB',
      affectsBalance: false,
      startDate: LocalDate(2026, 9, 15),
    );
    expect(
      (zero as Failure<int>).error.fieldErrors['amount'],
      'validationAmountPositive',
    );

    final dates = await commands.save(
      kind: CashflowKind.expense,
      categoryId: category,
      amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
      affectsBalance: false,
      startDate: LocalDate(2026, 9, 15),
      endDate: LocalDate(2026, 9, 14),
    );
    expect(
      (dates as Failure<int>).error.fieldErrors['endDate'],
      'validationRecurringDates',
    );

    expect(await repository.watchActive().first, isEmpty);
    expect(await db.select(db.cashflowEntries).get(), isEmpty);
  });

  test('revise меняет сумму, delete останавливает будущие платежи', () async {
    final property = await createProperty(db);
    final category = await categoryId(db, CashflowKind.expense);
    final created = await commands.save(
      kind: CashflowKind.expense,
      categoryId: category,
      amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
      propertyId: property,
      affectsBalance: false,
      startDate: LocalDate(2026, 9, 15),
    );
    final id = (created as Success<int>).value;

    await commands.save(
      id: id,
      kind: CashflowKind.expense,
      categoryId: category,
      amount: const Money(minorUnits: 200000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
      propertyId: property,
      affectsBalance: false,
      startDate: LocalDate(2026, 9, 15),
    );
    final revised = (await repository.watchActive().first).single;
    expect(revised.amount?.minorUnits, 200000);
    expect(revised.lastGeneratedPeriod, '2026-11');

    await commands.delete(id);
    expect(await repository.watchActive().first, isEmpty);
    // История операций не удаляется.
    expect(await db.select(db.cashflowEntries).get(), hasLength(3));
  });

  test('будущая дата начала создаёт правило без операций', () async {
    final property = await createProperty(db);
    final category = await categoryId(db, CashflowKind.expense);

    final result = await commands.save(
      kind: CashflowKind.expense,
      categoryId: category,
      amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
      propertyId: property,
      affectsBalance: false,
      startDate: LocalDate(2027, 1, 15),
    );

    expect(result, isA<Success<int>>());
    expect(await db.select(db.cashflowEntries).get(), isEmpty);
  });
}
