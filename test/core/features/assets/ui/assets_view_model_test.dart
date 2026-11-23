import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

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
const _jpy = Currency(
  code: 'JPY',
  name: 'Иена',
  fractionDigits: 0,
  isPreset: false,
  isEnabled: true,
);

final class _StreamAssets implements AssetRepository {
  _StreamAssets(this.controller, {this.onCancel});

  final StreamController<List<AssetSnapshot>> controller;
  final void Function()? onCancel;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      controller.stream;

  @override
  Stream<AssetSnapshot?> watchById(int id) => const Stream.empty();

  @override
  Future<AssetSnapshot> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(AssetDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(int id, AssetDraft draft) => throw UnimplementedError();

  @override
  Future<void> deleteIfUnused(int id) => throw UnimplementedError();

  @override
  Future<void> archive(int id) => throw UnimplementedError();

  @override
  Future<void> recordValuation(AssetValuationDraft draft) =>
      throw UnimplementedError();

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) =>
      throw UnimplementedError();

  @override
  Future<List<AssetValuation>> valuations(int id) => throw UnimplementedError();

  @override
  Future<void> setLockedAmount(
    int assetId,
    String currencyCode,
    Money amount,
  ) async {}

  @override
  Future<List<Money>> lockedAmounts(int assetId) async => const [];
}

final class _StreamCurrencies implements CurrencyRepository {
  _StreamCurrencies(this.controller);

  final StreamController<List<Currency>> controller;

  @override
  Stream<List<Currency>> watchAll() => controller.stream;

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

final class _StreamSettings implements SettingsRepository {
  _StreamSettings(this.controller);

  final StreamController<Currency> controller;

  @override
  Stream<Currency> watchBaseCurrency() => controller.stream;

  @override
  Future<Currency> getBaseCurrency() async => _rub;

  @override
  Future<void> setBaseCurrency(String code) async {}
}

final class _NoRates implements ExchangeRateRepository {
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

final class _Rates implements ExchangeRateRepository {
  _Rates(this.rates);

