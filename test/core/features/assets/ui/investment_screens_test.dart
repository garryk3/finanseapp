import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_screen.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/investment_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/investment_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/valuation_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/valuation_form_view_model.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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

const _eur = Currency(
  code: 'EUR',
  name: 'Евро',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

const _jpy = Currency(
  code: 'JPY',
  name: 'Иена',
  fractionDigits: 0,
  isPreset: true,
  isEnabled: true,
);

final class FakeAssets implements AssetRepository {
  FakeAssets(this.snapshot, {this.valuationsHistory = const []})
    : locked = [...snapshot.locked];

  AssetSnapshot snapshot;
  final List<AssetValuation> valuationsHistory;
  final List<Money> locked;
  final List<Money> savedLocked = [];
  final List<AssetValuationDraft> recorded = [];
  DomainException? valuationFailure;
  AssetDraft? savedDraft;

  AssetSnapshot _withLocked() => AssetSnapshot(
    asset: snapshot.asset,
    currentValue: snapshot.currentValue,
    currencyBalances: snapshot.currencyBalances,
    lockedBalances: locked.isEmpty ? null : List.of(locked),
  );

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([_withLocked()]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => Stream.value(_withLocked());

  @override
  Future<AssetSnapshot> getById(int id) async => _withLocked();

  @override
  Future<int> create(AssetDraft draft) async {
    savedDraft = draft;
    return 1;
  }

  @override
  Future<void> update(int id, AssetDraft draft) async {
    savedDraft = draft;
  }

  @override
  Future<void> deleteIfUnused(int id) async {}

  @override
  Future<void> archive(int id) async {}

  @override
  Future<void> recordValuation(AssetValuationDraft draft) async {
    recorded.add(draft);
    final failure = valuationFailure;
    if (failure != null) throw failure;
  }

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) async =>
      const AssetReferenceCounts(
        transactions: 0,
        valuations: 0,
        goals: 0,
        cashflow: 0,
      );

  @override
  Future<List<AssetValuation>> valuations(int id) async => valuationsHistory;

  @override
  Future<void> setLockedAmount(
    int assetId,
    String currencyCode,
    Money amount,
  ) async {
    if (amount.isZero) {
      savedLocked.add(amount);
      locked.removeWhere((item) => item.currencyCode == currencyCode);
      return;
    }
    int? balance;
    for (final item in snapshot.breakdown) {
      if (item.currencyCode == currencyCode) balance = item.minorUnits;
    }
    if (balance == null || amount.minorUnits > balance) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'amount': 'validationLockedExceedsBalance'},
      );
    }
    savedLocked.add(amount);
    locked
      ..removeWhere((item) => item.currencyCode == currencyCode)
      ..add(amount);
  }

  @override
  Future<List<Money>> lockedAmounts(int assetId) async => List.of(locked);
}

final class FakeSubgroups implements SubgroupRepository {
  FakeSubgroups([List<Subgroup>? brokers])
    : brokers =
          brokers ??
          [const Subgroup(id: 7, kind: SubgroupKind.broker, name: 'Брокер')];

  final List<Subgroup> brokers;

  @override
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind) =>
      Stream.value([...brokers]);

  @override
  Future<List<Subgroup>> getByKind(SubgroupKind kind) async => [...brokers];

  @override
  Future<int> create(SubgroupKind kind, String name) async => 1;

  @override
  Future<void> rename(int id, String name) async {}

  @override
  Future<int> countAssets(int id) async => 0;

  @override
  Future<void> deleteIfUnused(int id) async {}

  @override
  Future<void> moveAssetsAndDelete(int id, int targetId) async {}
}

final class FakeCurrencies implements CurrencyRepository {
  FakeCurrencies([List<Currency>? items])
    : items = items ?? const [_rub, _usd, _eur, _jpy];

  final List<Currency> items;

  @override
  Stream<List<Currency>> watchAll() => Stream.value(items);

  @override
  Future<List<Currency>> getEnabled() async => items;

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(
    String code,
    String name,
    int fractionDigits,
  ) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class FakeSettings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async => _rub;

  @override
  Future<void> setBaseCurrency(String code) async {}
}

final class FakeRates implements ExchangeRateRepository {
  FakeRates({this.rate});

