// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_ink_well.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Tile актива: иконка, имя, вид/подгруппа, исходная стоимость; base
/// equivalent secondary. Архивный актив — стиль onSurfaceVariant + badge
/// [archivedLabel] (визуально и в Semantics).
///
/// Экраны: AssetsScreen (единый список видов), Dashboard (переходы к
/// отфильтрованным активам), GoalForm (eligible-активы).
class AppAssetListTile extends StatelessWidget {
  const AppAssetListTile({
    super.key,
    required this.name,
    required this.kindLabel,
    required this.amountText,
    this.subtitle,
    this.baseAmountText,
    this.icon,
    this.archived = false,
    this.archivedLabel,
    this.onTap,
  }) : assert(!archived || archivedLabel != null);

  final String name, kindLabel, amountText;
  final String? subtitle, baseAmountText;
  final IconData? icon;
  final bool archived;
  final String? archivedLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final secondary = scheme.onSurfaceVariant;
    final primaryText = archived ? secondary : scheme.onSurface;
    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: 22,
                color: archived ? secondary : scheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: AppText(
                          name,
                          style: textTheme.titleSmall?.copyWith(
                            color: primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (archived) ...<Widget>[
                        const SizedBox(width: AppSpacing.xs),
                        _Badge(label: archivedLabel!, archived: true),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    subtitle ?? kindLabel,
                    style: textTheme.bodySmall?.copyWith(color: secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  AppMoneyText(
                    amountText,
                    style: textTheme.titleSmall?.copyWith(color: primaryText),
                    maxLines: 1,
                    semanticsLabel: '$name, $amountText',
                  ),
                  if (baseAmountText != null) ...<Widget>[
                    const SizedBox(height: 2),
                    AppText(
                      baseAmountText!,
                      style: textTheme.bodySmall?.copyWith(color: secondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      semanticsLabel: baseAmountText,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Маленький badge-статус (Архив/Удалено/Связано).
class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.archived = false});

  final String label;
  final bool archived;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final bg = archived ? semantic.onArchived : scheme.secondaryContainer;
    final fg = archived ? semantic.archived : scheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: AppText(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}
