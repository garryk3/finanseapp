import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/app/theme/chart_series_colors.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/asset_comparison_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';
import 'package:finanseapp/uikit/app_chart_frame.dart';
import 'package:finanseapp/uikit/app_checkbox.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_chart_legend.dart';
import 'package:finanseapp/uikit/app_line_chart.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Сравнение 2–5 активов за общий период (12.2).
class AssetComparisonScreen extends StatefulWidget {
  const AssetComparisonScreen({super.key, required this.viewModel});

  final AssetComparisonViewModel viewModel;

  @override
  State<AssetComparisonScreen> createState() => _AssetComparisonScreenState();
}

class _AssetComparisonScreenState extends State<AssetComparisonScreen> {
  late AssetComparisonViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant AssetComparisonScreen oldWidget) {
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
      title: l10n.comparisonTitle,
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          if (vm.state.value is ViewError) {
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.init,
            );
          }
          if (vm.state.value is ViewLoading) {
            return Center(child: AppText(l10n.commonLoading));
          }
          return AppListView(
            children: [
              AppSection(
                header: l10n.comparisonSelectTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(l10n.comparisonSelectHint),
                    for (final asset in vm.assets.value)
                      AppCheckbox(
                        value: vm.selected.value.contains(asset.id),
                        label: asset.name,
                        onChanged:
                            vm.selected.value.contains(asset.id) ||
                                vm.canSelectMore
                            ? (_) => vm.toggleAsset(asset.id)
                            : null,
                      ),
                    if (vm.ready) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppFilterBar(
                        activeCount: vm.period.value == AnalyticsPeriod.month
                            ? 0
                            : 1,
                        children: [
                          for (final period in AnalyticsPeriod.values)
                            AppFilterChip(
                              label: _periodLabel(l10n, period),
                              selected: vm.period.value == period,
                              onSelected: (_) => vm.setPeriod(period),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppSegmentedControl<AssetComparisonMode>(
                        segments: [
                          AppSegment(
                            value: AssetComparisonMode.absolute,
                            label: l10n.comparisonModeAbsolute,
                          ),
                          AppSegment(
                            value: AssetComparisonMode.normalized,
                            label: l10n.comparisonModeNormalized,
                          ),
                        ],
                        selected: {vm.mode.value},
                        onSelectionChanged: (values) =>
                            vm.setMode(values.first),
                      ),
                    ],
                  ],
                ),
              ),
              if (!vm.ready) ...[
                const SizedBox(height: AppSpacing.md),
                AppEmptyState(
                  title: l10n.comparisonNoAssets,
                  message: l10n.comparisonSelectHint,
                  icon: Icons.compare_arrows,
                  actionLabel: l10n.comparisonGoAssets,
                  onAction: () => context.push(AppRoutes.assets),
                ),
              ] else if (vm.series.value.isEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: AppText(l10n.comparisonEmpty),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: AppChartFrame(
                    title: l10n.comparisonChartTitle,
                    subtitle: vm.mode.value == AssetComparisonMode.normalized
                        ? l10n.comparisonChartBase
                        : null,
                    accessibleSummary: _summary(l10n, vm),
                    child: AppLineChart(
                      series: _chartSeries(vm),
                      accessibleSummary: _summary(l10n, vm),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: AppChartLegend(
                    items: [
                      for (var i = 0; i < vm.series.value.length; i++)
                        AppChartLegendItem(
                          label: vm.series.value[i].asset.name,
                          colorKey: _colorAt(i),
                          dashed: i.isOdd,
                        ),
                    ],
                  ),
                ),
                AppSection(
                  header: l10n.comparisonTableTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in vm.series.value) ...[
                        AppText(item.asset.name),
                        for (var j = 0; j < item.points.length; j++)
                          MergeSemantics(
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    '${item.points[j].date.day.toString().padLeft(2, '0')}.'
                                    '${item.points[j].date.month.toString().padLeft(2, '0')}.'
                                    '${(item.points[j].date.year % 100).toString().padLeft(2, '0')}',
                                  ),
                                ),
                                AppText(vm.valueText(item, j)),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<AppLineChartSeries> _chartSeries(AssetComparisonViewModel vm) {
    final result = <AppLineChartSeries>[];
    for (var i = 0; i < vm.series.value.length; i++) {
      final item = vm.series.value[i];
      if (item.points.isEmpty) continue;
      result.add(
        AppLineChartSeries(
          id: '${item.asset.id}',
          label: item.asset.name,
          colorKey: _colorAt(i),
          dashed: i.isOdd,
          points: [
            for (var j = 0; j < item.points.length; j++)
              AppChartPoint(
                x: DateTime(
                  item.points[j].date.year,
                  item.points[j].date.month,
                  item.points[j].date.day,
                ),
                y: item.values[j],
                label:
                    '${item.points[j].date.day.toString().padLeft(2, '0')}.'
                    '${item.points[j].date.month.toString().padLeft(2, '0')}.'
                    '${(item.points[j].date.year % 100).toString().padLeft(2, '0')}',
                valueText: vm.valueText(item, j),
              ),
          ],
        ),
      );
    }
    return result;
  }

  String _summary(AppLocalizations l10n, AssetComparisonViewModel vm) {
    final parts = <String>[];
    for (final item in vm.series.value) {
      if (item.values.isEmpty) continue;
      final values = item.values;
      final minIndex = values.indexOf(values.reduce((a, b) => a < b ? a : b));
      final maxIndex = values.indexOf(values.reduce((a, b) => a > b ? a : b));
      parts.add(
        l10n.comparisonSummaryLine(
          item.asset.name,
          vm.lastValueText(item),
          vm.valueText(item, minIndex),
          vm.valueText(item, maxIndex),
        ),
      );
    }
    return '${_periodLabel(l10n, vm.period.value)}. ${parts.join('; ')}';
  }

  AppChartSeriesKey _colorAt(int index) => const [
    AppChartSeriesKey.netWorth,
    AppChartSeriesKey.expense,
    AppChartSeriesKey.assets,
  ][(index ~/ 2) % 3];

  String _periodLabel(AppLocalizations l10n, AnalyticsPeriod value) =>
      switch (value) {
        AnalyticsPeriod.month => l10n.analyticsPeriodMonth,
        AnalyticsPeriod.threeMonths => l10n.analyticsPeriodThreeMonths,
        AnalyticsPeriod.sixMonths => l10n.analyticsPeriodSixMonths,
        AnalyticsPeriod.year => l10n.analyticsPeriodYear,
        AnalyticsPeriod.all => l10n.analyticsPeriodAll,
      };
}
