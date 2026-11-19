import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_chip.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Итоги cashflow по категориям с долей от доходов/расходов (9.4).
class CategoryTotalsSection extends StatelessWidget {
  const CategoryTotalsSection({
    super.key,
    required this.totals,
    required this.categories,
    required this.l10n,
    required this.formatMoney,
    required this.shareOf,
    required this.showShare,
  });

  final List<CategoryTotal> totals;
  final Map<int, CashflowCategory> categories;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final double Function(CategoryTotal) shareOf;
  final bool showShare;

  String _shareText(CategoryTotal total) {
    final share = shareOf(total);
    final percent = share * 100;
    final text = !showShare
        ? ''
        : share > 0 && percent < 1
        ? '<1%'
        : '${percent.round()}%';
    final category = categories[total.categoryId];
    final kind = category == null
        ? null
        : category.kind == CashflowKind.income
        ? l10n.analyticsCashflowIncome
        : l10n.analyticsCashflowExpense;
    if (kind == null) return text;
    return text.isEmpty ? kind : '$text · $kind';
  }

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final sorted = [...totals]
      ..sort((a, b) => b.total.minorUnits.compareTo(a.total.minorUnits));
    return AppSection(
      header: l10n.analyticsCategoriesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final total in sorted)
            MergeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: AppText(
                                  categories[total.categoryId]?.name ??
                                      l10n.analyticsUnknownCategory,
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              if (categories[total.categoryId]?.archivedAt !=
                                  null) ...[
                                const SizedBox(width: AppSpacing.xs),
                                AppChip(label: l10n.accountArchivedBadge),
                              ],
                            ],
                          ),
                          if (_shareText(total).isNotEmpty)
                            AppText(
                              _shareText(total),
                              style: textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppMoneyText(
                      formatMoney(total.total),
                      style: textTheme.bodyMedium,
                      tone: switch (categories[total.categoryId]?.kind) {
                        CashflowKind.income => AppMoneyTone.income,
                        CashflowKind.expense => AppMoneyTone.expense,
                        null => AppMoneyTone.neutral,
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
