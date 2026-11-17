// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_progress.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Карточка цели: имя, progress bar (ratio clamp 0..1), точные текущая/
/// целевая суммы и статус. При >100% бар полон, фактический процент
/// приходит в [progressText]/[statusLabel] и не обрезается (finance.md §3).
///
/// Экраны: GoalsScreen (список целей), Dashboard (секция целей).
class AppGoalCard extends StatelessWidget {
  const AppGoalCard({
    super.key,
    required this.name,
    required this.progressText,
    required this.targetText,
    required this.ratio,
    this.statusLabel,
    this.deadlineText,
    this.deficitText,
    this.onTap,
  });

  final String name, progressText, targetText;
  final double ratio;
  final String? statusLabel, deadlineText, deficitText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final secondary = scheme.onSurfaceVariant;
    return AppCard(
      onTap: onTap,
      semanticLabel: '$name, $progressText из $targetText',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: AppText(
                  name,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              if (statusLabel != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: AppText(
                    statusLabel!,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgress(
            value: ratio,
            semanticLabel: '$progressText из $targetText',
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: AppText(
                  progressText,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  semanticsLabel: 'Текущий прогресс: $progressText',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: AppText(
                  targetText,
                  style: textTheme.bodySmall?.copyWith(color: secondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  semanticsLabel: 'Цель: $targetText',
                ),
              ),
            ],
          ),
          if (deadlineText != null || deficitText != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            AppText(
              <String>[
                if (deadlineText != null) deadlineText!,
                if (deficitText != null) deficitText!,
              ].join(' · '),
              style: textTheme.bodySmall?.copyWith(color: secondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ],
        ],
      ),
    );
  }
}
