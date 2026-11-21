# Inputs, select и фильтры

## 1. Text fields

```dart
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key, required this.label, this.controller, this.focusNode,
    this.hint, this.helperText, this.errorText, this.keyboardType,
    this.textInputAction, this.onChanged, this.onSubmitted,
    this.enabled = true, this.readOnly = false, this.obscureText = false,
    this.maxLines = 1, this.minLines, this.maxLength,
    this.prefixIcon, this.suffix, this.autofocus = false,
  });
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint, helperText, errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled, readOnly, obscureText, autofocus;
  final int maxLines;
  final int? minLines, maxLength;
  final IconData? prefixIcon;
  final Widget? suffix;
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key, required this.controller, required this.label,
    this.hint, this.onChanged, this.onClear, this.enabled = true,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool enabled;
}

class AppAmountField extends StatelessWidget {
  const AppAmountField({
    super.key, required this.controller, required this.label,
    required this.currencySuffix, this.errorText, this.helperText,
    this.onChanged, this.enabled = true, this.autofocus = false,
    this.allowZero = false, this.maxFractionDigits = 2,
  });
  final TextEditingController controller;
  final String label, currencySuffix;
  final String? errorText, helperText;
  final ValueChanged<String>? onChanged;
  final bool enabled, autofocus, allowZero;
  final int maxFractionDigits;
}
```

`AppAmountField` принимает digits и обе `.`/`,` как decimal separator, не допускает
экспоненту и более maxFractionDigits. Он не конвертирует в Money и не округляет: parsing
и ошибки выполняет feature logic. Суффикс валюты не является частью returned string.
Error связывается с input Semantics, keyboard numeric с decimal option, enabled=false
не стирает controller.

## 2. Date и generic select

```dart
class AppDatePickerField extends StatelessWidget {
  const AppDatePickerField({
    super.key, required this.label, required this.valueText,
    required this.firstDate, required this.lastDate, required this.onChanged,
    this.errorText, this.helperText, this.enabled = true,
  });
  final String label, valueText;
  final DateTime firstDate, lastDate;
  final ValueChanged<DateTime> onChanged;
  final String? errorText, helperText;
  final bool enabled;
}

class AppSelectItem<T> {
  const AppSelectItem({
    required this.value, required this.label,
    this.subtitle, this.icon, this.enabled = true,
  });
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
}

class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key, required this.label, required this.items,
    required this.onChanged, this.value, this.hint, this.errorText,
    this.enabled = true, this.searchable = false,
  });
  final String label;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T> onChanged;
  final T? value;
  final String? hint, errorText;
  final bool enabled, searchable;
}
```

Date picker возвращает DateTime без бизнес-конвертации; ViewModel преобразует LocalDate.
Используются Material localizations RU. Generic value сравнивается по equality; отсутствие
value среди items — assert в debug и безопасный hint, не crash в production.

## 3. Финансовые selects — только presentation options

```dart
class AppCurrencyOption {
  const AppCurrencyOption({
    required this.code, required this.name, this.fractionDigits = 2,
    this.enabled = true,
  });
  final String code, name;
  final int fractionDigits;
  final bool enabled;
}

class AppCurrencySelect extends StatelessWidget {
  const AppCurrencySelect({
    super.key, required this.label, required this.items,
    required this.onChanged, this.valueCode, this.errorText,
    this.enabled = true, this.disabledReason,
  });
  final String label;
  final List<AppCurrencyOption> items;
  final ValueChanged<String> onChanged;
  final String? valueCode, errorText, disabledReason;
  final bool enabled;
}

class AppCategoryOption {
  const AppCategoryOption({
    required this.id, required this.name, this.icon,
    this.colorKey, this.archived = false,
  });
  final int id;
  final String name;
  final IconData? icon;
  final String? colorKey;
  final bool archived;
}

class AppCategorySelect extends StatelessWidget {
  const AppCategorySelect({
    super.key, required this.label, required this.items,
    required this.onChanged, this.valueId, this.errorText,
    this.enabled = true, this.kindLabel,
  });
  final String label;
  final List<AppCategoryOption> items;
  final ValueChanged<int> onChanged;
  final int? valueId;
  final String? errorText, kindLabel;
  final bool enabled;
}

class AppAssetOption {
  const AppAssetOption({
    required this.id, required this.name, required this.kindLabel,
    required this.currencyCode, this.archived = false,
  });
  final int id;
  final String name, kindLabel, currencyCode;
  final bool archived;
}

class AppAssetSelect extends StatelessWidget {
  const AppAssetSelect({
    super.key, required this.label, required this.items,
    required this.onChanged, this.valueId, this.errorText,
    this.enabled = true, this.searchable = true,
  });
  final String label;
  final List<AppAssetOption> items;
  final ValueChanged<int> onChanged;
  final int? valueId;
  final String? errorText;
  final bool enabled, searchable;
}
```

Options архивных объектов допустимы только для historical current value; onChanged для
archived не вызывается. Длинный список searchable фильтрует по name/code без сети.
`disabledReason` доступен Semantics и визуально под currency lock.

## 4. Segments и filters

```dart
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

class AppSegmentedControl<T> extends StatefulWidget {
  const AppSegmentedControl({
    super.key, required this.segments, required this.selected,
    required this.onSelectionChanged, this.expanded = true,
  });
  final List<AppSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;

  /// `false` — горизонтальный скролл, контрастный scrollbar с track,
  /// edge-fade и автоподвод выбранного сегмента только по горизонтали
  /// (длинные подписи на узких экранах).
  final bool expanded;
}

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key, required this.label, required this.selected,
    required this.onSelected, this.icon, this.count,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final int? count;
}

class AppFilterBar extends StatelessWidget {
  const AppFilterBar({
    super.key, required this.children, this.onReset, this.resetLabel,
    this.activeCount = 0,
  });
  final List<Widget> children;
  final VoidCallback? onReset;
  final String? resetLabel;
  final int activeCount;
}

class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key, required this.title, required this.children,
    this.subtitle, this.errorText,
  });
  final String title;
  final String? subtitle, errorText;
  final List<Widget> children;
}
```

Single-select control запрещает пустой selected; multi-select используется только filters.
При 320dp segments прокручиваются горизонтально или складываются без обрезки labels.
FilterBar использует horizontal scroll/Wrap и показывает Reset только при activeCount>0.
FormSection задаёт 16/24dp rhythm, errors не сдвигают label за пределы viewport.

## 5. Input tests

- Amount: `1000`, `1000,25`, `1000.25`; reject `1e3`, `-5`, третий знак при 2 digits;
  error/helper и disabled reason читаются Semantics.
- Date limits и RU locale; returned date один раз. Select empty/value missing/long list,
  archived disabled и search.
- Keyboard done/next, clear button 48dp, error restoration после исправления.
- Segments single selection не становится empty; filters Reset сбрасывает один callback.
- Все inputs: light/dark, font scale 1.3, 320dp, длинный label/error без overflow.
