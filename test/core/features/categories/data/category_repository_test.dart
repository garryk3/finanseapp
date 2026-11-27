import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/data/category_repository_impl.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl repository;

  setUp(() {
    db = openTestDatabase();
    repository = CategoryRepositoryImpl(db.referencesDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> createEntry(int categoryId) => db.cashflowDao.create(
    CashflowEntryInput(
      kind: CashflowKind.expense,
      categoryId: categoryId,
      amountMinor: 100,
      currencyCode: 'RUB',
      occurredOn: LocalDate(2026, 1, 10),
      rateToRub: Decimal.one,
      amountRubMinor: 100,
      affectsBalance: false,
    ),
  );

  test(
    'одинаковое имя income/expense разрешено, duplicate внутри kind — нет',
    () async {
      await repository.create(
        const CashflowCategoryDraft(
          kind: CashflowKind.expense,
          name: 'Подписки',
        ),
      );
      await expectLater(
        repository.create(
          const CashflowCategoryDraft(
            kind: CashflowKind.income,
            name: 'Подписки',
          ),
        ),
        completes,
      );
      await expectLater(
        repository.create(
          const CashflowCategoryDraft(
            kind: CashflowKind.expense,
            name: '  подписки ',
          ),
        ),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.conflict,
          ),
        ),
      );
    },
  );

  test('предустановленная категория редактируется', () async {
    final salary = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Зарплата'))).getSingle();
    final category = CashflowCategory(
      id: salary.id,
      kind: salary.kind,
      name: 'Оклад',
      isPreset: true,
    );

    await repository.update(category);

    final list = await repository.watchByKind(CashflowKind.income).first;
    expect(list.firstWhere((c) => c.id == salary.id).name, 'Оклад');
  });

  test(
    'архивная категория скрыта по умолчанию и видна с includeArchived',
    () async {
      final id = await repository.create(
        const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Тест'),
      );
      await repository.archive(id);

      final active = await repository.watchByKind(CashflowKind.expense).first;
      final all = await repository
          .watchByKind(CashflowKind.expense, includeArchived: true)
          .first;

      expect(active.any((category) => category.id == id), isFalse);
      expect(all.any((category) => category.id == id), isTrue);
    },
  );

  test('перенос 10 записей и удаление одной транзакцией', () async {
    final source = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Источник'),
    );
    final target = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Цель'),
    );
    for (var i = 0; i < 10; i++) {
      await createEntry(source);
    }

    await repository.moveEntriesAndDelete(source, target);

    expect(await repository.countEntries(source), 0);
    expect(await repository.countEntries(target), 10);
    final list = await repository.watchByKind(CashflowKind.expense).first;
    expect(list.map((category) => category.id), contains(target));
    expect(list.map((category) => category.id), isNot(contains(source)));
  });

  test('перенос включает soft-deleted записи', () async {
    final source = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Источник'),
    );
    final target = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Цель'),
    );
    final first = await createEntry(source);
    await createEntry(source);
    await createEntry(source);
    await db.cashflowDao.softDelete(first);

    await repository.moveEntriesAndDelete(source, target);

    expect(await repository.countEntries(target), 3);
    expect(await repository.countEntries(source), 0);
  });

  test('cross-kind и same-target переносы отклоняются', () async {
    final source = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'A'),
    );
    final income = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.income, name: 'B'),
    );

    await expectLater(
      repository.moveEntriesAndDelete(source, income),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.moveEntriesAndDelete(source, source),
      throwsA(isA<DomainException>()),
    );
  });

  test('сбой удаления откатывает перенос записей', () async {
    final source = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Источник'),
    );
    final target = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Цель'),
    );
    await createEntry(source);
    await db.customStatement(
      'CREATE TRIGGER test_blocks_delete BEFORE DELETE ON categories '
      "BEGIN SELECT RAISE(ABORT, 'blocked'); END",
    );

    await expectLater(
      repository.moveEntriesAndDelete(source, target),
      throwsA(isA<Exception>()),
    );
    await db.customStatement('DROP TRIGGER test_blocks_delete');

    expect(await repository.countEntries(source), 1);
    expect(await repository.countEntries(target), 0);
  });

  test('используемую категорию нельзя физически удалить', () async {
    final id = await repository.create(
      const CashflowCategoryDraft(kind: CashflowKind.expense, name: 'Занятая'),
    );
    await createEntry(id);

    await expectLater(
      repository.deleteIfUnused(id),
      throwsA(isA<DomainException>()),
    );
  });

  test('findActiveIdByName находит активную и игнорирует архив', () async {
    final salary = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Зарплата'))).getSingle();

    expect(
      await repository.findActiveIdByName('Зарплата', CashflowKind.income),
      salary.id,
    );

    await repository.archive(salary.id);

    expect(
      await repository.findActiveIdByName('Зарплата', CashflowKind.income),
      isNull,
    );
  });

  test('findActiveIdByName нормализует имя и различает вид', () async {
    expect(
      await repository.findActiveIdByName('  зарплата ', CashflowKind.income),
      isNotNull,
    );
    expect(
      await repository.findActiveIdByName('Зарплата', CashflowKind.expense),
      isNull,
    );
  });
}
