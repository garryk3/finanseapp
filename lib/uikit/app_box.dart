// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Layout-helper: padding/margin/size/color/border одним виджетом.
/// Цвет — только из темы; raw `Color(...)` запрещён даже здесь (DESIGN.md §2).
///
/// Экраны: редкий helper для локальных отступов и подложек — Dashboard,
/// Аналитика, детали активов.
class AppBox extends StatelessWidget {
  const AppBox({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.border,
    this.borderRadius,
    this.clipBehavior = Clip.none,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding, margin;
  final double? width, height;
  final Color? color;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: border,
        borderRadius: borderRadius,
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
