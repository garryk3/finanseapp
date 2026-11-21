// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_ink_well.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Tile операции (доход/расход/пополнение/снятие/перевод): typeLabel + icon
/// обязательны и попадают в Semantics вместе со знаком суммы — смысл не
/// только цветом. Связанная запись — badge [linkedLabel] без второй суммы
/// в aggregate (finance.md §2).
///
/// Экраны: журналы Операции (cashflow + транзакции). Пустые части meta-строки
/// опускаются, чтобы не оставлять висячий разделитель.
class AppOperationListTile extends StatelessWidget {
  const AppOperationListTile({
    super.key,
    required this.title,
    required this.typeLabel,
    required this.icon,
    required this.amountText,
    required this.dateText,
    required this.tone,
    this.categoryLabel,
    this.accountLabel,
    this.comment,
    this.linkedLabel,
    this.deleted = false,
    this.deletedLabel,
    this.showDeletedBadge = true,
    this.onTap,
  }) : assert(!deleted || deletedLabel != null);

  final String title, typeLabel;
  final IconData icon;
  final String amountText, dateText;
  final AppMoneyTone tone;
  final String? categoryLabel, accountLabel, comment, linkedLabel;
  final bool deleted;
  final String? deletedLabel;

  /// Бейдж «удалено» можно скрыть, когда контекст задаёт сам экран (аудит).
  final bool showDeletedBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final secondary = scheme.onSurfaceVariant;
    final primaryText = deleted ? secondary : scheme.onSurface;
    final metaParts = <String>[
      if (categoryLabel != null) categoryLabel!,
      if (accountLabel != null) accountLabel!,
    ];
    final semanticLabel = <String>[
      typeLabel,
      title,
      amountText,
      if (dateText.trim().isNotEmpty) dateText,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    return Semantics(
      label: semanticLabel,
      child: AppInkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  icon,
                  size: 22,
                  color: deleted
                      ? secondary
                      : resolveMoneyToneColor(context, tone),
                  semanticLabel: typeLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: AppText(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              color: primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (deleted && showDeletedBadge) ...<Widget>[
                          const SizedBox(width: AppSpacing.xs),
                          _StatusBadge(label: deletedLabel!, deleted: true),
                        ] else if (linkedLabel != null) ...<Widget>[
                          const SizedBox(width: AppSpacing.xs),
                          _StatusBadge(label: linkedLabel!, deleted: false),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      <String>[typeLabel, dateText, ...metaParts]
                          .map((part) => part.trim())
                          .where((part) => part.isNotEmpty)
                          .join(' · '),
                      style: textTheme.bodySmall?.copyWith(color: secondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    if (comment != null) ...<Widget>[
                      const SizedBox(height: 2),
                      AppText(
                        comment!,
                        style: textTheme.bodySmall?.copyWith(color: secondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: AppMoneyText(
                  amountText,
                  tone: deleted ? AppMoneyTone.neutral : tone,
                  style: textTheme.titleSmall?.copyWith(color: primaryText),
                  maxLines: 1,
                  semanticsLabel: amountText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.deleted});

  final String label;
  final bool deleted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final bg = deleted ? semantic.onArchived : scheme.secondaryContainer;
    final fg = deleted ? semantic.archived : scheme.onSecondaryContainer;
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
