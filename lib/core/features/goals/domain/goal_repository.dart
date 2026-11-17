import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';

/// Repository финансовых целей (domain_model §9).
abstract interface class GoalRepository {
  Stream<List<FinancialGoal>> watchAll();

  Future<FinancialGoal> getById(int id);

  Future<int> create(GoalDraft draft);

  Future<void> update(int id, GoalDraft draft);

  Future<void> setStatus(int id, GoalStatus status);

  Future<void> softDelete(int id);
}
