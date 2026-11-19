import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/goals/data/goal_repository_impl.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late GoalRepositoryImpl repository;

  setUp(() {
    db = openTestDatabase();
    repository = GoalRepositoryImpl(db.goalsDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> account(String name) => createAccount(db, name: name);

  Future<int> investment(String name) => createInvestment(db, name: name);

  GoalDraft draft({
    GoalCategory category = GoalCategory.accounts,
    Set<int>? assetIds,
    int target = 1000000,
    String name = 'Цель',
    LocalDate? targetDate,
  }) => GoalDraft(
    name: name,
    category: category,
    targetAmount: Money(minorUnits: target, currencyCode: 'RUB'),
    assetIds: assetIds ?? {},
    targetDate: targetDate,
  );

  test('accounts goal принимает два счёта', () async {
    final first = await account('А');
    final second = await account('Б');
    final id = await repository.create(draft(assetIds: {first, second}));

    final goal = await repository.getById(id);
    expect(goal.category, GoalCategory.accounts);
    expect(goal.assetIds, {first, second});
    expect(goal.targetAmount.minorUnits, 1000000);
  });

  test('accounts отклоняет инвестицию, investments — счёт', () async {
    final acc = await account('А');
    final inv = await investment('И');

    await expectLater(
      repository.create(draft(assetIds: {inv})),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.create(
        draft(category: GoalCategory.investments, assetIds: {acc}),
      ),
      throwsA(isA<DomainException>()),
    );
  });

  test('пустые активы и нулевая сумма отклоняются', () async {
    await expectLater(
      repository.create(draft()),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.create(draft(target: 0)),
      throwsA(isA<DomainException>()),
    );
  });

  test('архивный привязанный актив сохраняет связь', () async {
    final acc = await account('А');
    final id = await repository.create(draft(assetIds: {acc}));
    await db.assetsDao.archive(acc);

    final goal = await repository.getById(id);
    expect(goal.assetIds, {acc});
  });

  test('closed не удаляет цель, soft delete скрывает из списка', () async {
    final acc = await account('А');
    final id = await repository.create(draft(assetIds: {acc}));

    await repository.setStatus(id, GoalStatus.closed);
    expect((await repository.getById(id)).status, GoalStatus.closed);
    expect(await repository.watchAll().first, hasLength(1));

    await repository.softDelete(id);
    expect(await repository.watchAll().first, isEmpty);
  });

  test('update меняет цель и связи', () async {
    final first = await account('А');
    final second = await account('Б');
    final id = await repository.create(draft(assetIds: {first}));

    await repository.update(
      id,
      draft(assetIds: {second}, target: 2000000, name: 'Новая цель'),
    );

    final goal = await repository.getById(id);
    expect(goal.name, 'Новая цель');
    expect(goal.targetAmount.minorUnits, 2000000);
    expect(goal.assetIds, {second});
  });

  test('дата цели в прошлом отклоняется при создании (BR-G-6)', () async {
    final acc = await account('А');
    final today = db.today();
    final yesterday = LocalDate.fromDateTime(
      DateTime.utc(
        today.year,
        today.month,
        today.day,
      ).subtract(const Duration(days: 1)),
    );

    await expectLater(
      repository.create(draft(assetIds: {acc}, targetDate: yesterday)),
      throwsA(
        isA<DomainException>().having(
          (error) => error.fieldErrors['targetDate'],
          'targetDate',
          'validationGoalDateInPast',
        ),
      ),
    );
  });

  test('setStatus не меняет soft-deleted цель', () async {
    final acc = await account('А');
    final id = await repository.create(draft(assetIds: {acc}));
    await repository.softDelete(id);

    await expectLater(
      repository.setStatus(id, GoalStatus.closed),
      throwsA(isA<DomainException>()),
    );
  });
}
