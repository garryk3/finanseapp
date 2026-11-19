import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/backup/domain/backup_exception.dart';
import 'package:finanseapp/core/features/backup/logic/backup_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Резервная копия: share/save/import и restart-диалог (10.4).
class BackupSection extends StatelessWidget {
  const BackupSection({
    super.key,
    required this.viewModel,
    required this.onRestart,
  });

  final BackupViewModel viewModel;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SignalBuilder(
      builder: (context) {
        final state = viewModel.state.value;
        final blocked = state.requiresRestart;
        final actions = <Widget>[
          _action(
            context,
            label: l10n.backupShare,
            icon: Icons.ios_share,
            action: BackupAction.share,
            state: state,
            enabled: !blocked,
            onPressed: viewModel.exportShared,
          ),
          _action(
            context,
            label: l10n.backupSave,
            icon: Icons.save_alt,
            action: BackupAction.save,
            state: state,
            enabled: !blocked,
            onPressed: () =>
                viewModel.exportSaved(dialogTitle: l10n.backupSave),
          ),
          _action(
            context,
            label: l10n.backupImport,
            icon: Icons.file_download_outlined,
            action: BackupAction.import,
            state: state,
            enabled: !blocked,
            onPressed: () => _import(context, l10n),
          ),
        ];
        final status = _statusWidget(context, l10n, state);
        return AppSection(
          header: l10n.settingsBackupSection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(
                    Icons.lock_open_outlined,
                    size: 20,
                    color: resolveStatusToneColor(
                      context,
                      AppStatusTone.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: AppText(l10n.settingsBackupWarning)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow =
                      constraints.maxWidth < AppSpacing.twoColumnBreakpoint ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.15;
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.xs),
                          actions[i],
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(child: actions[i]),
                      ],
                    ],
                  );
                },
              ),
              if (blocked) ...[
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  l10n.backupRestoreFailed,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.error),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.backupRestartOk,
                  variant: AppButtonVariant.tonal,
                  onPressed: onRestart,
                ),
              ] else if (status != null) ...[
                const SizedBox(height: AppSpacing.sm),
                status,
                if (state.status == BackupStatusKind.importFailed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: l10n.backupRestartOk,
                    variant: AppButtonVariant.tonal,
                    onPressed: onRestart,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _action(
    BuildContext context, {
    required String label,
    required IconData icon,
    required BackupAction action,
    required BackupState state,
    required bool enabled,
    required VoidCallback onPressed,
  }) => AppButton(
    label: label,
    icon: icon,
    variant: AppButtonVariant.tonal,
    pending: state.busyAction == action,
    onPressed: !enabled || state.isBusy ? null : onPressed,
  );

  Widget? _statusWidget(
    BuildContext context,
    AppLocalizations l10n,
    BackupState state,
  ) {
    final error = state.validationError;
    final String? text;
    if (error != null) {
      text = _validationText(l10n, error);
    } else if (state.status != null) {
      text = _statusText(l10n, state.status!);
    } else {
      text = null;
    }
    if (text == null) return null;
    final isError =
        error != null ||
        state.status == BackupStatusKind.exportFailed ||
        state.status == BackupStatusKind.importFailed;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isError) ...[
            AppIcon(
              Icons.error_outline,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Expanded(
            child: AppText(
              text,
              style: isError
                  ? Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: l10n.backupImportConfirmTitle,
        message: l10n.backupImportConfirmMessage,
        confirmLabel: l10n.backupImportConfirm,
        cancelLabel: l10n.commonCancel,
        destructive: true,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed != true) return;
    final done = await viewModel.importSelected();
    if (!done || !context.mounted) return;
    await showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AppDialog(
          title: AppText(l10n.backupRestartTitle),
          content: AppText(l10n.backupRestartMessage),
          actions: [
            AppButton(
              label: l10n.backupRestartOk,
              onPressed: () {
                Navigator.of(context).pop();
                onRestart();
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _statusText(AppLocalizations l10n, BackupStatusKind status) =>
      switch (status) {
        BackupStatusKind.exportShared => l10n.backupExportShared,
        BackupStatusKind.exportSaved => l10n.backupExportSaved,
        BackupStatusKind.shareCancelled => l10n.backupShareCancelled,
        BackupStatusKind.shareResultUnknown => l10n.backupShareUnknown,
        BackupStatusKind.saveCancelled => l10n.backupSaveCancelled,
        BackupStatusKind.importDone => l10n.backupImportDone,
        BackupStatusKind.exportFailed => l10n.backupExportFailed,
        BackupStatusKind.importFailed => l10n.backupImportFailed,
        BackupStatusKind.restoreFailed => l10n.backupRestoreFailed,
      };

  static String _validationText(
    AppLocalizations l10n,
    BackupValidationException error,
  ) => switch (error.reason) {
    BackupValidationError.notADatabase => l10n.backupValidationNotDatabase,
    BackupValidationError.corrupted => l10n.backupValidationCorrupted,
    BackupValidationError.schemaNewer => l10n.backupValidationNewerSchema(
      error.schemaVersion ?? 0,
      error.installedVersion ?? 0,
    ),
    BackupValidationError.notFinanseApp => l10n.backupValidationOtherApp,
    BackupValidationError.invalidReferences => l10n.backupValidationReferences,
  };
}
