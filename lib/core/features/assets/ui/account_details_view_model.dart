import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/logic/net_worth_calculator.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/logic/account_forecast_calculator.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:signals/signals.dart';

/// Детали счёта: баланс, прогноз и действия.
class AccountDetailsViewModel {
  AccountDetailsViewModel({
    required this.repository,
    required this.assetId,
    required this.today,
    required this.settingsRepository,
    required this.currencyRepository,
    required this.rateRepository,
    this.cashflowRepository,
    this.recurringRepository,
    this.categoryRepository,
  });

  final AssetRepository repository;
  final int assetId;
  final LocalDate today;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final CashflowRepository? cashflowRepository;
  final RecurringRepository? recurringRepository;
  final CategoryRepository? categoryRepository;

  final Signal<AccountAsset?> account = signal(null);
  final Signal<Asset?> asset = signal(null);
  final Signal<Currency?> currency = signal(null);
  final Signal<List<AssetValuation>> valuationHistory = signal(const []);
  final Signal<Money?> balance = signal(null);
  final Signal<List<Money>> breakdown = signal(const []);
  final Signal<Money?> forecast = signal(null);
  final Signal<bool> busy = signal(false);
  final Signal<String?> error = signal(null);
  final Signal<Money?> baseEquivalent = signal(null);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<bool> baseRateUnavailable = signal(false);
  final Signal<AssetReferenceCounts?> referenceCounts = signal(null);

  StreamSubscription<AssetSnapshot?>? _subscription;
  bool _reloading = false;
  bool _reloadQueued = false;
  bool _disposed = false;
  bool _firstEvent = true;

  /// Подписывается на снимок актива и загружает детали.
  Future<void> load() async {
    _subscribe();
    if (_reloading) {
      _reloadQueued = true;
      return;
    }
    await _reload();
  }

  void _subscribe() {
    if (_disposed || _subscription != null) return;
    _subscription = repository.watchById(assetId).listen((_) {
      if (_firstEvent) {
        _firstEvent = false;
        return;
      }
      _scheduleReload();
    }, onError: (Object _) => _onStreamError());
  }

  void _onStreamError() {
    if (_disposed) return;
    error.value = 'storageFailure';
  }

  void _scheduleReload() {
    if (_disposed) return;
    if (_reloading) {
      _reloadQueued = true;
      return;
    }
    unawaited(_reload());
  }

  Future<void> _reload() async {
    if (_disposed) return;
    _reloading = true;
    try {
      final snapshot = await repository.getById(assetId);
      if (_disposed) return;
      final loaded = snapshot.asset;
      final loadedCurrency = await _currencyOf(loaded.currencyCode);
      if (_disposed) return;
      asset.value = loaded;
      currency.value = loadedCurrency;
      balance.value = snapshot.currentValue;
      breakdown.value = snapshot.breakdown;
      if (loaded is AccountAsset) {
        account.value = loaded;
        forecast.value = AccountForecastCalculator.call(
          account: loaded,
          currentBalance: snapshot.currentValue,
          asOf: today,
          currency: loadedCurrency,
        );
      } else {
        account.value = null;
        forecast.value = null;
        valuationHistory.value = await repository.valuations(assetId);
      }
      final counts = await repository.referenceCounts(assetId);
      if (_disposed) return;
      referenceCounts.value = counts;
      await _loadBaseEquivalent(snapshot);
    } on DomainException catch (exception) {
      error.value = exception.code.name;
    } on Exception {
      error.value = 'storageFailure';
    } finally {
      _reloading = false;
      if (_reloadQueued) {
        _reloadQueued = false;
        _scheduleReload();
      }
    }
  }

  Future<void> _loadBaseEquivalent(AssetSnapshot snapshot) async {
    if (_disposed) return;
    try {
      final base = await settingsRepository.getBaseCurrency();
      if (_disposed) return;
      baseCurrency.value = base;
      final breakdown = snapshot.breakdown;
      final needsConversion = breakdown.any(
        (money) => money.currencyCode != base.code,
      );
      final rates = <String, Decimal>{};
      if (needsConversion) {
        final codes = <String>{
          for (final money in breakdown)
            if (money.currencyCode != base.code && money.currencyCode != 'RUB')
              money.currencyCode,
          if (base.code != 'RUB') base.code,
        };
        for (final code in codes) {
          final rate = await rateRepository.find(code, today);
          if (rate == null) {
            baseRateUnavailable.value = true;
            return;
          }
          rates[code] = rate.rateToRub;
        }
      }
      final values = <NetWorthAssetValue>[];
      for (final money in breakdown) {
        values.add(
          NetWorthAssetValue(
            kind: snapshot.asset.kind,
            value: money,
            currency: await _currencyOf(money.currencyCode),
          ),
        );
        if (_disposed) return;
      }
      baseEquivalent.value = NetWorthCalculator.calculate(
        assets: values,
        ratesToRub: rates,
        baseCurrency: base,
      ).total;
      baseRateUnavailable.value = false;
    } on DomainException {
      baseRateUnavailable.value = true;
    } on Exception {
      baseRateUnavailable.value = true;
    }
  }

  Future<Currency> _currencyOf(String code) async {
    final currencies = await currencyRepository.watchAll().first;
    return currencies.firstWhere(
      (currency) => currency.code == code,
      orElse: () => Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      ),
    );
  }

  Future<Result<void>> archive() async {
    busy.value = true;
    try {
      await repository.archive(assetId);
      await load();
      return const Success(null);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }

  Future<Result<void>> delete() async {
    busy.value = true;
    try {
      await repository.deleteIfUnused(assetId);
      return const Success(null);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}
