import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:decimal/decimal.dart';
import 'package:signals/signals.dart';

/// Аналитика: период, вид активов и серия чистого капитала (9.2).
class AnalyticsViewModel {
  AnalyticsViewModel({
    required this.queries,
    required this.settingsRepository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.now,
  });

  final AnalyticsQueries queries;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;

  /// Провайдер «сегодня»: экран открывается заново, но дата должна быть
  /// актуальной при каждом reload.
  final LocalDate Function() now;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<AnalyticsPeriod> period = signal(AnalyticsPeriod.month);
  final Signal<AssetKind?> kind = signal(null);
  final Signal<List<NetWorthPoint>> points = signal(const []);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<bool> hasAnyAssets = signal(false);
  final Signal<MissingRate?> missingRate = signal(null);

  LocalDate _today = LocalDate.fromDateTime(DateTime.now());
  int _requestId = 0;
  bool _disposed = false;

  bool get filtersActive =>
      period.value != AnalyticsPeriod.month || kind.value != null;

  void init() {
    _today = now();
    _reload();
  }

  void selectPeriod(AnalyticsPeriod value) {
    if (period.value == value) return;
    period.value = value;
    _reload();
  }

  void selectKind(AssetKind? value) {
    if (kind.value == value) return;
    kind.value = value;
    _reload();
  }

  void resetFilters() {
    period.value = AnalyticsPeriod.month;
    kind.value = null;
    _reload();
  }

  void reload() {
    _today = now();
    _reload();
  }

  Future<void> _reload() async {
    final request = ++_requestId;
    state.value = const ViewLoading();
    try {
      final base = await settingsRepository.getBaseCurrency();
      final currencyList = await currencyRepository.watchAll().first;
      final selectedKind = kind.value;
      final earliestAll = await queries.earliestActivityDate();
      final earliest = selectedKind == null
          ? earliestAll
          : await queries.earliestActivityDate(assetKind: selectedKind);
      final range = analyticsRange(
        period: period.value,
        today: _today,
        earliest: earliest,
      );
      final series = await queries.netWorthSeries(
        period: range,
        assetKind: selectedKind,
      );
      if (_disposed || request != _requestId) return;
      baseCurrency.value = base;
      currencies.value = {
        for (final currency in currencyList) currency.code: currency,
      };
      hasAnyAssets.value = earliestAll != null;
      missingRate.value = null;
      points.value = series;
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      if (_disposed || request != _requestId) return;
      missingRate.value = error.code == DomainErrorCode.rateUnavailable
          ? _missingRateOf(error)
          : null;
      state.value = ViewError(error.code);
    } on Exception {
      if (_disposed || request != _requestId) return;
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  /// Ручной курс для отсутствующей даты (BR-C-2, BR-S-3): сохраняет и
  /// пересчитывает серию.
  Future<void> submitManualRate(Decimal rate) async {
    final missing = missingRate.value;
    if (missing == null) return;
    try {
      await rateRepository.saveManual(missing.currencyCode, missing.date, rate);
      missingRate.value = null;
      await _reload();
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  static MissingRate? _missingRateOf(DomainException error) {
    final code = error.fieldErrors['currencyCode'];
    final date = error.fieldErrors['date'];
    if (code == null || date == null) return null;
    try {
      return MissingRate(code, LocalDate.parse(date));
    } on DomainException {
      return null;
    }
  }

  String formatMoney(Money money) => const MoneyFormatter().format(
    money,
    currencies.value[money.currencyCode] ??
        baseCurrency.value ??
        Currency(
          code: money.currencyCode,
          name: money.currencyCode,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        ),
  );

  void dispose() {
    _disposed = true;
    _requestId++;
  }
}

/// Курс, которого не хватает для построения серии.
final class MissingRate {
  const MissingRate(this.currencyCode, this.date);

  final String currencyCode;
  final LocalDate date;
}
