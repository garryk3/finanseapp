import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
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
  late DateTime now;

  setUp(() {
    db = openTestDatabase();
    queries = AnalyticsQueriesImpl(
      db,
      ExchangeRateRepositoryImpl(db.currenciesDao, CbrExchangeRateClient()),
      SettingsRepositoryImpl(db.settingsDao),
      CurrencyRepositoryImpl(db.currenciesDao),
    );
    now = testNow();
  });

  tearDown(() async {
    await db.close();
  });

  LocalDate today() => LocalDate.fromDateTime(now.toLocal());

  Future<void> saveRate(String code, int rateToRub, {LocalDate? onDate}) =>
      db.currenciesDao.saveRate(
        currencyCode: code,
        date: onDate ?? today(),
        rateToRub: Decimal.fromInt(rateToRub),
        source: ExchangeRateSource.manual,
      );

  Money rub(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

  test('активы в разных валютах приводятся к базовой', () async {
    await createAccount(db, currencyCode: 'RUB', openingValueMinor: 100000);
    await createInvestment(db, currencyCode: 'USD', openingValueMinor: 1000);
    await createProperty(db, currencyCode: 'EUR', openingValueMinor: 200);
    await saveRate('USD', 90);
    await saveRate('EUR', 100);

    final summary = await queries.netWorth(today());

    expect(summary.total, rub(2100));
    expect(summary.byAssetKind[AssetKind.account], rub(1000));
    expect(summary.byAssetKind[AssetKind.investment], rub(900));
    expect(summary.byAssetKind[AssetKind.property], rub(200));
  });

  test('базовая валюта EUR: A→RUB→base', () async {
    await createAccount(db, currencyCode: 'RUB', openingValueMinor: 100000);
    await createInvestment(db, currencyCode: 'USD', openingValueMinor: 1000);
    await createProperty(db, currencyCode: 'EUR', openingValueMinor: 200);
    await saveRate('USD', 90);
    await saveRate('EUR', 100);
    await db.settingsDao.setBaseCurrency('EUR');

    final summary = await queries.netWorth(today());

    expect(summary.total, const Money(minorUnits: 2100, currencyCode: 'EUR'));
    expect(
      summary.byAssetKind[AssetKind.account],
      const Money(minorUnits: 1000, currencyCode: 'EUR'),
    );
    expect(
      summary.byAssetKind[AssetKind.investment],
      const Money(minorUnits: 900, currencyCode: 'EUR'),
    );
    expect(
      summary.byAssetKind[AssetKind.property],
      const Money(minorUnits: 200, currencyCode: 'EUR'),
    );
  });

  test('нет курса базовой валюты — rateUnavailable, не ноль', () async {
    await createAccount(db, currencyCode: 'RUB', openingValueMinor: 100000);
    await db.settingsDao.setBaseCurrency('EUR');

    await expectLater(
      queries.netWorth(today()),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.rateUnavailable,
        ),
      ),
    );
  });

  test(
    'архивный актив входит до даты архивации и выходит с неё (A-6)',
    () async {
      final account = await createAccount(
        db,
        currencyCode: 'RUB',
        openingValueMinor: 100000,
      );
      await db.assetsDao.archive(
        account,
        archivedAt: DateTime.utc(2026, 11, 18, 12),
      );

      final before = await queries.netWorth(LocalDate(2026, 11, 17));
      final after = await queries.netWorth(LocalDate(2026, 11, 18));

      expect(before.total, rub(1000));
      expect(after.total, rub(0));
    },
  );

  test('удалённая операция не участвует в итоге', () async {
    final account = await createAccount(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    final deposit = await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.deposit,
        amountMinor: 50000,
        occurredOn: today(),
        rateToRub: Decimal.one,
        amountRubMinor: 50000,
      ),
    );
    expect((await queries.netWorth(today())).total, rub(1500));

    await db.transactionsDao.softDelete(deposit);

    expect((await queries.netWorth(today())).total, rub(1000));
  });

  test('оценка заменяет opening на дату действия', () async {
    final investment = await createInvestment(
      db,
      currencyCode: 'USD',
      openingValueMinor: 1000,
    );
    await saveRate('USD', 90, onDate: LocalDate(2026, 11, 15));
    await saveRate('USD', 90);
    await db.valuationsDao.create(
      assetId: investment,
      effectiveOn: today(),
      valueMinor: 2000,
      rateToRub: Decimal.fromInt(90),
      valueRubMinor: 180000,
    );

    final summary = await queries.netWorth(today());

    expect(summary.byAssetKind[AssetKind.investment], rub(1800));
  });

  test('сумма категорий равна общему итогу', () async {
    await createAccount(db, currencyCode: 'RUB', openingValueMinor: 333);
    await createInvestment(db, currencyCode: 'USD', openingValueMinor: 111);
    await createProperty(db, currencyCode: 'EUR', openingValueMinor: 7);
    await saveRate('USD', 90);
    await saveRate('EUR', 100);

    final summary = await queries.netWorth(today());
    final kinds = [
      for (final kind in AssetKind.values) summary.byAssetKind[kind]!,
    ];

    expect(
      kinds.fold<int>(0, (sum, value) => sum + value.minorUnits),
      summary.total.minorUnits,
    );
  });

  test('CALC-022: 1000 RUB + 20 USD×90 + 1000 EUR×100 = 102 800 RUB', () async {
    await createAccount(db, currencyCode: 'RUB', openingValueMinor: 100000);
    await createInvestment(db, currencyCode: 'USD', openingValueMinor: 2000);
    await createProperty(db, currencyCode: 'EUR', openingValueMinor: 100000);
    await saveRate('USD', 90);
    await saveRate('EUR', 100);

    expect((await queries.netWorth(today())).total, rub(102800));
  });

  test('операция позже onDate не участвует в историческом итоге', () async {
    final account = await createAccount(
      db,
      currencyCode: 'RUB',
      openingValueMinor: 100000,
    );
    // Актив существовал раньше, чем дата запроса.
    await (db.update(db.assets)..where((a) => a.id.equals(account))).write(
      AssetsCompanion(createdAt: Value(DateTime.utc(2026, 11, 1))),
    );
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.deposit,
        amountMinor: 50000,
        occurredOn: today(),
        rateToRub: Decimal.one,
        amountRubMinor: 50000,
      ),
    );

    final before = await queries.netWorth(LocalDate(2026, 11, 15));
    final after = await queries.netWorth(today());

    expect(before.total, rub(1000));
    expect(after.total, rub(1500));
  });

  test('оценка позже onDate не применяется к историческому итогу', () async {
    final investment = await createInvestment(
      db,
      currencyCode: 'USD',
      openingValueMinor: 1000,
    );
    await (db.update(db.assets)..where((a) => a.id.equals(investment))).write(
      AssetsCompanion(createdAt: Value(DateTime.utc(2026, 11, 1))),
    );
    await saveRate('USD', 90, onDate: LocalDate(2026, 11, 15));
    await saveRate('USD', 90);
    await db.valuationsDao.create(
      assetId: investment,
      effectiveOn: today(),
      valueMinor: 2000,
      rateToRub: Decimal.fromInt(90),
      valueRubMinor: 180000,
    );

    final before = await queries.netWorth(LocalDate(2026, 11, 15));
    final after = await queries.netWorth(today());

    expect(before.byAssetKind[AssetKind.investment], rub(900));
    expect(after.byAssetKind[AssetKind.investment], rub(1800));
  });
}
