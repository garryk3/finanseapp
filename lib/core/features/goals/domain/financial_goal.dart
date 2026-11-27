import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';

/// Категория и статус финансовой цели (domain_model §7).
///
/// [mixed] — производная категория цели, объединяющей счета и инвестиции.
/// Пользователь её не выбирает: категория выводится из видов связанных активов
/// через [forAssets].
enum GoalCategory {
  accounts,
  investments,
  mixed;

  /// Категория по видам активов цели (BR-G-1): пусто → `null`, только счета →
  /// [accounts], только инвестиции → [investments], оба вида → [mixed].
  ///
  /// Единственный источник истины для `goals.category`: используется DAO при
  /// записи. Недвижимость не относится ни к одной категории и игнорируется
  /// (DAO отклоняет её отдельно).
  static GoalCategory? forAssets(Iterable<AssetKind> kinds) {
    var hasAccount = false;
    var hasInvestment = false;
    for (final kind in kinds) {
      switch (kind) {
        case AssetKind.account:
          hasAccount = true;
        case AssetKind.investment:
          hasInvestment = true;
        case AssetKind.property:
          break;
      }
    }
    if (hasAccount && hasInvestment) return GoalCategory.mixed;
    if (hasAccount) return GoalCategory.accounts;
    if (hasInvestment) return GoalCategory.investments;
    return null;
  }
}

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

/// Draft цели. Категория не входит в draft: она выводится из видов активов
/// ([GoalCategory.forAssets]) на стороне DAO.
final class GoalDraft {
  const GoalDraft({
    required this.name,
    required this.targetAmount,
    required this.assetIds,
    this.targetDate,
  });

  final String name;
  final Money targetAmount;
  final Set<int> assetIds;
  final LocalDate? targetDate;
}
