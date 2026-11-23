// ignore_for_file: type=lint
// Тестовая фикстура: raw Material-виджеты разрешены (зона test/**, CI-гард проверяет только lib/).
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
  group('AppAmountInputFormatter', () {
    TextEditingValue apply(String oldText, String newText) {
      final formatter = AppAmountInputFormatter(maxFractionDigits: 2);
      return formatter.formatEditUpdate(
        TextEditingValue(text: oldText),
        TextEditingValue(text: newText),
      );
    }

    test('принимает целое и дробное через точку и запятую', () {
      expect(apply('', '1000').text, '1000');
      expect(apply('', '1000.25').text, '1000.25');
      expect(apply('', '1000,25').text, '1000.25');
    });

    test('отклоняет экспоненту, минус и буквы', () {
      expect(apply('100', '100e').text, '100');
      expect(apply('', '-5').text, '');
      expect(apply('12', '12a').text, '12');
    });

    test('третий дробный знак при maxFractionDigits=2 отклонён', () {
      expect(apply('12.34', '12.345').text, '12.34');
    });

    test('второй разделитель отклонён', () {
      expect(apply('1.2', '1.2.3').text, '1.2');
    });
  });

  group('AppTextField', () {
    testWidgets('рендерит label, hint и inline error', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppTextField(
            label: 'Название',
            hint: 'Введите название',
            errorText: 'Обязательное поле',
          ),
        ),
      );
      expect(find.text('Название'), findsOneWidget);
      expect(find.text('Обязательное поле'), findsOneWidget);
    });

    testWidgets('onChanged приходит с введённым текстом', (tester) async {
      var captured = '';
      await tester.pumpWidget(
        testApp(
          AppTextField(
            label: 'Название',
            onChanged: (value) => captured = value,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Счёт в банке');
      expect(captured, 'Счёт в банке');
    });
  });

  group('AppSegmentedControl', () {
    testWidgets('выбор сегмента вызывает callback с одним значением', (
      tester,
    ) async {
      Set<String> selected = <String>{'cashflow'};
      await tester.pumpWidget(
        testApp(
          StatefulBuilder(
            builder: (context, setState) => AppSegmentedControl<String>(
              segments: const <AppSegment<String>>[
                AppSegment<String>(value: 'cashflow', label: 'Денежный поток'),
                AppSegment<String>(value: 'transactions', label: 'Транзакции'),
              ],
              selected: selected,
              onSelectionChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Транзакции'));
      await tester.pump();
      expect(selected, <String>{'transactions'});
    });
  });

  group('AppFilterBar', () {
    testWidgets('Reset виден только при activeCount > 0', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppFilterBar(
            activeCount: 0,
            onReset: _noop,
            resetLabel: 'Сбросить фильтры',
            children: <Widget>[SizedBox.shrink()],
          ),
        ),
      );
      expect(find.text('Сбросить фильтры'), findsNothing);

      await tester.pumpWidget(
        testApp(
          const AppFilterBar(
            activeCount: 2,
            onReset: _noop,
            resetLabel: 'Сбросить фильтры',
            children: <Widget>[SizedBox.shrink()],
          ),
        ),
      );
      expect(find.text('Сбросить фильтры'), findsOneWidget);
    });

    testWidgets('выбранный чип подводится в видимую область на узком экране', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testApp(
          AppFilterBar(
            children: <Widget>[
              for (final label in <String>[
                'Месяц',
                '3 месяца',
                '6 месяцев',
                'Год',
                'Всё время',
              ])
                AppFilterChip(
                  label: label,
                  selected: label == 'Всё время',
                  onSelected: (_) {},
                ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.text('Всё время'));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('программный сброс подводит первый чип в видимую область', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final selected = ValueNotifier<String>('Всё время');
      addTearDown(selected.dispose);
      await tester.pumpWidget(
        testApp(
          ValueListenableBuilder<String>(
            valueListenable: selected,
            builder: (context, value, _) => AppFilterBar(
              children: <Widget>[
                for (final label in <String>[
                  'Месяц',
                  '3 месяца',
                  '6 месяцев',
                  'Год',
                  'Всё время',
                ])
                  AppFilterChip(
                    label: label,
                    selected: label == value,
                    onSelected: (_) {},
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      selected.value = 'Месяц';
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.text('Месяц'));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
    });
  });

  group('AppFormSection', () {
    testWidgets('рендерит title, subtitle и error', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppFormSection(
            title: 'Счёт',
            subtitle: 'Основные параметры',
            errorText: 'Проверьте поля',
            children: <Widget>[SizedBox(height: 8)],
          ),
        ),
      );
      expect(find.text('Счёт'), findsOneWidget);
      expect(find.text('Основные параметры'), findsOneWidget);
      expect(find.text('Проверьте поля'), findsOneWidget);
    });
  });

  group('AppSearchField', () {
    testWidgets('очистка вызывает onClear', (tester) async {
      final controller = TextEditingController(text: 'руб');
      addTearDown(controller.dispose);
      var cleared = 0;
      await tester.pumpWidget(
        testApp(
          AppSearchField(
            controller: controller,
            label: 'Поиск',
            onClear: () => cleared++,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Очистить'));
      expect(cleared, 1);
    });
  });
}

void _noop() {}
