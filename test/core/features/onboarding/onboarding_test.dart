import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_screen.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/onboarding/data/onboarding_repository_impl.dart';
import 'package:finanseapp/core/features/onboarding/domain/onboarding_repository.dart';
import 'package:finanseapp/core/features/onboarding/ui/onboarding_gate.dart';
import 'package:finanseapp/core/features/onboarding/ui/onboarding_screen.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../database/database_fixtures.dart';
import '../../../app/test_app_locator.dart';

void main() {
  test('флаг онбординга сохраняется в app_settings', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repository = OnboardingRepositoryImpl(db.settingsDao);

    expect(await repository.isCompleted(), isFalse);
    await repository.complete();
    expect(await repository.isCompleted(), isTrue);
  });

  testWidgets('первый запуск показывает онбординг, skip ведёт на Главную', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final locator = await buildTestLocator(onboardingCompleted: false);
    addTearDown(locator.reset);

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingTitle), findsWidgets);
    expect(find.text(l10n.onboardingSkip), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingSkip));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
    await locator.reset();
  });

  testWidgets('онбординг: выбор валюты и «Начать» сохраняют настройки', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final settings = _Settings();
    final onboarding = _Onboarding();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        // Гейт стоит в builder, как в app.dart: Navigator у экрана только свой.
        builder: (context, child) => OnboardingGate(
          repository: onboarding,
          settingsRepository: settings,
          currencyRepository: _Currencies(),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('RUB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.onboardingStart));
    await tester.pumpAndSettle();

    expect(settings.base, 'USD');
    expect(onboarding.completed, isTrue);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('онбординг: системный BACK закрывает выбор валюты', (
    tester,
  ) async {
    final settings = _Settings();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        builder: (context, child) => OnboardingGate(
          repository: _Onboarding(),
          settingsRepository: settings,
          currencyRepository: _Currencies(),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('RUB'));
    await tester.pumpAndSettle();
    expect(find.text('USD'), findsWidgets);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('USD'), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('онбординг: ошибка сохранения видна и без списка валют', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        builder: (context, child) => OnboardingGate(
          repository: _FailingOnboarding(),
          settingsRepository: _FailingSettings(),
          currencyRepository: _FailingCurrencies(),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();
    // Без загруженного списка «Начать» недоступно — остаётся вторая CTA.
    final start = tester.widget<AppButton>(
      find.widgetWithText(AppButton, l10n.onboardingStart),
    );
    expect(start.onPressed, isNull);

    await tester.tap(find.text(l10n.onboardingSkip));
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboardingSaveError), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('онбординг: ошибка чтения валют не оставляет вечную загрузку', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: OnboardingScreen(
          repository: _Onboarding(),
          settingsRepository: _Settings(),
          currencyRepository: _FailingCurrencies(),
          onDone: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorStateMessage), findsOneWidget);
    expect(find.text(l10n.retry), findsOneWidget);
    expect(find.text(l10n.commonLoading), findsNothing);
  });
}

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _usd = Currency(
  code: 'USD',
  name: 'Доллар',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class _Settings implements SettingsRepository {
  String base = 'RUB';

  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async => base == 'USD' ? _usd : _rub;

  @override
  Future<void> setBaseCurrency(String code) async => base = code;
  @override
  Future<int> getTaxRatePercent() async => defaultTaxRatePercent;

  @override
  Future<void> setTaxRatePercent(int percent) async {}
}

final class _Onboarding implements OnboardingRepository {
  bool completed = false;

  @override
  Future<bool> isCompleted() async => completed;

  @override
  Future<void> complete() async => completed = true;
}

final class _Currencies implements CurrencyRepository {
  @override
  Future<List<Currency>> getEnabled() async => const [_rub, _usd];

  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub, _usd]);

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(String code, String name, int digits) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class _FailingCurrencies implements CurrencyRepository {
  @override
  Future<List<Currency>> getEnabled() async => throw StateError('db');

  @override
  Stream<List<Currency>> watchAll() => const Stream.empty();

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(String code, String name, int digits) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class _FailingSettings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async => _rub;

  @override
  Future<void> setBaseCurrency(String code) async => throw StateError('db');
  @override
  Future<int> getTaxRatePercent() async => defaultTaxRatePercent;

  @override
  Future<void> setTaxRatePercent(int percent) async {}
}

final class _FailingOnboarding implements OnboardingRepository {
  @override
  Future<bool> isCompleted() async => false;

  @override
  Future<void> complete() async => throw StateError('db');
}
