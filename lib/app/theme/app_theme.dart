// ignore_for_file: type=lint
// Зона дизайн-токенов: seed-цвет и прямые Color(...) разрешены только здесь
// (см. DESIGN.md, AGENTS.md «Сырые Material-виджеты»).
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';

/// Централизованные темы приложения (Material 3, светлая + тёмная).
abstract final class AppTheme {
  /// Сид-цвет схемы. Черновик из DESIGN.md — заменить решением владельца.
  static const Color seedColor = Color(0xFF2E7D32);

  /// Фон видео-заставки: тёмно-зелёный, совпадает с фоном `finsplash.mp4`.
  static const Color splashBackground = Color(0xFF06110E);

  /// Прозрачный вариант фона заставки для градиентных «шторок» по краям.
  static const Color splashBackgroundTransparent = Color(0x0006110E);

  /// Текст/индикатор на тёмном фоне заставки (не зависит от темы).
  static const Color splashForeground = Color(0xFFFFFFFF);

  /// Системные бары на время заставки: тёмно-зелёные со светлыми иконками.
  static const SystemUiOverlayStyle splashOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: splashBackground,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: splashBackground,
    systemNavigationBarDividerColor: splashBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Единственный источник семантических ролей (income/expense/transfer/...).
      extensions: <ThemeExtension<dynamic>>[
        AppSemanticColors.fromScheme(scheme),
      ],
      // Спокойный инструмент: иерархия через surface-роли, не через тени.
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
