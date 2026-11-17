// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Тонкий разделитель `outlineVariant` (1dp, из темы).
///
/// Экраны: Аудит (хронология ревизий), детали операций/активов, списки
/// Настроек и Ещё.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent = 0, this.endIndent = 0});

  final double indent, endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(indent: indent, endIndent: endIndent, height: 1);
  }
}
