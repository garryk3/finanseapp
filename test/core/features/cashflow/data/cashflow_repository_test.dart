import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/data/cashflow_repository_impl.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_calculator.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/categories/data/category_repository_impl.dart';
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
  late int incomeCategoryId;
  late int expenseCategoryId;

  setUp(() async {
    db = openTestDatabase();
    repository = CashflowRepositoryImpl(db.cashflowDao, db.currenciesDao);
    commands = CashflowCommands(
      repository: repository,
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
      today: LocalDate(2026, 1, 3),
    );
    final categories = await db.select(db.categories).get();
    incomeCategoryId = categories
        .firstWhere((row) => row.kind == CashflowKind.income)
        .id;
    expenseCategoryId = categories
        .firstWhere((row) => row.kind == CashflowKind.expense)
        .id;
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> saveIncome({
    int amount = 10000000,
    String? comment,
    LocalDate? date,
    int? id,
  }) async {
    final result = await commands.save(
      id: id,
      kind: CashflowKind.income,
      categoryId: incomeCategoryId,
      amount: Money(minorUnits: amount, currencyCode: 'RUB'),
      occurredOn: date ?? LocalDate(2026, 1, 2),
      comment: comment,
    );
    expect(result, isA<Success<int>>());
    return (result as Success<int>).value;
  }

  test('доход 100000 RUB: snapshot и отсутствие asset tx', () async {
    final id = await saveIncome(amount: 10000000, comment: 'Зарплата');

    final entry = await repository.getById(id);
    expect(entry.kind, CashflowKind.income);
    expect(entry.amount.minorUnits, 10000000);
    expect(entry.amountRub.minorUnits, 10000000);
    expect(entry.affectsBalance, isFalse);
    expect(entry.accountId, isNull);
    expect(await db.transactionsDao.allRows(), isEmpty);
    expect(await db.cashflowDao.revisions(id), hasLength(1));
  });

  test('расход 250,50 RUB сохраняет точные минорные единицы', () async {
    final result = await commands.save(
      kind: CashflowKind.expense,
      categoryId: expenseCategoryId,
      amount: const Money(minorUnits: 25050, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
    );
    final id = (result as Success<int>).value;
    expect((await repository.getById(id)).amount.minorUnits, 25050);
  });

  test('вид и категория должны совпадать', () async {
    final result = await commands.save(
      kind: CashflowKind.expense,
      categoryId: incomeCategoryId,
      amount: const Money(minorUnits: 100, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
    );
    expect(result, isA<Failure<int>>());
    expect(await db.select(db.cashflowEntries).get(), isEmpty);
  });

  test('нулевая/будущая сумма и архивная категория отклоняются', () async {
    final zero = await commands.save(
      kind: CashflowKind.income,
      categoryId: incomeCategoryId,
      amount: const Money(minorUnits: 0, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
    );
    expect(zero, isA<Failure<int>>());

    final future = await commands.save(
      kind: CashflowKind.income,
      categoryId: incomeCategoryId,
      amount: const Money(minorUnits: 100, currencyCode: 'RUB'),
      occurredOn: LocalDate(2030, 1, 1),
    );
    expect(future, isA<Failure<int>>());

    await db.referencesDao.archiveCategory(incomeCategoryId);
    final archived = await commands.save(
      kind: CashflowKind.income,
      categoryId: incomeCategoryId,
      amount: const Money(minorUnits: 100, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
    );
    expect(archived, isA<Failure<int>>());
  });

  test('правка увеличивает ревизию и обновляет snapshot', () async {
    final id = await saveIncome(amount: 10000000, comment: '  ');
    expect((await repository.getById(id)).comment, isNull);

    final result = await commands.save(
      id: id,
      kind: CashflowKind.income,
      categoryId: incomeCategoryId,
      amount: const Money(minorUnits: 20000000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
      comment: 'Обновлено',
    );
    expect(result, isA<Success<int>>());

    final entry = await repository.getById(id);
    expect(entry.revisionNo, 2);
    expect(entry.amount.minorUnits, 20000000);
    expect(entry.comment, 'Обновлено');
    expect(await db.cashflowDao.revisions(id), hasLength(2));
  });

  test('удалённая запись исчезает из журнала, ревизия остаётся', () async {
    final id = await saveIncome();
    await commands.delete(id);

    expect(await repository.watch(const CashflowFilter()).first, isEmpty);
    expect(await db.cashflowDao.revisions(id), hasLength(2));
    expect(await db.transactionsDao.allRows(), isEmpty);
  });

  test('editing сохраняет propertyId записи', () async {
    final propertyId = await createProperty(db);
    final id = await repository.create(
      CashflowEntryDraft(
        kind: CashflowKind.expense,
        categoryId: expenseCategoryId,
        amount: const Money(minorUnits: 10000, currencyCode: 'RUB'),
        occurredOn: LocalDate(2026, 1, 2),
        rateToRub: Decimal.one,
        affectsBalance: false,
        propertyId: propertyId,
      ),
    );
    final form = CashflowFormViewModel(
      repository: repository,
      categoryRepository: CategoryRepositoryImpl(db.referencesDao),
      currencyRepository: FakeCurrencies(),
      commands: commands,
      editingId: id,
    );
    await form.load();

    final result = await form.save(
      kind: CashflowKind.expense,
      categoryId: expenseCategoryId,
      amount: const Money(minorUnits: 20000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
    );

    expect(result, isA<Success<int>>());
    final entry = await repository.getById(id);
    expect(entry.propertyId, propertyId);
    expect(entry.amount.minorUnits, 20000);
  });

  test('итоги считают доходы и расходы в RUB', () async {
    await saveIncome(amount: 10000000);
    await commands.save(
      kind: CashflowKind.expense,
      categoryId: expenseCategoryId,
      amount: const Money(minorUnits: 25050, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
    );

    final entries = await repository.watch(const CashflowFilter()).first;
    final totals = CashflowCalculator.totals(entries);
    expect(totals.income.minorUnits, 10000000);
    expect(totals.expense.minorUnits, 25050);
    expect(totals.net.minorUnits, 9974950);
  });
}
