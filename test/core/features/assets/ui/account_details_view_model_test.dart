import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_view_model.dart';
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

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

AssetSnapshot _account(int value) => AssetSnapshot(
  asset: AccountAsset(
    id: 1,
    name: 'Вклад',
    currencyCode: 'RUB',
    openingValue: _rubles(value),
    createdAt: DateTime.utc(2026, 1, 1),
    bankId: 1,
    annualRate: Decimal.zero,
    startDate: LocalDate(2026, 1, 1),
  ),
  currentValue: _rubles(value),
);

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

final class _Assets implements AssetRepository {
  _Assets(this.snapshot);

  AssetSnapshot snapshot;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void emit(int value) {
    snapshot = _account(value);
    _changes.add(null);
  }

  void fail() => _changes.addError(StateError('stream failure'));

  @override
  Stream<AssetSnapshot?> watchById(int id) async* {
    yield snapshot;
    await for (final _ in _changes.stream) {
      yield snapshot;
    }
  }

  @override
  Future<AssetSnapshot> getById(int id) async => snapshot;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([snapshot]);

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
  Future<AssetReferenceCounts> referenceCounts(int id) async =>
      const AssetReferenceCounts(
        transactions: 0,
        valuations: 0,
        goals: 0,
        cashflow: 0,
      );

  @override
  Future<List<AssetValuation>> valuations(int id) async => const [];
}

final class _Currencies implements CurrencyRepository {
  _Currencies([this.items = const [_rub]]);

  final List<Currency> items;

  @override
  Stream<List<Currency>> watchAll() => Stream.value(items);

  @override
  Future<List<Currency>> getEnabled() async => items;

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

final class _Settings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async => _rub;

  @override
  Future<void> setBaseCurrency(String code) async {}
}

final class _Rates implements ExchangeRateRepository {
  _Rates([this.rates = const {}]);

  final Map<String, Decimal> rates;

  @override
  Future<ExchangeRate?> find(String code, LocalDate date) async {
    final rate = rates[code];
    if (rate == null) return null;
    return ExchangeRate(
      id: 1,
      currencyCode: code,
      date: date,
      rateToRub: rate,
      source: ExchangeRateSource.manual,
      fetchedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<ExchangeRate> fetchFromCbr(String code, LocalDate date) =>
      throw UnimplementedError();

  @override
  Future<ExchangeRate> saveManual(String code, LocalDate date, Decimal rate) =>
      throw UnimplementedError();
}

void main() {
  test('изменение счёта обновляет баланс при открытых деталях', () async {
    final assets = _Assets(_account(100));
    final vm = AccountDetailsViewModel(
      repository: assets,
      assetId: 1,
      today: LocalDate(2026, 11, 19),
      settingsRepository: _Settings(),
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
    );
    addTearDown(vm.dispose);

    await vm.load();
    expect(vm.balance.value, _rubles(100));

    assets.emit(150);
    await pumpEventQueue();
    await pumpEventQueue();

    expect(vm.balance.value, _rubles(150));
  });

  test('ошибка watch-потока даёт storageFailure', () async {
    final assets = _Assets(_account(100));
    final vm = AccountDetailsViewModel(
      repository: assets,
      assetId: 1,
      today: LocalDate(2026, 11, 19),
      settingsRepository: _Settings(),
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
    );
    addTearDown(vm.dispose);
    await vm.load();

    assets.fail();
    await pumpEventQueue();

    expect(vm.error.value, 'storageFailure');
  });

  test(
    'базовый эквивалент мультивалютной инвестиции — сумма позиций',
    () async {
      final assets = _Assets(
        _investment(const [
          Money(minorUnits: 10000000, currencyCode: 'RUB'),
          Money(minorUnits: 12000, currencyCode: 'USD'),
        ]),
      );
      final vm = AccountDetailsViewModel(
        repository: assets,
        assetId: 1,
        today: LocalDate(2026, 11, 19),
        settingsRepository: _Settings(),
        currencyRepository: _Currencies(),
        rateRepository: _Rates({'USD': Decimal.fromInt(92)}),
      );
      addTearDown(vm.dispose);

      await vm.load();

      expect(vm.breakdown.value, const [
        Money(minorUnits: 10000000, currencyCode: 'RUB'),
        Money(minorUnits: 12000, currencyCode: 'USD'),
      ]);
      expect(vm.baseEquivalent.value, _rubles(111040));
      expect(vm.baseRateUnavailable.value, isFalse);
    },
  );

  test('мультивалютная инвестиция без курса позиции — unavailable', () async {
    final assets = _Assets(
      _investment(const [
        Money(minorUnits: 10000000, currencyCode: 'RUB'),
        Money(minorUnits: 12000, currencyCode: 'USD'),
      ]),
    );
    final vm = AccountDetailsViewModel(
      repository: assets,
      assetId: 1,
      today: LocalDate(2026, 11, 19),
      settingsRepository: _Settings(),
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
    );
    addTearDown(vm.dispose);

    await vm.load();

    expect(vm.baseEquivalent.value, isNull);
    expect(vm.baseRateUnavailable.value, isTrue);
  });

  test('VM загружает справочник валют для форматирования строк', () async {
    final assets = _Assets(
      _investment(const [
        Money(minorUnits: 10000000, currencyCode: 'RUB'),
        Money(minorUnits: 12000, currencyCode: 'USD'),
      ]),
    );
    final vm = AccountDetailsViewModel(
      repository: assets,
      assetId: 1,
      today: LocalDate(2026, 11, 19),
      settingsRepository: _Settings(),
      currencyRepository: _Currencies(const [_rub, _usd]),
      rateRepository: _Rates({'USD': Decimal.fromInt(92)}),
    );
    addTearDown(vm.dispose);

    await vm.load();

    expect(vm.currencies.value['RUB'], _rub);
    expect(vm.currencies.value['USD'], _usd);
  });

  test('после dispose эмиссия не меняет баланс', () async {
    final assets = _Assets(_account(100));
    final vm = AccountDetailsViewModel(
      repository: assets,
      assetId: 1,
      today: LocalDate(2026, 11, 19),
      settingsRepository: _Settings(),
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
    );
    await vm.load();
    vm.dispose();

    assets.emit(150);
    await pumpEventQueue();

    expect(vm.balance.value, _rubles(100));
  });
}
