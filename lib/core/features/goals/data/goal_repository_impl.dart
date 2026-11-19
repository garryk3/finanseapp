import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/goals_dao.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';

/// Цели и явные связи с активами (8.1).
final class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._dao);

  final GoalsDao _dao;

  @override
  Stream<List<FinancialGoal>> watchAll() => _dao.watchAll().asyncMap(
    (rows) async => [for (final row in rows) await _map(row)],
  );

  @override
  Future<FinancialGoal> getById(int id) async => _map(await _dao.getById(id));

  @override
  Future<int> create(GoalDraft draft) => _dao.create(
    name: draft.name,
    category: draft.category,
    targetAmountMinor: draft.targetAmount.minorUnits,
    currencyCode: draft.targetAmount.currencyCode,
    assetIds: draft.assetIds,
    targetDate: draft.targetDate,
  );

  @override
  Future<void> update(int id, GoalDraft draft) => _dao.updateGoal(
    id,
    name: draft.name,
    category: draft.category,
    targetAmountMinor: draft.targetAmount.minorUnits,
    currencyCode: draft.targetAmount.currencyCode,
    assetIds: draft.assetIds,
    targetDate: draft.targetDate,
  );

  @override
  Future<void> setStatus(int id, GoalStatus status) =>
      _dao.setStatus(id, status);

  @override
  Future<void> softDelete(int id) => _dao.softDelete(id);

  Future<FinancialGoal> _map(GoalRow row) async => FinancialGoal(
    id: row.id,
    name: row.name,
    category: row.category,
    targetAmount: Money(
      minorUnits: row.targetAmountMinor,
      currencyCode: row.currencyCode,
    ),
    status: row.status,
    assetIds: await _dao.assetIdsFor(row.id),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    targetDate: row.targetDate,
    deletedAt: row.deletedAt,
  );
}