  final Decimal? rate;

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    final value = rate;
    if (value == null) return null;
    return ExchangeRate(
      id: 1,
      currencyCode: currencyCode,
      date: date,
      rateToRub: value,
      source: ExchangeRateSource.cbr,
      fetchedAt: DateTime.utc(2026),
    );
  }

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw const DomainException(DomainErrorCode.rateUnavailable);

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) async => ExchangeRate(
    id: 1,
    currencyCode: currencyCode,
    date: date,
    rateToRub: rateToRub,
    source: ExchangeRateSource.manual,
    fetchedAt: DateTime.utc(2026),
  );
}

InvestmentAsset _investment({
  int opening = 100000,
  bool archived = false,
  String currency = 'RUB',
}) => InvestmentAsset(
  id: 1,
  name: 'Брокерский счёт',
  currencyCode: currency,
  openingValue: Money(minorUnits: opening, currencyCode: currency),
  createdAt: DateTime.utc(2026),
  brokerId: 7,
  archivedAt: archived ? DateTime.utc(2026, 2, 1) : null,
);

AssetSnapshot _snapshot({int current = 150000}) => AssetSnapshot(
  asset: _investment(),
  currentValue: Money(minorUnits: current, currencyCode: 'RUB'),
);

late GoRouter _router;

/// Форма инвестиции внутри роутера, как в приложении: VM создаётся в builder
/// (или переиспользуется переданная), второй маршрут — справочник брокеров.
Widget _investmentFormApp(
  InvestmentFormViewModel? viewModel, {
  InvestmentFormViewModel Function()? buildViewModel,
}) {
  _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => InvestmentFormScreen(
          viewModel: viewModel ?? buildViewModel!.call(),
        ),
      ),
      GoRoute(
        path: '/more/subgroups',
        builder: (context, state) =>
            AppScaffold(title: 'Брокеры', body: const SizedBox.shrink()),
      ),
    ],
  );
  return MaterialApp.router(
    theme: AppTheme.light(),
    routerConfig: _router,
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      AppLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ru')],
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
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

  testWidgets('форма инвестиции создаёт draft с брокером и суммой', (
    tester,
  ) async {
    final repository = FakeAssets(_snapshot());
    final vm = InvestmentFormViewModel(
      repository: repository,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, InvestmentFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Инвестиция');
    await tester.enterText(fields.at(1), '1000');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final draft = repository.savedDraft;
    expect(draft, isA<InvestmentDraft>());
    expect((draft! as InvestmentDraft).brokerId, 7);
    expect(draft.openingValue.minorUnits, 100000);
  });

  testWidgets('пустой начальный баланс инвестиции сохраняется нулём', (
    tester,
  ) async {
    final repository = FakeAssets(_snapshot());
    final vm = InvestmentFormViewModel(
      repository: repository,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, InvestmentFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).at(0), 'Инвестиция');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final draft = repository.savedDraft;
    expect(draft, isA<InvestmentDraft>());
    expect((draft! as InvestmentDraft).openingValue.minorUnits, 0);
    expect(find.text(l10n.accountErrorAmount), findsNothing);
  });

  testWidgets('редактирование: нулевой баланс инвестиции показан пустым', (
    tester,
  ) async {
    final repository = FakeAssets(
      AssetSnapshot(
        asset: _investment(opening: 0),
        currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
      ),
    );
    final vm = InvestmentFormViewModel(
      repository: repository,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
      editingId: 1,
    );
    await _pump(tester, InvestmentFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('редактирование: ненулевой баланс инвестиции показан как есть', (
    tester,
  ) async {
    final repository = FakeAssets(_snapshot());
    final vm = InvestmentFormViewModel(
      repository: repository,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
      editingId: 1,
    );
    await _pump(tester, InvestmentFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '1000',
    );
  });

  testWidgets('форма инвестиции не сохраняет пустое название', (tester) async {
    final repository = FakeAssets(_snapshot());
    final vm = InvestmentFormViewModel(
      repository: repository,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, InvestmentFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.investmentErrorName), findsOneWidget);
    expect(repository.savedDraft, isNull);
  });

  testWidgets('после добавления брокера форма перезагружает данные', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final subgroups = FakeSubgroups([]);
    final vm = InvestmentFormViewModel(
      repository: FakeAssets(_snapshot()),
      subgroupRepository: subgroups,
      currencyRepository: FakeCurrencies(),
    );
    await tester.pumpWidget(_investmentFormApp(vm));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.investmentNoBrokers), findsOneWidget);

    subgroups.brokers.add(
      const Subgroup(id: 8, kind: SubgroupKind.broker, name: 'Новый брокер'),
    );
    await tester.ensureVisible(find.text(l10n.brokerAddAction));
    await tester.tap(find.text(l10n.brokerAddAction));
    await tester.pumpAndSettle();
    _router.pop();
    await tester.pumpAndSettle();

    expect(find.text(l10n.investmentNoBrokers), findsNothing);
    expect(find.text('Новый брокер'), findsOneWidget);
    final save = tester.widget<AppButton>(
      find.widgetWithText(AppButton, l10n.commonSave),
    );
    expect(save.onPressed, isNotNull);
  });

  testWidgets(
    'новый ViewModel из router builder подхватывается без потери формы',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final subgroups = FakeSubgroups([]);
      // Роутер создаёт VM в builder — как в app/router.dart.
      var builds = 0;
      await tester.pumpWidget(
        _investmentFormApp(
          null,
          buildViewModel: () {
            builds++;
            return InvestmentFormViewModel(
              repository: FakeAssets(_snapshot()),
              subgroupRepository: subgroups,
              currencyRepository: FakeCurrencies(),
            );
          },
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(l10n.investmentNoBrokers), findsOneWidget);

      subgroups.brokers.add(
        const Subgroup(
          id: 9,
          kind: SubgroupKind.broker,
          name: 'Брокер из builder',
        ),
      );
      await tester.ensureVisible(find.text(l10n.brokerAddAction));
      await tester.tap(find.text(l10n.brokerAddAction));
      await tester.pumpAndSettle();
      _router.pop();
      await tester.pumpAndSettle();

      expect(builds, greaterThan(1));
      expect(find.text(l10n.investmentNoBrokers), findsNothing);
      expect(find.text('Брокер из builder'), findsOneWidget);
      final save = tester.widget<AppButton>(
        find.widgetWithText(AppButton, l10n.commonSave),
      );
      expect(save.onPressed, isNotNull);
    },
  );

  testWidgets('оценка сохраняется с курсом RUB и подтверждением', (
    tester,
  ) async {
    final repository = FakeAssets(_snapshot());
    final vm = ValuationFormViewModel(
      repository: repository,
      rateRepository: FakeRates(),
      currencyRepository: FakeCurrencies(),
      assetId: 1,
      today: LocalDate(2026, 1, 2),
    );
    await _pump(tester, ValuationFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, '1500');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.recorded, hasLength(1));
    final draft = repository.recorded.single;
    expect(draft.value.minorUnits, 150000);
    expect(draft.effectiveOn, LocalDate(2026, 1, 2));
    expect(draft.rateToRub, Decimal.one);
  });

  testWidgets(
    'форма оценки инвестиции показывает селектор валюты с валютой актива',
    (tester) async {
      final repository = FakeAssets(_snapshot());
      final vm = ValuationFormViewModel(
        repository: repository,
        rateRepository: FakeRates(),
        currencyRepository: FakeCurrencies(),
        assetId: 1,
        today: LocalDate(2026, 1, 2),
      );
      await _pump(tester, ValuationFormScreen(viewModel: vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(l10n.valuationCurrencyLabel), findsOneWidget);
      expect(find.text('Рубль (RUB)'), findsOneWidget);
    },
  );

  testWidgets('неизменяемый курс показывает понятное сообщение', (
    tester,
  ) async {
    final repository = FakeAssets(_snapshot())
      ..valuationFailure = const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'rate': 'validationRateImmutable'},
      );
    final vm = ValuationFormViewModel(
      repository: repository,
      rateRepository: FakeRates(),
      currencyRepository: FakeCurrencies(),
      assetId: 1,
      today: LocalDate(2026, 1, 2),
    );
    await _pump(tester, ValuationFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Рубль (RUB)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Доллар'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '120');
    await tester.enterText(find.byType(TextField).at(1), '92');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.rateErrorImmutable), findsOneWidget);
    expect(find.byType(ValuationFormScreen), findsOneWidget);
  });

  testWidgets('форма оценки USD-инвестиции по умолчанию выбирает USD', (
    tester,
  ) async {
    final repository = FakeAssets(
      AssetSnapshot(
        asset: _investment(currency: 'USD'),
        currentValue: const Money(minorUnits: 100000, currencyCode: 'USD'),
      ),
    );
    final vm = ValuationFormViewModel(
      repository: repository,
      rateRepository: FakeRates(),
      currencyRepository: FakeCurrencies(),
      assetId: 1,
      today: LocalDate(2026, 1, 2),
    );
    await _pump(tester, ValuationFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.valuationCurrencyLabel), findsOneWidget);
    expect(find.text('Доллар (USD)'), findsOneWidget);
  });

  testWidgets(
    'оценка инвестиции в USD сохраняется с выбранной валютой и курсом',
    (tester) async {
      final repository = FakeAssets(_snapshot());
      final vm = ValuationFormViewModel(
        repository: repository,
        rateRepository: FakeRates(),
        currencyRepository: FakeCurrencies(),
        assetId: 1,
        today: LocalDate(2026, 1, 2),
      );
      await _pump(tester, ValuationFormScreen(viewModel: vm));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Рубль (RUB)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Доллар'));
      await tester.pumpAndSettle();
      expect(find.text('Доллар (USD)'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '120');
      await tester.enterText(find.byType(TextField).at(1), '90');
      await tester.ensureVisible(find.text(l10n.commonSave));
      await tester.tap(find.text(l10n.commonSave));
      await tester.pump(const Duration(milliseconds: 300));

      final draft = repository.recorded.single;
      expect(draft.value.currencyCode, 'USD');
      expect(draft.value.minorUnits, 12000);
      expect(draft.rateToRub, Decimal.fromInt(90));
    },
  );

  testWidgets('форма оценки квартиры не показывает селектор валюты', (
    tester,
  ) async {
    final snapshot = AssetSnapshot(
      asset: PropertyAsset(
        id: 1,
        name: 'Квартира',
        currencyCode: 'RUB',
        openingValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
        createdAt: DateTime.utc(2026),
        address: 'Улица',
      ),
      currentValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
    );
    final repository = FakeAssets(snapshot);
    final vm = ValuationFormViewModel(
      repository: repository,
      rateRepository: FakeRates(),
      currencyRepository: FakeCurrencies(),
      assetId: 1,
      today: LocalDate(2026, 1, 2),
    );
    await _pump(tester, ValuationFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.valuationCurrencyLabel), findsNothing);
    await tester.enterText(find.byType(TextField).first, '1500');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.recorded.single.value.currencyCode, 'RUB');
  });

  test('оценка квартиры в чужой валюте отклоняется VM', () async {
    final snapshot = AssetSnapshot(
      asset: PropertyAsset(
        id: 1,
        name: 'Квартира',
        currencyCode: 'RUB',
        openingValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
        createdAt: DateTime.utc(2026),
      ),
      currentValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
    );
    final repository = FakeAssets(snapshot);
    final vm = ValuationFormViewModel(
      repository: repository,
      rateRepository: FakeRates(),
      currencyRepository: FakeCurrencies(),
      assetId: 1,
      today: LocalDate(2026, 1, 2),
    );
    await vm.load();

    final result = await vm.save(
      value: const Money(minorUnits: 12000, currencyCode: 'USD'),
      effectiveOn: LocalDate(2026, 1, 2),
      manualRate: Decimal.fromInt(90),
    );

    expect(result, isA<Failure<void>>());
    expect(repository.recorded, isEmpty);
  });

  testWidgets('история оценок форматирует валюту оценки и помечает текущую', (
    tester,
  ) async {
    final repository = FakeAssets(
      _snapshot(),
      valuationsHistory: [
        AssetValuation(
          id: 4,
          assetId: 1,
          effectiveOn: LocalDate(2026, 1, 4),
          value: const Money(minorUnits: 1234, currencyCode: 'JPY'),
          rateToRub: Decimal.parse('0.5'),
          valueRub: const Money(minorUnits: 61700, currencyCode: 'RUB'),
          createdAt: DateTime.utc(2026),
        ),
        AssetValuation(
          id: 3,
          assetId: 1,
          effectiveOn: LocalDate(2026, 1, 3),
          value: const Money(minorUnits: 15000, currencyCode: 'EUR'),
          rateToRub: Decimal.fromInt(100),
          valueRub: const Money(minorUnits: 1500000, currencyCode: 'RUB'),
          createdAt: DateTime.utc(2026),
        ),
        AssetValuation(
          id: 2,
          assetId: 1,
          effectiveOn: LocalDate(2026, 1, 2),
          value: const Money(minorUnits: 14000, currencyCode: 'EUR'),
          rateToRub: Decimal.fromInt(100),
          valueRub: const Money(minorUnits: 1400000, currencyCode: 'RUB'),
          createdAt: DateTime.utc(2026),
        ),
        AssetValuation(
          id: 1,
          assetId: 1,
          effectiveOn: LocalDate(2026, 1, 1),
          value: const Money(minorUnits: 1000, currencyCode: 'JPY'),
          rateToRub: Decimal.parse('0.5'),
          valueRub: const Money(minorUnits: 50000, currencyCode: 'RUB'),
          createdAt: DateTime.utc(2026),
        ),
      ],
    );
    final vm = AccountDetailsViewModel(
      repository: repository,
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text(
        const MoneyFormatter().format(
          const Money(minorUnits: 1234, currencyCode: 'JPY'),
          _jpy,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        const MoneyFormatter().format(
          const Money(minorUnits: 15000, currencyCode: 'EUR'),
          _eur,
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.valuationCurrent), findsNWidgets(2));
  });

  testWidgets('отрицательная оценка отклоняется формой', (tester) async {
    final repository = FakeAssets(_snapshot());
    final vm = ValuationFormViewModel(
      repository: repository,
      rateRepository: FakeRates(),
      currencyRepository: FakeCurrencies(),
      assetId: 1,
      today: LocalDate(2026, 1, 2),
    );
    await _pump(tester, ValuationFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, '-5');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.valuationErrorValue), findsOneWidget);
    expect(repository.recorded, isEmpty);
  });

  test('будущая дата отклоняется', () async {
    final repository = FakeAssets(_snapshot());
    final vm = ValuationFormViewModel(
      repository: repository,
      rateRepository: FakeRates(),
      currencyRepository: FakeCurrencies(),
      assetId: 1,
      today: LocalDate(2026, 1, 2),
    );
    await vm.load();

    final result = await vm.save(
      value: const Money(minorUnits: 100, currencyCode: 'RUB'),
      effectiveOn: LocalDate(2026, 1, 3),
    );

    expect(result, isA<Failure<void>>());
    expect(repository.recorded, isEmpty);
  });

  testWidgets('валютная инвестиция показывает base equivalent без падения', (
    tester,
  ) async {
    const usd = Currency(
      code: 'USD',
      name: 'Доллар',
      fractionDigits: 2,
      isPreset: true,
      isEnabled: true,
    );
    final snapshot = AssetSnapshot(
      asset: _investment(currency: 'USD'),
      currentValue: const Money(minorUnits: 100000, currencyCode: 'USD'),
    );
    final vm = AccountDetailsViewModel(
      repository: FakeAssets(snapshot),
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies([usd, _rub]),
      rateRepository: FakeRates(rate: Decimal.fromInt(90)),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.assetBaseEquivalent), findsOneWidget);
    expect(find.textContaining('90'), findsWidgets);
  });

  testWidgets(
    'мультивалютная инвестиция показывает итог в базовой валюте и состав',
    (tester) async {
      final snapshot = AssetSnapshot(
        asset: _investment(),
        currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
        currencyBalances: const [
          Money(minorUnits: 10000000, currencyCode: 'RUB'),
          Money(minorUnits: 12000, currencyCode: 'USD'),
        ],
      );
      final vm = AccountDetailsViewModel(
        repository: FakeAssets(snapshot),
        assetId: 1,
        today: LocalDate(2026, 1, 3),
        settingsRepository: FakeSettings(),
        currencyRepository: FakeCurrencies(),
        rateRepository: FakeRates(rate: Decimal.fromInt(92)),
      );
      await _pump(tester, AccountDetailsScreen(viewModel: vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text(l10n.investmentBreakdownTitle), findsOneWidget);
      expect(find.text(l10n.investmentTotalBase), findsOneWidget);
      expect(find.text(l10n.assetBaseEquivalent), findsNothing);
      expect(
        find.text(
          const MoneyFormatter().format(
            const Money(minorUnits: 11104000, currencyCode: 'RUB'),
            _rub,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          const MoneyFormatter().format(
            const Money(minorUnits: 12000, currencyCode: 'USD'),
            _usd,
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.text(l10n.investmentBreakdownTitle)).dy,
        lessThan(tester.getTopLeft(find.text(l10n.accountEdit)).dy),
      );
    },
  );

  testWidgets(
    'мультивалютная инвестиция без курса показывает состав и подпись',
    (tester) async {
      final snapshot = AssetSnapshot(
        asset: _investment(),
        currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
        currencyBalances: const [
          Money(minorUnits: 10000000, currencyCode: 'RUB'),
          Money(minorUnits: 12000, currencyCode: 'USD'),
        ],
      );
      final vm = AccountDetailsViewModel(
        repository: FakeAssets(snapshot),
        assetId: 1,
        today: LocalDate(2026, 1, 3),
        settingsRepository: FakeSettings(),
        currencyRepository: FakeCurrencies(),
        rateRepository: FakeRates(),
      );
      await _pump(tester, AccountDetailsScreen(viewModel: vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(l10n.investmentBreakdownTitle), findsOneWidget);
      expect(find.text(l10n.assetBaseUnavailable), findsOneWidget);
      expect(find.text('—'), findsWidgets);
      expect(
        find.text(
          const MoneyFormatter().format(
            const Money(minorUnits: 10000000, currencyCode: 'RUB'),
            _rub,
          ),
        ),
        findsWidgets,
      );
    },
  );

  testWidgets('архивная инвестиция только для чтения', (tester) async {
    final snapshot = AssetSnapshot(
      asset: _investment(archived: true),
      currentValue: const Money(minorUnits: 150000, currencyCode: 'RUB'),
    );
    final vm = AccountDetailsViewModel(
      repository: FakeAssets(snapshot),
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.accountArchivedBadge), findsOneWidget);
    expect(find.text(l10n.accountEdit), findsNothing);
    expect(find.text(l10n.investmentAddValuation), findsNothing);
  });

  testWidgets('детали инвестиции показывают стоимость и историю оценок', (
    tester,
  ) async {
    final repository = FakeAssets(
      _snapshot(),
      valuationsHistory: [
        AssetValuation(
          id: 2,
          assetId: 1,
          effectiveOn: LocalDate(2026, 1, 2),
          value: const Money(minorUnits: 150000, currencyCode: 'RUB'),
          rateToRub: Decimal.one,
          valueRub: const Money(minorUnits: 150000, currencyCode: 'RUB'),
          createdAt: DateTime.utc(2026),
        ),
      ],
    );
    final vm = AccountDetailsViewModel(
      repository: repository,
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.investmentDetailsTitle), findsOneWidget);
    expect(find.text(l10n.investmentCurrentValue), findsOneWidget);
    expect(find.text(l10n.valuationHistory), findsOneWidget);
    expect(find.text('02.01.2026'), findsOneWidget);
    expect(find.text(l10n.investmentAddValuation), findsOneWidget);
    expect(find.text(l10n.accountForecastLabel), findsNothing);
  });

  testWidgets('инвестиция показывает заблокированные суммы по валютам', (
    tester,
  ) async {
    final repository = FakeAssets(
      _lockedSnapshot(
        locked: const [
          Money(minorUnits: 9900, currencyCode: 'USD'),
          Money(minorUnits: 500, currencyCode: 'EUR'),
        ],
      ),
    );
    final vm = AccountDetailsViewModel(
      repository: repository,
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(rate: Decimal.fromInt(92)),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.lockedAssetsTitle), findsOneWidget);
    // Доллар (USD) есть и в составе, и в строке заблокированной суммы.
    expect(find.text('Доллар (USD)'), findsNWidgets(2));
    expect(
      find.text(
        l10n.lockedAmountSubtitle(
          const MoneyFormatter().format(
            const Money(minorUnits: 9900, currencyCode: 'USD'),
            _usd,
          ),
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        l10n.lockedAmountSubtitle(
          const MoneyFormatter().format(
            const Money(minorUnits: 500, currencyCode: 'EUR'),
            _eur,
          ),
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.lockedNotMarked), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNWidgets(2));
    expect(find.byIcon(Icons.lock_open), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(l10n.lockedAssetsTitle)).dy,
      greaterThan(
        tester.getTopLeft(find.text(l10n.investmentBreakdownTitle)).dy,
      ),
    );
  });

  testWidgets('диалог заблокированной суммы сохраняет значение', (
    tester,
  ) async {
    final repository = FakeAssets(_lockedSnapshot());
    final vm = AccountDetailsViewModel(
      repository: repository,
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(rate: Decimal.fromInt(92)),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Доллар (USD)').last);
    await tester.pumpAndSettle();

    expect(find.text(l10n.lockedEditTitle), findsOneWidget);
    expect(
      find.text(
        l10n.lockedAvailableHint(
          const MoneyFormatter().format(
            const Money(minorUnits: 12000, currencyCode: 'USD'),
            _usd,
          ),
        ),
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).last, '99');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(
      repository.savedLocked.single,
      const Money(minorUnits: 9900, currencyCode: 'USD'),
    );
    expect(find.text(l10n.lockedSaved), findsOneWidget);
  });

  testWidgets('превышение баланса показывается под полем диалога', (
    tester,
  ) async {
    final repository = FakeAssets(_lockedSnapshot());
    final vm = AccountDetailsViewModel(
      repository: repository,
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(rate: Decimal.fromInt(92)),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Доллар (USD)').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '121');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(
      find.text(
        l10n.lockedErrorExceeds(
          const MoneyFormatter().format(
            const Money(minorUnits: 12000, currencyCode: 'USD'),
            _usd,
          ),
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.lockedEditTitle), findsOneWidget);
    expect(repository.savedLocked, isEmpty);
  });

  testWidgets('пустой ввод снимает отметку и показывает snackbar', (
    tester,
  ) async {
    final repository = FakeAssets(
      _lockedSnapshot(
        locked: const [Money(minorUnits: 9900, currencyCode: 'USD')],
      ),
    );
    final vm = AccountDetailsViewModel(
      repository: repository,
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(rate: Decimal.fromInt(92)),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Доллар (USD)').last);
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField).last);
    expect(field.controller!.text, '99');

    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(repository.savedLocked.single.isZero, isTrue);
    expect(find.text(l10n.lockedRemoved), findsOneWidget);
  });

  testWidgets('отметка валюты вне breakdown видна и открывается', (
    tester,
  ) async {
    final snapshot = AssetSnapshot(
      asset: _investment(),
      currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
      currencyBalances: const [
        Money(minorUnits: 10000000, currencyCode: 'RUB'),
      ],
      lockedBalances: const [Money(minorUnits: 9900, currencyCode: 'USD')],
    );
    final vm = AccountDetailsViewModel(
      repository: FakeAssets(snapshot),
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(rate: Decimal.fromInt(92)),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Доллар (USD)'), findsOneWidget);
    await tester.tap(find.text('Доллар (USD)'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.lockedEditTitle), findsOneWidget);
    expect(
      find.text(
        l10n.lockedAvailableHint(
          const MoneyFormatter().format(
            const Money(minorUnits: 0, currencyCode: 'USD'),
            _usd,
          ),
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('секция блокировки на 320dp/1.3/dark без overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = AccountDetailsViewModel(
      repository: FakeAssets(_lockedSnapshot()),
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(rate: Decimal.fromInt(92)),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: AccountDetailsScreen(viewModel: vm),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.lockedAssetsTitle), findsOneWidget);
  });

  testWidgets('архивная инвестиция показывает отметки без кнопки', (
    tester,
  ) async {
    final repository = FakeAssets(
      _lockedSnapshot(
        archived: true,
        locked: const [Money(minorUnits: 9900, currencyCode: 'USD')],
      ),
    );
    final vm = AccountDetailsViewModel(
      repository: repository,
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(rate: Decimal.fromInt(92)),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.lockedAssetsTitle), findsOneWidget);
    expect(
      find.text(
        l10n.lockedAmountSubtitle(
          const MoneyFormatter().format(
            const Money(minorUnits: 9900, currencyCode: 'USD'),
            _usd,
          ),
        ),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_open), findsNothing);
  });
}

AssetSnapshot _lockedSnapshot({
  bool archived = false,
  List<Money> locked = const [],
}) => AssetSnapshot(
  asset: _investment(archived: archived),
  currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
  currencyBalances: const [
    Money(minorUnits: 10000000, currencyCode: 'RUB'),
    Money(minorUnits: 12000, currencyCode: 'USD'),
    Money(minorUnits: 500, currencyCode: 'EUR'),
  ],
  lockedBalances: locked.isEmpty ? null : locked,
);
