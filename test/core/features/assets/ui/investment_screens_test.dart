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
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class FakeAssets implements AssetRepository {
  FakeAssets(this.snapshot, {this.valuationsHistory = const []});

  final AssetSnapshot snapshot;
  final List<AssetValuation> valuationsHistory;
  final List<AssetValuationDraft> recorded = [];
  AssetDraft? savedDraft;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([snapshot]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => Stream.value(snapshot);

  @override
  Future<AssetSnapshot> getById(int id) async => snapshot;

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
}

final class FakeSubgroups implements SubgroupRepository {
  @override
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind) => Stream.value([
    const Subgroup(id: 7, kind: SubgroupKind.broker, name: 'Брокер'),
  ]);

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
  ) async => ExchangeRate(
    id: 1,
    currencyCode: currencyCode,
    date: date,
    rateToRub: rateToRub,
    source: ExchangeRateSource.manual,
    fetchedAt: DateTime.utc(2026),
  );
}

InvestmentAsset _investment({int opening = 100000, bool archived = false}) =>
    InvestmentAsset(
      id: 1,
      name: 'Брокерский счёт',
      currencyCode: 'RUB',
      openingValue: Money(minorUnits: opening, currencyCode: 'RUB'),
      createdAt: DateTime.utc(2026),
      brokerId: 7,
      archivedAt: archived ? DateTime.utc(2026, 2, 1) : null,
    );

AssetSnapshot _snapshot({int current = 150000}) => AssetSnapshot(
  asset: _investment(),
  currentValue: Money(minorUnits: current, currencyCode: 'RUB'),
);

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
}
