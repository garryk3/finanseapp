// ignore_for_file: type=lint
// Зона дизайн-токенов: spacing/shape scale приложения (см. DESIGN.md §4).
import 'package:material_ui/material_ui.dart';

/// Единый spacing scale (4/8/12/16/24/32/48) и layout-константы.
///
/// Экраны: все экраны приложения (сетки, отступы карточек и форм).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Минимальный touch target (WCAG 2.2 AA).
  static const double minTouchTarget = 48;

  /// Максимальная ширина контентных сеток (dashboard, аналитика).
  static const double contentMaxWidth = 1200;

  /// Максимальная ширина форм — они остаются одной колонкой даже на широких экранах.
  static const double formMaxWidth = 640;

  /// Breakpoint адаптивной сетки: `<600dp` — одна колонка, `>=600dp` — две.
  static const double twoColumnBreakpoint = 600;

  /// Горизонтальный padding экрана: compact 16, expanded 24.
  static double screenPadding(double width) =>
      width >= twoColumnBreakpoint ? lg : md;
}

/// Радиусы скругления поверхностей.
///
/// Экраны: карточки, инпуты, шимеры, sheets — все поверхности приложения.
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
