import 'dart:async';

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_goal_card.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Список финансовых целей с прогрессом по статусам (8.2).
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key, required this.viewModel});

  final GoalsViewModel viewModel;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late GoalsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant GoalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final saved = await context.push<bool>(AppRoutes.goalNew);
    if (!mounted || saved != true) return;
    _viewModel.reload();
  }

  Future<void> _open(int id) async {
    await context.push(AppRoutes.goalDetailsPath(id));
    if (!mounted) return;
    _viewModel.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navGoals,
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        tooltip: l10n.goalsAdd,
        onPressed: _add,
      ),
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          return switch (vm.state.value) {
            ViewLoading() => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    const AppSkeleton(width: double.infinity, height: 56),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            ViewError() => AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.init,
            ),
            ViewData(:final value) =>
              value.isEmpty
                  ? AppEmptyState(
                      icon: Icons.flag_outlined,
                      title: l10n.goalsEmptyTitle,
                      message: l10n.goalsEmptyMessage,
                      actionLabel: l10n.goalsAdd,
                      onAction: _add,
                    )
                  : _list(context, vm, l10n, value),
          };
        },
      ),
    );
  }

  Widget _list(
    BuildContext context,
    GoalsViewModel vm,
    AppLocalizations l10n,
    List<GoalView> views,
  ) {
    final groups = <(String, List<GoalView>)>[
      (
        l10n.goalGroupActive,
        views.where((v) => v.goal.status == GoalStatus.active).toList(),
      ),
      (
        l10n.goalGroupAchieved,
        views.where((v) => v.goal.status == GoalStatus.achieved).toList(),
      ),
      (
        l10n.goalGroupClosed,
        views.where((v) => v.goal.status == GoalStatus.closed).toList(),
      ),
    ];
    return AppListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        for (final (title, items) in groups)
          if (items.isNotEmpty) ...[
            AppSectionHeader(title: title),
            for (final view in items)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _card(context, vm, l10n, view),
              ),
          ],
      ],
    );
  }

  Widget _card(
    BuildContext context,
    GoalsViewModel vm,
    AppLocalizations l10n,
    GoalView view,
  ) {
    final goal = view.goal;
    final progress = view.progress;
    if (progress == null) {
      return AppListTile(
        key: ValueKey(goal.id),
        title: goal.name,
        subtitle:
            '${l10n.assetBaseUnavailable} · ${_status(l10n, goal.status)}',
        leading: const AppIcon(Icons.flag_outlined),
        trailing: AppMoneyText(
          vm.formatTarget(goal),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        onTap: () => _open(goal.id),
      );
    }

    final targetDate = goal.status == GoalStatus.active
        ? goal.targetDate
        : null;
    final String? deadlineText;
    if (targetDate == null) {
      deadlineText = null;
    } else if (targetDate.compareTo(vm.today) < 0) {
      deadlineText = l10n.goalDeadlineExpired;
    } else {
      deadlineText = l10n.goalDeadline(
        const DateFormatter().format(targetDate),
      );
    }
    final String? footerText;
    if (progress.deficit.minorUnits > 0) {
      footerText = l10n.goalDeficit(vm.formatMoney(progress.deficit));
    } else if (progress.surplus.minorUnits > 0) {
      footerText = l10n.goalSurplus(vm.formatMoney(progress.surplus));
    } else {
      footerText = null;
    }

    return AppGoalCard(
      key: ValueKey(goal.id),
      name: goal.name,
      progressText: vm.formatMoney(progress.progress),
      targetText: vm.formatTarget(goal),
      ratio: progress.completionRatio.toDouble(),
      deadlineText: deadlineText,
      deficitText: footerText,
      onTap: () => _open(goal.id),
    );
  }

  static String _status(AppLocalizations l10n, GoalStatus status) =>
      switch (status) {
        GoalStatus.active => l10n.goalStatusActive,
        GoalStatus.achieved => l10n.goalStatusAchieved,
        GoalStatus.closed => l10n.goalStatusClosed,
      };
}
