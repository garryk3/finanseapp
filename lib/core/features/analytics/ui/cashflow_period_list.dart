import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Список периодов денежного потока: дата + доход, расход, итог (18.5).
class CashflowPeriodList extends StatelessWidget {
  const CashflowPeriodList({
    super.key,
    required this.points,
    required this.l10n,
    required this.formatMoney,
  });

  final List<CashflowPeriodPoint> points;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final point in points)
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    const DateFormatter().format(point.periodStart),
                    style: textTheme.bodyMedium,
                  ),
                  AppText(
                    '${l10n.cashflowIncome}: '
                    '${formatMoney(point.summary.income)}',
                    style: textTheme.bodySmall,
                  ),
                  AppText(
                    '${l10n.cashflowExpense}: '
                    '${formatMoney(point.summary.expense)}',
                    style: textTheme.bodySmall,
                  ),
                  AppText(
                    '${l10n.cashflowTotalsNet}: '
                    '${formatMoney(point.summary.net)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
