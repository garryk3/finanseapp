// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Chip: подпись + опциональная иконка, selectable, опциональный delete.
/// Delete-кнопка имеет собственный target с обязательным [deleteTooltip].
///
/// Экраны: фильтры и подсказки-статусы — Операции, Активы, Аналитика,
/// Аудит; выбранные связи в формах (CashflowForm, TransactionForm).
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.deleteTooltip,
    this.color,
  }) : assert(onDeleted == null || deleteTooltip != null);

  final String label;
  final IconData? icon;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final String? deleteTooltip;

  /// Цвет иконки (category colorKey и т.п.); `null` — цвет по умолчанию.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Widget chip = icon == null
        ? Chip(
            label: Text(label),
            onDeleted: onDeleted,
            deleteIcon: onDeleted == null
                ? null
                : Tooltip(
                    message: deleteTooltip!,
                    child: const Icon(Icons.close, size: 18),
                  ),
          )
        : Chip(
            avatar: Icon(icon, size: 18, color: color),
            label: Text(label),
            onDeleted: onDeleted,
            deleteIcon: onDeleted == null
                ? null
                : Tooltip(
                    message: deleteTooltip!,
                    child: const Icon(Icons.close, size: 18),
                  ),
          );
    if (onSelected == null) return chip;
    final selectedChip = FilterChip(
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null ? null : Icon(icon, size: 18, color: color),
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: onDeleted == null
          ? null
          : Tooltip(
              message: deleteTooltip!,
              child: const Icon(Icons.close, size: 18),
            ),
    );
    return selectedChip;
  }
}
