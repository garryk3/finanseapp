import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_goal_card.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Блок целей на главной: до трёх карточек и переходы (10.1).
class DashboardGoals extends StatelessWidget {
  const DashboardGoals({
    super.key,
    required this.goals,
    required this.l10n,
    required this.formatMoney,
    required this.onGoal,
    required this.onAll,
    required this.onAdd,
    this.padded = true,
  });

  static const visibleLimit = 3;

  final List<DashboardGoal> goals;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final void Function(int goalId) onGoal;
  final VoidCallback onAll;
  final VoidCallback onAdd;

  /// false — секция внутри контейнера с готовым горизонтальным отступом.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final visible = goals.take(visibleLimit).toList();
    return AppSection(
      header: l10n.dashboardGoalsTitle,
      padded: padded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (visible.isEmpty) ...[
            AppText(l10n.dashboardGoalsEmpty),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.goalsAdd,
              variant: AppButtonVariant.outlined,
              onPressed: onAdd,
            ),
          ] else ...[
            for (final view in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppGoalCard(
                  name: view.goal.name,
                  progressText: view.progress == null
                      ? l10n.assetBaseUnavailable
                      : formatMoney(view.progress!.progress),
                  targetText: formatMoney(view.goal.targetAmount),
                  ratio: view.progress?.completionRatio.toDouble() ?? 0,
                  statusLabel: _status(l10n, view.displayStatus),
                  onTap: () => onGoal(view.goal.id),
                ),
              ),
            if (goals.length > visibleLimit)
              AppButton(
                label: l10n.dashboardAllGoals,
                variant: AppButtonVariant.text,
                onPressed: onAll,
              ),
          ],
        ],
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
