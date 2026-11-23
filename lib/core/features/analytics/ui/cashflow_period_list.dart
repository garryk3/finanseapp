import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Список периодов денежного потока: дата + доход, расход, итог (18.5).
///
/// [monthly] включает подпись «Ноябрь 2026» для месячных бакетов; для
/// дневных периодов используется `dd.MM.yyyy`.
class CashflowPeriodList extends StatelessWidget {
  const CashflowPeriodList({
    super.key,
    required this.points,
    required this.l10n,
    required this.formatMoney,
    required this.monthly,
  });

  final List<CashflowPeriodPoint> points;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final bool monthly;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final point in points)
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    _label(context, point.periodStart),
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppMoneyText(
                    '${l10n.cashflowIncome}: '
                    '${formatMoney(point.summary.income)}',
                    tone: AppMoneyTone.income,
                    style: textTheme.bodySmall,
                  ),
                  AppMoneyText(
                    '${l10n.cashflowExpense}: '
                    '${formatMoney(point.summary.expense)}',
                    tone: AppMoneyTone.expense,
                    style: textTheme.bodySmall,
                  ),
                  AppMoneyText(
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

  String _label(BuildContext context, LocalDate date) {
    if (!monthly) return const DateFormatter().format(date);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat(
      'LLLL yyyy',
      locale,
    ).format(date.toUtcDateTime());
    if (formatted.isEmpty) return formatted;
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}
