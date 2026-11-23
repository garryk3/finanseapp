import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/cashflow_details_view_model.dart';
import 'package:finanseapp/core/features/analytics/ui/cashflow_period_list.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/ui/manual_rate_dialog.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_chip.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Детализация денежного потока по периодам отдельной страницей (18.5).
class CashflowDetailsScreen extends StatefulWidget {
  const CashflowDetailsScreen({super.key, required this.viewModel});

  final CashflowDetailsViewModel viewModel;

  @override
  State<CashflowDetailsScreen> createState() => _CashflowDetailsScreenState();
}

class _CashflowDetailsScreenState extends State<CashflowDetailsScreen> {
  late CashflowDetailsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant CashflowDetailsScreen oldWidget) {
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
      title: l10n.analyticsDetailsTitle,
      body: SignalBuilder(
        builder: (context) => _body(context, l10n, _viewModel),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    CashflowDetailsViewModel vm,
  ) {
    final state = vm.state.value;
    final kind = vm.cashflowKind.value;
    final hasInheritedFilters = kind != null || vm.categoryId.value != null;
    final filtersActive =
        vm.period.value != AnalyticsPeriod.month || hasInheritedFilters;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: AppListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.xl,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppFilterBar(
                activeCount: filtersActive ? 1 : 0,
                onReset: filtersActive ? vm.resetFilters : null,
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
            ),
            if (hasInheritedFilters)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.xs,
                ),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    if (kind != null)
                      AppChip(
                        label: kind == CashflowKind.income
                            ? l10n.analyticsCashflowIncome
                            : l10n.analyticsCashflowExpense,
                        icon: Icons.filter_alt_outlined,
                      ),
                    if (vm.categoryId.value != null)
                      AppChip(
                        label: l10n.analyticsDetailsCategoryFilter,
                        icon: Icons.category_outlined,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            if (state is ViewLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      const AppSkeleton(
                        width: double.infinity,
                        height: AppSpacing.minTouchTarget,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ],
                ),
              )
            else if (state case ViewError(:final errorCode))
              _errorState(context, l10n, vm, errorCode)
            else if (vm.points.value.isEmpty)
              AppEmptyState(
                icon: Icons.bar_chart,
                title: vm.period.value == AnalyticsPeriod.month
                    ? l10n.analyticsCashflowEmptyMonthTitle
                    : l10n.analyticsCashflowEmptyTitle,
                message: hasInheritedFilters
                    ? l10n.analyticsDetailsEmptyFilteredMessage
                    : vm.period.value == AnalyticsPeriod.month
                    ? l10n.analyticsCashflowEmptyMonthMessage
                    : l10n.analyticsCashflowEmptyMessage,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: CashflowPeriodList(
                  points: vm.points.value,
                  l10n: l10n,
                  formatMoney: vm.formatMoney,
                  monthly: vm.monthlyBuckets,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(
    BuildContext context,
    AppLocalizations l10n,
    CashflowDetailsViewModel vm,
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
}
