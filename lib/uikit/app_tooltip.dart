// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Tooltip для элементов, чей смысл иначе неочевиден (icon-only действия).
///
/// Экраны: все экраны — trailing-действия тайлов, маркеры графиков,
/// пояснения курсоров/иконок в деталях операций.
class AppTooltip extends StatelessWidget {
  const AppTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(message: message, child: child);
  }
}
