// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Варианты кнопки: filled — только главный Save/Create; tonal — вторичные
/// (backup/update); text — навигационные; destructive — только delete/replace.
enum AppButtonVariant { filled, tonal, outlined, text, destructive }

/// Кнопка приложения. [pending] сохраняет ширину, показывает spinner
/// и семантику «Выполняется», блокирует повторный callback (DESIGN.md §5).
///
/// Экраны: все экраны — Save/Create в формах, backup-действия Настроек,
/// «Проверить обновление», Retry в error-состояниях, delete/destructive.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.pending = false,
    this.expanded = false,
    this.semanticLabel,
    this.pendingLabel = 'Выполняется',
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool pending, expanded;
  final String? semanticLabel;

  /// Семантический статус pending — переопределяется feature (l10n).
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final callback = (onPressed == null || pending) ? null : onPressed;
    final labelContent = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(label)),
            ],
          );
    // Pending сохраняет ширину: label остаётся невидимым фоном, поверх —
    // спиннер (foundations.md §4: без layout shift).
    final content = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(opacity: pending ? 0 : 1, child: labelContent),
        if (pending)
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: switch (variant) {
                AppButtonVariant.filled => scheme.onPrimary,
                AppButtonVariant.destructive => scheme.onError,
                _ => scheme.primary,
              },
            ),
          ),
      ],
    );
    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: callback,
        child: content,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: callback,
        child: content,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: callback,
        child: content,
      ),
      AppButtonVariant.text => TextButton(onPressed: callback, child: content),
      AppButtonVariant.destructive => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
        ),
        onPressed: callback,
        child: content,
      ),
    };
    final wrapped = expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
    return Semantics(
      label: semanticLabel ?? label,
      button: true,
      enabled: callback != null,
      value: pending ? pendingLabel : null,
      child: wrapped,
    );
  }
}
