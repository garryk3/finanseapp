import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/data/cashflow_repository_impl.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class FakeCurrencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub];

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(
    String code,
    String name,
    int fractionDigits,
  ) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class FakeRates implements ExchangeRateRepository {
  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async => null;

  @override
  Future<ExchangeRate?> findLatestOnOrBefore(
    String currencyCode,
    LocalDate date,
  ) async => null;

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw const DomainException(DomainErrorCode.rateUnavailable);

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => throw const DomainException(DomainErrorCode.validation);
}

void main() {
  late AppDatabase db;
  late CashflowRepositoryImpl repository;
  late CashflowCommands commands;
  late int expenseCategoryId;
  late int accountId;

  setUp(() async {
    db = openTestDatabase();
    repository = CashflowRepositoryImpl(db.cashflowDao, db.currenciesDao, db);
    commands = CashflowCommands(
      repository: repository,
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
      today: LocalDate(2026, 1, 3),
      db: db,
    );
    expenseCategoryId = (await db.select(db.categories).get())
        .firstWhere((row) => row.kind == CashflowKind.expense)
        .id;
    accountId = await createAccount(db, openingValueMinor: 10000);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Result<int>> save({
    int? id,
    int amount = 10000,
    int? account,
    bool affects = false,
  }) => commands.save(
    id: id,
    kind: CashflowKind.expense,
    categoryId: expenseCategoryId,
    amount: Money(minorUnits: amount, currencyCode: 'RUB'),
    occurredOn: LocalDate(2026, 1, 2),
    accountId: account,
    affectsBalance: affects,
    comment: 'Ремонт',
  );

  test('linked-расход создаёт пару и не дублирует итоги', () async {
    final result = await save(account: accountId, affects: true);
    final entryId = (result as Success<int>).value;

    final entry = await repository.getById(entryId);
    expect(entry.affectsBalance, isTrue);
    expect(entry.accountId, accountId);
    expect(entry.assetTransactionId, isNotNull);
    final transactions = await db.transactionsDao.allRows();
    expect(transactions, hasLength(1));
    expect(transactions.single.kind.name, 'withdrawal');

    final entries = await repository.watch(const CashflowFilter()).first;
    expect(entries, hasLength(1));
  });

  test('нехватка баланса откатывает обе записи', () async {
    final result = await save(amount: 10001, account: accountId, affects: true);

    expect(result, isA<Failure<int>>());
    expect(await db.select(db.cashflowEntries).get(), isEmpty);
    expect(await db.transactionsDao.allRows(), isEmpty);
  });

  test('off→on создаёт операцию и связывает существующую запись', () async {
    final created = await save(amount: 5000);
    final entryId = (created as Success<int>).value;

    final result = await save(
      id: entryId,
      amount: 5000,
      account: accountId,
      affects: true,
    );
    expect(result, isA<Success<int>>());

    final entry = await repository.getById(entryId);
    expect(entry.affectsBalance, isTrue);
    expect(entry.assetTransactionId, isNotNull);
    expect(entry.revisionNo, 2);
    expect(await db.transactionsDao.allRows(), hasLength(1));
  });

  test('правка связанной пары обновляет обе стороны', () async {
    final created = await save(amount: 5000, account: accountId, affects: true);
    final entryId = (created as Success<int>).value;
    final txId = (await repository.getById(entryId)).assetTransactionId!;

    final result = await save(
      id: entryId,
      amount: 7000,
      account: accountId,
      affects: true,
    );
    expect(result, isA<Success<int>>());

    final entry = await repository.getById(entryId);
    expect(entry.amount.minorUnits, 7000);
    expect(entry.revisionNo, 2);
    final tx = await db.transactionsDao.getById(txId);
    expect(tx.amountMinor, 7000);
    expect(tx.revisionNo, 2);
  });

  test('on→off мягко удаляет операцию и снимает связь', () async {
    final created = await save(amount: 5000, account: accountId, affects: true);
    final entryId = (created as Success<int>).value;

    final result = await save(id: entryId, amount: 5000);
    expect(result, isA<Success<int>>());

    final entry = await repository.getById(entryId);
    expect(entry.affectsBalance, isFalse);
    expect(entry.assetTransactionId, isNull);
    expect(entry.revisionNo, 2);
    final active = await db.transactionsDao.watchByAsset(accountId).first;
    expect(active, isEmpty);
    final all = await db.transactionsDao.allRows();
    expect(all.single.deletedAt, isNotNull);
  });

  test('restore связанной пары восстанавливает обе записи', () async {
    final created = await save(amount: 5000, account: accountId, affects: true);
    final entryId = (created as Success<int>).value;
    final txId = (await repository.getById(entryId)).assetTransactionId!;
    await commands.delete(entryId);

    await repository.restore(entryId);

    expect((await repository.getById(entryId)).deletedAt, isNull);
    final cashflowRevisions = await db.cashflowDao.revisions(entryId);
    expect(cashflowRevisions.last.action.name, 'restore');
    final txRevisions = await db.transactionsDao.revisions(txId);
    expect(txRevisions.last.action.name, 'restore');
  });

  test('удаление пары создаёт delete-ревизии обеим', () async {
    final created = await save(amount: 5000, account: accountId, affects: true);
    final entryId = (created as Success<int>).value;
    final txId = (await repository.getById(entryId)).assetTransactionId!;

    final result = await commands.delete(entryId);
    expect(result, isA<Success<void>>());

    final cashflowRevisions = await db.cashflowDao.revisions(entryId);
    expect(cashflowRevisions.last.action.name, 'delete');
    final txRevisions = await db.transactionsDao.revisions(txId);
    expect(txRevisions.last.action.name, 'delete');
    expect(await repository.watch(const CashflowFilter()).first, isEmpty);
  });
}
