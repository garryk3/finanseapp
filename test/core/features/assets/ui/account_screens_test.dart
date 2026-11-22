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
import 'package:finanseapp/core/features/assets/ui/account_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class FakeAssets implements AssetRepository {
  FakeAssets(
    this.snapshot, {
    this.counts = const AssetReferenceCounts(
      transactions: 0,
      valuations: 0,
      goals: 0,
      cashflow: 0,
    ),
  });

  final AssetSnapshot snapshot;
  final AssetReferenceCounts counts;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([snapshot]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => Stream.value(snapshot);

  @override
  Future<AssetSnapshot> getById(int id) async => snapshot;

  AssetDraft? createdDraft;
  AssetDraft? updatedDraft;

  @override
  Future<List<AssetValuation>> valuations(int id) async => const [];

  @override
  Future<int> create(AssetDraft draft) async {
    createdDraft = draft;
    return 1;
  }

  @override
  Future<void> update(int id, AssetDraft draft) async {
    updatedDraft = draft;
  }

  @override
  Future<void> deleteIfUnused(int id) async {}

  @override
  Future<void> archive(int id) async {}

  @override
  Future<void> recordValuation(AssetValuationDraft draft) async {}

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) async => counts;
}

final class FakeSubgroups implements SubgroupRepository {
  @override
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind) => Stream.value([
    const Subgroup(id: 1, kind: SubgroupKind.bank, name: 'Банк'),
  ]);

  @override
  Future<List<Subgroup>> getByKind(SubgroupKind kind) async => [
    const Subgroup(id: 1, kind: SubgroupKind.bank, name: 'Банк'),
  ];

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
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub];

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
  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async => null;

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw const DomainException(DomainErrorCode.rateUnavailable);

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => throw const DomainException(DomainErrorCode.validation);
}

