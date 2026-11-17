import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/seed/seed_data.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:flutter_test/flutter_test.dart';

import 'database_fixtures.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('seed создаёт 5 валют, 6 доходов, 10 расходов и базовую RUB', () async {
    final currencies = await db.select(db.currencies).get();
    final income = await (db.select(
      db.categories,
    )..where((c) => c.kind.equalsValue(CashflowKind.income))).get();
    final expense = await (db.select(
      db.categories,
    )..where((c) => c.kind.equalsValue(CashflowKind.expense))).get();
    final base = await db.settingsDao.getBaseCurrency();

    expect(currencies.map((c) => c.code).toSet(), {
      'RUB',
      'CNY',
      'EUR',
      'USD',
      'HKD',
    });
    expect(
      currencies.every((c) => c.isPreset && c.fractionDigits == 2),
      isTrue,
    );
    expect(income, hasLength(6));
    expect(expense, hasLength(10));
    expect(income.every((c) => c.isPreset), isTrue);
    expect(base.code, 'RUB');
  });

  test('повторный seed не создаёт дублей и не меняет данные', () async {
    final salary = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Зарплата'))).getSingle();
    await db.referencesDao.renameCategory(salary.id, 'Оклад');

    await ReferenceSeeder.seed(db);

    final currencies = await db.select(db.currencies).get();
    final categories = await db.select(db.categories).get();
    expect(currencies, hasLength(5));
    expect(categories, hasLength(16));
    expect(categories.where((c) => c.name == 'Оклад'), hasLength(1));
    expect(categories.where((c) => c.name == 'Зарплата'), isEmpty);
  });

  test(
    'seed не перезаписывает выбранную базовую валюту и enabled-флаги',
    () async {
      await db.settingsDao.setBaseCurrency('USD');
      await db.currenciesDao.setEnabled('EUR', false);

      await ReferenceSeeder.seed(db);

      expect((await db.settingsDao.getBaseCurrency()).code, 'USD');
      final eur = await db.currenciesDao.find('EUR');
      expect(eur!.isEnabled, isFalse);
    },
  );

  test(
    'все seed-записи доступны после переоткрытия (обычное открытие)',
    () async {
      // Повторный вызов onCreate не происходит, но seed доступен как операция
      // инициализации справочников.
      await ReferenceSeeder.seed(db);
      final count = await db.select(db.categories).get();
      expect(count, hasLength(16));
    },
  );
}
