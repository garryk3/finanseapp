// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Tooltip графика: заголовок точки и строки exact formatted values
/// (не raw double). Используется внутри line/bar touch-data.
///
/// Экраны: Аналитика, Dashboard — всплывающие значения точек графиков.
class AppChartTooltip extends StatelessWidget {
  const AppChartTooltip({super.key, required this.title, required this.rows});

  final String title;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppText(
            title,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onInverseSurface,
            ),
          ),
          for (final row in rows)
            AppText(
              row,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onInverseSurface,
              ),
            ),
        ],
      ),
    );
  }
}
