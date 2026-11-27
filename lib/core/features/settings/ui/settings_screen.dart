import 'dart:async';

import 'package:finanseapp/app/app_restart.dart';
import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/backup/logic/backup_view_model.dart';
import 'package:finanseapp/core/features/settings/logic/update_check_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/settings_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/widgets/backup_section.dart';
import 'package:finanseapp/core/features/settings/ui/widgets/update_section.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Настройки: базовая валюта и вход в «О приложении» (10.3).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.viewModel,
    required this.backupViewModel,
    required this.updateViewModel,
  });

  final SettingsViewModel viewModel;
  final BackupViewModel backupViewModel;
  final UpdateCheckViewModel updateViewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
    widget.updateViewModel.init();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..init();
    }
    if (!identical(oldWidget.updateViewModel, widget.updateViewModel)) {
      oldWidget.updateViewModel.dispose();
      widget.updateViewModel.init();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    widget.updateViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.settingsTitle,
      body: SignalBuilder(
        builder: (context) {
          final base = _viewModel.baseCurrency.value;
          return AppListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              AppSection(
                header: l10n.settingsReportsSection,
                child: AppListTile(
                  title: l10n.baseCurrencyTitle,
                  subtitle: base == null ? null : '${base.code} · ${base.name}',
                  leading: const AppIcon(Icons.star_outline),
                  onTap: () => context.push(AppRoutes.baseCurrency),
                ),
              ),
              AppSection(
                header: l10n.settingsDisplaySection,
                child: AppSwitch(
                  value: _viewModel.amountsHidden.value,
                  label: l10n.settingsHideAmountsLabel,
                  onChanged: (value) =>
                      unawaited(_viewModel.setAmountsHidden(value)),
                ),
              ),
              BackupSection(
                viewModel: widget.backupViewModel,
                onRestart: restartApp,
              ),
              UpdateSection(
                viewModel: widget.updateViewModel,
                onOpenAbout: () => context.push(AppRoutes.about),
              ),
            ],
          );
        },
      ),
    );
  }
}
