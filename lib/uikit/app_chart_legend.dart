// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/app/theme/chart_series_colors.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';

/// Легенда графика: цвет/тип линии + подпись серии (Wrap — переносится
/// при 320dp и font scale 1.3).
///
/// Экраны: Аналитика (под line/bar графиками), Dashboard (chart teaser).
class AppChartLegend extends StatelessWidget {
  const AppChartLegend({super.key, required this.items});

  final List<AppChartLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        for (final item in items)
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: _Marker(item: item),
                ),
                TextSpan(text: ' ${item.label}'),
              ],
            ),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.item});

  final AppChartLegendItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (item.markerIcon != null) {
      return Icon(item.markerIcon, size: 14, color: scheme.onSurfaceVariant);
    }
    if (item.dashed) {
      return Container(
        width: 16,
        height: 0,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: scheme.onSurfaceVariant, width: 2),
          ),
        ),
      );
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: ChartSeriesColors.resolve(context, item.colorKey),
        shape: BoxShape.circle,
      ),
    );
  }
}
