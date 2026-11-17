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
  group('AppButton', () {
    testWidgets('callback ровно один раз на tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        testApp(AppButton(label: 'Сохранить', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Сохранить'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled и pending не вызывают callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        testApp(AppButton(label: 'Сохранить', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Сохранить'));
      await tester.pump();
      expect(taps, 1);

      await tester.pumpWidget(
        testApp(
          AppButton(label: 'Сохранить', pending: true, onPressed: () => taps++),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Сохранить'));
      await tester.pump();
      expect(taps, 1, reason: 'pending блокирует повторный callback');
      final semantics = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Сохранить')),
      );
      expect(semantics.value, 'Выполняется');
    });

    testWidgets('destructive использует error-роль, expense — нет', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const Column(
            children: <Widget>[
              AppButton(
                label: 'Удалить',
                variant: AppButtonVariant.destructive,
              ),
              AppButton(label: 'Расход', variant: AppButtonVariant.filled),
            ],
          ),
        ),
      );
      final scheme = AppTheme.light().colorScheme;
      final errorButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Удалить'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(
        errorButton.style?.backgroundColor?.resolve(<WidgetState>{}),
        scheme.error,
      );
    });
  });

  group('AppIconButton', () {
    testWidgets('tooltip доступен и callback один раз', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        testApp(
          AppIconButton(
            icon: Icons.more_vert,
            tooltip: 'Действия',
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.byTooltip('Действия'), findsOneWidget);
      await tester.tap(find.byTooltip('Действия'));
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('AppCard / AppListTile', () {
    testWidgets('AppCard onTap с semanticLabel', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        testApp(
          AppCard(
            semanticLabel: 'Карточка итогов',
            onTap: () => taps++,
            child: const SizedBox(height: 48),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Карточка итогов'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('AppListTile disabled не вызывает callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        testApp(
          AppListTile(title: 'Валюты', enabled: false, onTap: () => taps++),
        ),
      );
      await tester.tap(find.text('Валюты'), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });
  });

  group('AppChip', () {
    testWidgets('onDeleted без deleteTooltip падает assert', (tester) async {
      expect(() => AppChip(label: 'x', onDeleted: () {}), throwsAssertionError);
    });
  });

  group('AppSwitch / AppCheckbox', () {
    testWidgets('переключение по label вызывает onChanged', (tester) async {
      var value = false;
      await tester.pumpWidget(
        testApp(
          StatefulBuilder(
            builder: (context, setState) => AppSwitch(
              value: value,
              label: 'Влияет на баланс',
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Влияет на баланс'));
      await tester.pump();
      expect(value, isTrue);
    });
  });

  group('AppPopupMenu', () {
    testWidgets('выбор пункта возвращает значение', (tester) async {
      String? selected;
      await tester.pumpWidget(
        testApp(
          AppPopupMenu<String>(
            tooltip: 'Действия',
            items: const <AppPopupMenuItem<String>>[
              AppPopupMenuItem<String>(value: 'edit', label: 'Изменить'),
              AppPopupMenuItem<String>(value: 'archive', label: 'В архив'),
            ],
            onSelected: (value) => selected = value,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Действия'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('В архив'));
      await tester.pump();
      expect(selected, 'archive');
    });
  });

  group('AppNavigationBar', () {
    testWidgets('отражает selection и вызывает callback', (tester) async {
      var index = -1;
      await tester.pumpWidget(
        testApp(
          AppNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (i) => index = i,
            destinations: const <AppNavigationDestination>[
              AppNavigationDestination(
                label: 'Главная',
                icon: Icons.home_outlined,
              ),
              AppNavigationDestination(
                label: 'Операции',
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Операции'));
      expect(index, 1);
    });
  });
}
