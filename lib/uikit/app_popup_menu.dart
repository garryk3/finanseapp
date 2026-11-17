// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Пункт popup-меню со значением, подписью и опциональной иконкой.
class AppPopupMenuItem<T> {
  const AppPopupMenuItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Overflow-меню для редких действий тайла (edit/archive/delete).
/// Не содержит destructive default без подтверждения (patterns.md §4).
///
/// Экраны: trailing-действия списков — Операции, Активы, Цели, Валюты,
/// Категории, Аудит, детали операций.
class AppPopupMenu<T> extends StatelessWidget {
  const AppPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    required this.tooltip,
    this.icon = Icons.more_vert,
    this.enabled = true,
  });

  final List<AppPopupMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      icon: Icon(icon),
      enabled: enabled,
      onSelected: onSelected,
      itemBuilder: (context) => <PopupMenuEntry<T>>[
        for (final item in items)
          PopupMenuItem<T>(
            value: item.value,
            child: Row(
              children: <Widget>[
                if (item.icon != null) ...<Widget>[
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(item.label),
              ],
            ),
          ),
      ],
    );
  }
}
