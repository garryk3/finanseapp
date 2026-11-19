import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_cashflow_chart.dart';
import 'package:finanseapp/uikit/app_cashflow_summary.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';
import 'package:finanseapp/uikit/app_chart_frame.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Cashflow месяца на главной: итоги + компактные bars (10.2).
class DashboardCashflow extends StatelessWidget {
  const DashboardCashflow({
    super.key,
    required this.summary,
    required this.points,
    required this.baseCurrency,
    required this.monthLabel,
    required this.l10n,
    required this.formatMoney,
    required this.onOpenAnalytics,
    required this.onAddExpense,
  });

  final CashflowSummary summary;
  final List<CashflowPeriodPoint> points;
  final Currency baseCurrency;
  final String monthLabel;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    final incomeText = formatMoney(summary.income);
    final expenseText = formatMoney(summary.expense);
    final netText = formatMoney(summary.net);
    final empty = summary.income.isZero && summary.expense.isZero;
    final accessible = l10n.analyticsCashflowChartSummary(
      monthLabel,
      incomeText,
      expenseText,
      netText,
    );
    return AppSection(
      header: l10n.dashboardCashflowTitle,
      child: empty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(l10n.dashboardCashflowEmpty),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.dashboardAddExpense,
                  variant: AppButtonVariant.outlined,
                  onPressed: onAddExpense,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCashflowSummary(
                  incomeText: incomeText,
                  expenseText: expenseText,
                  netText: netText,
                  periodLabel: monthLabel,
                  incomeLabel: l10n.cashflowIncome,
                  expenseLabel: l10n.cashflowExpense,
                  netLabel: l10n.cashflowTotalsNet,
                  onTap: onOpenAnalytics,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppChartFrame(
                  title: l10n.dashboardCashflowDynamics,
                  height: 140,
                  accessibleSummary: accessible,
                  child: AppCashflowChart(
                    groups: _weeklyGroups(points),
                    accessibleSummary: accessible,
                    incomeLabel: l10n.cashflowIncome,
                    expenseLabel: l10n.cashflowExpense,
                  ),
                ),
              ],
            ),
    );
  }

  List<AppCashflowBarGroup> _weeklyGroups(List<CashflowPeriodPoint> points) {
    if (points.isEmpty) return const [];
    final totals = <int, _WeeklyTotal>{};
    for (final point in points) {
      final week = (point.periodStart.day - 1) ~/ 7;
      final current = totals[week];
      totals[week] = current == null
          ? _WeeklyTotal(
              income: point.summary.income,
              expense: point.summary.expense,
              net: point.summary.net,
            )
          : _WeeklyTotal(
              income: MoneyMath.add(current.income, point.summary.income),
              expense: MoneyMath.add(current.expense, point.summary.expense),
              net: MoneyMath.add(current.net, point.summary.net),
            );
    }
    final lastDay = points.last.periodStart.day;
    return [
      for (final entry
          in totals.entries.toList()
            ..sort((left, right) => left.key.compareTo(right.key)))
        AppCashflowBarGroup(
          label: _weekLabel(points.first.periodStart, entry.key, lastDay),
          income: _toDouble(entry.value.income),
          expense: _toDouble(entry.value.expense),
          incomeText: formatMoney(entry.value.income),
          expenseText: formatMoney(entry.value.expense),
          netText: formatMoney(entry.value.net),
        ),
    ];
  }

  static String _weekLabel(LocalDate first, int week, int lastDay) {
    final start = first.day + week * 7;
    final end = start + 6 > lastDay ? lastDay : start + 6;
    return '${_two(start)}–${_two(end)}.${_two(first.month)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  double _toDouble(Money money) =>
      MoneyMath.toDecimal(money, baseCurrency).toDouble();
}

final class _WeeklyTotal {
  const _WeeklyTotal({
    required this.income,
    required this.expense,
    required this.net,
  });

  final Money income, expense, net;
}
