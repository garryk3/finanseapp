// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Ленивый или фиксированный список. Для неограниченных журналов используется
/// `.builder` (DESIGN.md §4: lazy builder для journals).
///
/// Экраны: все списки приложения — журналы Операций/Активов/Целей, Ещё,
/// Настройки, Аудит, результаты поиска.
class AppListView extends StatelessWidget {
  const AppListView({
    super.key,
    required this.children,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
  }) : itemCount = null,
       itemBuilder = null;

  const AppListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.physics,
  }) : children = null,
       shrinkWrap = false;

  final List<Widget>? children;
  final int? itemCount;
  final NullableIndexedWidgetBuilder? itemBuilder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final builder = itemBuilder;
    if (builder != null) {
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: builder,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        controller: controller,
      );
    }
    return ListView(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      children: children ?? const <Widget>[],
    );
  }
}
