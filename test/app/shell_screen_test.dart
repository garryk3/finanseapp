import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_navigation_bar.dart';
import 'package:finanseapp/uikit/app_navigation_rail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app_locator.dart';

void main() {
  testWidgets('compact <600dp показывает NavigationBar', (tester) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.byType(AppNavigationRail), findsNothing);
  });

  testWidgets('320dp + font scale 1.3 не даёт переполнения навигации', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationBar), findsOneWidget);

    // Переходим на раздел с самой длинной подписью и проверяем геометрию:
    // подпись выбранного раздела должна целиком помещаться в бар.
    final router = GoRouter.of(tester.element(find.byType(AppNavigationBar)));
    router.go('/operations');
    await tester.pumpAndSettle();

    final label = find.descendant(
      of: find.byType(AppNavigationBar),
      matching: find.text(l10n.navOperations),
    );
    final bar = find.byType(AppNavigationBar);
    expect(
      tester.getRect(label).bottom,
      lessThanOrEqualTo(tester.getRect(bar).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('360dp при обычном шрифте показывает все подписи', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).labelBehavior,
      NavigationDestinationLabelBehavior.alwaysShow,
    );
    for (final label in [
      l10n.navOperations,
      l10n.navAssets,
      l10n.navGoals,
      l10n.navMore,
    ]) {
      expect(
        find.descendant(
          of: find.byType(AppNavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }
  });

  testWidgets('medium >=600dp показывает NavigationRail', (tester) async {
    tester.view.physicalSize = const Size(900, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final locator = await buildTestLocator();
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationRail), findsOneWidget);
    expect(find.byType(AppNavigationBar), findsNothing);
  });
}
