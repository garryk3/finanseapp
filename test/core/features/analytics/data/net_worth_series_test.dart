import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/data/analytics_queries_impl.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/settings/data/settings_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AnalyticsQueriesImpl queries;

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

  Future<void> setCreatedAt(int assetId, LocalDate date) =>
      (db.update(db.assets)..where((a) => a.id.equals(assetId))).write(
        AssetsCompanion(
          createdAt: Value(DateTime.utc(date.year, date.month, date.day, 12)),
        ),
      );

  Future<void> saveRate(String code, LocalDate date, int rateToRub) =>
      db.currenciesDao.saveRate(
        currencyCode: code,
        date: date,
        rateToRub: Decimal.fromInt(rateToRub),
        source: ExchangeRateSource.manual,
      );

  final start = LocalDate(2026, 11, 10);

  test('операция внутри дня применяется к точке даты', () async {
    final account = await createAccount(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    await setCreatedAt(account, start);
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.deposit,
        amountMinor: 50000,
        occurredOn: LocalDate(2026, 11, 12),
        rateToRub: Decimal.one,
        amountRubMinor: 50000,
      ),
    );

    final points = await queries.netWorthSeries(
      period: DateRange(start: start, end: LocalDate(2026, 11, 13)),
    );

    expect(
      [for (final point in points) point.date],
      [LocalDate(2026, 11, 10), LocalDate(2026, 11, 12)],
    );
    expect(
      points[0].value,
      const Money(minorUnits: 100000, currencyCode: 'RUB'),
    );
    expect(
      points[1].value,
      const Money(minorUnits: 150000, currencyCode: 'RUB'),
    );
  });

  test('оценка заменяет накопленное только с effectiveOn', () async {
    final investment = await createInvestment(
      db,
      currencyCode: 'USD',
      openingValueMinor: 1000,
    );
    await setCreatedAt(investment, start);
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: investment,
        kind: AssetTransactionKind.deposit,
        amountMinor: 500,
        occurredOn: LocalDate(2026, 11, 11),
        rateToRub: Decimal.fromInt(90),
        amountRubMinor: 45000,
      ),
    );
    await db.valuationsDao.create(
      assetId: investment,
      effectiveOn: LocalDate(2026, 11, 12),
      valueMinor: 2000,
      rateToRub: Decimal.fromInt(90),
      valueRubMinor: 180000,
    );
    for (final date in [
      start,
      LocalDate(2026, 11, 11),
      LocalDate(2026, 11, 12),
    ]) {
      await saveRate('USD', date, 90);
    }

    final points = await queries.netWorthSeries(
      period: DateRange(start: start, end: LocalDate(2026, 11, 12)),
    );

    expect(
      [for (final point in points) point.value.minorUnits],
      [90000, 135000, 180000],
    );
  });

  test(
    'архивный актив остаётся в прошлых точках и падает на дате архивации',
    () async {
      final account = await createAccount(
        db,
        currencyCode: 'RUB',
        openingValueMinor: 100000,
      );
      await setCreatedAt(account, start);
      await db.assetsDao.archive(
        account,
        archivedAt: DateTime.utc(2026, 11, 12, 12),
      );

      final points = await queries.netWorthSeries(
        period: DateRange(start: start, end: LocalDate(2026, 11, 13)),
      );

      expect(
        [for (final point in points) point.date],
        [LocalDate(2026, 11, 10), LocalDate(2026, 11, 12)],
      );
      expect(points[0].value.minorUnits, 100000);
      expect(points[1].value.minorUnits, 0);
    },
  );

  test('kind-фильтр исключает чужие активы и их события', () async {
    final account = await createAccount(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    final investment = await createInvestment(
      db,
      currencyCode: 'USD',
      openingValueMinor: 1000,
    );
    await setCreatedAt(account, start);
    await setCreatedAt(investment, start);
    await db.valuationsDao.create(
      assetId: investment,
      effectiveOn: LocalDate(2026, 11, 12),
      valueMinor: 2000,
      rateToRub: Decimal.fromInt(90),
      valueRubMinor: 180000,
    );
    await saveRate('USD', start, 90);
    await saveRate('USD', LocalDate(2026, 11, 12), 90);

    final accounts = await queries.netWorthSeries(
      period: DateRange(start: start, end: LocalDate(2026, 11, 13)),
      assetKind: AssetKind.account,
    );
    final investments = await queries.netWorthSeries(
      period: DateRange(start: start, end: LocalDate(2026, 11, 13)),
      assetKind: AssetKind.investment,
    );

    expect([for (final point in accounts) point.date], [start]);
    expect(
      [for (final point in investments) point.date],
      [start, LocalDate(2026, 11, 12)],
    );
  });

  test('удалённая операция не создаёт точку и не меняет значение', () async {
    final account = await createAccount(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    await setCreatedAt(account, start);
    final deposit = await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.deposit,
        amountMinor: 50000,
        occurredOn: LocalDate(2026, 11, 12),
        rateToRub: Decimal.one,
        amountRubMinor: 50000,
      ),
    );
    await db.transactionsDao.softDelete(deposit);

    final points = await queries.netWorthSeries(
      period: DateRange(start: start, end: LocalDate(2026, 11, 13)),
    );

    expect([for (final point in points) point.date], [start]);
    expect(points.single.value.minorUnits, 100000);
  });

  test('пустой набор активов выбранного вида — пустая серия', () async {
    await createAccount(db, currencyCode: 'RUB', openingValueMinor: 100000);

    final points = await queries.netWorthSeries(
      period: DateRange(start: start, end: LocalDate(2026, 11, 13)),
      assetKind: AssetKind.property,
    );

    expect(points, isEmpty);
  });

  test('границы периода включительны', () async {
    final account = await createAccount(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    await setCreatedAt(account, start);
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.withdrawal,
        amountMinor: 10000,
        occurredOn: LocalDate(2026, 11, 13),
        rateToRub: Decimal.one,
        amountRubMinor: 10000,
      ),
    );

    final points = await queries.netWorthSeries(
      period: DateRange(start: start, end: LocalDate(2026, 11, 13)),
    );

    expect(points.last.date, LocalDate(2026, 11, 13));
    expect(points.last.value.minorUnits, 90000);
  });

  test('earliest учитывает операции и оценки, а не только создание', () async {
    final account = await createAccount(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    await setCreatedAt(account, start);
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.deposit,
        amountMinor: 10000,
        occurredOn: LocalDate(2026, 11, 5),
        rateToRub: Decimal.one,
        amountRubMinor: 10000,
      ),
    );
    final investment = await createInvestment(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    await setCreatedAt(investment, start);
    await db.valuationsDao.create(
      assetId: investment,
      effectiveOn: LocalDate(2026, 11, 3),
      valueMinor: 200000,
      rateToRub: Decimal.one,
      valueRubMinor: 200000,
    );

    expect(
      await queries.earliestActivityDate(assetKind: AssetKind.account),
      LocalDate(2026, 11, 5),
    );
    expect(
      await queries.earliestActivityDate(assetKind: AssetKind.investment),
      LocalDate(2026, 11, 3),
    );
  });

  test(
    'актив в валюте без курса — rateUnavailable с валютой и датой',
    () async {
      await createInvestment(db, currencyCode: 'USD', openingValueMinor: 1000);

      await expectLater(
        queries.netWorthSeries(
          period: DateRange(start: start, end: LocalDate(2026, 11, 17)),
        ),
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
                'USD',
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
