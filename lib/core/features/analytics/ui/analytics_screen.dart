import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/analytics/ui/net_worth_chart_section.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/currencies/ui/manual_rate_dialog.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Аналитика: net worth за период и вид активов (9.2).
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.viewModel});

  final AnalyticsViewModel viewModel;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late AnalyticsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant AnalyticsScreen oldWidget) {
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
      title: l10n.analyticsTitle,
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          return _body(context, l10n, vm);
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    AnalyticsViewModel vm,
  ) {
    final state = vm.state.value;
    final points = vm.points.value;
    final base = vm.baseCurrency.value;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: AppListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.xl,
          ),
          children: [
            _filters(l10n, vm),
            const SizedBox(height: AppSpacing.md),
            if (state is ViewLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    const AppSkeleton(width: double.infinity, height: 240),
                    const SizedBox(height: AppSpacing.sm),
                    for (var i = 0; i < 3; i++) ...[
                      const AppSkeleton(width: double.infinity, height: 40),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ],
                ),
              )
            else if (state case ViewError(:final errorCode))
              _errorState(context, l10n, vm, errorCode)
            else if (points.isEmpty || base == null)
              vm.hasAnyAssets.value
                  ? AppEmptyState(
                      icon: Icons.show_chart,
                      title: l10n.analyticsEmptyTitle,
                      message: l10n.analyticsEmptyMessage,
                      actionLabel: vm.filtersActive
                          ? l10n.assetsResetFilters
                          : null,
                      onAction: vm.filtersActive ? vm.resetFilters : null,
                    )
                  : AppEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.analyticsNoAssetsTitle,
                      message: l10n.analyticsNoAssetsMessage,
                      actionLabel: l10n.navAssets,
                      onAction: () => context.go(AppRoutes.assets),
                    )
            else
              NetWorthChartSection(
                points: points,
                baseCurrency: base,
                periodLabel: _periodLabel(l10n, vm.period.value),
                l10n: l10n,
                formatMoney: vm.formatMoney,
                onShowAllTime: vm.period.value == AnalyticsPeriod.all
                    ? null
                    : () => vm.selectPeriod(AnalyticsPeriod.all),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filters(AppLocalizations l10n, AnalyticsViewModel vm) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFilterBar(
          activeCount: vm.filtersActive ? 1 : 0,
          onReset: vm.filtersActive ? vm.resetFilters : null,
          resetLabel: l10n.assetsResetFilters,
          children: [
            for (final period in AnalyticsPeriod.values)
              AppFilterChip(
                label: _periodLabel(l10n, period),
                selected: vm.period.value == period,
                onSelected: (_) => vm.selectPeriod(period),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AppFilterBar(
          children: [
            AppFilterChip(
              label: l10n.analyticsKindAll,
              selected: vm.kind.value == null,
              onSelected: (_) => vm.selectKind(null),
            ),
            for (final kind in AssetKind.values)
              AppFilterChip(
                label: _kindLabel(l10n, kind),
                selected: vm.kind.value == kind,
                onSelected: (_) => vm.selectKind(kind),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _errorState(
    BuildContext context,
    AppLocalizations l10n,
    AnalyticsViewModel vm,
    DomainErrorCode code,
  ) {
    final missing = vm.missingRate.value;
    if (code == DomainErrorCode.rateUnavailable && missing != null) {
      return AppErrorState(
        title: l10n.analyticsRateErrorTitle,
        message: l10n.analyticsRateErrorMessage(
          missing.currencyCode,
          const DateFormatter().format(missing.date),
        ),
        errorLabel: l10n.errorLabel,
        retryLabel: l10n.analyticsEnterRate,
        onRetry: () async {
          final rate = await showManualRateDialog(
            context,
            currencyCode: missing.currencyCode,
          );
          if (rate != null) await vm.submitManualRate(rate);
        },
      );
    }
    return AppErrorState(
      title: l10n.errorStateTitle,
      message: l10n.errorStateMessage,
      errorLabel: l10n.errorLabel,
      retryLabel: l10n.retry,
      onRetry: vm.reload,
    );
  }

  static String _periodLabel(AppLocalizations l10n, AnalyticsPeriod period) =>
      switch (period) {
        AnalyticsPeriod.month => l10n.analyticsPeriodMonth,
        AnalyticsPeriod.threeMonths => l10n.analyticsPeriodThreeMonths,
        AnalyticsPeriod.sixMonths => l10n.analyticsPeriodSixMonths,
        AnalyticsPeriod.year => l10n.analyticsPeriodYear,
        AnalyticsPeriod.all => l10n.analyticsPeriodAll,
      };

  static String _kindLabel(AppLocalizations l10n, AssetKind kind) =>
      switch (kind) {
        AssetKind.account => l10n.assetKindAccount,
        AssetKind.investment => l10n.assetKindInvestment,
        AssetKind.property => l10n.assetKindProperty,
      };
}
