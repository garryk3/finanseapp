// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_bottom_sheet.dart';
import 'package:finanseapp/uikit/app_search_field.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Элемент generic select: значение, подпись, опциональные subtitle/icon;
/// disabled элементы видны, но не выбираются.
class AppSelectItem<T> {
  const AppSelectItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
}

/// Показывает bottom sheet с поиском (опционально) и списком опций.
/// Возвращает выбранное значение через `Navigator.pop`.
///
/// Экраны: все select-поля форм — выбор валюты, категории, актива, базовой
/// валюты, видов из справочников.
Future<T?> showAppSelectSheet<T>({
  required BuildContext context,
  required List<AppSelectItem<T>> items,
  T? selectedValue,
  String? title,
  bool searchable = false,
  String searchLabel = 'Поиск',
}) {
  return showAppBottomSheet<T>(
    context: context,
    builder: (sheetContext) => _AppSelectSheet<T>(
      items: items,
      selectedValue: selectedValue,
      title: title,
      searchable: searchable,
      searchLabel: searchLabel,
    ),
  );
}

class _AppSelectSheet<T> extends StatefulWidget {
  const _AppSelectSheet({
    required this.items,
    this.selectedValue,
    this.title,
    this.searchable = false,
    this.searchLabel = 'Поиск',
  });

  final List<AppSelectItem<T>> items;
  final T? selectedValue;
  final String? title;
  final bool searchable;
  final String searchLabel;

  @override
  State<_AppSelectSheet<T>> createState() => _AppSelectSheetState<T>();
}

class _AppSelectSheetState<T> extends State<_AppSelectSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final query = _query.trim().toLowerCase();
    final items = widget.searchable && query.isNotEmpty
        ? widget.items
              .where(
                (item) =>
                    item.label.toLowerCase().contains(query) ||
                    (item.subtitle?.toLowerCase().contains(query) ?? false),
              )
              .toList()
        : widget.items;

    return AppBottomSheet(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (widget.searchable) ...<Widget>[
            AppSearchField(
              controller: _searchController,
              label: widget.searchLabel,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = item.value == widget.selectedValue;
                return InkWell(
                  onTap: item.enabled
                      ? () => Navigator.of(context).pop(item.value)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: <Widget>[
                        if (item.icon != null) ...<Widget>[
                          Icon(
                            item.icon,
                            size: 20,
                            color: item.enabled
                                ? scheme.onSurfaceVariant
                                : scheme.outline,
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AppText(
                                item.label,
                                style: textTheme.bodyLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                              if (item.subtitle != null)
                                AppText(
                                  item.subtitle!,
                                  style: textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (selected) Icon(Icons.check, color: scheme.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic select: поле с выбранным значением, открывает список опций в
/// bottom sheet. Отсутствие value среди items — assert в debug и безопасный
/// hint в production (inputs.md §2).
///
/// Экраны: редко напрямую — формы предпочитают специализированные selects;
/// BaseCurrencyScreen (выбор из enabled-валют), справочники.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.searchable = false,
    this.searchLabel = 'Поиск',
  });

  final String label;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T> onChanged;
  final T? value;
  final String? hint, errorText;
  final bool enabled, searchable;
  final String searchLabel;

  @override
  Widget build(BuildContext context) {
    assert(value == null || items.any((item) => item.value == value));
    final textTheme = Theme.of(context).textTheme;
    final selectedItem = items.where((item) => item.value == value).firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(label, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        InkWell(
          onTap: enabled
              ? () async {
                  final result = await showAppSelectSheet<T>(
                    context: context,
                    items: items,
                    selectedValue: value,
                    title: label,
                    searchable: searchable,
                    searchLabel: searchLabel,
                  );
                  if (result != null) onChanged(result);
                }
              : null,
          borderRadius: AppRadii.input,
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: errorText,
              suffixIcon: const Icon(Icons.unfold_more),
            ),
            isEmpty: selectedItem == null,
            child: AppText(
              selectedItem?.label ?? hint ?? '—',
              style: textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
