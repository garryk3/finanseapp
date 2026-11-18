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
import 'package:flutter_test/flutter_test.dart';
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

  @override
  Future<int> create(AssetDraft draft) async {
    createdDraft = draft;
    return 1;
  }

  @override
  Future<void> update(int id, AssetDraft draft) async {}

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

AccountAsset _account({int opening = 10000000, bool archived = false}) =>
    AccountAsset(
      id: 1,
      name: 'Вклад',
      currencyCode: 'RUB',
      openingValue: Money(minorUnits: opening, currencyCode: 'RUB'),
      createdAt: DateTime.utc(2026),
      bankId: 1,
      annualRate: Decimal.parse('12'),
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
    expect(find.text(l10n.accountForecastLabel), findsOneWidget);
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
    final vm = AccountFormViewModel(
      repository: FakeAssets(snapshot),
      subgroupRepository: FakeSubgroups(),
      currencyRepository: FakeCurrencies(),
    );
    await _pump(tester, AccountFormScreen(viewModel: vm));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.ensureVisible(find.text(l10n.accountAddEndDate));
    await tester.tap(find.widgetWithText(AppButton, l10n.accountAddEndDate));
    await tester.pump();
    expect(find.text(l10n.accountRemoveEndDate), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.accountRemoveEndDate));
    await tester.tap(find.widgetWithText(AppButton, l10n.accountRemoveEndDate));
    await tester.pump();
    expect(find.text(l10n.accountAddEndDate), findsOneWidget);
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

    await tester.tap(find.text(l10n.accountDelete));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.assetInUseTitle), findsOneWidget);
    expect(find.text(l10n.assetInUseMessage(2, 0, 1, 0)), findsOneWidget);
  });
}
