import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/recurring_dao.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/cashflow/data/cashflow_repository_impl.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_generator.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late RecurringGenerator generator;

  setUp(() {
    now = DateTime.utc(2026, 11, 17, 12);
    db = AppDatabase(executor: NativeDatabase.memory(), now: () => now);
    generator = RecurringGenerator(
      db: db,
      rateRepository: ExchangeRateRepositoryImpl(
        db.currenciesDao,
        CbrExchangeRateClient(),
      ),
      currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> createRule({
    CashflowKind kind = CashflowKind.expense,
    int amountMinor = 100000,
    String currencyCode = 'RUB',
    int? accountId,
    int? propertyId,
    bool affectsBalance = false,
    required LocalDate startDate,
    LocalDate? endDate,
  }) async => db.recurringDao.create(
    RecurringRuleInput(
      strategy: RecurringStrategy.fixed,
      kind: kind,
      categoryId: await categoryId(db, kind),
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      accountId: accountId,
      propertyId: propertyId,
      affectsBalance: affectsBalance,
      startDate: startDate,
      endDate: endDate,
    ),
  );

  Future<List<CashflowEntryRow>> entriesOf(int ruleId) async {
    final rows = await (db.select(
      db.cashflowEntries,
    )..where((e) => e.recurringRuleId.equals(ruleId))).get();
    return rows..sort((a, b) {
      final byDate = a.occurredOn.compareTo(b.occurredOn);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
  }

  int balanceOf(AssetRow asset, List<AssetTransactionRow> transactions) {
    var balance = asset.openingValueMinor;
    for (final transaction in transactions) {
      balance += switch (transaction.kind) {
        AssetTransactionKind.deposit ||
        AssetTransactionKind.transferIn => transaction.amountMinor,
        AssetTransactionKind.withdrawal ||
        AssetTransactionKind.transferOut => -transaction.amountMinor,
      };
    }
    return balance;
  }

  test('расход по недвижимости: догон, маркер и идемпотентность', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2026, 9, 15),
    );

    final report = await generator.run();

    expect(report.generated, 3);
    expect(report.pending, isEmpty);
    final entries = await entriesOf(ruleId);
    expect(entries.map((entry) => entry.occurredOn.toIsoString()), [
      '2026-09-15',
      '2026-10-15',
      '2026-11-15',
    ]);
    expect(entries.map((entry) => entry.revisionNo), [1, 1, 1]);
    expect(entries.map((entry) => entry.propertyId), everyElement(property));
    expect(entries.map((entry) => entry.affectsBalance), everyElement(isFalse));
    expect(
      entries.map((entry) => entry.assetTransactionId),
      everyElement(isNull),
    );
    expect(
      (await db.recurringDao.getById(ruleId)).lastGeneratedPeriod,
      '2026-11',
    );

    final revisions = await db.select(db.cashflowEntryRevisions).get();
    expect(revisions, hasLength(3));

    final again = await generator.run();
    expect(again.generated, 0);
    expect(await entriesOf(ruleId), hasLength(3));
  });

  test('доход со счётом создаёт связанную пару и увеличивает баланс', () async {
    final account = await createAccount(db, name: 'Вклад');
    final ruleId = await createRule(
      kind: CashflowKind.income,
      accountId: account,
      affectsBalance: true,
      startDate: LocalDate(2026, 9, 15),
    );

    final report = await generator.run();

    expect(report.generated, 3);
    final entries = await entriesOf(ruleId);
    expect(
      entries.map((entry) => entry.assetTransactionId),
      everyElement(isNotNull),
    );
    expect(entries.map((entry) => entry.accountId), everyElement(account));
    final transactions = await (db.select(
      db.assetTransactions,
    )..where((t) => t.assetId.equals(account))).get();
    expect(transactions, hasLength(3));
    expect(
      transactions.map((t) => t.kind),
      everyElement(AssetTransactionKind.deposit),
    );
    expect(
      balanceOf(await db.assetsDao.getById(account), transactions),
      300000,
    );
  });

  test('расход со счёта без средств: pending, маркер не двигается', () async {
    final account = await createAccount(db);
    final ruleId = await createRule(
      accountId: account,
      affectsBalance: true,
      startDate: LocalDate(2026, 9, 15),
    );

    final report = await generator.run();

    expect(report.generated, 0);
    expect(report.pending.map((item) => item.reason), [
      RecurringPendingReason.negativeBalance,
    ]);
    expect(await entriesOf(ruleId), isEmpty);
    expect(await db.select(db.assetTransactions).get(), isEmpty);
    expect((await db.recurringDao.getById(ruleId)).lastGeneratedPeriod, isNull);
  });

  test('USD без курса откладывается, после курса генерируется', () async {
    final account = await createAccount(
      db,
      name: 'Валютный',
      currencyCode: 'USD',
    );
    final ruleId = await createRule(
      kind: CashflowKind.income,
      currencyCode: 'USD',
      accountId: account,
      affectsBalance: true,
      startDate: LocalDate(2026, 9, 15),
    );

    final deferred = await generator.run();

    expect(deferred.generated, 0);
    expect(deferred.pending.map((item) => item.reason), [
      RecurringPendingReason.rateUnavailable,
    ]);
    expect((await db.recurringDao.getById(ruleId)).lastGeneratedPeriod, isNull);

    for (final month in [9, 10, 11]) {
      await db.currenciesDao.saveRate(
        currencyCode: 'USD',
        date: LocalDate(2026, month, 15),
        rateToRub: Decimal.parse('90'),
        source: ExchangeRateSource.cbr,
      );
    }

    final report = await generator.run();

    expect(report.generated, 3);
    final entries = await entriesOf(ruleId);
    expect(entries, hasLength(3));
    expect(entries.map((entry) => entry.amountRubMinor), everyElement(9000000));
  });

  test('RUB-правило работает без курсов в БД', () async {
    final property = await createProperty(db);
    await createRule(propertyId: property, startDate: LocalDate(2026, 9, 15));

    final report = await generator.run();

    expect(report.generated, 3);
    expect(await db.select(db.exchangeRates).get(), isEmpty);
  });

  test('удалённая пользователем операция не пересоздаётся', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2026, 9, 15),
    );
    await generator.run();
    final entries = await entriesOf(ruleId);
    await db.cashflowDao.softDelete(entries[1].id);
    await db.recurringDao.updateLastGeneratedPeriod(ruleId, '2026-09');

    final report = await generator.run();

    expect(report.generated, 0);
    final after = await entriesOf(ruleId);
    expect(after, hasLength(3));
    expect(after.where((entry) => entry.deletedAt == null), hasLength(2));
    expect(
      (await db.recurringDao.getById(ruleId)).lastGeneratedPeriod,
      '2026-11',
    );
  });

  test('архивный объект останавливает правило', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2026, 9, 15),
    );
    await db.assetsDao.archive(property);

    final report = await generator.run();

    expect(report.generated, 0);
    expect(report.pending.map((item) => item.reason), [
      RecurringPendingReason.assetArchived,
    ]);
    expect(await entriesOf(ruleId), isEmpty);
    expect((await db.recurringDao.getById(ruleId)).lastGeneratedPeriod, isNull);
  });

  test('архивная категория останавливает правило', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2026, 9, 15),
    );
    final rule = await db.recurringDao.getById(ruleId);
    await db.customStatement(
      'UPDATE categories SET archived_at = ? WHERE id = ?',
      ['2026-01-01T00:00:00.000000Z', rule.categoryId],
    );

    final report = await generator.run();

    expect(report.generated, 0);
    expect(report.pending.map((item) => item.reason), [
      RecurringPendingReason.categoryUnavailable,
    ]);
    expect(await entriesOf(ruleId), isEmpty);
  });

  test('удалённое правило не генерирует', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2026, 9, 15),
    );
    await db.recurringDao.softDelete(ruleId);

    final report = await generator.run();

    expect(report.generated, 0);
    expect(report.pending, isEmpty);
    expect(await entriesOf(ruleId), isEmpty);
  });

  test('правка суммы влияет только на будущие периоды', () async {
    final property = await createProperty(db);
    final category = await categoryId(db, CashflowKind.expense);
    now = DateTime.utc(2026, 9, 20, 12);
    final ruleId = await createRule(
      propertyId: property,
      amountMinor: 100000,
      startDate: LocalDate(2026, 9, 15),
    );
    await generator.run();

    await db.recurringDao.revise(
      ruleId,
      RecurringRuleInput(
        strategy: RecurringStrategy.fixed,
        kind: CashflowKind.expense,
        categoryId: category,
        amountMinor: 200000,
        currencyCode: 'RUB',
        propertyId: property,
        affectsBalance: false,
        startDate: LocalDate(2026, 9, 15),
      ),
    );
    now = DateTime.utc(2026, 10, 20, 12);
    final report = await generator.run();

    expect(report.generated, 1);
    final entries = await entriesOf(ruleId);
    expect(entries.map((entry) => entry.occurredOn.toIsoString()), [
      '2026-09-15',
      '2026-10-15',
    ]);
    expect(entries.map((entry) => entry.amountMinor), [100000, 200000]);
  });

  test('долгое отсутствие: 83 периода и корректный маркер', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2020, 1, 15),
    );

    final report = await generator.run();

    expect(report.generated, 83);
    final entries = await entriesOf(ruleId);
    expect(entries, hasLength(83));
    expect(entries.first.occurredOn, LocalDate(2020, 1, 15));
    expect(entries.last.occurredOn, LocalDate(2026, 11, 15));
    expect(
      (await db.recurringDao.getById(ruleId)).lastGeneratedPeriod,
      '2026-11',
    );
  });

  test('31-е число в долгом отсутствии clamp-ится и не даёт ноябрь', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2020, 1, 31),
    );

    final report = await generator.run();

    expect(report.generated, 82);
    final entries = await entriesOf(ruleId);
    expect(entries[1].occurredOn, LocalDate(2020, 2, 29));
    expect(entries.last.occurredOn, LocalDate(2026, 10, 31));
    expect(
      (await db.recurringDao.getById(ruleId)).lastGeneratedPeriod,
      '2026-10',
    );
  });

  test('CashflowRepository видит автооперацию с recurringRuleId', () async {
    final property = await createProperty(db);
    final ruleId = await createRule(
      propertyId: property,
      startDate: LocalDate(2026, 11, 1),
    );
    await generator.run();

    final repository = CashflowRepositoryImpl(
      db.cashflowDao,
      db.currenciesDao,
      db,
    );
    final entries = await repository.watch(CashflowFilter()).first;

    expect(entries, hasLength(1));
    expect(entries.single.recurringRuleId, ruleId);
  });
}
