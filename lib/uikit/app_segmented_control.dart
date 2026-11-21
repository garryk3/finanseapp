// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Сегмент single-select переключателя.
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// M3 segmented control (single-select; пустой selected запрещён — assert).
///
/// [expanded] растягивает сегменты по ширине. Не-expanded вариант нужен для
/// узких экранов и длинных подписей: содержимое прокручивается горизонтально,
/// показывает контрастный scrollbar, edge-fade и автоматически подводит
/// выбранный сегмент в видимую область (inputs.md §4). Прокручивается только
/// сама полоса, родительский вертикальный список не двигается.
///
/// Экраны: хост Операции (Доходы и расходы / Операции по активам / Регулярные),
/// CategoriesScreen (доходы/расходы), AuditScreen (asset tx / cashflow),
/// SubgroupsScreen (банки/брокеры), Аналитика (периоды).
class AppSegmentedControl<T> extends StatefulWidget {
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
  State<AppSegmentedControl<T>> createState() => _AppSegmentedControlState<T>();
}

class _AppSegmentedControlState<T> extends State<AppSegmentedControl<T>> {
  final GlobalKey _selectedKey = GlobalKey();
  final ScrollController _controller = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateScrollEdges);
    _scheduleScrollToSelected();
  }

  @override
  void didUpdateWidget(covariant AppSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected.single != widget.selected.single) {
      _scheduleScrollToSelected();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateScrollEdges)
      ..dispose();
    super.dispose();
  }

  void _scheduleScrollToSelected() {
    if (widget.expanded) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateScrollEdges();
      final context = _selectedKey.currentContext;
      if (context == null || !_controller.hasClients) return;
      final renderObject = context.findRenderObject();
      if (renderObject == null) return;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      unawaited(
        _controller.position.ensureVisible(
          renderObject,
          alignment: 0.5,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  void _updateScrollEdges() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final canLeft = position.pixels > 0.5;
    final canRight = position.pixels < position.maxScrollExtent - 0.5;
    if (canLeft == _canScrollLeft && canRight == _canScrollRight) return;
    setState(() {
      _canScrollLeft = canLeft;
      _canScrollRight = canRight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected.single;
    final control = SegmentedButton<T>(
      segments: <ButtonSegment<T>>[
        for (final segment in widget.segments)
          ButtonSegment<T>(
            value: segment.value,
            label: KeyedSubtree(
              key: !widget.expanded && segment.value == selected
                  ? _selectedKey
                  : null,
              child: Text(segment.label),
            ),
            icon: segment.icon == null ? null : Icon(segment.icon, size: 18),
          ),
      ],
      selected: widget.selected,
      onSelectionChanged: widget.onSelectionChanged,
      showSelectedIcon: false,
    );
    if (widget.expanded) {
      return SizedBox(width: double.infinity, child: control);
    }
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        ScrollbarTheme(
          data: Theme.of(context).scrollbarTheme.copyWith(
            thumbColor: WidgetStatePropertyAll(scheme.primary),
            trackColor: WidgetStatePropertyAll(scheme.surfaceContainerHighest),
          ),
          child: Scrollbar(
            controller: _controller,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 3,
            radius: const Radius.circular(3),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: control,
              ),
            ),
          ),
        ),
        if (_canScrollLeft)
          _EdgeFade(
            alignment: AlignmentDirectional.centerStart,
            color: scheme.surface,
          ),
        if (_canScrollRight)
          _EdgeFade(
            alignment: AlignmentDirectional.centerEnd,
            color: scheme.surface,
          ),
      ],
    );
  }
}

class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.alignment, required this.color});

  final AlignmentGeometry alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fromLeft = alignment == AlignmentDirectional.centerStart;
    return PositionedDirectional(
      start: fromLeft ? 0 : null,
      end: fromLeft ? null : 0,
      top: 0,
      bottom: 6,
      width: 20,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: fromLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: fromLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
