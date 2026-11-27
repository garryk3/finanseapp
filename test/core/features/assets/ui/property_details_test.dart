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
import 'package:finanseapp/core/features/assets/ui/account_details_screen.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_view_model.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
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

PropertyAsset _property() => PropertyAsset(
  id: 1,
  name: 'Квартира',
  currencyCode: 'RUB',
  openingValue: const Money(minorUnits: 500000000, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  address: 'ул. Ленина, 1',
  purchasePrice: const Money(minorUnits: 450000000, currencyCode: 'RUB'),
);

final class FakeAssets implements AssetRepository {
  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([
        AssetSnapshot(
          asset: _property(),
          currentValue: _property().openingValue,
        ),
      ]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => const Stream.empty();

  @override
  Future<AssetSnapshot> getById(int id) async =>
      AssetSnapshot(asset: _property(), currentValue: _property().openingValue);

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

final class FakeCashflow implements CashflowRepository {
  @override
  Stream<List<CashflowEntry>> watchDeleted() => const Stream.empty();

  @override
  Stream<List<CashflowEntry>> watch(CashflowFilter filter) =>
      Stream.value(const []);

  @override
  Future<CashflowEntry> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(CashflowEntryDraft draft) async => 1;

  @override
  Future<int> createLinked(
    CashflowEntryDraft draft, {
    required int assetTransactionId,
  }) async => 1;

  @override
  Future<void> revise(int id, CashflowEntryDraft draft) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> restore(int id) async {}
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
  @override
  Future<int> getTaxRatePercent() async => defaultTaxRatePercent;

  @override
  Future<void> setTaxRatePercent(int percent) async {}
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

void main() {
  testWidgets('детали квартиры: правка, адрес, цена и cashflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final vm = AccountDetailsViewModel(
      repository: FakeAssets(),
      assetId: 1,
      today: LocalDate(2026, 1, 3),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
      cashflowRepository: FakeCashflow(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: AccountDetailsScreen(viewModel: vm),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.assetKindProperty), findsWidgets);
    expect(find.text('ул. Ленина, 1'), findsOneWidget);
    expect(
      find.textContaining(l10n.propertyPurchasePriceLabel),
      findsOneWidget,
    );
    expect(find.text(l10n.accountEdit), findsOneWidget);
    expect(find.text(l10n.propertyCashflowTitle), findsOneWidget);
    expect(find.text(l10n.propertyYieldNoOperations), findsOneWidget);
  });
}
