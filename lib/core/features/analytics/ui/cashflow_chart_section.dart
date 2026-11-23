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
import 'package:finanseapp/uikit/app_cashflow_chart.dart';
import 'package:finanseapp/uikit/app_cashflow_summary.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';
import 'package:finanseapp/uikit/app_chart_frame.dart';
import 'package:finanseapp/uikit/app_chart_legend.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Cashflow summary + grouped bars + легенда (9.3).
///
/// Список периодов вынесен на страницу «Детализация за месяц» (18.5).
class CashflowChartSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
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

    final incomeText = formatMoney(summary.income);
    final expenseText = formatMoney(summary.expense);
    final netText = formatMoney(summary.net);
    final accessible = l10n.analyticsCashflowChartSummary(
      periodLabel,
      incomeText,
      expenseText,
      netText,
    );
    final monthly =
        points.length > 1 && points.every((p) => p.periodStart.day == 1);
    final rangeText = _rangeText(points, monthly: monthly);
    final periodSubtitle = '$periodLabel · $rangeText · ${baseCurrency.code}';
    final groups = [
      for (final point in points)
        AppCashflowBarGroup(
          label: _shortDate(point.periodStart, monthly: monthly),
          income: _toDouble(point.summary.income),
          expense: _toDouble(point.summary.expense),
          incomeText: formatMoney(point.summary.income),
          expenseText: formatMoney(point.summary.expense),
          netText: formatMoney(point.summary.net),
        ),
    ];

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
      MoneyMath.toDecimal(money, baseCurrency).toDouble();
}
