import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/app/shell_screen.dart';
import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app_locator.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  Future<GoRouter> pumpApp(WidgetTester tester) async {
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();
    return GoRouter.of(tester.element(find.byType(ShellScreen)));
  }

  testWidgets('невалидный id и unknown route ведут в NotFound', (tester) async {
    final router = await pumpApp(tester);

    router.go('/assets/abc');
    await tester.pumpAndSettle();
    expect(find.text(l10n.notFoundTitle), findsWidgets);

    router.go('/assets/0');
    await tester.pumpAndSettle();
    expect(find.text(l10n.notFoundTitle), findsWidgets);

    router.go('/no-such-page');
    await tester.pumpAndSettle();
    expect(find.text(l10n.notFoundTitle), findsWidgets);

    router.go('/transactions/transfer/abc/edit');
    await tester.pumpAndSettle();
    expect(find.text(l10n.notFoundTitle), findsWidgets);
  });

  testWidgets('malformed query не роняет экран', (tester) async {
    final router = await pumpApp(tester);

    router.go('/operations?tab=unknown&id=abc');
    await tester.pumpAndSettle();

    expect(find.text(l10n.cashflowEmptyTitle), findsOneWidget);
  });

  testWidgets('кнопка «На главную» возвращает на dashboard', (tester) async {
    final router = await pumpApp(tester);

    router.go('/no-such-page');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.notFoundHome));
    await tester.pumpAndSettle();

    expect(find.text(l10n.dashboardEmptyTitle), findsOneWidget);
  });

  test('parseId принимает только положительные decimal id', () {
    expect(AppRoutes.parseId('42'), 42);
    expect(AppRoutes.parseId('0'), isNull);
    expect(AppRoutes.parseId('-1'), isNull);
    expect(AppRoutes.parseId('abc'), isNull);
    expect(AppRoutes.parseId(null), isNull);
    expect(AppRoutes.parseId('1.5'), isNull);
  });
}
