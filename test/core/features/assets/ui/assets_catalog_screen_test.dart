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
import 'package:finanseapp/core/features/assets/ui/assets_screen.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:flutter_test/flutter_test.dart';
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

final class FakeAssets implements AssetRepository {
  FakeAssets(this.snapshots);

  final List<AssetSnapshot> snapshots;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([
        for (final snapshot in snapshots)
          if (includeArchived || snapshot.asset.archivedAt == null) snapshot,
      ]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => Stream.value(
    snapshots.where((snapshot) => snapshot.asset.id == id).firstOrNull,
  );

  @override
  Future<AssetSnapshot> getById(int id) async =>
      snapshots.firstWhere((snapshot) => snapshot.asset.id == id);

  @override
  Future<int> create(AssetDraft draft) async => 1;

  @override
  Future<void> update(int id, AssetDraft draft) async {}

  @override
  Future<void> deleteIfUnused(int id) async {}

  @override
  Future<void> archive(int id) async {}

  @override
  Future<void> recordValuation(AssetValuationDraft draft) async {}

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) async =>
      const AssetReferenceCounts(
        transactions: 0,
        valuations: 0,
        goals: 0,
        cashflow: 0,
      );

  @override
  Future<List<AssetValuation>> valuations(int id) async => const [];

  @override
  Future<void> setLockedAmount(
    int assetId,
    String currencyCode,
    Money amount,
  ) async {}

  @override
  Future<List<Money>> lockedAmounts(int assetId) async => const [];
}

final class FakeCurrencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub, _usd]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub, _usd];

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
  @override
  Future<int> getTaxRatePercent() async => defaultTaxRatePercent;

  @override
  Future<void> setTaxRatePercent(int percent) async {}
}

final class FakeRates implements ExchangeRateRepository {
  FakeRates({this.usdRate = true});

  final bool usdRate;

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    if (currencyCode != 'USD' || !usdRate) return null;
    return ExchangeRate(
      id: 1,
      currencyCode: 'USD',
      date: date,
      rateToRub: Decimal.fromInt(90),
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
  ) => throw const DomainException(DomainErrorCode.validation);
}

AssetSnapshot _account() => AssetSnapshot(
  asset: AccountAsset(
    id: 1,
    name: 'Вклад',
    currencyCode: 'RUB',
    openingValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
    createdAt: DateTime.utc(2026),
    bankId: 1,
    annualRate: Decimal.zero,
    startDate: LocalDate(2026, 1, 1),
  ),
  currentValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
);

AssetSnapshot _investment() => AssetSnapshot(
  asset: InvestmentAsset(
    id: 2,
    name: 'Брокерский портфель',
    currencyCode: 'USD',
    openingValue: const Money(minorUnits: 100000, currencyCode: 'USD'),
    createdAt: DateTime.utc(2026),
    brokerId: 1,
  ),
  currentValue: const Money(minorUnits: 100000, currencyCode: 'USD'),
);

AssetSnapshot _archivedInvestment() => AssetSnapshot(
  asset: InvestmentAsset(
    id: 3,
    name: 'Старая инвестиция',
    currencyCode: 'RUB',
    openingValue: const Money(minorUnits: 50000, currencyCode: 'RUB'),
    createdAt: DateTime.utc(2026),
    brokerId: 1,
    archivedAt: DateTime.utc(2026, 2, 1),
  ),
  currentValue: const Money(minorUnits: 50000, currencyCode: 'RUB'),
);

AssetSnapshot _property() => AssetSnapshot(
  asset: PropertyAsset(
    id: 4,
    name: 'Дом на Ленина',
    currencyCode: 'RUB',
    openingValue: const Money(minorUnits: 500000000, currencyCode: 'RUB'),
    createdAt: DateTime.utc(2026),
  ),
  currentValue: const Money(minorUnits: 500000000, currencyCode: 'RUB'),
);

AssetsViewModel _viewModel(List<AssetSnapshot> snapshots, {FakeRates? rates}) =>
    AssetsViewModel(
      repository: FakeAssets(snapshots),
      currencyRepository: FakeCurrencies(),
      settingsRepository: FakeSettings(),
      rateRepository: rates ?? FakeRates(),
      today: LocalDate(2026, 1, 3),
    );

Future<void> _pump(WidgetTester tester, AssetsViewModel viewModel) async {
  tester.view.physicalSize = const Size(1000, 1800);
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
      home: AssetsScreen(viewModel: viewModel),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('список показывает виды, суммы и base equivalent', (
    tester,
  ) async {
    await _pump(tester, _viewModel([_account(), _investment(), _property()]));

    expect(find.text('Вклад'), findsOneWidget);
    expect(find.text('Брокерский портфель'), findsOneWidget);
    expect(find.text('Дом на Ленина'), findsOneWidget);
    expect(find.text(l10n.assetKindProperty), findsWidgets);
    expect(find.text(l10n.assetKindAccount), findsWidgets);
    expect(find.text(l10n.assetKindInvestment), findsWidgets);
    expect(find.textContaining('90\u00A0000'), findsOneWidget);
  });

  testWidgets('фильтр по виду и поиск сужают список', (tester) async {
    await _pump(tester, _viewModel([_account(), _investment(), _property()]));

    await tester.tap(
      find.widgetWithText(AppFilterChip, '${l10n.assetKindAccount} (1)'),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Вклад'), findsOneWidget);
    expect(find.text('Брокерский портфель'), findsNothing);

    await tester.tap(find.text(l10n.assetsResetFilters));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'Брокер');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Брокерский портфель'), findsOneWidget);
    expect(find.text('Вклад'), findsNothing);
  });

  testWidgets('архивные показываются по фильтру с бейджем', (tester) async {
    await _pump(
      tester,
      _viewModel([_account(), _investment(), _archivedInvestment()]),
    );

    expect(find.text('Старая инвестиция'), findsNothing);
    await tester.tap(find.text(l10n.assetsFilterArchived));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Старая инвестиция'), findsOneWidget);
    expect(find.text(l10n.accountArchivedBadge), findsOneWidget);
  });

  testWidgets('пустой фильтр отличается от пустого каталога', (tester) async {
    await _pump(tester, _viewModel([_account(), _investment()]));

    await tester.enterText(find.byType(TextField), 'нет такого');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.assetsFilteredEmptyTitle), findsOneWidget);
    expect(find.text(l10n.assetsEmptyTitle), findsNothing);

    await tester.tap(find.text(l10n.assetsResetFilters).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Вклад'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('каталог только из архивных не выглядит пустым', (tester) async {
    await _pump(tester, _viewModel([_archivedInvestment()]));

    expect(find.text(l10n.assetsAllArchivedTitle), findsOneWidget);
    expect(find.text(l10n.assetsEmptyTitle), findsNothing);

    await tester.tap(find.text(l10n.assetsFilterArchived).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Старая инвестиция'), findsOneWidget);
  });

  testWidgets('без курса эквивалент показывает «Курс недоступен»', (
    tester,
  ) async {
    await _pump(
      tester,
      _viewModel([_investment()], rates: FakeRates(usdRate: false)),
    );

    expect(find.text(l10n.assetBaseUnavailable), findsOneWidget);
  });

  testWidgets('пустой каталог предлагает создать актив', (tester) async {
    await _pump(tester, _viewModel([]));

    expect(find.text(l10n.assetsEmptyTitle), findsOneWidget);
    expect(find.text(l10n.assetsAddAsset), findsWidgets);
  });
}
