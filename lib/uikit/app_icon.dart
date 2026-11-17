// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Иконка с обязательной доступностью: [semanticLabel] для content-иконок,
/// `null` — для декоративных (исключается из Semantics).
///
/// Экраны: все экраны — leading/trailing иконки тайлов, кнопок, метрик,
/// type-иконки операций (Доход/Расход/Перевод).
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color, semanticLabel: semanticLabel);
  }
}
