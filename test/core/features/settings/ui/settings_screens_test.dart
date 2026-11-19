import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/settings/ui/about_screen.dart';
import 'package:finanseapp/core/features/settings/ui/about_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/more_screen.dart';
import 'package:finanseapp/core/features/settings/ui/more_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/settings_screen.dart';
import 'package:finanseapp/core/features/settings/ui/settings_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _usd = Currency(
  code: 'USD',
  name: 'Доллар',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class _Settings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_usd);

  @override
  Future<Currency> getBaseCurrency() async => _usd;

  @override
  Future<void> setBaseCurrency(String code) async {}
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  Future<GoRouter> pump(
    WidgetTester tester, {
    required Widget home,
    List<GoRoute> routes = const [],
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => home),
        ...routes,
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('More ведёт в справочники, настройки и about', (tester) async {
    final router = await pump(
      tester,
      home: MoreScreen(viewModel: MoreViewModel()),
      routes: [
        GoRoute(
          path: '/more/settings',
          builder: (context, state) => const AppText('SETTINGS'),
        ),
        GoRoute(
          path: '/more/about',
          builder: (context, state) => const AppText('ABOUT'),
        ),
        GoRoute(
          path: '/more/currencies',
          builder: (context, state) => const AppText('CURRENCIES'),
        ),
      ],
    );

    expect(find.text(l10n.categoriesTitle), findsOneWidget);
    expect(find.text(l10n.subgroupsTitle), findsOneWidget);
    expect(find.text(l10n.currenciesTitle), findsOneWidget);
    expect(find.text(l10n.settingsTitle), findsOneWidget);
    expect(find.text(l10n.aboutTitle), findsOneWidget);

    await tester.tap(find.text(l10n.settingsTitle));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.currenciesTitle));
    await tester.pumpAndSettle();
    expect(find.text('CURRENCIES'), findsOneWidget);
  });

  testWidgets('Settings показывает базовую валюту и ведёт в About', (
    tester,
  ) async {
    final router = await pump(
      tester,
      home: SettingsScreen(
        viewModel: SettingsViewModel(repository: _Settings()),
      ),
      routes: [
        GoRoute(
          path: '/more/currencies/base',
          builder: (context, state) => const AppText('BASE'),
        ),
        GoRoute(
          path: '/more/about',
          builder: (context, state) => const AppText('ABOUT'),
        ),
      ],
    );

    expect(find.text(l10n.baseCurrencyTitle), findsOneWidget);
    expect(find.text('USD · Доллар'), findsOneWidget);

    await tester.tap(find.text(l10n.baseCurrencyTitle));
    await tester.pumpAndSettle();
    expect(find.text('BASE'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsAboutDetails));
    await tester.pumpAndSettle();
    expect(find.text('ABOUT'), findsOneWidget);
  });

  testWidgets('About показывает назначение и offline-дисклеймер', (
    tester,
  ) async {
    await pump(tester, home: AboutScreen(viewModel: AboutViewModel()));

    expect(find.text(l10n.aboutTitle), findsOneWidget);
    expect(find.text(l10n.aboutDescription), findsOneWidget);
  });
}
