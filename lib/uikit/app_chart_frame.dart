// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Каркас графика: заголовок, подзаголовок, действия и bounded height.
/// [accessibleSummary] — полная русская строка (период, последнее/min/max,
/// направление); canvas внутри child исключается из Semantics, поэтому
/// под графиком feature Screen обязан показать text alternative тех же
/// точек (charts.md §2).
///
/// [semanticsHidden] исключает денежную сводку из подписи (D21.4): заголовок
/// остаётся читаемым, а суммы не попадают в TalkBack.
///
/// Экраны: Аналитика (net worth line, cashflow bars), Dashboard
/// (chart teaser).
class AppChartFrame extends StatelessWidget {
  const AppChartFrame({
    super.key,
    required this.title,
    required this.child,
    required this.accessibleSummary,
    this.subtitle,
    this.actions = const <Widget>[],
    this.height = 240,
    this.semanticsHidden = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String accessibleSummary;
  final List<Widget> actions;
  final double height;

  /// `true` — не включать [accessibleSummary] в подпись (скрытые суммы).
  final bool semanticsHidden;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsHidden ? title : '$title. $accessibleSummary',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: AppRadii.card,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppText(
                        title,
                        style: textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        AppText(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                for (final action in actions) action,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: height,
              child: ExcludeSemantics(child: child),
            ),
          ],
        ),
      ),
    );
  }
}
