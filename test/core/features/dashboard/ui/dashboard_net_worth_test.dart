import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_net_worth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _parts = [
  DashboardNetWorthPart(label: 'Счета', value: '−1 234,56 ₽'),
  DashboardNetWorthPart(label: 'Инвестиции', value: '5 000 000,00 ₽'),
  DashboardNetWorthPart(label: 'Недвижимость', value: '45 001 234,56 ₽'),
];

Widget _app({double textScale = 1.3, bool dark = false}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: SizedBox(
      width: 320,
      child: DashboardNetWorth(
        title: 'Чистый капитал',
        value: '50 000 000,00 ₽',
        subtitle: '23.11.2026 · RUB',
        breakdown: _parts,
      ),
    ),
  ),
);

void main() {
  testWidgets('разбивка: 320dp/1.3/dark без overflow, порядок строк', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(dark: true));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final accounts = tester.getTopLeft(find.text('Счета'));
    final investments = tester.getTopLeft(find.text('Инвестиции'));
    final property = tester.getTopLeft(find.text('Недвижимость'));
    expect(accounts.dy, lessThan(investments.dy));
    expect(investments.dy, lessThan(property.dy));
  });

  testWidgets(
    'разбивка: 320dp/2.0 без overflow и одной семантической строкой',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(textScale: 2.0));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        find.bySemanticsLabel(RegExp(r'Счета .*Инвестиции .*Недвижимость')),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );
}
