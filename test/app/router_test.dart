import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_screen.dart';
import 'package:finanseapp/app/shell_screen.dart';
import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app_locator.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    void Function(ServiceLocator locator)? onLocator,
  }) async {
    final locator = await buildTestLocator();
    onLocator?.call(locator);
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();
    addTearDown(() async {
      // Закрываем drift-стримы до проверки pending timers.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    });
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

  testWidgets('детализация: malformed query не роняет экран', (tester) async {
    final router = await pumpApp(tester);

    router.go('/more/analytics/details?period=nope&kind=other&categoryId=abc');
    await tester.pumpAndSettle();

    expect(find.text(l10n.analyticsDetailsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('детализация: period из query выбирает чип', (tester) async {
    final router = await pumpApp(tester);

    router.go('/more/analytics/details?period=year&kind=income&categoryId=1');
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AppFilterChip>(
            find.widgetWithText(AppFilterChip, l10n.analyticsPeriodYear),
          )
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<AppFilterChip>(
            find.widgetWithText(AppFilterChip, l10n.analyticsPeriodMonth),
          )
          .selected,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('аналитика сохраняет период после возврата с детализации', (
    tester,
  ) async {
    late ServiceLocator locator;
    late AnalyticsViewModel analytics;
    final router = await pumpApp(
      tester,
      onLocator: (value) {
        locator = value;
        analytics = value.get<AnalyticsViewModel>();
      },
    );

    router.go(AppRoutes.analytics);
    await tester.pumpAndSettle();
    analytics.period.value = AnalyticsPeriod.year;
    await tester.pumpAndSettle();

    router.push(AppRoutes.analyticsDetails);
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(identical(locator.get<AnalyticsViewModel>(), analytics), isTrue);
    expect(analytics.period.value, AnalyticsPeriod.year);
  });

  test('AnalyticsViewModel зарегистрирован как singleton', () async {
    final locator = await buildTestLocator();
    final first = locator.get<AnalyticsViewModel>();
    final second = locator.get<AnalyticsViewModel>();
    expect(identical(first, second), isTrue);
    await locator.reset();
  });

  testWidgets('кнопка «На главную» возвращает на dashboard', (tester) async {
    final router = await pumpApp(tester);

    router.go('/no-such-page');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.notFoundHome));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
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
