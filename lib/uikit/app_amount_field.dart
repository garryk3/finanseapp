// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Фильтр денежного ввода: цифры и один decimal separator (`.` или `,`),
/// максимум [maxFractionDigits] знаков после него, без минуса и экспоненты.
/// Конвертацию в Money и валидацию выполняет feature logic (inputs.md §1).
class AppAmountInputFormatter extends TextInputFormatter {
  AppAmountInputFormatter({this.maxFractionDigits = 2});

  final int maxFractionDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');
    final buffer = StringBuffer();
    var hasSeparator = false;
    var fractionDigits = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final isDigit = char.compareTo('0') >= 0 && char.compareTo('9') <= 0;
      if (isDigit) {
        if (hasSeparator) {
          if (fractionDigits >= maxFractionDigits) return oldValue;
          fractionDigits++;
        }
        buffer.write(char);
      } else if (char == '.') {
        if (hasSeparator) return oldValue;
        hasSeparator = true;
        buffer.write(char);
      } else {
        return oldValue;
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: newValue.selection.copyWith(
        baseOffset: newValue.selection.baseOffset.clamp(0, buffer.length),
        extentOffset: newValue.selection.extentOffset.clamp(0, buffer.length),
      ),
    );
  }
}

/// Денежное поле: numeric keyboard с decimal, суффикс валюты справа
/// (не часть возвращаемой строки), валидация ввода на лету.
///
/// Экраны: все денежные формы — TransactionForm, TransferForm (обе ноги),
/// CashflowForm, ValuationForm (оценка, ручной курс), GoalForm (target),
/// CurrencyForm (курс), AccountForm (opening), InvestmentForm, PropertyForm
/// (purchase price).
class AppAmountField extends StatelessWidget {
  const AppAmountField({
    super.key,
    required this.controller,
    required this.label,
    required this.currencySuffix,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.allowZero = false,
    this.maxFractionDigits = 2,
  });

  final TextEditingController controller;
  final String label, currencySuffix;
  final String? errorText, helperText;
  final ValueChanged<String>? onChanged;
  final bool enabled, autofocus;

  /// Нулевая допустимость — семантическая валидация выполняется feature
  /// logic (пустое/ноль/отрицательное/точное — разные field errors,
  /// navigation_and_screens §7); форматтер фильтрует только символы.
  final bool allowZero;
  final int maxFractionDigits;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(label, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        TextField(
          controller: controller,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            AppAmountInputFormatter(maxFractionDigits: maxFractionDigits),
          ],
          decoration: InputDecoration(
            hintText: '0',
            helperText: helperText,
            errorText: errorText,
            suffixText: currencySuffix,
            suffixStyle: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