AccountAsset _account({
  int opening = 10000000,
  bool archived = false,
  String rate = '12',
}) => AccountAsset(
  id: 1,
  name: 'Вклад',
  currencyCode: 'RUB',
  openingValue: Money(minorUnits: opening, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  bankId: 1,
  annualRate: Decimal.parse(rate),
  startDate: LocalDate(2026, 1, 1),
  endDate: LocalDate(2027, 1, 1),
  archivedAt: archived ? DateTime.utc(2026, 2, 1) : null,
);

Future<void> _pump(WidgetTester tester, Widget child) async {
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

  testWidgets('форма предзаполняет баланс в основных единицах', (tester) async {
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
    );
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
      editingId: 1,
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.any((field) => field.controller?.text == '100000'), isTrue);
  });

  testWidgets('ошибка загрузки формы счёта даёт retry', (tester) async {
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: FakeSubgroups(),
      currencyRepository: _FailingCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    expect(find.text(l10n.errorStateMessage), findsOneWidget);
    expect(find.text(l10n.retry), findsOneWidget);

    await tester.tap(find.text(l10n.retry));
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorStateMessage), findsNothing);
    expect(find.text(l10n.commonSave), findsOneWidget);
  });

  testWidgets('пустой справочник банков предлагает добавить банк', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final subgroups = _MutableSubgroups();
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: subgroups,
      currencyRepository: FakeCurrencies(),
    );
    String? requestedKind;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AccountFormScreen(viewModel: vm),
        ),
        GoRoute(
          path: '/more/subgroups',
          builder: (context, state) {
            requestedKind = state.uri.queryParameters['kind'];
            return const AppScaffold(title: 'Банки', body: AppText('STUB'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.accountNoBanks), findsOneWidget);
    expect(find.text(l10n.bankAddAction), findsOneWidget);

    subgroups.banks.add(
      const Subgroup(id: 9, kind: SubgroupKind.bank, name: 'Новый банк'),
    );
    await tester.tap(find.text(l10n.bankAddAction));
    await tester.pumpAndSettle();
    expect(requestedKind, 'bank');
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountNoBanks), findsNothing);
    expect(find.text('Новый банк'), findsOneWidget);
  });

  testWidgets('создание: поле ставки пустое, ввод 12 даёт 12', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final assets = FakeAssets(snapshot);
    final vm = AccountFormViewModel(
      repository: assets,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    final rateField = tester.widget<TextField>(find.byType(TextField).at(2));
    expect(rateField.controller!.text, isEmpty);
    expect(rateField.decoration?.hintText, l10n.accountRateHint);

    await tester.enterText(find.byType(TextField).first, 'Наличные');
    await tester.enterText(find.byType(TextField).at(2), '12');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      (assets.createdDraft! as AccountDraft).annualRate,
      Decimal.parse('12'),
    );
  });

  testWidgets('редактирование: нулевые баланс и ставка показаны пустыми', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final snapshot = AssetSnapshot(
      asset: _account(opening: 0, rate: '0'),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final assets = FakeAssets(snapshot);
    final vm = AccountFormViewModel(
      repository: assets,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
      editingId: 1,
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, isEmpty);
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, isEmpty);

    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final draft = assets.updatedDraft! as AccountDraft;
    expect(draft.openingValue.minorUnits, 0);
    expect(draft.annualRate, Decimal.zero);
  });

  testWidgets('редактирование: ненулевые баланс и ставка показаны как есть', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final snapshot = AssetSnapshot(
      asset: _account(opening: 10000000, rate: '12.5'),
      currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
    );
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
      editingId: 1,
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, '100000');
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, '12.5');
  });

  testWidgets('пустые баланс и ставка сохраняются как нули', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final assets = FakeAssets(snapshot);
    final vm = AccountFormViewModel(
      repository: assets,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    await tester.enterText(find.byType(TextField).first, 'Наличные');
    await tester.enterText(find.byType(TextField).at(2), '');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final draft = assets.createdDraft;
    expect(draft, isA<AccountDraft>());
    expect((draft! as AccountDraft).openingValue.minorUnits, 0);
    expect((draft as AccountDraft).annualRate, Decimal.zero);
    expect(find.text(l10n.accountErrorAmount), findsNothing);
    expect(find.text(l10n.accountErrorRate), findsNothing);
  });

  testWidgets('невалидная ставка отклоняется', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final assets = FakeAssets(snapshot);
    final vm = AccountFormViewModel(
      repository: assets,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    await tester.enterText(find.byType(TextField).first, 'Наличные');
    await tester.enterText(find.byType(TextField).at(2), 'abc');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.accountErrorRate), findsOneWidget);
    expect(assets.createdDraft, isNull);
  });

  testWidgets('форма не сохраняет пустое название', (tester) async {
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.accountErrorName), findsOneWidget);
  });

  testWidgets('детали показывают баланс, прогноз и архивный статус', (
    tester,
  ) async {
    final snapshot = AssetSnapshot(
      asset: _account(archived: true),
      currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
    );
    final vm = AccountDetailsViewModel(
      repository: FakeAssets(snapshot),
      assetId: 1,
      today: LocalDate(2026, 1, 1),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));

    expect(find.text(l10n.accountBalanceLabel), findsOneWidget);
    expect(find.textContaining(l10n.accountForecastLabel), findsOneWidget);
    expect(find.text(l10n.accountArchivedBadge), findsOneWidget);
    expect(find.textContaining('100\u00A0000'), findsWidgets);
  });

  testWidgets('дата окончания включается и снимается', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final repository = FakeAssets(snapshot);
    final vm = AccountFormViewModel(
      repository: repository,
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 500));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Счёт');
    await tester.enterText(fields.at(1), '100');

    await tester.ensureVisible(find.text(l10n.accountAddEndDate));
    await tester.tap(find.widgetWithText(AppButton, l10n.accountAddEndDate));
    await tester.pump();
    expect(find.text(l10n.accountRemoveEndDate), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.createdDraft, isA<AccountDraft>());
    expect((repository.createdDraft! as AccountDraft).endDate, isNotNull);

    await tester.ensureVisible(find.text(l10n.accountRemoveEndDate));
    await tester.tap(find.widgetWithText(AppButton, l10n.accountRemoveEndDate));
    await tester.pump();
    expect(find.text(l10n.accountAddEndDate), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));
    expect((repository.createdDraft! as AccountDraft).endDate, isNull);
  });

  testWidgets('детали перезагружаются при новом VM', (tester) async {
    final first = AssetSnapshot(
      asset: _account(opening: 10000000),
      currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
    );
    final second = AssetSnapshot(
      asset: _account(opening: 5000000),
      currentValue: const Money(minorUnits: 5000000, currencyCode: 'RUB'),
    );
    final vm1 = AccountDetailsViewModel(
      repository: FakeAssets(first),
      assetId: 1,
      today: LocalDate(2026, 1, 1),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
    );
    final vm2 = AccountDetailsViewModel(
      repository: FakeAssets(second),
      assetId: 1,
      today: LocalDate(2026, 1, 1),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm1));
    expect(find.textContaining('100\u00A0000'), findsWidgets);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: AccountDetailsScreen(viewModel: vm2),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('50\u00A0000'), findsWidgets);
  });

  testWidgets('занятый счёт не предлагает удаление, а объясняет', (
    tester,
  ) async {
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
    );
    final vm = AccountDetailsViewModel(
      repository: FakeAssets(
        snapshot,
        counts: const AssetReferenceCounts(
          transactions: 2,
          valuations: 0,
          goals: 1,
          cashflow: 0,
        ),
      ),
      assetId: 1,
      today: LocalDate(2026, 1, 1),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
    );
    await _pump(tester, AccountDetailsScreen(viewModel: vm));

    await tester.tap(find.byTooltip(l10n.assetActions));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.accountDelete));
    await tester.pumpAndSettle();

    expect(find.text(l10n.assetInUseTitle), findsOneWidget);
    expect(find.text(l10n.assetInUseMessage(2, 0, 1, 0, 0)), findsOneWidget);
  });

  testWidgets('подсказка о капитализации появляется при ставке > 0', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));

    expect(find.text(l10n.accountRateAutoHint), findsNothing);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(2), '12');
    await tester.pump();

    expect(find.text(l10n.accountRateAutoHint), findsOneWidget);
  });

  test('сохранение счёта запускает catch-up процентов', () async {
    var catchupCalls = 0;
    final snapshot = AssetSnapshot(
      asset: _account(),
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
      catchup: () async {
        catchupCalls++;
      },
    );

    final result = await vm.save(
      name: 'Вклад',
      bankId: 1,
      currencyCode: 'RUB',
      openingValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
      annualRate: Decimal.parse('12'),
      startDate: LocalDate(2026, 1, 1),
    );
    await Future<void>.delayed(Duration.zero);

    expect(result, isA<Success<int>>());
    expect(catchupCalls, 1);
    vm.dispose();
  });
}

final class _FailingCurrencies implements CurrencyRepository {
  int calls = 0;

  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  Future<List<Currency>> getEnabled() async {
    calls++;
    if (calls == 1) {
      throw const DomainException(DomainErrorCode.storageFailure);
    }
    return const [_rub];
  }

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

final class _MutableSubgroups implements SubgroupRepository {
  final List<Subgroup> banks = [];

  @override
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind) =>
      Stream.value([...banks]);

  @override
  Future<List<Subgroup>> getByKind(SubgroupKind kind) async => [...banks];

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
