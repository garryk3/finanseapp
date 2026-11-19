import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/app/theme/chart_series_colors.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_cashflow_chart.dart';
import 'package:finanseapp/uikit/app_cashflow_summary.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';
import 'package:finanseapp/uikit/app_chart_frame.dart';
import 'package:finanseapp/uikit/app_chart_legend.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Cashflow summary + grouped bars + доступный список периодов (9.3).
class CashflowChartSection extends StatefulWidget {
  const CashflowChartSection({
    super.key,
    required this.summary,
    required this.points,
    required this.baseCurrency,
    required this.periodLabel,
    required this.l10n,
    required this.formatMoney,
  });

  final CashflowSummary summary;
  final List<CashflowPeriodPoint> points;
  final Currency baseCurrency;
  final String periodLabel;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;

  @override
  State<CashflowChartSection> createState() => _CashflowChartSectionState();
}

class _CashflowChartSectionState extends State<CashflowChartSection> {
  static const _collapsedCount = 5;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    if (points.isEmpty) return const SizedBox.shrink();
    final l10n = widget.l10n;
    if (points.every(_isZero)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppEmptyState(
          icon: Icons.bar_chart,
          title: l10n.analyticsCashflowEmptyTitle,
          message: l10n.analyticsCashflowEmptyMessage,
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final incomeText = widget.formatMoney(widget.summary.income);
    final expenseText = widget.formatMoney(widget.summary.expense);
    final netText = widget.formatMoney(widget.summary.net);
    final accessible = l10n.analyticsCashflowChartSummary(
      widget.periodLabel,
      incomeText,
      expenseText,
      netText,
    );
    final monthly =
        points.length > 1 && points.every((p) => p.periodStart.day == 1);
    final rangeText = _rangeText(points, monthly: monthly);
    final periodSubtitle =
        '${widget.periodLabel} · $rangeText · ${widget.baseCurrency.code}';
    final groups = [
      for (final point in points)
        AppCashflowBarGroup(
          label: _shortDate(point.periodStart, monthly: monthly),
          income: _toDouble(point.summary.income),
          expense: _toDouble(point.summary.expense),
          incomeText: widget.formatMoney(point.summary.income),
          expenseText: widget.formatMoney(point.summary.expense),
          netText: widget.formatMoney(point.summary.net),
        ),
    ];
    final visible = _expanded
        ? points.reversed
        : points.reversed.take(_collapsedCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppCashflowSummary(
            incomeText: incomeText,
            expenseText: expenseText,
            netText: netText,
            periodLabel: periodSubtitle,
            incomeLabel: l10n.cashflowIncome,
            expenseLabel: l10n.cashflowExpense,
            netLabel: l10n.cashflowTotalsNet,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppChartFrame(
            title: l10n.analyticsCashflowTitle,
            accessibleSummary: accessible,
            child: AppCashflowChart(
              groups: groups,
              accessibleSummary: accessible,
              incomeLabel: l10n.cashflowIncome,
              expenseLabel: l10n.cashflowExpense,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppChartLegend(
            items: [
              AppChartLegendItem(
                label: l10n.cashflowIncome,
                colorKey: AppChartSeriesKey.income,
              ),
              AppChartLegendItem(
                label: l10n.cashflowExpense,
                colorKey: AppChartSeriesKey.expense,
              ),
            ],
          ),
        ),
        AppSection(
          header: l10n.analyticsPeriodsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final point in visible)
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          const DateFormatter().format(point.periodStart),
                          style: textTheme.bodyMedium,
                        ),
                        AppText(
                          '${l10n.cashflowIncome}: '
                          '${widget.formatMoney(point.summary.income)}',
                          style: textTheme.bodySmall,
                        ),
                        AppText(
                          '${l10n.cashflowExpense}: '
                          '${widget.formatMoney(point.summary.expense)}',
                          style: textTheme.bodySmall,
                        ),
                        AppText(
                          '${l10n.cashflowTotalsNet}: '
                          '${widget.formatMoney(point.summary.net)}',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              if (points.length > _collapsedCount)
                AppButton(
                  label: _expanded
                      ? l10n.analyticsCollapsePeriods
                      : l10n.analyticsShowAllPeriods(points.length),
                  variant: AppButtonVariant.text,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static bool _isZero(CashflowPeriodPoint point) =>
      point.summary.income.isZero &&
      point.summary.expense.isZero &&
      point.summary.net.isZero;

  String _rangeText(List<CashflowPeriodPoint> points, {required bool monthly}) {
    final formatter = const DateFormatter();
    final first = formatter.format(points.first.periodStart);
    final lastStart = points.last.periodStart;
    final last = formatter.format(
      monthly
          ? LocalDate(
              lastStart.year,
              lastStart.month,
              DateTime.utc(lastStart.year, lastStart.month + 1, 0).day,
            )
          : lastStart,
    );
    return first == last ? first : '$first – $last';
  }

  static String _shortDate(LocalDate date, {required bool monthly}) => monthly
      ? '${_two(date.month)}.${_two(date.year % 100)}'
      : '${_two(date.day)}.${_two(date.month)}';

  static String _two(int value) => value.toString().padLeft(2, '0');

  double _toDouble(Money money) =>
      MoneyMath.toDecimal(money, widget.baseCurrency).toDouble();
}
