// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Актив как presentation-опция: имя, вид, валюта; архивные доступны
/// только как текущее historical value.
class AppAssetOption {
  const AppAssetOption({
    required this.id,
    required this.name,
    required this.kindLabel,
    required this.currencyCode,
    this.archived = false,
  });

  final int id;
  final String name, kindLabel, currencyCode;
  final bool archived;
}

/// Выбор актива из searchable-списка. Архивные активы не выбираются
/// для новых записей (inputs.md §3).
///
/// Экраны: TransactionForm (актив операции), TransferForm (from/to счета),
/// CashflowForm (связь со счётом), GoalForm (eligible-активы цели),
/// фильтры Операций/Активов.
class AppAssetSelect extends StatelessWidget {
  const AppAssetSelect({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.valueId,
    this.errorText,
    this.enabled = true,
    this.searchable = true,
    this.archivedLabel,
  });

  final String label;
  final List<AppAssetOption> items;
  final ValueChanged<int> onChanged;
  final int? valueId;
  final String? errorText;
  final bool enabled, searchable;

  /// Подпись архивных опций — приходит из feature View.
  final String? archivedLabel;

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
                          subtitle: item.archived
                              ? archivedLabel
                              : '${item.kindLabel} · ${item.currencyCode}',
                          enabled: !item.archived,
                        ),
                    ],
                    selectedValue: valueId,
                    title: label,
                    searchable: searchable,
                  );
                  if (result != null) onChanged(result);
                }
              : null,
          borderRadius: AppRadii.input,
          child: InputDecorator(
            decoration: InputDecoration(errorText: errorText),
            isEmpty: selected == null,
            child: AppText(
              selected?.name ?? '—',
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
