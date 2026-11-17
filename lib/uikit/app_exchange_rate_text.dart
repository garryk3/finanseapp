// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Строка курса: значение, источник и дата; ручной курс помечается
/// иконкой/подписью [manual]. Недоступный курс отображает View текстом
/// «Курс недоступен», не нулём (finance.md §4).
///
/// Экраны: TransactionDetails, CashflowDetails (курс операции),
/// ValuationForm (ручной курс), CurrencyForm, курсовая секция Настроек.
class AppExchangeRateText extends StatelessWidget {
  const AppExchangeRateText({
    super.key,
    required this.formattedRate,
    required this.sourceLabel,
    required this.dateText,
    this.manual = false,
  });

  final String formattedRate, sourceLabel, dateText;
  final bool manual;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$formattedRate, $sourceLabel, $dateText',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (manual) ...<Widget>[
            Icon(
              Icons.edit_outlined,
              size: 14,
              color: scheme.onSurfaceVariant,
              semanticLabel: null,
            ),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Flexible(
            child: AppText(
              '$formattedRate · $sourceLabel · $dateText',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
