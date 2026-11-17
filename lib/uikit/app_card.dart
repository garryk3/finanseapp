// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';

/// Карточка: radius 16, elevation 0, тонкая граница `outlineVariant`.
/// Иерархия — через surface-роли, не через тени (DESIGN.md §4).
///
/// Экраны: Dashboard (summary/quick actions), Активы, Цели, Аналитика,
/// Настройки (backup tiles), Ещё, детали операций/активов.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.semanticLabel,
    this.outlined = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: outlined
            ? BorderSide(color: scheme.outlineVariant)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
    final tappable = onTap == null ? card : InkWell(onTap: onTap, child: card);
    return semanticLabel == null
        ? tappable
        : Semantics(label: semanticLabel, child: tappable);
  }
}
