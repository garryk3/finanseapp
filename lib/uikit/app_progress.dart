// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Прогресс: `value == null` — неопределённый; иначе clamp 0..1.
/// [label] видимая подпись, [semanticLabel] — доступное описание состояния.
///
/// Экраны: Цели (progress bar цели), GoalDetails (прогресс/дефицит),
/// Настройки (прогресс импорта/экспорта).
class AppProgress extends StatelessWidget {
  const AppProgress({
    super.key,
    required this.value,
    this.label,
    this.semanticLabel,
  });

  final double? value; // null = indeterminate, иначе clamp 0..1
  final String? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final clamped = value == null ? null : value!.clamp(0.0, 1.0);
    final indicator = LinearProgressIndicator(
      value: clamped,
      semanticsLabel: semanticLabel ?? label,
    );
    if (label == null) return indicator;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        indicator,
        const SizedBox(height: AppSpacing.xs),
        AppText(label!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
