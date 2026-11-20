import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/data/analytics_queries_impl.dart';
import 'package:finanseapp/core/features/cashflow/data/cashflow_repository_impl.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/settings/data/settings_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_classification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AnalyticsQueriesImpl queries;
  final today = LocalDate.fromDateTime(testNow().toLocal());

  setUp(() {
    db = openTestDatabase();
    queries = AnalyticsQueriesImpl(
      db,
      ExchangeRateRepositoryImpl(db.currenciesDao, CbrExchangeRateClient()),
      SettingsRepositoryImpl(db.settingsDao),
      CurrencyRepositoryImpl(db.currenciesDao),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> addEntry({
    required CashflowKind kind,
    required int amountMinor,
    String currencyCode = 'RUB',
    int rateToRub = 1,
    int? amountRubMinor,
    LocalDate? occurredOn,
    int? category,
    int? propertyId,
    int? accountId,
    String? comment,
    bool affectsBalance = false,
  }) async {
    final resolvedCategory = category ?? await categoryId(db, kind);
    return db.cashflowDao.create(
      CashflowEntryInput(
        kind: kind,
        categoryId: resolvedCategory,
        amountMinor: amountMinor,
        currencyCode: currencyCode,
        occurredOn: occurredOn ?? today,
        rateToRub: Decimal.fromInt(rateToRub),
        amountRubMinor: amountRubMinor ?? amountMinor,
        affectsBalance: affectsBalance,
        propertyId: propertyId,
        accountId: accountId,
        comment: comment,
      ),
    );
  }

  Future<void> saveRate(String code, LocalDate date, int rate) =>
      db.currenciesDao.saveRate(
        currencyCode: code,
        date: date,
        rateToRub: Decimal.fromInt(rate),
        source: ExchangeRateSource.manual,
      );

  test('income 1000, expense 250 → net 750', () async {
    await addEntry(kind: CashflowKind.income, amountMinor: 100000);
    await addEntry(kind: CashflowKind.expense, amountMinor: 25000);

    final summary = await queries.cashflow(const CashflowFilter());

    expect(
      summary.income,
      const Money(minorUnits: 100000, currencyCode: 'RUB'),
    );
    expect(
      summary.expense,
      const Money(minorUnits: 25000, currencyCode: 'RUB'),
    );
    expect(summary.net, const Money(minorUnits: 75000, currencyCode: 'RUB'));
    expect(summary.currencyCode, 'RUB');
  });

  test('asset deposit без cashflow-записи не участвует', () async {
    final account = await createAccount(db, openingValueMinor: 100000);
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.deposit,
        amountMinor: 50000,
        occurredOn: today,
        rateToRub: Decimal.one,
        amountRubMinor: 50000,
      ),
    );

    final summary = await queries.cashflow(const CashflowFilter());

    expect(summary.income, const Money(minorUnits: 0, currencyCode: 'RUB'));
    expect(summary.expense, const Money(minorUnits: 0, currencyCode: 'RUB'));
  });

  test('deleted-запись исключена', () async {
    final id = await addEntry(kind: CashflowKind.income, amountMinor: 100000);
    await db.cashflowDao.softDelete(id);

    final summary = await queries.cashflow(const CashflowFilter());

    expect(summary.income.minorUnits, 0);
  });

  test('USD income конвертируется в базовую EUR через RUB даты', () async {
    await saveRate('USD', today, 90);
    await saveRate('EUR', today, 100);
    await db.settingsDao.setBaseCurrency('EUR');
    await addEntry(
      kind: CashflowKind.income,
      amountMinor: 10000,
      currencyCode: 'USD',
      rateToRub: 90,
      amountRubMinor: 900000,
    );
    await addEntry(
      kind: CashflowKind.expense,
      amountMinor: 5000,
      currencyCode: 'EUR',
      rateToRub: 100,
      amountRubMinor: 500000,
    );

    final summary = await queries.cashflow(const CashflowFilter());

    expect(summary.income, const Money(minorUnits: 9000, currencyCode: 'EUR'));
    expect(summary.expense, const Money(minorUnits: 5000, currencyCode: 'EUR'));
    expect(summary.net, const Money(minorUnits: 4000, currencyCode: 'EUR'));
  });

  test(
    'CALC-025: 1000 USD@90 → 900 EUR при базе 100, snapshot 90 000 RUB',
    () async {
      final repository = CashflowRepositoryImpl(
        db.cashflowDao,
        db.currenciesDao,
      );
      final id = await repository.create(
        CashflowEntryDraft(
          kind: CashflowKind.income,
          categoryId: await categoryId(db, CashflowKind.income),
          amount: const Money(minorUnits: 100000, currencyCode: 'USD'),
          occurredOn: today,
          rateToRub: Decimal.fromInt(90),
          affectsBalance: false,
        ),
      );
      expect((await repository.getById(id)).amountRub.minorUnits, 9000000);

      await saveRate('USD', today, 90);
      await saveRate('EUR', today, 100);
      await db.settingsDao.setBaseCurrency('EUR');
      final summary = await queries.cashflow(const CashflowFilter());

      expect(
        summary.income,
        const Money(minorUnits: 90000, currencyCode: 'EUR'),
      );
      expect(summary.net, const Money(minorUnits: 90000, currencyCode: 'EUR'));
    },
  );

  test('property-фильтр совпадает с деталями', () async {
    final first = await createProperty(db, name: 'Первая');
    final second = await createProperty(db, name: 'Вторая');
    await addEntry(
      kind: CashflowKind.income,
      amountMinor: 60000,
      propertyId: first,
    );
    await addEntry(
      kind: CashflowKind.expense,
      amountMinor: 15000,
      propertyId: first,
    );
    await addEntry(
      kind: CashflowKind.income,
      amountMinor: 99900,
      propertyId: second,
    );

    final summary = await queries.cashflow(CashflowFilter(propertyId: first));

    expect(summary.income.minorUnits, 60000);
    expect(summary.expense.minorUnits, 15000);
  });

  test('категории: суммы и архивная категория остаётся', () async {
    final first = await categoryId(db, CashflowKind.expense);
    final second = await db.referencesDao.createCategory(
      CashflowKind.expense,
      'Вторая',
    );
    await addEntry(
      kind: CashflowKind.expense,
      amountMinor: 25000,
      category: first,
    );
    await addEntry(
      kind: CashflowKind.expense,
      amountMinor: 75000,
      category: second,
    );
    await db.referencesDao.archiveCategory(second);

    final totals = await queries.cashflowByCategory(const CashflowFilter());

    expect(
      {for (final total in totals) total.categoryId: total.total.minorUnits},
      {first: 25000, second: 75000},
    );
  });

  test('серия: короткий период — дни с нулевыми точками', () async {
    final start = LocalDate(2026, 11, 10);
    await addEntry(
      kind: CashflowKind.income,
      amountMinor: 100000,
      occurredOn: LocalDate(2026, 11, 11),
    );

    final points = await queries.cashflowSeries(
      CashflowFilter(
        period: DateRange(start: start, end: LocalDate(2026, 11, 12)),
      ),
    );

    expect(
      [for (final point in points) point.periodStart],
      [start, LocalDate(2026, 11, 11), LocalDate(2026, 11, 12)],
    );
    expect(points[0].summary.income.minorUnits, 0);
    expect(points[1].summary.income.minorUnits, 100000);
  });

  test('серия: период >62 дней — месячные бакеты', () async {
    await addEntry(
      kind: CashflowKind.income,
      amountMinor: 100000,
      occurredOn: LocalDate(2026, 10, 15),
    );

    final points = await queries.cashflowSeries(
      CashflowFilter(
        period: DateRange(
          start: LocalDate(2026, 9, 1),
          end: LocalDate(2026, 11, 17),
        ),
      ),
    );

    expect(
      [for (final point in points) point.periodStart],
      [LocalDate(2026, 9, 1), LocalDate(2026, 10, 1), LocalDate(2026, 11, 1)],
    );
    expect(points[1].summary.income.minorUnits, 100000);
  });

  test('поиск по комментарию применяется в агрегатах', () async {
    await addEntry(
      kind: CashflowKind.income,
      amountMinor: 100000,
      comment: 'Аренда',
    );
    await addEntry(
      kind: CashflowKind.income,
      amountMinor: 50000,
      comment: 'Прочее',
    );

    final summary = await queries.cashflow(
      const CashflowFilter(query: 'аренд'),
    );

    expect(summary.income.minorUnits, 100000);
  });

  test('linked expense учитывается один раз', () async {
    final account = await createAccount(db, openingValueMinor: 100000);
    final category = await categoryId(db, CashflowKind.expense);
    final repository = AssetTransactionRepositoryImpl(db);
    await repository.create(
      AssetTransactionDraft(
        assetId: account,
        kind: AssetTransactionKind.withdrawal,
        amount: const Money(minorUnits: 25000, currencyCode: 'RUB'),
        occurredOn: today,
        rateToRub: Decimal.one,
        classification: TransactionClassification(
          kind: CashflowKind.expense,
          categoryId: category,
        ),
      ),
    );

    final summary = await queries.cashflow(const CashflowFilter());

    expect(
      summary.expense,
      const Money(minorUnits: 25000, currencyCode: 'RUB'),
    );
    expect(summary.income.minorUnits, 0);
  });

  test('перевод между счетами не попадает в cashflow-итоги', () async {
    final from = await createAccount(db, name: 'A', openingValueMinor: 100000);
    final to = await createAccount(db, name: 'B', openingValueMinor: 0);
    final repository = AssetTransactionRepositoryImpl(db);
    await repository.transfer(
      TransferDraft(
        fromAccountId: from,
        toAccountId: to,
        amount: const Money(minorUnits: 50000, currencyCode: 'RUB'),
        destinationAmount: const Money(minorUnits: 50000, currencyCode: 'RUB'),
        occurredOn: today,
        fromRateToRub: Decimal.one,
        toRateToRub: Decimal.one,
      ),
    );

    final summary = await queries.cashflow(const CashflowFilter());

    expect(summary.income.minorUnits, 0);
    expect(summary.expense.minorUnits, 0);
  });

  test('account-фильтр ограничивает итоги своим счётом', () async {
    final first = await createAccount(db, name: 'A');
    final second = await createAccount(db, name: 'B');
    await addEntry(
      kind: CashflowKind.expense,
      amountMinor: 10000,
      accountId: first,
    );
    await addEntry(
      kind: CashflowKind.expense,
      amountMinor: 20000,
      accountId: second,
    );

    final summary = await queries.cashflow(CashflowFilter(accountId: first));

    expect(summary.expense.minorUnits, 10000);
  });

  test(
    'нет курса базовой валюты — rateUnavailable с датой и валютой',
    () async {
      await db.settingsDao.setBaseCurrency('EUR');
      await saveRate('USD', today, 90);
      await addEntry(
        kind: CashflowKind.expense,
        amountMinor: 10000,
        currencyCode: 'USD',
        rateToRub: 90,
        amountRubMinor: 900000,
      );

      await expectLater(
        queries.cashflow(const CashflowFilter()),
        throwsA(
          isA<DomainException>()
              .having(
                (error) => error.code,
                'code',
                DomainErrorCode.rateUnavailable,
              )
              .having(
                (error) => error.fieldErrors['currencyCode'],
                'currencyCode',
                'EUR',
              )
              .having(
                (error) => error.fieldErrors.containsKey('date'),
                'hasDate',
                isTrue,
              ),
        ),
      );
    },
  );
}
