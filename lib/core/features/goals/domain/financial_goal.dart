import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';

/// Категория и статус финансовой цели (domain_model §7).
enum GoalCategory { accounts, investments }

enum GoalStatus { active, achieved, closed }

/// Финансовая цель с явной привязкой активов.
final class FinancialGoal {
  const FinancialGoal({
    required this.id,
    required this.name,
    required this.category,
    required this.targetAmount,
    required this.status,
    required this.assetIds,
    required this.createdAt,
    required this.updatedAt,
    this.targetDate,
    this.deletedAt,
  });

  final int id;
  final String name;
  final GoalCategory category;
  final Money targetAmount;
  final GoalStatus status;
  final Set<int> assetIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LocalDate? targetDate;
  final DateTime? deletedAt;
}

/// Draft цели.
final class GoalDraft {
  const GoalDraft({
    required this.name,
    required this.category,
    required this.targetAmount,
    required this.assetIds,
    this.targetDate,
  });

  final String name;
  final GoalCategory category;
  final Money targetAmount;
  final Set<int> assetIds;
  final LocalDate? targetDate;
}
