// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';

/// Grouped bar chart денежного потока: рядом столбцы дохода и расхода за
/// период; знак итога читается в [AppCashflowBarGroup.netText], zero
/// baseline обязателен. Tooltip — exact formatted values.
///
/// Экраны: Аналитика (доходы/расходы по периодам), Dashboard (cashflow
/// teaser), Операции (summary-график).
class AppCashflowChart extends StatelessWidget {
  const AppCashflowChart({
    super.key,
    required this.groups,
    required this.accessibleSummary,
    this.onGroupTap,
    this.incomeLabel = 'Доход',
    this.expenseLabel = 'Расход',
  });

  final List<AppCashflowBarGroup> groups;
  final String accessibleSummary;
  final ValueChanged<AppCashflowBarGroup>? onGroupTap;

  /// Подписи серий в tooltip — chrome-строки, feature может переопределить.
  final String incomeLabel, expenseLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final maxValue = groups.fold<double>(
      0,
      (max, group) => math.max(max, math.max(group.income, group.expense)),
    );
    final top = maxValue <= 0 ? 1.0 : maxValue * 1.15;

    return Semantics(
      label: accessibleSummary,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Много периодов: минимальная ширина группы + горизонтальный
            // скролл вместо слипшихся столбцов (charts.md §3).
            final contentWidth = math.max(
              constraints.maxWidth,
              groups.length * 36.0 + 24,
            );
            // Шаг подписей считаем по фактической ширине текста и слоту:
            // fl_chart для BarChart рисует подпись на каждую группу и interval
            // не фильтрует, поэтому пропуск делается в getTitlesWidget.
            final labelStyle = Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant);
            final textScaler = MediaQuery.textScalerOf(context);
            var labelWidth = 0.0;
            for (final group in groups) {
              final painter = TextPainter(
                text: TextSpan(text: group.label, style: labelStyle),
                textDirection: TextDirection.ltr,
                textScaler: textScaler,
              )..layout();
              labelWidth = math.max(labelWidth, painter.width);
              painter.dispose();
            }
            final slotWidth = contentWidth <= constraints.maxWidth
                ? constraints.maxWidth / math.max(1, groups.length)
                : 36.0;
            final labelStep = math.max(
              1,
              ((labelWidth + 8) / math.max(1, slotWidth)).ceil(),
            );
            // Якорь на последний период: текущая/последняя дата всегда видна.
            final labelStart = groups.isEmpty
                ? 0
                : (groups.length - 1) % labelStep;
            final chart = SizedBox(
              width: contentWidth,
              child: BarChart(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                BarChartData(
                  maxY: top,
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
                        interval: labelStep.toDouble(),
                        reservedSize: 8 + textScaler.scale(20),
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 ||
                              index >= groups.length ||
                              (index - labelStart) % labelStep != 0) {
                            return const SizedBox.shrink();
                          }
                          final label = groups[index].label;
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(label, style: labelStyle),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => scheme.inverseSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final g = groups[groupIndex];
                        final text = switch (rodIndex) {
                          0 => '$incomeLabel: ${g.incomeText}',
                          1 => '$expenseLabel: ${g.expenseText}',
                          _ => '${g.netText}',
                        };
                        return BarTooltipItem(
                          '${g.label}\n$text',
                          TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onInverseSurface,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (onGroupTap == null) return;
                      if (!event.isInterestedForInteractions) return;
                      final touched = response?.spot?.touchedBarGroupIndex;
                      if (touched == null || touched >= groups.length) return;
                      onGroupTap!(groups[touched]);
                    },
                  ),
                  barGroups: <BarChartGroupData>[
                    for (var i = 0; i < groups.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: <BarChartRodData>[
                          BarChartRodData(
                            toY: groups[i].income,
                            color: semantic.income,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: groups[i].expense,
                            color: semantic.expense,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
            if (contentWidth <= constraints.maxWidth) return chart;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: chart,
            );
          },
        ),
      ),
    );
  }
}
