// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Секция формы: заголовок (titleMedium), опциональный subtitle, общая
/// ошибка секции и поля с ритмом 16dp. Errors не сдвигают label за
/// пределы viewport (inputs.md §4).
///
/// Экраны: все формы — AccountForm, InvestmentForm, PropertyForm,
/// TransactionForm, TransferForm, CashflowForm, ValuationForm, GoalForm,
/// CategoryForm, CurrencyForm.
class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.errorText,
  });

  final String title;
  final String? subtitle, errorText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(title, style: textTheme.titleMedium),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          AppText(
            subtitle!,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (errorText != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          AppText(
            errorText!,
            style: textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
        SizedBox(height: children.isEmpty ? 0 : AppSpacing.md),
        for (var i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          children[i],
        ],
      ],
    );
  }
}
