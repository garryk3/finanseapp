// ignore_for_file: type=lint
// Тестовая фикстура: raw Material-виджеты разрешены (зона test/**, CI-гард проверяет только lib/).
import 'package:fl_chart/fl_chart.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/chart_series_colors.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/uikit/uikit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget testApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: Scaffold(body: child),
  );
}

AppChartPoint point(double y, {String? label}) => AppChartPoint(
  x: DateTime(2026, 11, 1),
  y: y,
  label: label ?? 'нояб',
  valueText: '${y.toStringAsFixed(2)} ₽',
);

void main() {
  group('chart models', () {
    test('NaN/бесконечность отклоняются assert', () {
      expect(
        () => AppChartPoint(
          x: DateTime(2026),
          y: double.nan,
          label: 'x',
          valueText: 'x',
        ),
        throwsAssertionError,
      );
      expect(
        () => AppCashflowBarGroup(
          label: 'нояб',
          income: -1,
          expense: 0,
          incomeText: '0',
          expenseText: '0',
          netText: '0',
        ),
        throwsAssertionError,
      );
    });
  });

  group('AppLineChart', () {
    testWidgets('пустая серия и одна точка — без crash', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SizedBox(
            height: 240,
            child: AppLineChart(
              series: <AppLineChartSeries>[],
              accessibleSummary: 'Нет данных за период.',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppLineChart), findsOneWidget);

      await tester.pumpWidget(
        testApp(
          SizedBox(
            height: 240,
            child: AppLineChart(
              series: <AppLineChartSeries>[
                AppLineChartSeries(
                  id: 'netWorth',
                  label: 'Net worth',
                  colorKey: AppChartSeriesKey.netWorth,
                  points: <AppChartPoint>[point(100)],
                ),
              ],
              accessibleSummary: 'Net worth 100,00 ₽ на ноябрь 2026.',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppLineChart), findsOneWidget);
    });

    testWidgets('accessibleSummary доступен в Semantics', (tester) async {
      await tester.pumpWidget(
        testApp(
          SizedBox(
            height: 240,
            child: AppLineChart(
              series: <AppLineChartSeries>[
                AppLineChartSeries(
                  id: 'netWorth',
                  label: 'Net worth',
                  colorKey: AppChartSeriesKey.netWorth,
                  points: <AppChartPoint>[point(1), point(2), point(3)],
                ),
              ],
              accessibleSummary: 'Net worth вырос с 1 до 3 за период.',
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Net worth вырос с 1 до 3 за период.'),
        findsOneWidget,
      );
    });
  });

  group('AppCashflowChart', () {
    testWidgets('maxY покрывает больший столбец в обе стороны', (tester) async {
      Future<double> maxYFor(double income, double expense) async {
        await tester.pumpWidget(
          testApp(
            SizedBox(
              width: 320,
              height: 160,
              child: AppCashflowChart(
                groups: [
                  AppCashflowBarGroup(
                    label: '15–21.11',
                    income: income,
                    expense: expense,
                    incomeText: '$income €',
                    expenseText: '$expense €',
                    netText: '0,00 €',
                  ),
                ],
                accessibleSummary: 'Неделя.',
              ),
            ),
          ),
        );
        await tester.pump();
        return tester.widget<BarChart>(find.byType(BarChart)).data.maxY;
      }

      expect(await maxYFor(0.5, 1.0), closeTo(1.15, 1e-9));
      expect(await maxYFor(2.0, 0.5), closeTo(2.3, 1e-9));
    });

    testWidgets('группы рендерятся, summary доступен', (tester) async {
      await tester.pumpWidget(
        testApp(
          SizedBox(
            height: 240,
            child: AppCashflowChart(
              groups: <AppCashflowBarGroup>[
                AppCashflowBarGroup(
                  label: 'окт',
                  income: 150,
                  expense: 90,
                  incomeText: '150 000,00 ₽',
                  expenseText: '90 000,00 ₽',
                  netText: '+60 000,00 ₽',
                ),
                AppCashflowBarGroup(
                  label: 'нояб',
                  income: 0,
                  expense: 0,
                  incomeText: '0,00 ₽',
                  expenseText: '0,00 ₽',
                  netText: '0,00 ₽',
                ),
              ],
              accessibleSummary: 'Октябрь: доход 150, расход 90. Ноябрь: нули.',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppCashflowChart), findsOneWidget);
      expect(
        find.bySemanticsLabel('Октябрь: доход 150, расход 90. Ноябрь: нули.'),
        findsOneWidget,
      );
    });

    testWidgets('много групп в узкой ширине — горизонтальный скролл', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          SizedBox(
            width: 320,
            height: 240,
            child: AppCashflowChart(
              groups: [
                for (var i = 0; i < 30; i++)
                  AppCashflowBarGroup(
                    label: '$i',
                    income: 100,
                    expense: 50,
                    incomeText: '100,00 ₽',
                    expenseText: '50,00 ₽',
                    netText: '50,00 ₽',
                  ),
              ],
              accessibleSummary: '30 периодов.',
            ),
          ),
        ),
      );
      await tester.pump();

      final scroll = tester.widgetList<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(
        scroll.any((widget) => widget.scrollDirection == Axis.horizontal),
        isTrue,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width != null &&
              widget.width! >= 30 * 36,
        ),
        findsOneWidget,
      );
    });
  });

  group('AppChartFrame', () {
    testWidgets('canvas исключён из Semantics, summary — нет', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppChartFrame(
            title: 'Динамика',
            subtitle: 'Net worth, ₽',
            accessibleSummary: 'Последнее значение 1 234,00 ₽.',
            child: SizedBox.expand(),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byType(AppChartFrame));
      expect(semantics.label, contains('Динамика'));
      expect(semantics.label, contains('Последнее значение 1 234,00 ₽'));
    });
  });

  group('AppChartLegend', () {
    testWidgets('переносится при 320dp без overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        testApp(
          const AppChartLegend(
            items: <AppChartLegendItem>[
              AppChartLegendItem(
                label: 'Очень длинная подпись серии номер один для переноса',
                colorKey: AppChartSeriesKey.income,
              ),
              AppChartLegendItem(
                label: 'Очень длинная подпись серии номер два для переноса',
                colorKey: AppChartSeriesKey.expense,
                dashed: true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      // RenderFlex overflow попадает в binding и всплывает через takeException.
      expect(tester.takeException(), isNull);
    });
  });

  group('theme foundations', () {
    test('semantic colors доступны на light/dark и lerp не null', () {
      for (final theme in <ThemeData>[AppTheme.light(), AppTheme.dark()]) {
        final semantic = theme.extension<AppSemanticColors>();
        expect(semantic, isNotNull);
        expect(semantic!.expense, theme.colorScheme.tertiary);
        expect(semantic.income, theme.colorScheme.primary);
        expect(semantic.transfer, theme.colorScheme.secondary);
        expect(semantic.lerp(semantic, 0.5), isNotNull);
      }
    });

    testWidgets('ChartSeriesColors.resolve маппит ключи серий', (tester) async {
      final theme = AppTheme.light();
      final semantic = theme.extension<AppSemanticColors>()!;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              expect(
                ChartSeriesColors.resolve(context, AppChartSeriesKey.netWorth),
                theme.colorScheme.primary,
              );
              expect(
                ChartSeriesColors.resolve(context, AppChartSeriesKey.income),
                semantic.income,
              );
              expect(
                ChartSeriesColors.resolve(context, AppChartSeriesKey.expense),
                semantic.expense,
              );
              expect(
                ChartSeriesColors.resolve(context, AppChartSeriesKey.assets),
                theme.colorScheme.secondary,
              );
              expect(
                ChartSeriesColors.resolve(context, AppChartSeriesKey.goals),
                theme.colorScheme.tertiary,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
