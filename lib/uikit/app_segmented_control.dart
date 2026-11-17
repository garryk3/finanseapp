// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Сегмент single-select переключателя.
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// M3 segmented control (single-select; пустой selected запрещён — assert).
/// [expanded] растягивает сегменты по ширине; при узком экране и длинных
/// подписях не-expanded вариант прокручивается горизонтально (inputs.md §4).
///
/// Экраны: хост Операции (Денежный поток / Транзакции), CategoriesScreen
/// (доходы/расходы), AuditScreen (asset tx / cashflow), SubgroupsScreen
/// (банки/брокеры), Аналитика (периоды).
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.expanded = true,
  }) : assert(selected.length == 1, 'single-select требует ровно один segment');

  final List<AppSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final control = SegmentedButton<T>(
      segments: <ButtonSegment<T>>[
        for (final segment in segments)
          ButtonSegment<T>(
            value: segment.value,
            label: Text(segment.label),
            icon: segment.icon == null ? null : Icon(segment.icon, size: 18),
          ),
      ],
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      showSelectedIcon: false,
    );
    if (expanded) {
      return SizedBox(width: double.infinity, child: control);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: control,
    );
  }
}
