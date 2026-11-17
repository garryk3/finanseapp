// ignore_for_file: type=lint
// Зона дизайн-токенов: M3-формы поверхностей (см. DESIGN.md §4).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';

/// M3-формы поверхностей приложения: карточки 16, инпуты 12, sheets 24 сверху.
///
/// Экраны: все карточки и поверхности (Dashboard, Активы, Цели, формы, sheets).
abstract final class AppShapes {
  /// Карточка: radius 16, elevation 0 (иерархия через surface-роли).
  static RoundedRectangleBorder card({Color? side}) => RoundedRectangleBorder(
    borderRadius: AppRadii.card,
    side: side == null ? BorderSide.none : BorderSide(color: side, width: 1),
  );

  /// Инпуты и кнопки: radius 12 (M3 full shape управляется их собственными темами).
  static RoundedRectangleBorder input = RoundedRectangleBorder(
    borderRadius: AppRadii.input,
  );

  /// Верхние углы модальных sheets: 24.
  static RoundedRectangleBorder sheetTop = const RoundedRectangleBorder(
    borderRadius: AppRadii.sheetTop,
  );
}
