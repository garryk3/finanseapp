import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/recurring/data/recurring_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late RecurringRepositoryImpl repository;

  setUp(() {
    db = openTestDatabase();
    repository = RecurringRepositoryImpl(db.recurringDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('create/watchActive маппят Money и стратегию', () async {
    final category = await categoryId(db, CashflowKind.expense);
    final property = await createProperty(db);
    final id = await repository.create(
      RecurringRuleDraft(
        strategy: RecurringStrategy.fixed,
        kind: CashflowKind.expense,
        categoryId: category,
        amount: const Money(minorUnits: 250000, currencyCode: 'RUB'),
        currencyCode: 'RUB',
        propertyId: property,
        affectsBalance: false,
        startDate: LocalDate(2026, 1, 15),
        comment: 'Содержание',
      ),
    );

    final rules = await repository.watchActive().first;
    expect(rules, hasLength(1));
    expect(rules.single.id, id);
    expect(
      rules.single.amount,
      const Money(minorUnits: 250000, currencyCode: 'RUB'),
    );
    expect(rules.single.strategy, RecurringStrategy.fixed);
    expect(rules.single.lastGeneratedPeriod, isNull);

    final byProperty = await repository.watchByProperty(property).first;
    expect(byProperty.single.id, id);
  });

  test('revise и softDelete через repository', () async {
    final category = await categoryId(db, CashflowKind.expense);
    final property = await createProperty(db);
    final id = await repository.create(
      RecurringRuleDraft(
        strategy: RecurringStrategy.fixed,
        kind: CashflowKind.expense,
        categoryId: category,
        amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
        currencyCode: 'RUB',
        propertyId: property,
        affectsBalance: false,
        startDate: LocalDate(2026, 1, 15),
      ),
    );

    await repository.revise(
      id,
      RecurringRuleDraft(
        strategy: RecurringStrategy.fixed,
        kind: CashflowKind.expense,
        categoryId: category,
        amount: const Money(minorUnits: 300000, currencyCode: 'RUB'),
        currencyCode: 'RUB',
        propertyId: property,
        affectsBalance: false,
        startDate: LocalDate(2026, 1, 15),
      ),
    );
    expect(
      (await repository.getById(id)).amount,
      const Money(minorUnits: 300000, currencyCode: 'RUB'),
    );

    await repository.softDelete(id);
    expect(await repository.watchActive().first, isEmpty);
    expect((await repository.getById(id)).deletedAt, isNotNull);
  });
}
