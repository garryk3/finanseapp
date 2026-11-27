import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/rate_refresh_service.dart';
import 'package:finanseapp/core/features/currencies/ui/base_currency_screen.dart';
import 'package:finanseapp/core/features/currencies/ui/base_currency_view_model.dart';
import 'package:finanseapp/core/features/currencies/ui/currencies_screen.dart';
import 'package:finanseapp/core/features/currencies/ui/currencies_view_model.dart';
import 'package:finanseapp/core/features/currencies/ui/manual_rate_dialog.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Российский рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

const _usd = Currency(
  code: 'USD',
  name: 'Доллар США',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

const _eur = Currency(
  code: 'EUR',
  name: 'Евро',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class FakeCurrencyRepository implements CurrencyRepository {
  FakeCurrencyRepository({this.referenced = const {}});

  final Set<String> referenced;
  final StreamController<List<Currency>> _controller =
      StreamController.broadcast(sync: true);

  @override
  Stream<List<Currency>> watchAll() => _controller.stream;

  void emit(List<Currency> currencies) => _controller.add(currencies);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub, _usd, _eur];

  @override
  Future<int> countReferences(String code) async =>
      referenced.contains(code) ? 1 : 0;

  @override
  Future<void> createCustom(
    String code,
    String name,
    int fractionDigits,
  ) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {
    if (code == 'RUB') {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'code': 'validationRubProtected'},
      );
    }
  }

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this.code);

  String code;

  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async =>
      const [_rub, _usd, _eur].firstWhere((item) => item.code == code);

  @override
  Future<void> setBaseCurrency(String code) async => this.code = code;
}

/// Курсы для ручного обновления: `cached` уже в кэше, `failures` — сетевые
/// сбои по коду, `gate` удерживает ответ для проверки pending-индикатора.
final class _FakeRateRepository implements ExchangeRateRepository {
  final Set<String> cached = <String>{};
  final Map<String, Object> failures = <String, Object>{};
  final List<String> fetched = <String>[];
  Completer<void>? gate;

  ExchangeRate _rate(String code, LocalDate date) => ExchangeRate(
    id: 1,
    currencyCode: code,
    date: date,
    rateToRub: Decimal.parse('90'),
    source: ExchangeRateSource.cbr,
    fetchedAt: DateTime.utc(2026, 11, 18),
  );

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async =>
      cached.contains(currencyCode) ? _rate(currencyCode, date) : null;

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) async {
    final waiting = gate;
    if (waiting != null) await waiting.future;
    fetched.add(currencyCode);
    final error = failures[currencyCode];
    if (error != null) throw error;
    return _rate(currencyCode, date);
  }

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) async => _rate(currencyCode, date);
}

RateRefreshService _refreshService({
  CurrencyRepository? currencies,
  _FakeRateRepository? rates,
}) => RateRefreshService(
  currencyRepository: currencies ?? FakeCurrencyRepository(),
  rateRepository: rates ?? _FakeRateRepository(),
  today: () => LocalDate(2026, 11, 18),
);

Future<void> pumpScreen(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru')],
      home: child,
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('список валют показывает коды и пустое состояние', (
    tester,
  ) async {
    final repository = FakeCurrencyRepository();
    final viewModel = CurrenciesViewModel(
      repository: repository,
      settingsRepository: FakeSettingsRepository('RUB'),
      rateRefreshService: _refreshService(),
    );
    addTearDown(viewModel.dispose);

    await pumpScreen(tester, CurrenciesScreen(viewModel: viewModel));
    repository.emit(const []);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.currencyAdd), findsWidgets);

    repository.emit(const [_rub, _usd]);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('RUB · Российский рубль'), findsOneWidget);
    expect(find.text('USD · Доллар США'), findsOneWidget);
    // Базовая валюта помечена в подписи (BR-C-5).
    expect(find.textContaining(l10n.baseCurrencyCurrent), findsOneWidget);
  });

  testWidgets('отключение используемой не-RUB валюты называет её код', (
    tester,
  ) async {
    final repository = FakeCurrencyRepository(referenced: {'USD'});
    final viewModel = CurrenciesViewModel(
      repository: repository,
      settingsRepository: FakeSettingsRepository('RUB'),
      rateRefreshService: _refreshService(),
    );
    addTearDown(viewModel.dispose);

    await pumpScreen(tester, CurrenciesScreen(viewModel: viewModel));
    repository.emit(const [_rub, _usd]);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('USD')),
        matching: find.byTooltip(l10n.currencyActionsTooltip),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.currencyToggleDisable));
    await tester.pumpAndSettle();

    expect(find.text(l10n.currencyErrorInUseCode('USD')), findsOneWidget);
    expect(find.text(l10n.currencyErrorRub), findsNothing);
  });

  testWidgets('базовая валюта выбирается и сохраняется', (tester) async {
    final settings = FakeSettingsRepository('RUB');
    final viewModel = BaseCurrencyViewModel(
      currencyRepository: FakeCurrencyRepository(),
      settingsRepository: settings,
    );

    await pumpScreen(tester, BaseCurrencyScreen(viewModel: viewModel));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('EUR · Евро'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(AppButton));
    await tester.pump(const Duration(milliseconds: 300));

    expect(settings.code, 'EUR');
  });

  testWidgets('ручной курс: невалидный ввод не закрывает диалог', (
    tester,
  ) async {
    Decimal? result;
    await pumpScreen(
      tester,
      AppScaffold(
        body: AppButton(
          label: 'open',
          onPressed: () async {
            result = await showManualRateDialog(
              tester.element(find.byType(AppButton)),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.manualRateInvalid), findsOneWidget);
    expect(result, isNull);

    await tester.enterText(find.byType(TextField), '93,4567');
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));
    expect(result, Decimal.parse('93.4567'));
  });

  testWidgets('ручное обновление курсов: индикатор и snackbar', (tester) async {
    final currencies = FakeCurrencyRepository();
    final rates = _FakeRateRepository()
      ..cached.add('USD')
      ..gate = Completer<void>();
    final viewModel = CurrenciesViewModel(
      repository: currencies,
      settingsRepository: FakeSettingsRepository('RUB'),
      rateRefreshService: _refreshService(currencies: currencies, rates: rates),
    );
    addTearDown(viewModel.dispose);

    await pumpScreen(tester, CurrenciesScreen(viewModel: viewModel));
    currencies.emit(const [_rub, _usd, _eur]);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip(l10n.currenciesRefreshTooltip));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    rates.gate!.complete();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.currenciesRefreshDone(1)), findsOneWidget);
  });

  testWidgets('ручное обновление: сетевая ошибка не скрывает данные', (
    tester,
  ) async {
    final currencies = FakeCurrencyRepository();
    final rates = _FakeRateRepository()
      ..cached.add('USD')
      ..failures['EUR'] = const DomainException(
        DomainErrorCode.networkUnavailable,
      );
    final viewModel = CurrenciesViewModel(
      repository: currencies,
      settingsRepository: FakeSettingsRepository('RUB'),
      rateRefreshService: _refreshService(currencies: currencies, rates: rates),
    );
    addTearDown(viewModel.dispose);

    await pumpScreen(tester, CurrenciesScreen(viewModel: viewModel));
    currencies.emit(const [_rub, _usd, _eur]);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip(l10n.currenciesRefreshTooltip));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.currenciesRefreshFailed(1)), findsOneWidget);
    expect(find.text('USD · Доллар США'), findsOneWidget);
  });
}
