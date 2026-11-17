// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Метрика «подпись — значение»: value визуально важнее caption, но caption
/// остаётся читаемым (не микроскопический meta, DESIGN.md §5).
///
/// Экраны: Dashboard (cashflow месяца: доход/расход/итог), Аналитика
/// (summary по периоду), GoalDetails (monthly contribution, дефицит).
class AppMetric extends StatelessWidget {
  const AppMetric({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.tone = AppMoneyTone.neutral,
  });

  final String label, value;
  final String? caption;
  final IconData? icon;
  final AppMoneyTone tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final captionColor = scheme.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 16, color: captionColor),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Flexible(
              child: AppText(
                label,
                style: textTheme.bodySmall?.copyWith(color: captionColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        AppMoneyText(
          value,
          tone: tone,
          style: textTheme.titleMedium,
          maxLines: 2,
          semanticsLabel: '$label: $value',
        ),
        if (caption != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          AppText(
            caption!,
            style: textTheme.bodySmall?.copyWith(color: captionColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ],
      ],
    );
  }
}
