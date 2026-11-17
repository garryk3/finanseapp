// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Дельта суммы: знак + иконка направления + обязательный [directionLabel]
/// («увеличение»/«уменьшение»/«без изменений») — смысл не только цветом
/// (finance.md §1).
///
/// Экраны: Dashboard (изменение net worth за период), Аналитика
/// (динамика по периодам), GoalDetails (surplus/deficit).
class AppMoneyDelta extends StatelessWidget {
  const AppMoneyDelta({
    super.key,
    required this.formattedDelta,
    required this.directionLabel,
    this.tone = AppMoneyTone.neutral,
    this.showIcon = true,
  });

  final String formattedDelta;
  final String directionLabel;
  final AppMoneyTone tone;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconData = switch (tone) {
      AppMoneyTone.income => Icons.arrow_upward,
      AppMoneyTone.expense => Icons.arrow_downward,
      AppMoneyTone.transfer => Icons.swap_horiz,
      AppMoneyTone.neutral => Icons.remove,
    };
    final color = resolveMoneyToneColor(context, tone);
    return Semantics(
      label: '$formattedDelta, $directionLabel',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showIcon) ...<Widget>[
            Icon(iconData, size: 16, color: color),
            const SizedBox(width: 4),
          ],
          AppMoneyText(
            formattedDelta,
            tone: tone,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (showIcon) ...<Widget>[
            const SizedBox(width: 8),
            AppText(
              directionLabel,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