  final Map<String, Decimal> rates;

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    final rate = rates[currencyCode];
    if (rate == null) return null;
    return ExchangeRate(
      id: 1,
      currencyCode: currencyCode,
      date: date,
      rateToRub: rate,
      source: ExchangeRateSource.manual,
      fetchedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw UnimplementedError();

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => throw UnimplementedError();
}

AssetSnapshot _investment(List<Money> balances) => AssetSnapshot(
  asset: InvestmentAsset(
    id: 1,
    name: 'Инвестиция',
    currencyCode: balances.first.currencyCode,
    openingValue: Money(
      minorUnits: 0,
      currencyCode: balances.first.currencyCode,
    ),
    createdAt: DateTime.utc(2026, 1, 1),
    brokerId: 1,
  ),
  currentValue: balances.first,
  currencyBalances: balances,
);

void main() {
  test('реагирует на смену базовой валюты и справочника', () async {
    final assets = StreamController<List<AssetSnapshot>>.broadcast();
    final base = StreamController<Currency>.broadcast();
    final currencies = StreamController<List<Currency>>.broadcast();
    final vm = AssetsViewModel(
      repository: _StreamAssets(assets),
      currencyRepository: _StreamCurrencies(currencies),
      settingsRepository: _StreamSettings(base),
      rateRepository: _NoRates(),
      today: LocalDate(2026, 1, 3),
    );
    addTearDown(() async {
      await vm.dispose();
      await assets.close();
      await base.close();
      await currencies.close();
    });

    vm.init();
    base.add(_rub);
    currencies.add(const [_rub, _usd]);
    await pumpEventQueue();
    expect(vm.baseCurrency.value?.code, 'RUB');

    base.add(_usd);
    currencies.add(const [_rub, _usd, _jpy]);
    await pumpEventQueue();

    expect(vm.baseCurrency.value?.code, 'USD');
    expect(vm.currencyOf('JPY').fractionDigits, 0);
  });

  test('dispose отменяет подписку на активы и справочники', () async {
    var cancelled = false;
    final assets = StreamController<List<AssetSnapshot>>(
      onCancel: () => cancelled = true,
    );
    final base = StreamController<Currency>.broadcast();
    final currencies = StreamController<List<Currency>>.broadcast();
    final vm = AssetsViewModel(
      repository: _StreamAssets(assets, onCancel: () => cancelled = true),
      currencyRepository: _StreamCurrencies(currencies),
      settingsRepository: _StreamSettings(base),
      rateRepository: _NoRates(),
      today: LocalDate(2026, 1, 3),
    );

    vm.init();
    await pumpEventQueue();
    expect(cancelled, isFalse);

    await vm.dispose();
    await pumpEventQueue();

    expect(cancelled, isTrue);
    expect(base.hasListener, isFalse);
    expect(currencies.hasListener, isFalse);
    await assets.close();
    await base.close();
    await currencies.close();
  });

  test(
    'базовый эквивалент мультивалютной инвестиции — сумма позиций',
    () async {
      final assets = StreamController<List<AssetSnapshot>>.broadcast();
      final base = StreamController<Currency>.broadcast();
      final currencies = StreamController<List<Currency>>.broadcast();
      final vm = AssetsViewModel(
        repository: _StreamAssets(assets),
        currencyRepository: _StreamCurrencies(currencies),
        settingsRepository: _StreamSettings(base),
        rateRepository: _Rates({'USD': Decimal.fromInt(92)}),
        today: LocalDate(2026, 1, 3),
      );
      addTearDown(() async {
        await vm.dispose();
        await assets.close();
        await base.close();
        await currencies.close();
      });

      final snapshot = _investment(const [
        Money(minorUnits: 10000000, currencyCode: 'RUB'),
        Money(minorUnits: 12000, currencyCode: 'USD'),
      ]);
      vm.init();
      base.add(_rub);
      currencies.add(const [_rub, _usd]);
      assets.add([snapshot]);
      await pumpEventQueue(times: 10);

      final result = vm.baseEquivalent(snapshot);
      expect(result.unavailable, isFalse);
      expect(result.text, '111\u00A0040,00 ₽');
    },
  );

  test('базовый эквивалент без курса позиции — unavailable', () async {
    final assets = StreamController<List<AssetSnapshot>>.broadcast();
    final base = StreamController<Currency>.broadcast();
    final currencies = StreamController<List<Currency>>.broadcast();
    final vm = AssetsViewModel(
      repository: _StreamAssets(assets),
      currencyRepository: _StreamCurrencies(currencies),
      settingsRepository: _StreamSettings(base),
      rateRepository: _NoRates(),
      today: LocalDate(2026, 1, 3),
    );
    addTearDown(() async {
      await vm.dispose();
      await assets.close();
      await base.close();
      await currencies.close();
    });

    final snapshot = _investment(const [
      Money(minorUnits: 10000000, currencyCode: 'RUB'),
      Money(minorUnits: 12000, currencyCode: 'USD'),
    ]);
    vm.init();
    base.add(_rub);
    currencies.add(const [_rub, _usd]);
    assets.add([snapshot]);
    await pumpEventQueue(times: 10);

    final result = vm.baseEquivalent(snapshot);
    expect(result.unavailable, isTrue);
    expect(result.text, isNull);
  });

  test('повторный init не оставляет старых подписок', () async {
    final assets = StreamController<List<AssetSnapshot>>.broadcast();
    final base = StreamController<Currency>.broadcast();
    final currencies = StreamController<List<Currency>>.broadcast();
    final vm = AssetsViewModel(
      repository: _StreamAssets(assets),
      currencyRepository: _StreamCurrencies(currencies),
      settingsRepository: _StreamSettings(base),
      rateRepository: _NoRates(),
      today: LocalDate(2026, 1, 3),
    );
    addTearDown(() async {
      await vm.dispose();
      await assets.close();
      await base.close();
      await currencies.close();
    });

    vm.init();
    vm.init();
    await pumpEventQueue();
    base.add(_usd);
    await pumpEventQueue();

    expect(vm.baseCurrency.value?.code, 'USD');
    expect(base.hasListener, isTrue);
  });
}
