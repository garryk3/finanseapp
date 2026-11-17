// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Radio-опция списка: подпись кликабельна как одна target ≥48dp, выбор
/// читается Semantics (selected value группы не зависит от цвета).
/// Группа управляется [RadioGroup]-предком (Flutter 3.32+: groupValue/
/// onChanged у самих Radio не используются).
///
/// Экраны: BaseCurrencyScreen (выбор базовой валюты), формы с единственным
/// выбором из списка (вид операции, kind категории), фильтры.
class AppRadioListTile<T> extends StatelessWidget {
  const AppRadioListTile({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final String? subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tile = RadioGroup<T>(
      groupValue: groupValue,
      onChanged: (T? selected) {
        if (selected != null) onChanged?.call(selected);
      },
      child: RadioListTile<T>(
        title: AppText(label, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: subtitle == null
            ? null
            : AppText(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        value: value,
      ),
    );
    if (enabled) return tile;
    return Semantics(
      enabled: false,
      child: IgnorePointer(child: Opacity(opacity: 0.6, child: tile)),
    );
  }
}
