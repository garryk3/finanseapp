// ignore_for_file: type=lint
// Тестовая фикстура: raw Material-виджеты разрешены (зона test/**, CI-гард проверяет только lib/).
import 'package:finanseapp/uikit/app_amount_blur.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_money_visibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Скоуп видимости сумм и блюр (D21.4).
Widget _host({required bool hidden, required Widget child}) => MaterialApp(
  home: AppMoneyVisibility(
    hidden: hidden,
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('AppMoneyVisibility.of по умолчанию false без провайдера', (
    tester,
  ) async {
    late bool value;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            value = AppMoneyVisibility.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(value, isFalse);
  });

  testWidgets('AppMoneyVisibility.of возвращает состояние провайдера', (
    tester,
  ) async {
    late bool value;
    await tester.pumpWidget(
      _host(
        hidden: true,
        child: Builder(
          builder: (context) {
            value = AppMoneyVisibility.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(value, isTrue);
  });

  testWidgets('AppMoneyText виден без блюра при показанных суммах', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(hidden: false, child: const AppMoneyText('1 000,00 ₽')),
    );

    expect(find.text('1 000,00 ₽'), findsOneWidget);
    expect(find.byType(ImageFiltered), findsNothing);
  });

  testWidgets('AppMoneyText блюрится и скрыт из семантики при hidden', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        hidden: true,
        child: const AppMoneyText(
          '1 000,00 ₽',
          semanticsLabel: 'Итог: 1 000,00 ₽',
        ),
      ),
    );

    expect(find.text('1 000,00 ₽'), findsOneWidget);
    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(AppAmountBlur)).flagsCollection.isHidden,
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('AppMoneyText остаётся читаемым для семантики при показе', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(hidden: false, child: const AppMoneyText('1 000,00 ₽')),
    );

    expect(
      tester.getSemantics(find.byType(AppAmountBlur)).flagsCollection.isHidden,
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('AppAmountBlur прозрачен при показанных суммах', (tester) async {
    await tester.pumpWidget(
      _host(hidden: false, child: const AppAmountBlur(child: Text('42'))),
    );

    expect(find.byType(ImageFiltered), findsNothing);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('AppAmountBlur блюрит и убирает семантику при hidden', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        hidden: true,
        child: const AppAmountBlur(
          child: Text('42', semanticsLabel: 'Сорок два'),
        ),
      ),
    );

    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(AppAmountBlur)).flagsCollection.isHidden,
      isTrue,
    );
    handle.dispose();
  });
}
