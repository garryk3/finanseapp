// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/uikit/app_amount_blur.dart';
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
    // Для neutral сохраняется цвет стиля (deleted/archived приглушение);
    // смысловой тон всегда сильнее цвета стиля — иначе цвет textTheme,
    // который M3 проставляет всем стилям, молча перебивал бы тон
    // (finance.md §2).
    final resolvedColor = tone == AppMoneyTone.neutral
        ? style?.color
        : resolveMoneyToneColor(context, tone);
    final effectiveStyle = base?.copyWith(
      color: resolvedColor,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    // D21.4: под активным AppMoneyVisibility сумма прячется за блюром и
    // исключается из семантики.
    return AppAmountBlur(
      child: AppText(
        formattedAmount,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
