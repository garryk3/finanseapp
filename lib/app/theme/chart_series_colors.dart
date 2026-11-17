// ignore_for_file: type=lint
// Зона дизайн-токенов: chart tokens (см. DESIGN.md §7, uikit/design/charts.md).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';

/// Ключи цветовых серий графиков.
enum AppChartSeriesKey { netWorth, income, expense, assets, goals }

/// Резолвер цветов серий: netWorth→primary, income→semantic income,
/// expense→semantic expense, assets→secondary, goals→tertiary.
///
/// Различие серий дублируется dash/marker/legend label, не только цветом.
///
/// Экраны: Аналитика (line/bar графики), Dashboard (chart teaser).
abstract final class ChartSeriesColors {
  static Color resolve(BuildContext context, AppChartSeriesKey key) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    return switch (key) {
      AppChartSeriesKey.netWorth => scheme.primary,
      AppChartSeriesKey.income => semantic.income,
      AppChartSeriesKey.expense => semantic.expense,
      AppChartSeriesKey.assets => scheme.secondary,
      AppChartSeriesKey.goals => scheme.tertiary,
    };
  }
}
