// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Валюта как presentation-опция select (код, название, дробные знаки).
class AppCurrencyOption {
  const AppCurrencyOption({
    required this.code,
    required this.name,
    this.fractionDigits = 2,
    this.enabled = true,
  });

  final String code, name;
  final int fractionDigits;
  final bool enabled;
}

/// Выбор валюты. Currency lock (disabled) объясняется текстом
/// [disabledReason] — визуально и в Semantics (inputs.md §3).
///
/// Экраны: AccountForm, InvestmentForm, PropertyForm (валюта актива),
/// ValuationForm (валюта оценки), CurrencyForm, BaseCurrencyScreen.
class AppCurrencySelect extends StatelessWidget {
  const AppCurrencySelect({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.valueCode,
    this.errorText,
    this.enabled = true,
    this.disabledReason,
  });

  final String label;
  final List<AppCurrencyOption> items;
  final ValueChanged<String> onChanged;
  final String? valueCode, errorText, disabledReason;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final selected = items.where((item) => item.code == valueCode).firstOrNull;
    final locked = !enabled && disabledReason != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(label, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        InkWell(
          onTap: enabled
              ? () async {
                  final result = await showAppSelectSheet<String>(
                    context: context,
                    items: <AppSelectItem<String>>[
                      for (final item in items)
                        AppSelectItem<String>(
                          value: item.code,
                          label: item.name,
                          subtitle: item.code,
                          enabled: item.enabled,
                        ),
                    ],
                    selectedValue: valueCode,
                    title: label,
                  );
                  if (result != null) onChanged(result);
                }
              : null,
          borderRadius: AppRadii.input,
          child: InputDecorator(
            decoration: InputDecoration(errorText: errorText),
            isEmpty: selected == null,
            child: AppText(
              selected == null ? '—' : '${selected.name} (${selected.code})',
              style: textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (locked) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          Semantics(
            label: disabledReason,
            child: AppText(
              disabledReason!,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
