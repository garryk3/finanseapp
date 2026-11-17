// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/chart_series_colors.dart';

/// Точка графика: координаты + точные formatted-строки для labels/tooltip.
/// Сортировка по x — задача presentation mapper; NaN/infinity отклоняются
/// assert'ом до рендера (charts.md §1).
class AppChartPoint {
  AppChartPoint({
    required this.x,
    required this.y,
    required this.label,
    required this.valueText,
  }) : assert(
         !y.isNaN && y.isFinite,
         'AppChartPoint.y должен быть конечным числом',
       );

  final DateTime x;
  final double y;
  final String label, valueText;
}

/// Серия линейного графика. Серии различаются label + dash/marker,
/// не только цветом.
class AppLineChartSeries {
  const AppLineChartSeries({
    required this.id,
    required this.label,
    required this.colorKey,
    required this.points,
    this.dashed = false,
    this.showMarkers = true,
  });

  final String id, label;
  final AppChartSeriesKey colorKey;
  final List<AppChartPoint> points;
  final bool dashed, showMarkers;
}

/// Группа столбцов денежного потока: income/expense — неотрицательные
/// высоты, знак читается в [netText].
class AppCashflowBarGroup {
  AppCashflowBarGroup({
    required this.label,
    required this.income,
    required this.expense,
    required this.incomeText,
    required this.expenseText,
    required this.netText,
  }) : assert(income >= 0, 'income — неотрицательная высота столбца'),
       assert(expense >= 0, 'expense — неотрицательная высота столбца'),
       assert(
         !income.isNaN && income.isFinite && !expense.isNaN && expense.isFinite,
         'Значения группы должны быть конечными числами',
       );

  final String label;
  final double income, expense;
  final String incomeText, expenseText, netText;
}

/// Элемент легенды графика.
class AppChartLegendItem {
  const AppChartLegendItem({
    required this.label,
    required this.colorKey,
    this.dashed = false,
    this.markerIcon,
  });

  final String label;
  final AppChartSeriesKey colorKey;
  final bool dashed;
  final IconData? markerIcon;
}
