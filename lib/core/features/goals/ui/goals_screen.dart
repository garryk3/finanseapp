import 'dart:async';

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Список финансовых целей (8.1).
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
                  : AppListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final goal = value[index];
                        return AppListTile(
                          key: ValueKey(goal.id),
                          title: goal.name,
                          subtitle:
                              '${vm.formatTarget(goal)} · '
                              '${_status(l10n, goal.status)}',
                          leading: const AppIcon(Icons.flag_outlined),
                          trailing: goal.status == GoalStatus.achieved
                              ? const AppIcon(Icons.check_circle_outline)
                              : null,
                          onTap: () => _open(goal.id),
                        );
                      },
                    ),
          };
        },
      ),
    );
  }

  static String _status(AppLocalizations l10n, GoalStatus status) =>
      switch (status) {
        GoalStatus.active => l10n.goalStatusActive,
        GoalStatus.achieved => l10n.goalStatusAchieved,
        GoalStatus.closed => l10n.goalStatusClosed,
      };
}
