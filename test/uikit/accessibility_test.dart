// ignore_for_file: type=lint
// Тестовая фикстура: raw Material-виджеты разрешены (зона test/**, CI-гард проверяет только lib/).
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/uikit/uikit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Accessibility-матрица (design/README.md): light/dark, 320dp,
/// font scale 1.3, длинный русский текст — без overflow и с читаемой
/// семантикой.
void main() {
  const longTitle =
      'Очень длинное название финансовой операции, которое должно '
      'полностью переноситься без обрезки';

  Widget harness(Widget child, {required ThemeData theme}) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: Scaffold(body: SizedBox(width: 320, height: 900, child: child)),
      ),
    );
  }

  final themes = <String, ThemeData>{
    'light': AppTheme.light(),
    'dark': AppTheme.dark(),
  };

  for (final entry in themes.entries) {
    group('${entry.key}, 320dp, 1.3', () {
      testWidgets('операция + актив + цель + summary — без overflow', (
        tester,
      ) async {
        final overflows = <FlutterErrorDetails>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = overflows.add;
        addTearDown(() => FlutterError.onError = prevOnError);
        await tester.binding.setSurfaceSize(const Size(320, 960));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          harness(
            const SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  AppSummaryCard(
                    title: longTitle,
                    value: '−123 456 789 012,34 ₽',
                    subtitle: longTitle,
                  ),
                  SizedBox(height: 16),
                  AppOperationListTile(
                    title: longTitle,
                    typeLabel: 'Расход',
                    icon: Icons.arrow_downward,
                    amountText: '−1 250,50 ₽',
                    dateText: '15 ноября 2026',
                    tone: AppMoneyTone.expense,
                    categoryLabel: longTitle,
                    comment: longTitle,
                  ),
                  AppAssetListTile(
                    name: longTitle,
                    kindLabel: 'Инвестиции · брокер',
                    amountText: '1 250 000,00 HKD',
                    baseAmountText: '12 345 678,90 ₽',
                    archived: true,
                    archivedLabel: 'Архив',
                  ),
                  AppGoalCard(
                    name: longTitle,
                    progressText: '125 000,00 ₽',
                    targetText: '1 000 000,00 ₽',
                    ratio: 0.125,
                    statusLabel: 'Активна',
                    deadlineText: '31 декабря 2027',
                    deficitText: 'Не хватает 875 000,00 ₽',
                  ),
                ],
              ),
            ),
            theme: entry.value,
          ),
        );
        await tester.pump();
        expect(
          overflows.where((d) => d.exceptionAsString().contains('overflowed')),
          isEmpty,
        );
      });

      testWidgets('суммы доступны полностью через Semantics', (tester) async {
        await tester.pumpWidget(
          harness(
            const AppMoneyText(
              '−123 456 789 012,34 ₽',
              tone: AppMoneyTone.expense,
              semanticsLabel: 'Расход: −123 456 789 012,34 ₽',
            ),
            theme: entry.value,
          ),
        );
        expect(
          find.bySemanticsLabel('Расход: −123 456 789 012,34 ₽'),
          findsOneWidget,
        );
      });
    });
  }
}
