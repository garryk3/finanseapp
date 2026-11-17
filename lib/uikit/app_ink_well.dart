// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';

/// Ink-реакция на tap. Disabled не даёт splash/callback.
///
/// Экраны: кликабельные области карточек без собственного onTap — quick
/// actions Dashboard, backup tiles Настройки, детали операций.
class AppInkWell extends StatelessWidget {
  const AppInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.semanticLabel,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final callback = (onTap == null || !enabled) ? null : onTap;
    final ink = InkWell(
      onTap: callback,
      borderRadius: borderRadius ?? AppRadii.card,
      child: child,
    );
    return semanticLabel == null
        ? ink
        : Semantics(
            label: semanticLabel,
            button: true,
            enabled: enabled,
            child: ink,
          );
  }
}
