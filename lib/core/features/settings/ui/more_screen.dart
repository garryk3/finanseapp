import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/settings/ui/more_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// «Ещё»: точка входа в справочники/настройки/аудит. Секции добавляются
/// задачами 4.x–10.x; сейчас — защита приложения.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key, required this.viewModel});

  final MoreViewModel viewModel;

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late MoreViewModel _viewModel = widget.viewModel;

  @override
  void didUpdateWidget(covariant MoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navMore,
      body: SignalBuilder(
        builder: (context) => AppListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            AppSection(
              header: l10n.moreOverviewSection,
              child: AppListTile(
                title: l10n.analyticsTitle,
                leading: const AppIcon(Icons.show_chart),
                onTap: () => context.push(AppRoutes.analytics),
              ),
            ),
            AppSection(
              header: l10n.moreReferencesSection,
              child: Column(
                children: [
                  AppListTile(
                    title: l10n.categoriesTitle,
                    leading: const AppIcon(Icons.category_outlined),
                    onTap: () =>
                        context.push(AppRoutes.categoriesPath('expense')),
                  ),
                  AppListTile(
                    title: l10n.subgroupsTitle,
                    leading: const AppIcon(Icons.account_balance_outlined),
                    onTap: () => context.push(AppRoutes.subgroupsPath('bank')),
                  ),
                  AppListTile(
                    title: l10n.currenciesTitle,
                    leading: const AppIcon(Icons.currency_exchange),
                    onTap: () => context.push(AppRoutes.currencies),
                  ),
                ],
              ),
            ),
            AppSection(
              header: l10n.moreAppSection,
              child: Column(
                children: [
                  AppListTile(
                    title: l10n.settingsTitle,
                    leading: const AppIcon(Icons.settings_outlined),
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  AppListTile(
                    title: l10n.aboutTitle,
                    leading: const AppIcon(Icons.info_outline),
                    onTap: () => context.push(AppRoutes.about),
                  ),
                ],
              ),
            ),
            AppSection(
              header: l10n.moreSecuritySection,
              child: AppListTile(
                title: l10n.appLockTitle,
                leading: const AppIcon(Icons.lock_outline),
                onTap: () => context.push(AppRoutes.applockManage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
