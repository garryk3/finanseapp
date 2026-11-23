import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_cashflow.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_goals.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_net_worth.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_overdue_accounts.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_recent_operations.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_adaptive_grid.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Главная: net worth, quick actions, цели и последние операции (10.1).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navDashboard,
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          return switch (vm.state.value) {
            ViewLoading() => const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  AppSkeleton(width: double.infinity, height: 120),
                  SizedBox(height: AppSpacing.md),
                  AppSkeleton(width: double.infinity, height: 56),
                  SizedBox(height: AppSpacing.sm),
                  AppSkeleton(width: double.infinity, height: 56),
                ],
              ),
            ),
            ViewError() => AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.reload,
            ),
            ViewData() => _body(context, l10n, vm),
          };
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    DashboardViewModel vm,
  ) {
    final summary = vm.netWorth.value;
    final base = vm.baseCurrency.value;
    final overdue = vm.overdueAccounts.value;
    final value = summary == null ? '—' : vm.formatMoney(summary.total);
    final currencyCode = vm.netWorthError.value != null
        ? base?.code ?? ''
        : summary?.total.currencyCode ?? base?.code ?? '';
    final subtitle = <String>[
      const DateFormatter().format(vm.today.value),
      if (currencyCode.isNotEmpty) currencyCode,
    ].join(' · ');
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: AppAdaptiveGrid(
        children: [
          AppSection(
            header: l10n.dashboardOverview,
            padded: false,
            child: DashboardNetWorth(
              title: l10n.dashboardNetWorthTitle,
              value: switch (vm.netWorthError.value) {
                null => value,
                DomainErrorCode.rateUnavailable => l10n.assetBaseUnavailable,
                _ => l10n.dashboardNetWorthUnavailable,
              },
              subtitle: subtitle,
              onTap: () => context.push(AppRoutes.analytics),
            ),
          ),
          _quickActions(context, l10n),
          if (overdue.isNotEmpty)
            DashboardOverdueAccounts(
              accounts: overdue,
              l10n: l10n,
              onAccount: (id) => context.push(AppRoutes.assetDetailsPath(id)),
            ),
          if (vm.cashflowError.value != null)
            AppSection(
              header: l10n.dashboardCashflowTitle,
              padded: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    vm.cashflowError.value == DomainErrorCode.rateUnavailable
                        ? l10n.dashboardCashflowRateUnavailable
                        : l10n.dashboardCashflowUnavailable,
                  ),
                  if (vm.cashflowError.value ==
                      DomainErrorCode.rateUnavailable) ...[
                    const SizedBox(height: AppSpacing.xs),
                    AppButton(
                      label: l10n.analyticsEnterRate,
                      variant: AppButtonVariant.text,
                      onPressed: () =>
                          context.push('${AppRoutes.analytics}?period=month'),
                    ),
                  ],
                ],
              ),
            )
          else if (vm.cashflowSummary.value != null)
            DashboardCashflow(
              summary: vm.cashflowSummary.value!,
              points: vm.cashflowPoints.value,
              baseCurrency: vm.currencyOf(
                vm.cashflowSummary.value!.currencyCode,
              ),
              monthLabel:
                  '${const DateFormatter().format(vm.cashflowRange.start)}'
                  ' – ${const DateFormatter().format(vm.cashflowRange.end)}',
              l10n: l10n,
              formatMoney: vm.formatMoney,
              padded: false,
              onOpenAnalytics: () =>
                  context.push('${AppRoutes.analytics}?period=month'),
              onAddExpense: () =>
                  context.push('${AppRoutes.cashflowNew}?kind=expense'),
            ),
          DashboardGoals(
            goals: vm.goals.value,
            l10n: l10n,
            formatMoney: vm.formatMoney,
            padded: false,
            onGoal: (id) => context.push(AppRoutes.goalDetailsPath(id)),
            onAll: () => context.go(AppRoutes.goals),
            onAdd: () => context.push(AppRoutes.goalNew),
          ),
          DashboardRecentOperations(
            operations: vm.recentOperations.value,
            assetNames: vm.assetNames.value,
            l10n: l10n,
            formatMoney: vm.formatMoney,
            padded: false,
            onOpen: (id) => context.push(AppRoutes.transactionDetailsPath(id)),
            onAll: () =>
                context.go(AppRoutes.operationsTab(tab: 'transactions')),
            unknownAssetName: l10n.dashboardUnknownAsset,
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context, AppLocalizations l10n) =>
      AppSection(
        header: l10n.dashboardQuickActions,
        padded: false,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            AppButton(
              label: l10n.cashflowIncome,
              icon: Icons.add,
              variant: AppButtonVariant.tonal,
              onPressed: () =>
                  context.push('${AppRoutes.cashflowNew}?kind=income'),
            ),
            AppButton(
              label: l10n.cashflowExpense,
              icon: Icons.remove,
              variant: AppButtonVariant.tonal,
              onPressed: () =>
                  context.push('${AppRoutes.cashflowNew}?kind=expense'),
            ),
            AppButton(
              label: l10n.transferAction,
              icon: Icons.swap_horiz,
              variant: AppButtonVariant.outlined,
              onPressed: () => context.push(AppRoutes.transferNew),
            ),
          ],
        ),
      );
}
