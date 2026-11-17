// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';

/// Заглушка первичной загрузки: статичный блок в surface-роли, исключён из
/// Semantics (не читается TalkBack как текст). Без анимации — спокойный
/// loading-фидбек без декоративного мерцания (DESIGN.md §1).
///
/// Экраны: первичный loading всех экранов со списками/summary — Dashboard,
/// Операции, Активы, Цели, Аналитика, Аудит.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadii.sm,
  });

  final double width, height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
