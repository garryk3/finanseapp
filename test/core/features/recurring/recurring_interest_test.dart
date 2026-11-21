import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_generator.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RecurringGenerator generator;
  late int bankId;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 4, 20, 12);
    db = AppDatabase(executor: NativeDatabase.memory(), now: () => now);
    bankId = await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
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

  Future<int> deposit({
    int openingValueMinor = 10000000,
    Decimal? annualRate,
    String currencyCode = 'RUB',
    LocalDate? startDate,
    LocalDate? endDate,
  }) => db.assetsDao.create(
    name: 'Вклад',
    kind: AssetKind.account,
    currencyCode: currencyCode,
    openingValueMinor: openingValueMinor,
    account: AccountDetailsCompanion.insert(
      bankId: bankId,
      annualRate: annualRate ?? Decimal.parse('12'),
      startDate: startDate ?? LocalDate(2026, 1, 15),
      endDate: Value(endDate),
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

  Future<int> activeAutoRuleId(int accountId) async {
    final rule = await db.recurringDao.findDepositInterestRule(accountId);
    expect(rule, isNotNull);
    return rule!.id;
  }

  test('CALC-037: капитализация 100 000 под 12% за 3 месяца', () async {
    now = DateTime.utc(2026, 4, 20, 12);
    final account = await deposit();
    final detail = (await db.assetsDao.allAccountDetails()).single;
    expect(detail.annualRate, Decimal.parse('12'));

    final report = await generator.run();

    expect(report.generated, 3);
    expect(report.pending, isEmpty);
    final rule = await db.recurringDao.findDepositInterestRule(account);
    expect(rule, isNotNull);
    expect(rule!.strategy, RecurringStrategy.depositInterest);
    expect(rule.lastGeneratedPeriod, '2026-04');
    final entries = await entriesOf(rule.id);
    expect(entries.map((entry) => entry.occurredOn.toIsoString()), [
      '2026-02-15',
      '2026-03-15',
      '2026-04-15',
    ]);
    expect(entries.map((entry) => entry.amountMinor), [100000, 101000, 102010]);
    expect(entries.map((entry) => entry.affectsBalance), everyElement(isTrue));
    expect(
      entries.map((entry) => entry.assetTransactionId),
      everyElement(isNotNull),
    );
    final category = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(rule.categoryId))).getSingle();
    expect(category.name, 'Проценты по вкладу');
    expect(
      await db.transactionsDao.balanceAsOfMinor(
        account,
        LocalDate(2026, 4, 20),
      ),
      10303010,
    );
    final last = await db.recurringDao.findLastGeneratedEntry(rule.id);
    expect(last?.amountMinor, 102010);
    expect((await generator.run()).generated, 0);
  });

  test('CALC-038: half away from zero', () async {
    now = DateTime.utc(2026, 2, 20, 12);
    final account = await deposit(openingValueMinor: 1050);

    await generator.run();

    final ruleId = await activeAutoRuleId(account);
    final entries = await entriesOf(ruleId);
    expect(entries.single.amountMinor, 11);
  });

  test('CALC-039: endDate включает последний период и останавливает', () async {
    now = DateTime.utc(2026, 4, 20, 12);
    final account = await deposit(endDate: LocalDate(2026, 3, 15));

    final report = await generator.run();

    expect(report.generated, 2);
    final ruleId = await activeAutoRuleId(account);
    final entries = await entriesOf(ruleId);
    expect(entries.map((entry) => entry.occurredOn.toIsoString()), [
      '2026-02-15',
      '2026-03-15',
    ]);
    expect(entries.map((entry) => entry.amountMinor), [100000, 101000]);
    expect(
      await db.transactionsDao.balanceAsOfMinor(
        account,
        LocalDate(2026, 4, 20),
      ),
      10201000,
    );
  });

  test('CALC-040: clamp 31-го числа', () async {
    now = DateTime.utc(2026, 5, 1, 12);
    final account = await deposit(startDate: LocalDate(2026, 1, 31));

    await generator.run();

    final ruleId = await activeAutoRuleId(account);
    final entries = await entriesOf(ruleId);
    expect(entries.map((entry) => entry.occurredOn.toIsoString()), [
      '2026-02-28',
      '2026-03-31',
      '2026-04-30',
    ]);
    expect(entries.map((entry) => entry.amountMinor), [100000, 101000, 102010]);
  });

  test('CALC-041: снятие между начислениями', () async {
    now = DateTime.utc(2026, 3, 20, 12);
    final account = await deposit();
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: account,
        kind: AssetTransactionKind.withdrawal,
        amountMinor: 5000000,
        occurredOn: LocalDate(2026, 1, 20),
        rateToRub: Decimal.one,
        amountRubMinor: 5000000,
      ),
    );

    await generator.run();

    final ruleId = await activeAutoRuleId(account);
    final entries = await entriesOf(ruleId);
    expect(entries.map((entry) => entry.amountMinor), [50000, 50500]);
    expect(
      await db.transactionsDao.balanceAsOfMinor(
        account,
        LocalDate(2026, 3, 20),
      ),
      5100500,
    );
  });

  test('нулевой процент закрывает период без операции', () async {
    now = DateTime.utc(2026, 2, 20, 12);
    final account = await deposit(openingValueMinor: 1);

    final report = await generator.run();

    expect(report.generated, 0);
    final ruleId = await activeAutoRuleId(account);
    expect(await entriesOf(ruleId), isEmpty);
    final rule = await db.recurringDao.getById(ruleId);
    expect(rule.lastGeneratedPeriod, '2026-02');
  });

  test(
    'ставка 0 останавливает, повторное включение восстанавливает маркер',
    () async {
      now = DateTime.utc(2026, 2, 20, 12);
      final account = await deposit();
      await generator.run();
      final firstId = await activeAutoRuleId(account);
      final firstEntries = await entriesOf(firstId);
      expect(firstEntries, hasLength(1));

      await db.customStatement(
        'UPDATE account_details SET annual_rate = ? WHERE asset_id = ?',
        ['0', account],
      );
      await generator.run();
      expect(await db.recurringDao.findDepositInterestRule(account), isNull);
      final deleted = await db.recurringDao.findDepositInterestRule(
        account,
        includeDeleted: true,
      );
      expect(deleted?.id, firstId);
      expect(deleted?.deletedAt, isNotNull);
      expect(await entriesOf(firstId), hasLength(1));

      await db.customStatement(
        'UPDATE account_details SET annual_rate = ? WHERE asset_id = ?',
        ['12', account],
      );
      now = DateTime.utc(2026, 3, 20, 12);
      await generator.run();

      final restored = await db.recurringDao.findDepositInterestRule(account);
      expect(restored, isNotNull);
      expect(restored?.id, firstId);
      expect(restored?.lastGeneratedPeriod, '2026-03');
      final entries = await entriesOf(firstId);
      expect(entries, hasLength(2));
      expect(entries.last.amountMinor, 101000);
    },
  );

  test('архивная категория процентов не создаёт правило', () async {
    now = DateTime.utc(2026, 2, 20, 12);
    await db.customStatement(
      'UPDATE categories SET archived_at = ? '
      "WHERE kind = 'income' AND name = 'Проценты по вкладу'",
      ['2026-01-01T00:00:00.000000Z'],
    );
    final archived = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Проценты по вкладу'))).getSingle();
    expect(archived.archivedAt, isNotNull);
    final account = await deposit();

    final report = await generator.run();

    expect(report.generated, 0);
    expect(report.pending.map((item) => item.reason), [
      RecurringPendingReason.categoryUnavailable,
    ]);
    expect(
      await db.recurringDao.findDepositInterestRule(
        account,
        includeDeleted: true,
      ),
      isNull,
    );
  });

  test('переименование категории останавливает правило и не начисляет после endDate', () async {
    now = DateTime.utc(2026, 4, 20, 12);
    final account = await deposit();
    await generator.run();
    final ruleId = await activeAutoRuleId(account);
    expect(await entriesOf(ruleId), hasLength(3));

    final category = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Проценты по вкладу'))).getSingle();
    await db.referencesDao.renameCategory(category.id, 'Проценты');
    await db.assetsDao.updateAccount(
      assetId: account,
      name: 'Вклад',
      currencyCode: 'RUB',
      openingValueMinor: 10000000,
      bankId: bankId,
      annualRate: Decimal.parse('12'),
      startDate: LocalDate(2026, 1, 15),
      endDate: LocalDate(2026, 3, 15),
    );

    now = DateTime.utc(2026, 6, 20, 12);
    final stopped = await generator.run();

    expect(stopped.generated, 0);
    expect(stopped.pending.map((item) => item.reason), [
      RecurringPendingReason.categoryUnavailable,
    ]);
    expect(await entriesOf(ruleId), hasLength(3));
    final paused = await db.recurringDao.findDepositInterestRule(
      account,
      includeDeleted: true,
    );
    expect(paused?.id, ruleId);
    expect(paused?.deletedAt, isNotNull);

    // Возврат категории восстанавливает ту же строку с новым endDate и
    // сохранённым маркером; после endDate ничего не начисляется.
    await db.referencesDao.renameCategory(category.id, 'Проценты по вкладу');
    final resumed = await generator.run();

    expect(resumed.generated, 0);
    final restored = await db.recurringDao.findDepositInterestRule(account);
    expect(restored?.id, ruleId);
    expect(restored?.endDate, LocalDate(2026, 3, 15));
    expect(restored?.lastGeneratedPeriod, '2026-04');
    expect(await entriesOf(ruleId), hasLength(3));
  });

  test('USD без курса откладывается, после курса капитализируется', () async {
    now = DateTime.utc(2026, 2, 20, 12);
    final account = await deposit(currencyCode: 'USD');

    final deferred = await generator.run();

    expect(deferred.generated, 0);
    expect(deferred.pending.map((item) => item.reason), [
      RecurringPendingReason.rateUnavailable,
    ]);
    final ruleId = await activeAutoRuleId(account);
    expect((await db.recurringDao.getById(ruleId)).lastGeneratedPeriod, isNull);

    await db.currenciesDao.saveRate(
      currencyCode: 'USD',
      date: LocalDate(2026, 2, 15),
      rateToRub: Decimal.parse('90'),
      source: ExchangeRateSource.cbr,
    );
    await generator.run();

    final entries = await entriesOf(ruleId);
    expect(entries, hasLength(1));
    expect(entries.single.amountMinor, 100000);
    expect(entries.single.amountRubMinor, 9000000);
  });

  test('архивный счёт останавливает проценты', () async {
    now = DateTime.utc(2026, 2, 20, 12);
    final account = await deposit();
    await generator.run();
    final ruleId = await activeAutoRuleId(account);
    expect(await entriesOf(ruleId), hasLength(1));

    await db.assetsDao.archive(account);
    await generator.run();

    expect(await db.recurringDao.findDepositInterestRule(account), isNull);
    final stopped = await db.recurringDao.findDepositInterestRule(
      account,
      includeDeleted: true,
    );
    expect(stopped?.id, ruleId);
    expect(stopped?.deletedAt, isNotNull);
    expect(await entriesOf(ruleId), hasLength(1));
  });

  test('Money в правиле процентов отсутствует', () async {
    now = DateTime.utc(2026, 2, 20, 12);
    final account = await deposit();
    await generator.run();
    final rule = await db.recurringDao.findDepositInterestRule(account);

    expect(rule?.amountMinor, isNull);
    expect(rule?.kind, CashflowKind.income);
    expect(rule?.accountId, account);
    expect(rule?.affectsBalance, isTrue);
  });
}
