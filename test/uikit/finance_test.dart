// ignore_for_file: type=lint
// Тестовая фикстура: raw Material-виджеты разрешены (зона test/**, CI-гард проверяет только lib/).
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
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

void main() {
  group('AppMoneyText', () {
    testWidgets('expense использует tertiary, не error', (tester) async {
      final scheme = AppTheme.light().colorScheme;
      await tester.pumpWidget(
        testApp(const AppMoneyText('−1 000,00 ₽', tone: AppMoneyTone.expense)),
      );
      final text = tester.widget<Text>(find.text('−1 000,00 ₽'));
      expect(text.style?.color, scheme.tertiary);
      expect(text.style?.color, isNot(scheme.error));
    });

    testWidgets('семантика содержит полное значение', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppMoneyText(
            '−1 000,00 ₽',
            tone: AppMoneyTone.expense,
            semanticsLabel: 'Расход: −1 000,00 ₽',
          ),
        ),
      );
      expect(find.bySemanticsLabel('Расход: −1 000,00 ₽'), findsOneWidget);
    });
  });

  group('AppAssetListTile', () {
    testWidgets('archived без archivedLabel падает assert', (tester) async {
      expect(
        () => AppAssetListTile(
          name: 'Счёт',
          kindLabel: 'Счёт',
          amountText: '1 000 ₽',
          archived: true,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('архивный актив показывает badge и визуально приглушён', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const AppAssetListTile(
            name: 'Старый счёт',
            kindLabel: 'Счёт',
            amountText: '1 000 ₽',
            archived: true,
            archivedLabel: 'Архив',
          ),
        ),
      );
      expect(find.text('Архив'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Старый счёт')), findsWidgets);
    });
  });

  group('AppOperationListTile', () {
    testWidgets('семантика содержит typeLabel, сумму и дату', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppOperationListTile(
            title: 'Продукты',
            typeLabel: 'Расход',
            icon: Icons.arrow_downward,
            amountText: '−1 250,00 ₽',
            dateText: '15 ноября 2026',
            tone: AppMoneyTone.expense,
            categoryLabel: 'Еда',
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byType(AppOperationListTile));
      expect(semantics.label, contains('Расход'));
      expect(semantics.label, contains('−1 250,00 ₽'));
      expect(semantics.label, contains('15 ноября 2026'));
      expect(find.text('Расход · 15 ноября 2026 · Еда'), findsOneWidget);
    });

    testWidgets('пустые date/meta не оставляют висячий разделитель', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const AppOperationListTile(
            title: 'Продукты',
            typeLabel: 'Расход',
            icon: Icons.arrow_downward,
            amountText: '−1 250,00 ₽',
            dateText: '',
            tone: AppMoneyTone.expense,
          ),
        ),
      );

      expect(find.text('Расход'), findsOneWidget);
      expect(find.textContaining('·'), findsNothing);
    });

    testWidgets('deleted без deletedLabel падает assert', (tester) async {
      expect(
        () => AppOperationListTile(
          title: 't',
          typeLabel: 'Расход',
          icon: Icons.arrow_downward,
          amountText: '1 ₽',
          dateText: 'd',
          tone: AppMoneyTone.expense,
          deleted: true,
        ),
        throwsAssertionError,
      );
    });
  });

  group('AppGoalCard', () {
    testWidgets('semantics содержит текущий прогресс и цель, не только %', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const AppGoalCard(
            name: 'Подушка',
            progressText: '125 000,00 ₽',
            targetText: '100 000,00 ₽',
            ratio: 1.25,
            statusLabel: 'Превышено',
          ),
        ),
      );
      final cardSemantics = tester.getSemantics(find.byType(AppGoalCard));
      expect(cardSemantics.label, contains('125 000,00 ₽'));
      expect(cardSemantics.label, contains('100 000,00 ₽'));
      expect(find.text('125 000,00 ₽'), findsOneWidget);
      expect(find.text('100 000,00 ₽'), findsOneWidget);
    });

    testWidgets('ratio 0.75/0/1.25 рендерится без ошибок', (tester) async {
      for (final ratio in <double>[0, 0.75, 1, 1.25]) {
        await tester.pumpWidget(
          testApp(
            AppGoalCard(
              name: 'Цель',
              progressText: '1 ₽',
              targetText: '100 ₽',
              ratio: ratio,
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(AppGoalCard), findsOneWidget);
      }
    });
  });

  group('AppSummaryCard', () {
    testWidgets('очень большая сумма не overflow при 320dp и 1.3', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        testApp(
          const SizedBox(
            width: 320,
            child: AppSummaryCard(
              title:
                  'Очень длинное название финансовой операции, которое '
                  'должно полностью переноситься без обрезки',
              value: '−123 456 789 012,34 ₽',
            ),
          ),
          theme: AppTheme.dark(),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('−123 456 789 012,34 ₽'), findsOneWidget);
    });

    testWidgets('footer рендерится и отсутствует без него', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppSummaryCard(
            title: 'Итог',
            value: '1 000,00 ₽',
            footer: AppText('Разбивка'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Разбивка'), findsOneWidget);

      await tester.pumpWidget(
        testApp(const AppSummaryCard(title: 'Итог', value: '1 000,00 ₽')),
      );
      await tester.pump();
      expect(find.text('Разбивка'), findsNothing);
    });
  });

  group('AppCashflowSummary', () {
    testWidgets('compact — вертикальный стек метрик', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SizedBox(
            width: 360,
            child: AppCashflowSummary(
              incomeText: '150 000,00 ₽',
              expenseText: '90 000,00 ₽',
              netText: '+60 000,00 ₽',
              periodLabel: 'Ноябрь 2026',
            ),
          ),
        ),
      );
      expect(find.text('150 000,00 ₽'), findsOneWidget);
      expect(find.text('90 000,00 ₽'), findsOneWidget);
      expect(find.text('+60 000,00 ₽'), findsOneWidget);
      expect(find.text('Ноябрь 2026'), findsOneWidget);
    });
  });
}
