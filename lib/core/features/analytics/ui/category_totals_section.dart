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
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Итоги cashflow по категориям с долей от доходов/расходов (9.4).
///
/// Доходы и расходы разделены табами: по умолчанию показаны расходы.
/// Если задан [cashflowKind] (фильтр аналитики по типу), таб заменяется
/// подписью типа: фильтр жёстко задаёт kind (18.6). [selectedKind] позволяет
/// родителю сохранить выбор таба, пока секция размонтирована на время reload.
class CategoryTotalsSection extends StatefulWidget {
  const CategoryTotalsSection({
    super.key,
    required this.totals,
    required this.categories,
    required this.l10n,
    required this.formatMoney,
    required this.shareOf,
    required this.showShare,
    this.cashflowKind,
    this.selectedKind,
    this.onKindChanged,
  });

  final List<CategoryTotal> totals;
  final Map<int, CashflowCategory> categories;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final double Function(CategoryTotal) shareOf;
  final bool showShare;

  /// Активный фильтр по типу cashflow; `null` — «Все операции».
  final CashflowKind? cashflowKind;

  /// Выбор пользователя, сохраняемый родителем между пересборками.
  final CashflowKind? selectedKind;

  /// Сообщает родителю о ручном переключении таба.
  final ValueChanged<CashflowKind>? onKindChanged;

  @override
  State<CategoryTotalsSection> createState() => _CategoryTotalsSectionState();
}

class _CategoryTotalsSectionState extends State<CategoryTotalsSection> {
  late CashflowKind _kind;

  @override
  void initState() {
    super.initState();
    _kind = widget.cashflowKind ?? widget.selectedKind ?? CashflowKind.expense;
  }

  @override
  void didUpdateWidget(covariant CategoryTotalsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final filterKind = widget.cashflowKind;
    if (filterKind != null) {
      _kind = filterKind;
      if (widget.onKindChanged != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onKindChanged?.call(filterKind);
        });
      }
    } else if (widget.selectedKind != null) {
      _kind = widget.selectedKind!;
    }
  }

  String _shareText(CategoryTotal total) {
    if (!widget.showShare) return '';
    final share = widget.shareOf(total);
    final percent = share * 100;
    return share > 0 && percent < 1 ? '<1%' : '${percent.round()}%';
  }

  void _selectKind(CashflowKind value) {
    if (widget.cashflowKind != null || value == _kind) return;
    setState(() => _kind = value);
    widget.onKindChanged?.call(value);
  }

  Widget _tabs() {
    return AppSegmentedControl<CashflowKind>(
      segments: [
        AppSegment(
          value: CashflowKind.expense,
          label: widget.l10n.analyticsCashflowExpense,
        ),
        AppSegment(
          value: CashflowKind.income,
          label: widget.l10n.analyticsCashflowIncome,
        ),
      ],
      selected: {_kind},
      onSelectionChanged: (values) => _selectKind(values.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totals.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final sorted = [
      for (final total in widget.totals)
        if (widget.categories[total.categoryId]?.kind == _kind) total,
    ]..sort((a, b) => b.total.minorUnits.compareTo(a.total.minorUnits));
    return AppSection(
      header: widget.l10n.analyticsCategoriesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.cashflowKind == null) ...[
            _tabs(),
            const SizedBox(height: AppSpacing.sm),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppText(
                _kind == CashflowKind.income
                    ? widget.l10n.analyticsCashflowIncome
                    : widget.l10n.analyticsCashflowExpense,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          if (sorted.isEmpty)
            AppText(
              _kind == CashflowKind.income
                  ? widget.l10n.analyticsCategoriesEmptyIncome
                  : widget.l10n.analyticsCategoriesEmptyExpense,
              style: textTheme.bodyMedium,
            )
          else
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
                                    widget.categories[total.categoryId]?.name ??
                                        widget.l10n.analyticsUnknownCategory,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                                if (widget
                                        .categories[total.categoryId]
                                        ?.archivedAt !=
                                    null) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  AppChip(
                                    label: widget.l10n.accountArchivedBadge,
                                  ),
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
                        widget.formatMoney(total.total),
                        style: textTheme.bodyMedium,
                        tone:
                            switch (widget.categories[total.categoryId]?.kind) {
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
