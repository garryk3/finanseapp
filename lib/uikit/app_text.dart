// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Базовый текст приложения. Стили — только из темы (роли M3, см. DESIGN.md).
class AppText extends StatelessWidget {
  const AppText(this.data, {super.key, this.style, this.textAlign});

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(data, style: style, textAlign: textAlign);
  }
}
