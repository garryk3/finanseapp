import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/widgets.dart';

/// Единое отображение loading/data/error для root-экранов shell.
class PrimaryEmptyBody extends StatelessWidget {
  const PrimaryEmptyBody({
    super.key,
    required this.state,
    required this.icon,
    required this.emptyTitle,
    required this.emptyMessage,
    this.actionLabel,
    this.onAction,
    this.onRetry,
  });

  final ViewState<void> state;
  final IconData icon;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback? onRetry;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (state) {
      ViewLoading() => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSkeleton(width: 220, height: 18),
              const SizedBox(height: AppSpacing.sm),
              AppText(l10n.commonLoading),
            ],
          ),
        ),
      ),
      ViewError() => AppErrorState(
        title: l10n.errorStateTitle,
        message: l10n.errorStateMessage,
        retryLabel: onRetry == null ? null : l10n.retry,
        onRetry: onRetry,
        errorLabel: l10n.errorLabel,
      ),
      ViewData() => AppEmptyState(
        icon: icon,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    };
  }
}
