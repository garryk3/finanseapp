import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';

/// Прогресс цели и рекомендация месячного взноса (domain_model §7).
final class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.progress,
    required this.deficit,
    required this.surplus,
    required this.completionRatio,
    this.monthlyContribution,
  });

  final FinancialGoal goal;
  final Money progress;
  final Money deficit;
  final Money surplus;
  final Decimal completionRatio;
  final Money? monthlyContribution;
}
