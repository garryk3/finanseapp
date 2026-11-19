import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
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
    required this.categoryRepository,
    required this.now,
  });

  final AnalyticsQueries queries;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final CategoryRepository categoryRepository;

  /// Провайдер «сегодня»: экран открывается заново, но дата должна быть
  /// актуальной при каждом reload.
  final LocalDate Function() now;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<AnalyticsPeriod> period = signal(AnalyticsPeriod.month);
  final Signal<AssetKind?> kind = signal(null);
  final Signal<List<NetWorthPoint>> points = signal(const []);
  final Signal<CashflowKind?> cashflowKind = signal(null);
  final Signal<int?> categoryId = signal(null);
  final Signal<CashflowSummary?> cashflowSummary = signal(null);
  final Signal<List<CashflowPeriodPoint>> cashflowPoints = signal(const []);
  final Signal<List<CategoryTotal>> categoryTotals = signal(const []);
  final Signal<Map<int, CashflowCategory>> categories = signal(const {});
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<bool> hasAnyAssets = signal(false);
  final Signal<bool> hasAnyCashflow = signal(false);
  final Signal<MissingRate?> missingRate = signal(null);

  LocalDate _today = LocalDate.fromDateTime(DateTime.now());
  int _requestId = 0;
  bool _disposed = false;

  bool get filtersActive => generalFiltersActive || cashflowFiltersActive;

  bool get generalFiltersActive =>
      period.value != AnalyticsPeriod.month || kind.value != null;

  bool get cashflowFiltersActive =>
      cashflowKind.value != null || categoryId.value != null;

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
    cashflowKind.value = null;
    categoryId.value = null;
    _reload();
  }

  void resetGeneralFilters() {
    period.value = AnalyticsPeriod.month;
    kind.value = null;
    _reload();
  }

  void resetCashflowFilters() {
    cashflowKind.value = null;
    categoryId.value = null;
    _reload();
  }

  void selectCashflowKind(CashflowKind? value) {
    if (cashflowKind.value == value) return;
    cashflowKind.value = value;
    final selectedCategory = categories.value[categoryId.value];
    if (selectedCategory != null &&
        value != null &&
        selectedCategory.kind != value) {
      categoryId.value = null;
    }
    if (value == null) categoryId.value = null;
    _reload();
  }

  void selectCategory(int? value) {
    if (categoryId.value == value) return;
    categoryId.value = value;
    _reload();
  }

  double categoryShare(CategoryTotal total) {
    final category = categories.value[total.categoryId];
    final summary = cashflowSummary.value;
    if (category == null || summary == null) return 0;
    final denominator = category.kind == CashflowKind.income
        ? summary.income.minorUnits
        : summary.expense.minorUnits;
    if (denominator == 0) return 0;
    return (total.total.minorUnits / denominator).clamp(0, 1).toDouble();
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
      final hasAnyCashflow = await queries.hasAnyCashflow();
      final cashflowFilter = CashflowFilter(
        period: period.value == AnalyticsPeriod.all ? null : range,
        kind: cashflowKind.value,
        categoryId: categoryId.value,
      );
      final cashflowSummary = await queries.cashflow(cashflowFilter);
      final cashflowPoints = await queries.cashflowSeries(cashflowFilter);
      final categoryTotals = await queries.cashflowByCategory(cashflowFilter);
      final incomeCategories = await categoryRepository
          .watchByKind(CashflowKind.income, includeArchived: true)
          .first;
      final expenseCategories = await categoryRepository
          .watchByKind(CashflowKind.expense, includeArchived: true)
          .first;
      if (_disposed || request != _requestId) return;
      baseCurrency.value = base;
      currencies.value = {
        for (final currency in currencyList) currency.code: currency,
      };
      categories.value = {
        for (final category in [...incomeCategories, ...expenseCategories])
          category.id: category,
      };
      hasAnyAssets.value = earliestAll != null;
      this.hasAnyCashflow.value = hasAnyCashflow;
      missingRate.value = null;
      points.value = series;
      this.cashflowSummary.value = cashflowSummary;
      this.cashflowPoints.value = cashflowPoints;
      this.categoryTotals.value = categoryTotals;
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
