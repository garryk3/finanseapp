// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Summary-карточка «заголовок — главное значение — подпись» с опциональными
/// leading/trailing и tap (карточки ведут к отфильтрованным данным,
/// DESIGN.md §6 Dashboard).
///
/// Экраны: Dashboard (net worth, cashflow месяца, цели — тизер),
/// Активы (итоги по видам), Аналитика (summary периода).
class AppSummaryCard extends StatelessWidget {
  const AppSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.tone = AppMoneyTone.neutral,
  });

  final String title, value;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onTap;
  final AppMoneyTone tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      semanticLabel: '$title, $value',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: AppText(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppMoneyText(
            value,
            tone: tone,
            style: textTheme.headlineSmall,
            maxLines: 2,
            semanticsLabel: '$title: $value',
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
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
