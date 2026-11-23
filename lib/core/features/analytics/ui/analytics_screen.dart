import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/analytics/ui/cashflow_chart_section.dart';
import 'package:finanseapp/core/features/analytics/ui/category_totals_section.dart';
import 'package:finanseapp/core/features/analytics/ui/net_worth_chart_section.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/ui/manual_rate_dialog.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_category_select.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Аналитика: net worth за период и вид активов (9.2).
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
    required this.viewModel,
    this.disposeViewModel = true,
  });

  final AnalyticsViewModel viewModel;

  /// false — ViewModel принадлежит DI/маршруту и переживает экран
  /// (фильтры сохраняются при возврате с подстраниц, 18.9).
  final bool disposeViewModel;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late AnalyticsViewModel _viewModel = widget.viewModel;

  /// Выбор таба «Расходы/Доходы» переживает unmount секции на время reload.
  CashflowKind _categoryKind = CashflowKind.expense;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant AnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      if (oldWidget.disposeViewModel) oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
    if (widget.disposeViewModel) _viewModel.dispose();
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
    final filterKind = vm.cashflowKind.value;
    // Активный kind-фильтр задаёт тип итогов; запоминаем его в state экрана,
    // чтобы после сброса фильтра таб не прыгал (и переживал reload).
    if (filterKind != null) _categoryKind = filterKind;
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
            else if (!vm.hasAnyAssets.value && !vm.hasAnyCashflow.value)
              AppEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.analyticsNoAssetsTitle,
                message: l10n.analyticsNoAssetsMessage,
                actionLabel: l10n.navAssets,
                onAction: () => context.go(AppRoutes.assets),
              )
            else ...[
              if (points.isNotEmpty && base != null)
                NetWorthChartSection(
                  points: points,
                  baseCurrency: base,
                  periodLabel: _periodLabel(l10n, vm.period.value),
                  l10n: l10n,
                  formatMoney: vm.formatMoney,
                  onShowAllTime: vm.period.value == AnalyticsPeriod.all
                      ? null
                      : () => vm.selectPeriod(AnalyticsPeriod.all),
                )
              else if (vm.hasAnyAssets.value)
                AppEmptyState(
                  icon: Icons.show_chart,
                  title: l10n.analyticsEmptyTitle,
                  message: l10n.analyticsEmptyMessage,
                  actionLabel: vm.filtersActive
                      ? l10n.assetsResetFilters
                      : null,
                  onAction: vm.filtersActive ? vm.resetFilters : null,
                ),
              const SizedBox(height: AppSpacing.lg),
              _cashflowFilters(l10n, vm),
              const SizedBox(height: AppSpacing.sm),
              if (base != null &&
                  vm.cashflowSummary.value != null &&
                  vm.cashflowPoints.value.isNotEmpty)
                CashflowChartSection(
                  summary: vm.cashflowSummary.value!,
                  points: vm.cashflowPoints.value,
                  baseCurrency: base,
                  periodLabel: _periodLabel(l10n, vm.period.value),
                  l10n: l10n,
                  formatMoney: vm.formatMoney,
                ),
              if (base != null)
                AppListTile(
                  title: l10n.analyticsDetailsTitle,
                  trailing: const AppIcon(
                    Icons.chevron_right,
                    semanticLabel: null,
                  ),
                  onTap: () => context.push(
                    AppRoutes.analyticsDetailsPath(
                      period: _periodToken(vm.period.value),
                      kind: _cashflowKindToken(vm.cashflowKind.value),
                      categoryId: vm.categoryId.value,
                    ),
                  ),
                ),
              if (base != null)
                CategoryTotalsSection(
                  totals: vm.categoryTotals.value,
                  categories: vm.categories.value,
                  cashflowKind: vm.cashflowKind.value,
                  selectedKind: _categoryKind,
                  onKindChanged: (kind) {
                    if (kind != _categoryKind) {
                      setState(() => _categoryKind = kind);
                    }
                  },
                  l10n: l10n,
                  formatMoney: vm.formatMoney,
                  shareOf: vm.categoryShare,
                  showShare: vm.categoryId.value == null,
                ),
            ],
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
          activeCount: vm.generalFiltersActive ? 1 : 0,
          onReset: vm.generalFiltersActive ? vm.resetGeneralFilters : null,
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

  Widget _cashflowFilters(AppLocalizations l10n, AnalyticsViewModel vm) {
    final categories = [
      for (final category in vm.categories.value.values)
        if (category.kind == vm.cashflowKind.value &&
            (category.archivedAt == null || category.id == vm.categoryId.value))
          category,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFilterBar(
            activeCount: vm.cashflowFiltersActive ? 1 : 0,
            onReset: vm.cashflowFiltersActive ? vm.resetCashflowFilters : null,
            resetLabel: l10n.assetsResetFilters,
            children: [
              AppFilterChip(
                label: l10n.analyticsCashflowKindAll,
                selected: vm.cashflowKind.value == null,
                onSelected: (_) => vm.selectCashflowKind(null),
              ),
              AppFilterChip(
                label: l10n.analyticsCashflowIncome,
                selected: vm.cashflowKind.value == CashflowKind.income,
                onSelected: (_) => vm.selectCashflowKind(CashflowKind.income),
              ),
              AppFilterChip(
                label: l10n.analyticsCashflowExpense,
                selected: vm.cashflowKind.value == CashflowKind.expense,
                onSelected: (_) => vm.selectCashflowKind(CashflowKind.expense),
              ),
            ],
          ),
          if (vm.cashflowKind.value != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: AppCategorySelect(
                label: l10n.analyticsCategoryFilterLabel,
                valueId: vm.categoryId.value ?? 0,
                archivedLabel: l10n.accountArchivedBadge,
                items: [
                  AppCategoryOption(id: 0, name: l10n.cashflowAllCategories),
                  for (final category in categories)
                    AppCategoryOption(
                      id: category.id,
                      name: category.name,
                      colorKey: category.colorKey,
                      archived: category.archivedAt != null,
                    ),
                ],
                onChanged: (id) => vm.selectCategory(id == 0 ? null : id),
              ),
            ),
        ],
      ),
    );
  }

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

  static String _periodToken(AnalyticsPeriod period) => switch (period) {
    AnalyticsPeriod.month => 'month',
    AnalyticsPeriod.threeMonths => '3m',
    AnalyticsPeriod.sixMonths => '6m',
    AnalyticsPeriod.year => 'year',
    AnalyticsPeriod.all => 'all',
  };

  static String? _cashflowKindToken(CashflowKind? kind) => switch (kind) {
    CashflowKind.income => 'income',
    CashflowKind.expense => 'expense',
    null => null,
  };

  static String _kindLabel(AppLocalizations l10n, AssetKind kind) =>
      switch (kind) {
        AssetKind.account => l10n.assetKindAccount,
        AssetKind.investment => l10n.assetKindInvestment,
        AssetKind.property => l10n.assetKindProperty,
      };
}
