import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_icon_button.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Блок заблокированных активов на главной (задача 18.4).
///
/// Итог по всем неархивным инвестициям в базовой валюте и его доля от
/// стоимости инвестиций; при нехватке курса показывает «Курс недоступен».
/// Тултип/диалог поясняют, что отметки не уменьшают стоимость инвестиции.
class DashboardLockedAssets extends StatelessWidget {
  const DashboardLockedAssets({
    super.key,
    required this.total,
    required this.share,
    required this.error,
    required this.l10n,
    required this.formatMoney,
    this.onTap,
  });

  /// Сумма отметок в базовой валюте; null — нет расчёта.
  final Money? total;

  /// Доля от стоимости инвестиций (0..1); null — знаменателя нет.
  final Decimal? share;

  /// Причина отсутствия суммы; null — ещё считается.
  final DomainErrorCode? error;

  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final secondary = textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final lockedShare = share;
    final subtitle = lockedShare == null
        ? null
        : l10n.dashboardLockedShare(_percent(context, lockedShare));
    final total = this.total;
    final Widget value;
    if (total != null) {
      value = AppMoneyText(
        formatMoney(total),
        style: textTheme.titleLarge,
        maxLines: 1,
      );
    } else {
      final text = switch (error) {
        DomainErrorCode.rateUnavailable => l10n.assetBaseUnavailable,
        null => '—',
        _ => l10n.dashboardNetWorthUnavailable,
      };
      value = AppText(
        text,
        style: textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    return AppSection(
      header: l10n.dashboardLockedTitle,
      padded: false,
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  value,
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(subtitle, style: secondary),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppIconButton(
              icon: Icons.info_outline,
              tooltip: l10n.dashboardLockedInfoLabel,
              onPressed: () => _showInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInfo(BuildContext context) => showAppDialog<void>(
    context: context,
    builder: (context) => AppDialog(
      title: AppText(l10n.dashboardLockedTitle),
      content: AppText(l10n.dashboardLockedTooltip),
      scrollable: true,
      actions: [
        AppButton(
          label: l10n.commonDone,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  /// Один десятичный знак с разделителем локали (например, «8,2»).
  String _percent(BuildContext context, Decimal share) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    ).format(share.toDouble() * 100);
  }
}
