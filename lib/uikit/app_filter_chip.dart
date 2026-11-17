// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Chip фильтра с опциональной иконкой и счётчиком совпадений.
///
/// Экраны: фильтры журналов и аналитики — Операции (тип/категория/счёт),
/// Активы (вид/архив), Аналитика (период/kind/категория), Аудит (тип).
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.count,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final text = count == null ? label : '$label ($count)';
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null ? null : Icon(icon, size: 18),
      label: Text(text),
    );
  }
}
