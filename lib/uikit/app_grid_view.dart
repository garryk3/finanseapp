// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Ленивая сетка с явным делегатом. Ячейки имеют bounded extent,
/// не зависящий от одной строки текста (DESIGN.md §4).
///
/// Экраны: плотные сетки дочерних элементов на широких экранах —
/// Аналитика (категории), Категории, Активы (миниатюры при необходимости).
class AppGridView extends StatelessWidget {
  const AppGridView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.controller,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      padding: padding,
      controller: controller,
    );
  }
}
