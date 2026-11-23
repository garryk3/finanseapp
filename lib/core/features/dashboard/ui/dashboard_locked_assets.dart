import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:finanseapp/uikit/app_tooltip.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Блок заблокированных активов на главной (задача 18.4).
///
/// Итог по всем неархивным инвестициям в базовой валюте и его доля от
/// стоимости инвестиций; при нехватке курса показывает «Курс недоступен».
/// Тултип поясняет, что отметки не уменьшают стоимость инвестиции.
class DashboardLockedAssets extends StatelessWidget {
  const DashboardLockedAssets({
    super.key,
    required this.total,
    required this.share,
    required this.l10n,
    required this.formatMoney,
    this.onTap,
  });

  /// Сумма отметок в базовой валюте; null — курс недоступен.
  final Money? total;

  /// Доля от стоимости инвестиций (0..1); null — знаменателя нет.
  final Decimal? share;

  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lockedShare = share;
    final subtitle = lockedShare == null
        ? null
        : l10n.dashboardLockedShare(_percent(context, lockedShare));
    final value = total;
    return AppSummaryCard(
      title: l10n.dashboardLockedTitle,
      value: value == null ? l10n.assetBaseUnavailable : formatMoney(value),
      subtitle: subtitle,
      trailing: AppTooltip(
        message: l10n.dashboardLockedTooltip,
        child: AppIcon(
          Icons.info_outline,
          semanticLabel: l10n.dashboardLockedInfoLabel,
        ),
      ),
      onTap: onTap,
    );
  }

  /// Один десятичный знак с разделителем локали (например, «8,2»).
  String _percent(BuildContext context, Decimal share) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    ).format(share.toDouble() * 100);
  }
}
