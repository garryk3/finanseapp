# Charts: presentation API и доступность

Графики используют `fl_chart` только внутри UIKit. Domain не конвертируется в double для
учёта: ViewModel заранее получает точные values, а presentation mapper отдельно создаёт
ограниченные chart values и точные formatted labels.

## 1. Models

```dart
class AppChartPoint {
  const AppChartPoint({
    required this.x, required this.y, required this.label,
    required this.valueText,
  });
  final DateTime x;
  final double y;
  final String label, valueText;
}

class AppLineChartSeries {
  const AppLineChartSeries({
    required this.id, required this.label, required this.colorKey,
    required this.points, this.dashed = false, this.showMarkers = true,
  });
  final String id, label;
  final AppChartSeriesKey colorKey;
  final List<AppChartPoint> points;
  final bool dashed, showMarkers;
}

class AppCashflowBarGroup {
  const AppCashflowBarGroup({
    required this.label, required this.income,
    required this.expense, required this.incomeText,
    required this.expenseText, required this.netText,
  });
  final String label;
  final double income, expense;
  final String incomeText, expenseText, netText;
}

class AppChartLegendItem {
  const AppChartLegendItem({
    required this.label, required this.colorKey,
    this.dashed = false, this.markerIcon,
  });
  final String label;
  final AppChartSeriesKey colorKey;
  final bool dashed;
  final IconData? markerIcon;
}
```

Points сортируются по x в presentation mapper. Пустой список — AppEmptyState вне chart;
одна точка имеет visible marker и не вызывает division by zero в range. NaN/infinity
запрещены assert и заменяются ошибкой данных до рендера. Negative expense в bar model не
используется: expense — неотрицательная height, знак читается в formatted net.

## 2. Widgets

```dart
class AppChartFrame extends StatelessWidget {
  const AppChartFrame({
    super.key, required this.title, required this.child,
    required this.accessibleSummary, this.subtitle, this.actions,
    this.height = 240,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final String accessibleSummary;
  final List<Widget> actions;
  final double height;
}

class AppChartLegend extends StatelessWidget {
  const AppChartLegend({super.key, required this.items});
  final List<AppChartLegendItem> items;
}

class AppChartTooltip extends StatelessWidget {
  const AppChartTooltip({
    super.key, required this.title, required this.rows,
  });
  final String title;
  final List<String> rows;
}

class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key, required this.series, required this.accessibleSummary,
    this.onPointTap, this.minY, this.maxY,
  });
  final List<AppLineChartSeries> series;
  final String accessibleSummary;
  final ValueChanged<AppChartPoint>? onPointTap;
  final double? minY, maxY;
}

class AppCashflowChart extends StatelessWidget {
  const AppCashflowChart({
    super.key, required this.groups, required this.accessibleSummary,
    this.onGroupTap,
  });
  final List<AppCashflowBarGroup> groups;
  final String accessibleSummary;
  final ValueChanged<AppCashflowBarGroup>? onGroupTap;
}
```

`accessibleSummary` — полная русская строка с period, последним/min/max значением и
направлением. Текстовая альтернатива: для net worth — expand/collapsed text table или
list тех же точек под графиком; для cashflow — отдельная страница «Детализация» со
списком точек и ссылкой под графиком. `AppChartFrame` сам данные не дублирует и не
вычисляет.

## 3. Поведение

- Frame имеет surfaceContainerLow, 16dp padding, bounded height 240; не glass/gradient.
- Axis labels берутся из `AppChartPoint.label`; density подбирается по width, но все labels
  доступны в text alternative. Horizontal scroll используется для большого числа periods,
  а не микроскопические подписи. Минимальная ширина группы cashflow-графика — 36dp;
  при переполнении контейнера включается горизонтальный скролл. Шаг подписей считается
  по фактической ширине `labelSmall` (text scale) и ширине слота, пропуск применяется
  в `getTitlesWidget` (fl_chart BarChart рисует подпись на каждую группу и `interval`
  не фильтрует), шаг якорится на последний период — текущая дата всегда подписана.
  Поэтому на 320dp/1.3 подписи недель не пересекаются.
- Tooltip содержит exact formatted values, не raw double. Tap/focus tooltip не единственный
  способ получить значение.
- Line income/expense отличаются label + dash/marker, не только цветом. Zero baseline и
  нулевой диапазон имеют finite padding. Огромные minor units преобразуются presentation
  mapper с проверкой finite double; учётные значения при этом не меняются.
- Remove animations отключает chart animation. TalkBack читает summary и список, canvas
  не превращается в сотни неинформативных nodes.

## 4. Chart tests

- Empty, single point, all zero, positive/negative net, >100 periods и одинаковые dates
  валидируются mapper до chart.
- Tooltip exact strings, series labels/dashes, text alternative имеет каждую точку.
- Light/dark contrast, 320dp/font 1.3 без overflow; semantics summary присутствует.
- `double.nan`/infinity отклоняются тестом presentation mapper; AppChart не падает.
- Golden покрывает representative line и grouped bars, но не заменяет semantics/unit tests.
