import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/ui/goal_details_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Детали финансовой цели (8.1).
class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen({super.key, required this.viewModel});

  final GoalDetailsViewModel viewModel;

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late GoalDetailsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void didUpdateWidget(covariant GoalDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..load();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.goalDetailsTitle,
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          final goal = vm.goal.value;
          if (vm.state.value is ViewError) {
            if (vm.state.value case ViewError(
              errorCode: DomainErrorCode.notFound,
            )) {
              return AppEmptyState(
                icon: Icons.search_off,
                title: l10n.notFoundTitle,
                message: l10n.notFoundMessage,
                actionLabel: l10n.notFoundHome,
                onAction: () => context.go(AppRoutes.dashboard),
              );
            }
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.load,
            );
          }
          if (goal == null) {
            return Center(child: AppText(l10n.commonLoading));
          }
          return AppListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppSummaryCard(
                  title: l10n.goalTargetAmountLabel,
                  value: _money(goal.targetAmount),
                  subtitle: _status(l10n, goal.status),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSection(
                header: goal.name,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      '${l10n.goalCategoryLabel}: '
                      '${goal.category == GoalCategory.accounts ? l10n.goalCategoryAccounts : l10n.goalCategoryInvestments}',
                    ),
                    if (goal.targetDate != null)
                      AppText(
                        '${l10n.goalTargetDateLabel}: '
                        '${const DateFormatter().format(goal.targetDate!)}',
                      ),
                    AppText(l10n.goalAssetsLabel),
                    for (final asset in vm.assets.value)
                      AppText(
                        asset.archivedAt == null
                            ? asset.name
                            : '${asset.name} · ${l10n.accountArchivedBadge}',
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l10n.accountEdit,
                      variant: AppButtonVariant.outlined,
                      onPressed: () async {
                        final saved = await context.push<bool>(
                          AppRoutes.goalEditPath(goal.id),
                        );
                        if (!mounted || saved != true) return;
                        await vm.load();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (goal.status != GoalStatus.achieved)
                      AppButton(
                        label: l10n.goalMarkAchieved,
                        variant: AppButtonVariant.tonal,
                        onPressed: vm.busy.value
                            ? null
                            : () => _setStatus(GoalStatus.achieved),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    if (goal.status == GoalStatus.active)
                      AppButton(
                        label: l10n.goalClose,
                        variant: AppButtonVariant.tonal,
                        onPressed: vm.busy.value
                            ? null
                            : () => _setStatus(GoalStatus.closed),
                      )
                    else
                      AppButton(
                        label: l10n.goalActivate,
                        variant: AppButtonVariant.tonal,
                        onPressed: vm.busy.value
                            ? null
                            : () => _setStatus(GoalStatus.active),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.accountDelete,
                      variant: AppButtonVariant.destructive,
                      pending: vm.busy.value,
                      onPressed: vm.busy.value ? null : _delete,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _setStatus(GoalStatus status) async {
    final result = await _viewModel.setStatus(status);
    if (!mounted) return;
    if (result is Failure<void>) {
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).errorStateMessage,
        isError: true,
      );
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final goal = _viewModel.goal.value;
    if (goal == null) return;
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: l10n.goalDeleteTitle,
        message: l10n.goalDeleteMessage,
        confirmLabel: l10n.commonDelete,
        cancelLabel: l10n.commonCancel,
        destructive: true,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed != true) return;
    final result = await _viewModel.delete();
    if (!mounted) return;
    if (result is Failure<void>) {
      showAppSnackBar(context, message: l10n.errorStateMessage, isError: true);
      return;
    }
    showAppSnackBar(context, message: l10n.goalDeleted);
    if (context.mounted) context.pop();
  }

  static String _status(AppLocalizations l10n, GoalStatus status) =>
      switch (status) {
        GoalStatus.active => l10n.goalStatusActive,
        GoalStatus.achieved => l10n.goalStatusAchieved,
        GoalStatus.closed => l10n.goalStatusClosed,
      };

  static String _money(Money money) => const MoneyFormatter().format(
    money,
    Currency(
      code: money.currencyCode,
      name: money.currencyCode,
      fractionDigits: 2,
      isPreset: true,
      isEnabled: true,
    ),
  );
}
