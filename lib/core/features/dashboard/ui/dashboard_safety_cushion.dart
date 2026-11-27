import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/dashboard/logic/safety_cushion.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_blur.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_money_visibility.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Карточка «Подушка безопасности»: runway по расходам, цель 6 месяцев и
/// срок достижения цели при текущем профиците (задача 19.2, формула C).
class DashboardSafetyCushion extends StatelessWidget {
  const DashboardSafetyCushion({
    super.key,
    required this.cushion,
    required this.l10n,
    required this.formatMoney,
  });

  final SafetyCushion cushion;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final secondary = textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final success = resolveStatusToneColor(context, AppStatusTone.success);

    final months = cushion.months;
    final String valueText;
    String? yearsText;
    final bool showRunwayLabel;
    if (months == 0) {
      valueText = cushion.cash.isZero
          ? l10n.dashboardSafetyNoReserve
          : l10n.dashboardSafetyLessThanMonth;
      showRunwayLabel = false;
    } else if (months > 1200) {
      valueText = l10n.dashboardSafetyMoreThan100Years;
      showRunwayLabel = false;
    } else {
      valueText = l10n.dashboardSafetyMonths(months);
      showRunwayLabel = true;
      final years = months ~/ 12;
      final restMonths = months % 12;
      if (years > 0) {
        yearsText = restMonths == 0
            ? l10n.dashboardSafetyYears(years)
            : l10n.dashboardSafetyYearsMonths(
                l10n.dashboardSafetyYears(years),
                restMonths,
              );
      }
    }

    final hidden = AppMoneyVisibility.of(context);
    final targetText = l10n.dashboardSafetyTarget(formatMoney(cushion.target));
    final monthsToTarget = cushion.monthsToTarget;
    final String statusText;
    final Widget status;
    if (monthsToTarget == 0) {
      statusText = l10n.dashboardSafetyReached;
      status = Row(
        children: [
          AppIcon(
            Icons.check_circle_outline,
            color: success,
            size: MediaQuery.textScalerOf(context).scale(18),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppText(statusText, style: secondary?.copyWith(color: success)),
        ],
      );
    } else if (monthsToTarget != null) {
      statusText = monthsToTarget > 120
          ? l10n.dashboardSafetyEtaMoreThan10Years(
              formatMoney(cushion.monthlyProfit),
            )
          : l10n.dashboardSafetyEta(
              monthsToTarget,
              formatMoney(cushion.monthlyProfit),
            );
      status = AppText(statusText, style: secondary);
    } else {
      statusText = l10n.dashboardSafetyNoProfit;
      status = AppText(statusText, style: secondary);
    }

    // D21.4: суммы (цель и профицит) прячутся и не читаются TalkBack'ом;
    // неденежные строки (сроки, «Достигнута») остаются.
    final statusHasMoney = monthsToTarget != null && monthsToTarget != 0;
    final phrase = yearsText ?? valueText;
    final semanticsLabel = [
      if (showRunwayLabel) '${l10n.dashboardSafetyRunway} $phrase' else phrase,
      l10n.dashboardSafetyPeriod,
      if (!hidden) targetText,
      if (!(hidden && statusHasMoney)) statusText,
    ].join('. ');

    return AppSection(
      header: l10n.dashboardSafetyTitle,
      padded: false,
      child: Semantics(
        container: true,
        excludeSemantics: true,
        label: semanticsLabel,
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showRunwayLabel) ...[
                AppText(l10n.dashboardSafetyRunway, style: secondary),
                const SizedBox(height: AppSpacing.xs),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        valueText,
                        style: textTheme.headlineSmall,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  if (yearsText != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: AppText(yearsText, style: secondary, maxLines: 2),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppText(l10n.dashboardSafetyPeriod, style: secondary),
              const SizedBox(height: AppSpacing.sm),
              AppAmountBlur(child: AppText(targetText, style: secondary)),
              const SizedBox(height: AppSpacing.xxs),
              if (statusHasMoney) AppAmountBlur(child: status) else status,
            ],
          ),
        ),
      ),
    );
  }
}
