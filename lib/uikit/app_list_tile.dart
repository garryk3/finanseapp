// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Стандартный list tile: title (обязателен), subtitle, leading/trailing.
/// Вся область — один tap target ≥48dp; trailing-элементы сохраняют
/// собственные targets.
///
/// Экраны: Ещё, Настройки, Валюты, Справочники (банки/брокеры, категории),
/// Аудит, детали операций (связанные записи).
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effectiveSubtitle = subtitle == null
        ? null
        : AppText(
            subtitle!,
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          );
    final callback = (onTap == null || !enabled) ? null : onTap;
    final tile = ListTile(
      title: AppText(
        title,
        style: textTheme.bodyLarge,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
      subtitle: effectiveSubtitle,
      leading: leading,
      trailing: trailing,
      onTap: callback,
      enabled: enabled,
      minTileHeight: 56,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
    );
    return semanticLabel == null
        ? tile
        : Semantics(label: semanticLabel, child: tile);
  }
}
