import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:material_ui/material_ui.dart';

/// Предупреждение о счетах с истёкшим сроком окончания (задача 19.3).
///
/// Показывается только при непустом списке; строки ведут в детали счёта,
/// «Ещё N» разворачивает оставшиеся строки на месте.
class DashboardOverdueAccounts extends StatefulWidget {
  const DashboardOverdueAccounts({
    super.key,
    required this.accounts,
    required this.l10n,
    required this.onAccount,
    this.visibleLimit = 3,
  });

  final List<AccountAsset> accounts;
  final AppLocalizations l10n;
  final void Function(int id) onAccount;
  final int visibleLimit;

  @override
  State<DashboardOverdueAccounts> createState() =>
      _DashboardOverdueAccountsState();
}

class _DashboardOverdueAccountsState extends State<DashboardOverdueAccounts> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = _expanded
        ? widget.accounts
        : widget.accounts.take(widget.visibleLimit).toList();
    final more = widget.accounts.length - visible.length;
    final warning = resolveStatusToneColor(context, AppStatusTone.warning);
    return AppSection(
      header: widget.l10n.dashboardOverdueTitle,
      padded: false,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final account in visible)
              if (account.endDate != null)
                AppListTile(
                  leading: AppIcon(Icons.warning_amber_rounded, color: warning),
                  title: account.name,
                  subtitle: widget.l10n.dashboardOverdueEnded(
                    const DateFormatter().format(account.endDate!),
                  ),
                  onTap: () => widget.onAccount(account.id),
                ),
            if (more > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: AppButton(
                    label: widget.l10n.dashboardOverdueMore(more),
                    variant: AppButtonVariant.text,
                    onPressed: () => setState(() => _expanded = true),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
