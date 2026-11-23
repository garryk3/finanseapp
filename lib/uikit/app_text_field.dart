// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Текстовое поле: label над input (DESIGN.md §5), hint, helper, inline
/// error (связан с input Semantics), prefix/suffix. Disabled не стирает
/// controller.
///
/// Экраны: все формы — название актива/категории/цели, комментарии
/// операций, адрес квартиры, ставка счёта (AccountForm, CategoryForm,
/// TransactionForm, CashflowForm, GoalForm, PropertyForm, CurrencyForm).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.autofocus = false,
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
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            errorMaxLines: 4,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: suffix,
            counterText: maxLength == null ? '' : null,
          ),
        ),
      ],
    );
  }
}
