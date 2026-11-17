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
  group('AppEmptyState', () {
    testWidgets('title, message и один CTA; callback один раз', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        testApp(
          AppEmptyState(
            title: 'Операций пока нет',
            message: 'Добавьте первую операцию — она появится здесь.',
            actionLabel: 'Добавить операцию',
            onAction: () => taps++,
          ),
        ),
      );
      expect(find.text('Операций пока нет'), findsOneWidget);
      expect(find.text('Добавить операцию'), findsOneWidget);
      await tester.tap(find.text('Добавить операцию'));
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('AppErrorState', () {
    testWidgets('retry вызывает onRetry один раз', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        testApp(
          AppErrorState(
            title: 'Не удалось загрузить курсы',
            message: 'Проверьте подключение и повторите.',
            retryLabel: 'Повторить',
            onRetry: () => retries++,
          ),
        ),
      );
      await tester.tap(find.text('Повторить'));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('без onRetry не показывает неработающую кнопку', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const AppErrorState(
            title: 'Ошибка',
            message: 'Введите курс вручную.',
          ),
        ),
      );
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('compact inline-вариант рендерится', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppErrorState(
            title: 'Нет соединения',
            message: 'Локальные данные доступны.',
            compact: true,
          ),
        ),
      );
      expect(find.text('Нет соединения'), findsOneWidget);
    });
  });

  group('AppConfirmDialog', () {
    testWidgets('destructive: confirm в error-роли, cancel текстовая', (
      tester,
    ) async {
      final scheme = AppTheme.light().colorScheme;
      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) => AppButton(
              label: 'Открыть',
              onPressed: () => showAppDialog<void>(
                context: context,
                builder: (_) => const AppConfirmDialog(
                  title: 'Удалить операцию?',
                  message: 'Запись будет скрыта из журнала.',
                  confirmLabel: 'Удалить',
                  cancelLabel: 'Отмена',
                  onConfirm: _noop,
                  onCancel: _noop,
                  destructive: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
      final confirm = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Удалить'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(
        confirm.style?.backgroundColor?.resolve(<WidgetState>{}),
        scheme.error,
      );
      expect(find.text('Отмена'), findsOneWidget);
    });

    testWidgets('pending блокирует оба действия', (tester) async {
      await tester.pumpWidget(
        testApp(
          const AppConfirmDialog(
            title: 'Импорт',
            message: 'Данные будут заменены.',
            confirmLabel: 'Заменить',
            cancelLabel: 'Отмена',
            onConfirm: _noop,
            onCancel: _noop,
            destructive: true,
            pending: true,
          ),
        ),
      );
      final buttons = tester.widgetList<AppButton>(find.byType(AppButton));
      expect(buttons.length, 2);
      for (final button in buttons) {
        expect(button.onPressed, isNull);
      }
    });
  });
}

void _noop() {}
