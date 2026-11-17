// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// FAB. С [label] становится extended. [pending] блокирует повторный tap.
///
/// Экраны: главное добавление — Операции (доход/расход), Активы
/// (счёт/инвестиция/квартира), Цели (цель).
class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.label,
    this.onPressed,
    this.pending = false,
    this.pendingLabel = 'Выполняется',
  });

  final IconData icon;
  final String tooltip;
  final String? label;
  final VoidCallback? onPressed;
  final bool pending;

  /// Семантический статус pending — переопределяется feature (l10n).
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final callback = (onPressed == null || pending) ? null : onPressed;
    final effectiveIcon = pending
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon);
    final fab = label == null
        ? FloatingActionButton(
            tooltip: tooltip,
            onPressed: callback,
            child: effectiveIcon,
          )
        : FloatingActionButton.extended(
            tooltip: tooltip,
            onPressed: callback,
            icon: effectiveIcon,
            label: Text(label!),
          );
    return Semantics(
      label: tooltip,
      button: true,
      enabled: callback != null,
      value: pending ? pendingLabel : null,
      child: fab,
    );
  }
}
