// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_metric.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Итоги денежного потока за период: три метрики (доход/расход/итог).
/// Compact — вертикальный стек, expanded (>=600dp) — три равные колонки,
/// значения не обрезаются (finance.md §1).
///
/// Экраны: Dashboard (cashflow месяца), Операции (summary cashflow-вкладки),
/// Аналитика (итоги выбранного периода).
class AppCashflowSummary extends StatelessWidget {
  const AppCashflowSummary({
    super.key,
    required this.incomeText,
    required this.expenseText,
    required this.netText,
    required this.periodLabel,
    this.incomeLabel = 'Доход',
    this.expenseLabel = 'Расход',
    this.netLabel = 'Итог',
  });

  final String incomeText, expenseText, netText, periodLabel;

  /// Подписи метрик — chrome-строки, по умолчанию на русском; feature может
  /// переопределить (l10n-правило design/README.md).
  final String incomeLabel, expenseLabel, netLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final metrics = <AppMetric>[
      AppMetric(
        label: incomeLabel,
        value: incomeText,
        tone: AppMoneyTone.income,
      ),
      AppMetric(
        label: expenseLabel,
        value: expenseText,
        tone: AppMoneyTone.expense,
      ),
      AppMetric(label: netLabel, value: netText),
    ];
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppSpacing.twoColumnBreakpoint;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppText(
                periodLabel,
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              const SizedBox(height: AppSpacing.md),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var i = 0; i < metrics.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: AppSpacing.lg),
                      // Равные колонки — только в широкой ветке (finance.md §1).
                      Expanded(child: metrics[i]),
                    ],
                  ],
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var i = 0; i < metrics.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      metrics[i],
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
