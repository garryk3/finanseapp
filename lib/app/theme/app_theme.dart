// ignore_for_file: type=lint
// Зона дизайн-токенов: seed-цвет и прямые Color(...) разрешены только здесь
// (см. DESIGN.md, AGENTS.md «Сырые Material-виджеты»).
import 'package:material_ui/material_ui.dart';

/// Централизованные темы приложения (Material 3, светлая + тёмная).
abstract final class AppTheme {
  /// Сид-цвет схемы. Черновик из DESIGN.md — заменить решением владельца.
  static const Color seedColor = Color(0xFF2E7D32);

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
    );
  }
}
