import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/settings/logic/update_check_view_model.dart';
import 'package:finanseapp/core/features/settings/domain/update_service.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Версия, ручная проверка обновлений и вход в About (10.5).
class UpdateSection extends StatelessWidget {
  const UpdateSection({
    super.key,
    required this.viewModel,
    required this.onOpenAbout,
  });

  final UpdateCheckViewModel viewModel;
  final VoidCallback onOpenAbout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SignalBuilder(
      builder: (context) {
        final vm = viewModel;
        final status = vm.status.value;
        final installed = vm.installedVersion.value;
        final latest = vm.release.value;
        final String? statusText = switch (status) {
          UpdateStatus.idle => null,
          UpdateStatus.checking => l10n.updateChecking,
          UpdateStatus.upToDate => l10n.updateUpToDate,
          UpdateStatus.updateAvailable =>
            latest == null || latest.tagName.isEmpty
                ? l10n.updateAvailableSimple
                : l10n.updateAvailable(latest.tagName),
          UpdateStatus.error => switch (vm.errorKind.value) {
            UpdateErrorKind.noReleases => l10n.updateNoReleases,
            UpdateErrorKind.network => l10n.updateNetworkError,
            UpdateErrorKind.invalid => l10n.updateInvalidResponse,
            null => l10n.updateCheckError,
          },
          UpdateStatus.openFailed => l10n.updateOpenFailed,
        };
        final checking = status == UpdateStatus.checking;
        final hasUpdate =
            latest != null &&
            (status == UpdateStatus.updateAvailable ||
                status == UpdateStatus.openFailed);
        return AppSection(
          header: l10n.settingsAboutSection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                installed == null
                    ? l10n.updateVersionUnavailable
                    : l10n.settingsUpdateVersion(installed),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: hasUpdate ? l10n.updateOpen : l10n.updateCheck,
                variant: AppButtonVariant.tonal,
                pending: checking,
                onPressed: checking
                    ? null
                    : hasUpdate
                    ? vm.openUpdate
                    : vm.check,
              ),
              if (statusText != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (status == UpdateStatus.error ||
                          status == UpdateStatus.openFailed) ...[
                        AppIcon(
                          Icons.error_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                      ],
                      Expanded(
                        child: AppText(
                          statusText,
                          style:
                              status == UpdateStatus.error ||
                                  status == UpdateStatus.openFailed
                              ? Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              AppListTile(
                title: l10n.settingsAboutDetails,
                leading: const AppIcon(Icons.info_outline),
                onTap: onOpenAbout,
              ),
            ],
          ),
        );
      },
    );
  }
}
