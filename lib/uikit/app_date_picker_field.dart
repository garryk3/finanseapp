// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Поле выбора даты: read-only инпут с иконкой календаря, открывает Material
/// date picker (RU-локаль из MaterialApp). Возвращает DateTime без
/// бизнес-конвертации — ViewModel преобразует LocalDate (inputs.md §2).
///
/// Экраны: TransactionForm, TransferForm, CashflowForm (дата операции),
/// ValuationForm (дата оценки), GoalForm (targetDate), фильтры периода
/// Аналитики.
class AppDatePickerField extends StatelessWidget {
  const AppDatePickerField({
    super.key,
    required this.label,
    required this.valueText,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.enabled = true,
  });

  final String label, valueText;
  final DateTime firstDate, lastDate;
  final ValueChanged<DateTime> onChanged;
  final String? errorText, helperText;
  final bool enabled;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().clamp(firstDate, lastDate),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(label, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        InkWell(
          onTap: enabled ? () => _pickDate(context) : null,
          borderRadius: AppRadii.input,
          child: InputDecorator(
            decoration: InputDecoration(
              helperText: helperText,
              errorText: errorText,
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            isEmpty: false,
            child: AppText(
              valueText,
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

extension on DateTime {
  DateTime clamp(DateTime min, DateTime max) {
    if (isBefore(min)) return min;
    if (isAfter(max)) return max;
    return this;
  }
}
