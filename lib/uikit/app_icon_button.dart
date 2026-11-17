// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_button.dart';

/// Icon-only кнопка. [tooltip] обязателен — единственный текстовый канал
/// для icon-only действия (touch target ≥48dp).
///
/// Экраны: все экраны — trailing-действия тайлов (edit/delete/archive),
/// очистка поиска, действия app bar, закрытие sheets.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.variant = AppButtonVariant.text,
    this.pending = false,
    this.pendingLabel = 'Выполняется',
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool pending;

  /// Семантический статус pending — переопределяется feature (l10n).
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final callback = (onPressed == null || pending) ? null : onPressed;
    final scheme = Theme.of(context).colorScheme;
    final spinner = SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
    );
    final effectiveIcon = pending ? spinner : Icon(icon);
    final button = switch (variant) {
      AppButtonVariant.filled => IconButton.filled(
        tooltip: tooltip,
        onPressed: callback,
        icon: effectiveIcon,
      ),
      AppButtonVariant.tonal => IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: callback,
        icon: effectiveIcon,
      ),
      AppButtonVariant.outlined => IconButton.outlined(
        tooltip: tooltip,
        onPressed: callback,
        icon: effectiveIcon,
      ),
      AppButtonVariant.destructive => IconButton(
        tooltip: tooltip,
        onPressed: callback,
        icon: effectiveIcon,
        style: IconButton.styleFrom(foregroundColor: scheme.error),
      ),
      AppButtonVariant.text => IconButton(
        tooltip: tooltip,
        onPressed: callback,
        icon: effectiveIcon,
      ),
    };
    return Semantics(
      label: tooltip,
      button: true,
      enabled: callback != null,
      value: pending ? pendingLabel : null,
      child: button,
    );
  }
}
