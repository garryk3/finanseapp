// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';

/// Горизонтальный ряд фильтров с кнопкой сброса. Reset показывается только
/// при `activeCount > 0` и сбрасывает одним callback (inputs.md §4).
///
/// Узкие экраны: полоса прокручивается горизонтально, показывает контрастный
/// scrollbar, edge-fade и подводит выбранный [AppFilterChip] в видимую область
/// (inputs.md §4, TC-122).
///
/// Экраны: Операции (тип/категория/период), Активы (kind/архив/query),
/// Аналитика (период/kind/категории), Аудит (тип/query), Детализация.
class AppFilterBar extends StatefulWidget {
  const AppFilterBar({
    super.key,
    required this.children,
    this.onReset,
    this.resetLabel,
    this.activeCount = 0,
  });

  final List<Widget> children;
  final VoidCallback? onReset;
  final String? resetLabel;
  final int activeCount;

  @override
  State<AppFilterBar> createState() => _AppFilterBarState();
}

class _AppFilterBarState extends State<AppFilterBar> {
  final GlobalKey _selectedKey = GlobalKey();
  final ScrollController _controller = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateScrollEdges);
    _selectedIndex = _findSelectedIndex();
    _scheduleScrollToSelected();
  }

  @override
  void didUpdateWidget(covariant AppFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = _findSelectedIndex();
    if (selected != _selectedIndex) {
      _selectedIndex = selected;
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

  int _findSelectedIndex() {
    for (var i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      if (child is AppFilterChip && child.selected) return i;
    }
    return -1;
  }

  void _scheduleScrollToSelected() {
    if (_selectedIndex < 0) return;
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
    final showReset = widget.onReset != null && widget.activeCount > 0;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: AppSpacing.minTouchTarget,
          child: Stack(
            children: [
              ScrollbarTheme(
                data: Theme.of(context).scrollbarTheme.copyWith(
                  thumbColor: WidgetStatePropertyAll(scheme.primary),
                  trackColor: WidgetStatePropertyAll(
                    scheme.surfaceContainerHighest,
                  ),
                ),
                child: Scrollbar(
                  controller: _controller,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 3,
                  radius: const Radius.circular(3),
                  child: SingleChildScrollView(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: <Widget>[
                        for (var i = 0; i < widget.children.length; i++)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              end: AppSpacing.xs,
                            ),
                            child: KeyedSubtree(
                              key: i == _selectedIndex ? _selectedKey : null,
                              child: widget.children[i],
                            ),
                          ),
                      ],
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
          ),
        ),
        if (showReset)
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: widget.resetLabel ?? 'Сбросить фильтры',
              variant: AppButtonVariant.text,
              onPressed: widget.onReset,
            ),
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
      bottom: 0,
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
