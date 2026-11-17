// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Простая tap-область без ink-эффекта (статичные карточки, overlay-hit).
/// Disabled не вызывает callback.
///
/// Экраны: выбор периода Аналитики, подменю списков, tap-зоны поверх
/// неинтерактивного контента — Dashboard, Операции.
class AppTapRegion extends StatelessWidget {
  const AppTapRegion({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final callback = (onTap == null || !enabled) ? null : onTap;
    final region = GestureDetector(onTap: callback, child: child);
    return semanticLabel == null
        ? region
        : Semantics(
            label: semanticLabel,
            button: true,
            enabled: enabled,
            child: region,
          );
  }
}
