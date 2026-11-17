// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Форматированная денежная строка с тоном (income/expense/transfer/
/// neutral) и tabular figures. Строку форматирует feature presentation
/// layer — здесь только отображение (finance.md §1).
///
/// Экраны: Dashboard (net worth, cashflow), детали активов (баланс,
/// оценки), TransactionDetails/CashflowDetails (суммы), Аналитика.
class AppMoneyText extends StatelessWidget {
  const AppMoneyText(
    this.formattedAmount, {
    super.key,
    this.tone = AppMoneyTone.neutral,
    this.style,
    this.textAlign,
    this.maxLines,
    this.semanticsLabel,
  });

  final String formattedAmount;
  final AppMoneyTone tone;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleSmall;
    // Явный цвет вызывающего (deleted/archived приглушение) имеет приоритет
    // над тоном; цвет дефолтного стиля темы — нет, иначе тон не применится
    // (finance.md §4).
    final Color? explicitColor = style?.color;
    final effectiveStyle = base?.copyWith(
      color: explicitColor ?? resolveMoneyToneColor(context, tone),
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    return AppText(
      formattedAmount,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      semanticsLabel: semanticsLabel,
    );
  }
}
