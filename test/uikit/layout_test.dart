// ignore_for_file: type=lint
// Тестовая фикстура: raw Material-виджеты разрешены (зона test/**, CI-гард проверяет только lib/).
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/uikit/uikit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget testApp(
  Widget child, {
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AppAdaptiveGrid', () {
    Widget grid(double width, {int maxColumns = 2, double? maxWidth}) {
      return testApp(
        SizedBox(
          width: width,
          height: 800,
          child: AppAdaptiveGrid(
            maxColumns: maxColumns,
            maxWidth: maxWidth ?? AppSpacing.contentMaxWidth,
            children: const <Widget>[
              SizedBox(key: Key('c1'), height: 100),
              SizedBox(key: Key('c2'), height: 100),
              SizedBox(key: Key('c3'), height: 100),
            ],
          ),
        ),
      );
    }

    testWidgets('599dp — одна колонка', (tester) async {
      await tester.pumpWidget(grid(599));
      final colFinder = find.byWidgetPredicate(
        (w) => w is Column && w.children.any((c) => c.key == const Key('c1')),
      );
      expect(colFinder, findsOneWidget);
      final rowFinder = find.byWidgetPredicate(
        (w) => w is Row && w.children.any((c) => c.key == const Key('c1')),
      );
      expect(rowFinder, findsNothing);
    });

    testWidgets('600dp и 1100dp (fold/планшет) — две колонки', (tester) async {
      for (final width in <double>[600, 1100]) {
        await tester.pumpWidget(grid(width));
        final rowFinder = find.byWidgetPredicate(
          (w) =>
              w is Row &&
              w.children.any(
                (c) => c is Expanded && c.child.key == const Key('c1'),
              ),
        );
        expect(rowFinder, findsOneWidget, reason: 'width=$width');
      }
    });

    testWidgets('maxColumns: 1 — одна колонка даже на широком экране (формы)', (
      tester,
    ) async {
      await tester.pumpWidget(grid(1100, maxColumns: 1));
      final colFinder = find.byWidgetPredicate(
        (w) => w is Column && w.children.any((c) => c.key == const Key('c1')),
      );
      expect(colFinder, findsOneWidget);
      final rowFinder = find.byWidgetPredicate(
        (w) => w is Row && w.children.any((c) => c.key == const Key('c1')),
      );
      expect(rowFinder, findsNothing);
    });

    testWidgets('контент центрируется с ограничением maxWidth', (tester) async {
      await tester.pumpWidget(grid(1600, maxWidth: 1200));
      final constrained = find.byWidgetPredicate(
        (w) => w is ConstrainedBox && w.constraints.maxWidth == 1200,
      );
      expect(constrained, findsOneWidget);
    });

    testWidgets('320dp + font scale 1.3 + длинный текст — без overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const SizedBox(
            width: 320,
            height: 640,
            child: AppAdaptiveGrid(
              children: <Widget>[
                AppSummaryCard(
                  title:
                      'Очень длинное название финансовой операции, которое '
                      'должно полностью переноситься без обрезки',
                  value: '−123 456 789 012,34 ₽',
                ),
                AppGoalCard(
                  name: 'Очень длинное название финансовой цели для переноса',
                  progressText: '75 000,50 ₽',
                  targetText: '1 000 000,00 ₽',
                  ratio: 0.075,
                ),
              ],
            ),
          ),
          textScaler: const TextScaler.linear(1.3),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
