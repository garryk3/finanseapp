import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/ui/build_net_worth_series.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_chart_frame.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_line_chart.dart';
import 'package:finanseapp/uikit/app_metric.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Сводка, график чистого капитала и доступный список точек (charts.md §2).
class NetWorthChartSection extends StatefulWidget {
  const NetWorthChartSection({
    super.key,
    required this.points,
    required this.baseCurrency,
    required this.periodLabel,
    required this.l10n,
    required this.formatMoney,
    this.onShowAllTime,
  });

  final List<NetWorthPoint> points;
  final Currency baseCurrency;
  final String periodLabel;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final VoidCallback? onShowAllTime;

  @override
  State<NetWorthChartSection> createState() => _NetWorthChartSectionState();
}

class _NetWorthChartSectionState extends State<NetWorthChartSection> {
  static const _collapsedCount = 5;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    if (points.isEmpty) return const SizedBox.shrink();
    final l10n = widget.l10n;
    final builder = NetWorthSeriesBuilder(
      baseCurrency: widget.baseCurrency,
      formatMoney: widget.formatMoney,
    );
    final stats = builder.stats(points)!;
    final title = l10n.analyticsNetWorthTitle;
    final trend = switch (stats.trend) {
      NetWorthTrend.up => l10n.analyticsTrendUp,
      NetWorthTrend.down => l10n.analyticsTrendDown,
      NetWorthTrend.flat => l10n.analyticsTrendFlat,
    };
    final summary = l10n.analyticsChartSummary(
      widget.periodLabel,
      widget.formatMoney(stats.last),
      widget.formatMoney(stats.min),
      widget.formatMoney(stats.max),
      trend,
    );
    final dates = _rangeText(points);
    final subtitle = '$dates · ${widget.baseCurrency.code} · $trend';
    final textTheme = Theme.of(context).textTheme;

    final summaryCard = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppSummaryCard(
        title: title,
        value: widget.formatMoney(stats.last),
        subtitle: subtitle,
      ),
    );

    if (points.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          summaryCard,
          const SizedBox(height: AppSpacing.sm),
          AppEmptyState(
            icon: Icons.show_chart,
            title: l10n.analyticsNoChangesTitle,
            message: l10n.analyticsNoChangesMessage,
            actionLabel: widget.onShowAllTime == null
                ? null
                : l10n.analyticsPeriodAll,
            onAction: widget.onShowAllTime,
          ),
        ],
      );
    }

    final visible = _expanded
        ? points.reversed
        : points.reversed.take(_collapsedCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        summaryCard,
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppMetric(
                  label: l10n.analyticsMinLabel,
                  value: widget.formatMoney(stats.min),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppMetric(
                  label: l10n.analyticsMaxLabel,
                  value: widget.formatMoney(stats.max),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppChartFrame(
            title: l10n.analyticsDynamicsTitle,
            accessibleSummary: summary,
            child: AppLineChart(
              series: [builder.build(points, label: title)],
              accessibleSummary: summary,
            ),
          ),
        ),
        AppSection(
          header: l10n.analyticsPointsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final point in visible)
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            const DateFormatter().format(point.date),
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppMoneyText(
                          widget.formatMoney(point.value),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              if (points.length > _collapsedCount)
                AppButton(
                  label: _expanded
                      ? l10n.analyticsCollapsePoints
                      : l10n.analyticsShowAllPoints(points.length),
                  variant: AppButtonVariant.text,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _rangeText(List<NetWorthPoint> points) {
    final formatter = const DateFormatter();
    final first = formatter.format(points.first.date);
    final last = formatter.format(points.last.date);
    return first == last ? first : '$first – $last';
  }
}
