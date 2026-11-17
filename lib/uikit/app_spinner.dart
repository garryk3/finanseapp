// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Индикатор загрузки. [semanticLabel] обязателен для самостоятельного
/// spinner'а (иначе «Загрузка» по умолчанию).
///
/// Экраны: блокирующая загрузка деталей, inline-загрузка курсов ЦБ,
/// обновление списков.
class AppSpinner extends StatelessWidget {
  const AppSpinner({
    super.key,
    this.size = 24,
    this.semanticLabel = 'Загрузка',
  });

  final double size;

  /// Семантический ярлык — переопределяется feature (l10n).
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(semanticsLabel: semanticLabel),
    );
  }
}
