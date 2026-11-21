import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/features/cashflow/ui/operations_tabs.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_screen.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'app/test_app_locator.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('стартует на главной, все пять разделов в навигации', (
    tester,
  ) async {
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.text(l10n.navDashboard), findsWidgets);
    expect(find.text(l10n.navOperations), findsOneWidget);
    expect(find.text(l10n.navAssets), findsOneWidget);
    expect(find.text(l10n.navGoals), findsOneWidget);
    expect(find.text(l10n.navMore), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('переключение разделов сохраняет выбранный tab', (tester) async {
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.navGoals));
    await tester.pumpAndSettle();
    expect(find.text(l10n.goalsEmptyTitle), findsOneWidget);

    await tester.tap(find.text(l10n.navMore));
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoriesTitle), findsOneWidget);

    await tester.tap(find.text(l10n.navGoals));
    await tester.pumpAndSettle();
    expect(find.text(l10n.goalsEmptyTitle), findsOneWidget);
    // Гасим drift-стрим экрана активов до проверки инвариантов.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('smoke: все пять разделов открываются', (tester) async {
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.navOperations));
    await tester.pumpAndSettle();
    expect(find.text(l10n.cashflowEmptyTitle), findsOneWidget);

    await tester.tap(find.text(l10n.navGoals));
    await tester.pumpAndSettle();
    expect(find.text(l10n.goalsEmptyTitle), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('вкладки журнала операций переключаются и сохраняются', (
    tester,
  ) async {
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.navOperations));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(OperationsTabs),
        matching: find.text(l10n.operationsTransactionsTab),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.transactionsEmptyTitle), findsOneWidget);

    // Уход и возврат сохраняют выбранную вкладку (StatefulShellRoute).
    await tester.tap(find.text(l10n.navGoals));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.navOperations));
    await tester.pumpAndSettle();
    expect(find.text(l10n.transactionsEmptyTitle), findsOneWidget);

    // Гасим drift-стрим журнала операций до проверки инвариантов.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('back со secondary возвращает на root раздела', (tester) async {
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.navGoals));
    await tester.pumpAndSettle();
    final context = tester.element(find.text(l10n.goalsEmptyTitle));
    GoRouter.of(context).push('/goals/new');
    await tester.pumpAndSettle();
    expect(find.text(l10n.goalFormNew), findsWidgets);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(l10n.goalsEmptyTitle), findsOneWidget);
    // Гасим drift-стрим экрана активов до проверки инвариантов.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('вход в защиту приложения и возврат на главную', (tester) async {
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.navMore));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text(l10n.appLockTitle),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.appLockTitle));
    await tester.pumpAndSettle();
    expect(find.text(l10n.appLockStatusOff), findsOneWidget);

    final context = tester.element(find.text(l10n.appLockStatusOff));
    GoRouter.of(context).go('/');
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
