import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Категория доходов/расходов (domain_model §3).
final class CashflowCategory {
  const CashflowCategory({
    required this.id,
    required this.kind,
    required this.name,
    required this.isPreset,
    this.colorKey,
    this.iconKey,
    this.archivedAt,
  });

  final int id;
  final CashflowKind kind;
  final String name;
  final bool isPreset;

  /// Закрытые семантические ключи UIKit, не hex и не code points.
  final String? colorKey;
  final String? iconKey;
  final DateTime? archivedAt;
}

/// Draft категории.
final class CashflowCategoryDraft {
  const CashflowCategoryDraft({
    required this.kind,
    required this.name,
    this.colorKey,
    this.iconKey,
  });

  final CashflowKind kind;
  final String name;
  final String? colorKey;
  final String? iconKey;
}
