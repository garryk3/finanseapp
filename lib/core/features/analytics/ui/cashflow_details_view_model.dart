import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Детализация денежного потока по периодам (18.5).
///
/// Серия приходит из [AnalyticsQueries.cashflowSeries] вместе с нулевыми
/// бакетами (они нужны графику), поэтому пустые периоды отфильтровываются
/// здесь, до показа списка.
final class CashflowDetailsViewModel {
  CashflowDetailsViewModel({
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

  /// Провайдер «сегодня»: период считается актуальным при каждом reload.
  final LocalDate Function() now;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<AnalyticsPeriod> period = signal(AnalyticsPeriod.month);
  final Signal<CashflowKind?> cashflowKind = signal(null);
  final Signal<int?> categoryId = signal(null);
  final Signal<List<CashflowPeriodPoint>> points = signal(const []);
  final Signal<CashflowSummary?> summary = signal(null);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<MissingRate?> missingRate = signal(null);

  LocalDate _today = LocalDate.fromDateTime(DateTime.now());
  int _requestId = 0;
  bool _disposed = false;

  /// Prefill фильтров из маршрута (до init).
  void setInitialPeriod(AnalyticsPeriod value) => period.value = value;

  void setInitialKind(CashflowKind? value) => cashflowKind.value = value;

  void setInitialCategoryId(int? value) => categoryId.value = value;

  void init() {
    _today = now();
    _reload();
  }

  void selectPeriod(AnalyticsPeriod value) {
    if (period.value == value) return;
    period.value = value;
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
      final range = analyticsRange(period: period.value, today: _today);
      final filter = CashflowFilter(
        period: period.value == AnalyticsPeriod.all ? null : range,
        kind: cashflowKind.value,
        categoryId: categoryId.value,
      );
      final cashflowSummary = await queries.cashflow(filter);
      final series = await queries.cashflowSeries(filter);
      if (_disposed || request != _requestId) return;
      baseCurrency.value = base;
      currencies.value = {
        for (final currency in currencyList) currency.code: currency,
      };
      missingRate.value = null;
      summary.value = cashflowSummary;
      points.value = [
        for (final point in series)
          if (!(point.summary.income.isZero && point.summary.expense.isZero))
            point,
      ]..sort((a, b) => b.periodStart.compareTo(a.periodStart));
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
  /// пересчитывает список.
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
