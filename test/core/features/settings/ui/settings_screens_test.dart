import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:finanseapp/core/features/backup/logic/backup_view_model.dart';
import 'package:finanseapp/core/features/settings/domain/display_settings_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/settings/domain/update_service.dart';
import 'package:finanseapp/core/features/settings/logic/update_check_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/about_screen.dart';
import 'package:finanseapp/core/features/settings/ui/about_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/more_screen.dart';
import 'package:finanseapp/core/features/settings/ui/more_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/settings_screen.dart';
import 'package:finanseapp/core/features/settings/ui/settings_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_switch.dart';
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

final class _Gateway implements BackupFileGateway {
  @override
  Future<String?> pickDatabase() async => null;

  @override
  Future<BackupShareOutcome> share(BackupFile file) async =>
      BackupShareOutcome.cancelled;

  @override
  Future<bool> save(BackupFile file, {required String dialogTitle}) async =>
      false;
}

final class _Updates implements UpdateService {
  @override
  Future<ReleaseInfo?> fetchLatestRelease() async => null;
}

final class _Settings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_usd);

  @override
  Future<Currency> getBaseCurrency() async => _usd;

  @override
  Future<void> setBaseCurrency(String code) async {}
}

final class _DisplaySettings implements DisplaySettingsRepository {
  _DisplaySettings({this.hidden = false});

  bool hidden;

  @override
  Stream<bool> watchAmountsHidden() => Stream.value(hidden);

  @override
  Future<bool> getAmountsHidden() async => hidden;

  @override
  Future<void> setAmountsHidden(bool value) async => hidden = value;
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
        GoRoute(
          path: '/more/audit',
          builder: (context, state) => const AppText('AUDIT'),
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

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.auditTitle));
    await tester.pumpAndSettle();
    expect(find.text('AUDIT'), findsOneWidget);
  });

  testWidgets('Settings показывает базовую валюту и ведёт в About', (
    tester,
  ) async {
    final router = await pump(
      tester,
      home: SettingsScreen(
        viewModel: SettingsViewModel(
          repository: _Settings(),
          display: _DisplaySettings(hidden: true),
        ),
        backupViewModel: BackupViewModel(
          () => throw UnimplementedError(),
          _Gateway(),
        ),
        updateViewModel: UpdateCheckViewModel(
          service: _Updates(),
          installedVersionProvider: () async => '0.1.0',
        ),
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
    expect(find.text(l10n.settingsUpdateVersion('0.1.0')), findsOneWidget);
    // Настройка отображения отражает сохранённое значение (D21.4).
    expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isTrue);

    await tester.tap(find.text(l10n.baseCurrencyTitle));
    await tester.pumpAndSettle();
    expect(find.text('BASE'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsAboutDetails));
    await tester.pumpAndSettle();
    expect(find.text('ABOUT'), findsOneWidget);
  });

  testWidgets('Settings: переключатель скрытия сумм меняет настройку', (
    tester,
  ) async {
    final display = _DisplaySettings();
    await pump(
      tester,
      home: SettingsScreen(
        viewModel: SettingsViewModel(repository: _Settings(), display: display),
        backupViewModel: BackupViewModel(
          () => throw UnimplementedError(),
          _Gateway(),
        ),
        updateViewModel: UpdateCheckViewModel(
          service: _Updates(),
          installedVersionProvider: () async => '0.1.0',
        ),
      ),
    );

    expect(find.text(l10n.settingsDisplaySection), findsOneWidget);
    expect(find.text(l10n.settingsHideAmountsLabel), findsOneWidget);
    expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isFalse);

    await tester.tap(find.byType(AppSwitch));
    await tester.pumpAndSettle();

    expect(display.hidden, isTrue);
    expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isTrue);
  });

  testWidgets('About показывает назначение и offline-дисклеймер', (
    tester,
  ) async {
    await pump(tester, home: AboutScreen(viewModel: AboutViewModel()));

    expect(find.text(l10n.aboutTitle), findsOneWidget);
    expect(find.text(l10n.aboutDescription), findsOneWidget);
  });
}
