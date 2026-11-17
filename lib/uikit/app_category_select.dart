// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Категория дохода/расхода как presentation-опция.
/// [colorKey] — только allowlisted semantic key
/// (`primary|secondary|tertiary|surfaceContainerHighest`), иначе neutral.
class AppCategoryOption {
  const AppCategoryOption({
    required this.id,
    required this.name,
    this.icon,
    this.colorKey,
    this.archived = false,
  });

  final int id;
  final String name;
  final IconData? icon;
  final String? colorKey;
  final bool archived;
}

/// Резолвер allowlisted colorKey в цвет категории; неизвестный ключ —
/// нейтральный fallback onSurfaceVariant, не Color.parse (finance.md §2).
Color resolveCategoryColor(BuildContext context, String? colorKey) {
  final scheme = Theme.of(context).colorScheme;
  return switch (colorKey) {
    'primary' => scheme.primary,
    'secondary' => scheme.secondary,
    'tertiary' => scheme.tertiary,
    'surfaceContainerHighest' => scheme.surfaceContainerHighest,
    _ => scheme.onSurfaceVariant,
  };
}

/// Выбор категории дохода/расхода. Архивные категории видны только как
/// текущее historical value и не выбираются (inputs.md §3).
///
/// Экраны: CashflowForm (категория записи), фильтры журнала Операций,
/// фильтры Аналитики (по категориям).
class AppCategorySelect extends StatelessWidget {
  const AppCategorySelect({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.valueId,
    this.errorText,
    this.enabled = true,
    this.kindLabel,
    this.archivedLabel,
  });

  final String label;
  final List<AppCategoryOption> items;
  final ValueChanged<int> onChanged;
  final int? valueId;
  final String? errorText, kindLabel;

  /// Подпись архивных опций — приходит из feature View.
  final String? archivedLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected = items.where((item) => item.id == valueId).firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(label, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        InkWell(
          onTap: enabled
              ? () async {
                  final result = await showAppSelectSheet<int>(
                    context: context,
                    items: <AppSelectItem<int>>[
                      for (final item in items)
                        AppSelectItem<int>(
                          value: item.id,
                          label: item.name,
                          subtitle: item.archived ? archivedLabel : kindLabel,
                          icon: item.icon,
                          enabled: !item.archived,
                        ),
                    ],
                    selectedValue: valueId,
                    title: label,
                    searchable: true,
                  );
                  if (result != null) onChanged(result);
                }
              : null,
          borderRadius: AppRadii.input,
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: errorText,
              helperText: kindLabel,
            ),
            isEmpty: selected == null,
            child: Row(
              children: <Widget>[
                if (selected?.icon != null) ...<Widget>[
                  Icon(
                    selected!.icon,
                    size: 18,
                    color: resolveCategoryColor(context, selected.colorKey),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: AppText(
                    selected?.name ?? '—',
                    style: textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
