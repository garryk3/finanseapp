import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/currency_converter.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/logic/account_forecast_calculator.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
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
  });

  final AssetRepository repository;
  final int assetId;
  final LocalDate today;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final CashflowRepository? cashflowRepository;

  final Signal<AccountAsset?> account = signal(null);
  final Signal<Asset?> asset = signal(null);
  final Signal<Currency?> currency = signal(null);
  final Signal<List<AssetValuation>> valuationHistory = signal(const []);
  final Signal<Money?> balance = signal(null);
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
      await _loadBaseEquivalent(snapshot.currentValue, loaded.currencyCode);
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

  Future<void> _loadBaseEquivalent(Money value, String sourceCode) async {
    if (_disposed) return;
    try {
      final base = await settingsRepository.getBaseCurrency();
      if (_disposed) return;
      baseCurrency.value = base;
      if (base.code == sourceCode) {
        baseEquivalent.value = value;
        baseRateUnavailable.value = false;
        return;
      }
      final source = await _currencyOf(sourceCode);
      final sourceRate = sourceCode == 'RUB'
          ? Decimal.one
          : (await rateRepository.find(sourceCode, today))?.rateToRub;
      final baseRate = base.code == 'RUB'
          ? Decimal.one
          : (await rateRepository.find(base.code, today))?.rateToRub;
      if (sourceRate == null || baseRate == null) {
        baseRateUnavailable.value = true;
        return;
      }
      baseEquivalent.value = CurrencyConverter.convertWithRates(
        value: value,
        source: source,
        target: base,
        sourceRateToRub: sourceRate,
        targetRateToRub: baseRate,
      );
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
