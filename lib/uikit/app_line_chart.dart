// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/chart_series_colors.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';

/// Линейный график (net worth, история стоимости). Равномерная сетка по
/// индексам точек; подписи оси — [AppChartPoint.label] с прореживанием по
/// ширине (все labels доступны в text alternative). Tooltip содержит
/// exact formatted values. Одна точка — видимый marker и finite range.
/// Remove animations отключает анимацию.
///
/// Экраны: Аналитика (история net worth/стоимости актива), Dashboard
/// (chart teaser).
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.series,
    required this.accessibleSummary,
    this.onPointTap,
    this.minY,
    this.maxY,
  });

  final List<AppLineChartSeries> series;
  final String accessibleSummary;
  final ValueChanged<AppChartPoint>? onPointTap;
  final double? minY, maxY;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final textScaler = MediaQuery.textScalerOf(context);

    // Диапазон Y: finite padding, нулевой диапазон не даёт division by zero.
    final allY = series.expand((s) => s.points.map((p) => p.y)).toList();
    var minY =
        this.minY ??
        (allY.isEmpty ? 0.0 : allY.reduce((a, b) => a < b ? a : b));
    var maxY =
        this.maxY ??
        (allY.isEmpty ? 1.0 : allY.reduce((a, b) => a > b ? a : b));
    if (minY == maxY) {
      minY = minY - 1;
      maxY = maxY + 1;
    }
    final span = maxY - minY;
    minY -= span * 0.1;
    maxY += span * 0.1;

    final maxLength = series.fold<int>(
      0,
      (max, s) => s.points.length > max ? s.points.length : max,
    );
    // Подписи не микроскопические: не более ~6 подписей на ось.
    final labelInterval = math.max(1, (maxLength / 6).ceil()).toDouble();

    final firstSeries = series.firstOrNull;
    final spotsCount = firstSeries?.points.length ?? 0;

    return Semantics(
      label: accessibleSummary,
      child: ExcludeSemantics(
        child: LineChart(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 250),
          LineChartData(
            minY: minY,
            maxY: maxY,
            minX: 0,
            maxX: spotsCount > 1 ? (spotsCount - 1).toDouble() : 1,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: scheme.outlineVariant, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: labelInterval,
                  reservedSize: 8 + textScaler.scale(20),
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    final label =
                        (firstSeries != null &&
                            index >= 0 &&
                            index < firstSeries.points.length)
                        ? firstSeries.points[index].label
                        : '';
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => scheme.inverseSurface,
                getTooltipItems: (touchedSpots) => <LineTooltipItem?>[
                  for (final spot in touchedSpots)
                    LineTooltipItem(
                      _tooltipFor(spot.barIndex, spot.spotIndex),
                      TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              touchCallback: (event, response) {
                if (onPointTap == null) return;
                if (!event.isInterestedForInteractions) return;
                final spot = response?.lineBarSpots?.firstOrNull;
                if (spot == null) return;
                final point = _pointFor(spot.barIndex, spot.x.round());
                if (point != null) onPointTap!(point);
              },
            ),
            lineBarsData: <LineChartBarData>[
              for (final s in series)
                LineChartBarData(
                  spots: <FlSpot>[
                    for (var i = 0; i < s.points.length; i++)
                      FlSpot(i.toDouble(), s.points[i].y),
                  ],
                  color: ChartSeriesColors.resolve(context, s.colorKey),
                  barWidth: 2,
                  isCurved: false,
                  dashArray: s.dashed ? const <int>[6, 4] : null,
                  dotData: FlDotData(show: s.showMarkers),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _tooltipFor(int barIndex, int spotIndex) {
    final s = series[barIndex];
    final p = s.points[spotIndex];
    return '${s.label}: ${p.valueText}';
  }

  AppChartPoint? _pointFor(int barIndex, int spotIndex) {
    if (barIndex >= series.length) return null;
    final points = series[barIndex].points;
    if (spotIndex >= points.length) return null;
    return points[spotIndex];
  }
}
