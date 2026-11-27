import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/cashflow_details_view_model.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

const _zeroSummary = CashflowSummary(
  income: Money(minorUnits: 0, currencyCode: 'RUB'),
  expense: Money(minorUnits: 0, currencyCode: 'RUB'),
  net: Money(minorUnits: 0, currencyCode: 'RUB'),
  currencyCode: 'RUB',
);

CashflowPeriodPoint _point(LocalDate date, {int income = 0, int expense = 0}) =>
    CashflowPeriodPoint(
      periodStart: date,
      summary: CashflowSummary(
        income: Money(minorUnits: income, currencyCode: 'RUB'),
        expense: Money(minorUnits: expense, currencyCode: 'RUB'),
        net: Money(minorUnits: income - expense, currencyCode: 'RUB'),
        currencyCode: 'RUB',
      ),
    );

final class _Queries implements AnalyticsQueries {
  _Queries({this.series = const []});

  List<CashflowPeriodPoint> series;
  CashflowSummary summary = _zeroSummary;
  Object? error;
  LocalDate? earliest = LocalDate(2024, 3, 5);
  final List<CashflowFilter> filters = [];

  CashflowFilter? get lastFilter => filters.isEmpty ? null : filters.last;

  @override
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind}) async =>
      earliest;

  @override
  Future<bool> hasAnyCashflow() async => true;

  @override
  Future<CashflowSummary> cashflow(CashflowFilter filter) async {
    filters.add(filter);
    final failure = error;
    if (failure != null) throw failure;
    return summary;
  }

  @override
  Future<List<CashflowPeriodPoint>> cashflowSeries(
    CashflowFilter filter,
  ) async {
    final failure = error;
    if (failure != null) throw failure;
    return series;
  }

  @override
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter) =>
      throw UnimplementedError();

  @override
  Future<NetWorthSummary> netWorth(LocalDate onDate) =>
      throw UnimplementedError();

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
    int? assetId,
  }) => throw UnimplementedError();
}

final class _Settings implements SettingsRepository {
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

final class _Currencies implements CurrencyRepository {
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

final class _Rates implements ExchangeRateRepository {
  final List<(String, LocalDate, Decimal)> saved = [];

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async => null;

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw UnimplementedError();

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) async {
    saved.add((currencyCode, date, rateToRub));
    return ExchangeRate(
      id: saved.length,
      currencyCode: currencyCode,
      date: date,
      rateToRub: rateToRub,
      source: ExchangeRateSource.manual,
      fetchedAt: DateTime.utc(2026, 11, 19),
    );
  }
}

void main() {
  final today = LocalDate(2026, 11, 19);

  CashflowDetailsViewModel build(_Queries queries, {_Rates? rates}) =>
      CashflowDetailsViewModel(
        queries: queries,
        settingsRepository: _Settings(),
        currencyRepository: _Currencies(),
        rateRepository: rates ?? _Rates(),
        now: () => today,
      );

  test('points: нулевые бакеты скрыты, порядок newest-first', () async {
    final queries = _Queries(
      series: [
        _point(LocalDate(2026, 9, 1), income: 1000),
        _point(LocalDate(2026, 10, 1)),
        _point(LocalDate(2026, 11, 1), expense: 500),
        _point(LocalDate(2026, 11, 2), income: 100, expense: 100),
      ],
    );
    final vm = build(queries)..init();
    await pumpEventQueue();

    expect(vm.state.value, isA<ViewData<void>>());
    expect(vm.points.value.map((point) => point.periodStart), [
      LocalDate(2026, 11, 2),
      LocalDate(2026, 11, 1),
      LocalDate(2026, 9, 1),
    ]);
  });

  test('по умолчанию месяц без kind/category', () async {
    final queries = _Queries();
    final vm = build(queries)..init();
    await pumpEventQueue();

    expect(vm.period.value, AnalyticsPeriod.month);
    expect(
      queries.lastFilter?.period,
      analyticsRange(period: AnalyticsPeriod.month, today: today),
    );
    expect(queries.lastFilter?.kind, isNull);
    expect(queries.lastFilter?.categoryId, isNull);
    expect(vm.summary.value, _zeroSummary);
    expect(vm.baseCurrency.value, _rub);
    expect(vm.points.value, isEmpty);
  });

  test('period/kind/category из query попадают в CashflowFilter', () async {
    final queries = _Queries();
    final vm = build(queries)
      ..setInitialPeriod(AnalyticsPeriod.year)
      ..setInitialKind(CashflowKind.expense)
      ..setInitialCategoryId(7)
      ..init();
    await pumpEventQueue();

    expect(
      queries.lastFilter?.period,
      analyticsRange(period: AnalyticsPeriod.year, today: today),
    );
    expect(queries.lastFilter?.kind, CashflowKind.expense);
    expect(queries.lastFilter?.categoryId, 7);
    expect(vm.period.value, AnalyticsPeriod.year);
    expect(vm.cashflowKind.value, CashflowKind.expense);
    expect(vm.categoryId.value, 7);
  });

  test('«всё время» передаёт null-период', () async {
    final queries = _Queries();
    build(queries)
      ..setInitialPeriod(AnalyticsPeriod.all)
      ..init();
    await pumpEventQueue();

    expect(queries.lastFilter?.period, isNull);
  });

  test('смена периода перезагружает серию', () async {
    final queries = _Queries(
      series: [_point(LocalDate(2026, 11, 1), income: 1000)],
    );
    final vm = build(queries)..init();
    await pumpEventQueue();
    final callsBefore = queries.filters.length;

    queries.series = [_point(LocalDate(2026, 1, 15), expense: 300)];
    vm.selectPeriod(AnalyticsPeriod.year);
    await pumpEventQueue();

    expect(queries.filters.length, callsBefore + 1);
    expect(
      queries.lastFilter?.period,
      analyticsRange(period: AnalyticsPeriod.year, today: today),
    );
    expect(vm.points.value.single.periodStart, LocalDate(2026, 1, 15));
  });

  test('все бакеты нулевые — пустой отфильтрованный список', () async {
    final queries = _Queries(
      series: [_point(LocalDate(2026, 11, 1)), _point(LocalDate(2026, 11, 2))],
    );
    final vm = build(queries)..init();
    await pumpEventQueue();

    expect(vm.state.value, isA<ViewData<void>>());
    expect(vm.points.value, isEmpty);
  });

  test('ошибка курса — missingRate; ручной курс перезагружает', () async {
    final queries = _Queries()
      ..error = const DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'currencyCode': 'USD', 'date': '2026-11-01'},
      );
    final rates = _Rates();
    final vm = build(queries, rates: rates)..init();
    await pumpEventQueue();

    expect(
      vm.state.value,
      isA<ViewError>().having(
        (state) => state.errorCode,
        'errorCode',
        DomainErrorCode.rateUnavailable,
      ),
    );
    expect(vm.missingRate.value?.currencyCode, 'USD');
    expect(vm.missingRate.value?.date, LocalDate(2026, 11, 1));

    queries.error = null;
    await vm.submitManualRate(Decimal.fromInt(90));
    await pumpEventQueue();

    expect(vm.missingRate.value, isNull);
    expect(vm.state.value, isA<ViewData<void>>());
    expect(rates.saved, [('USD', LocalDate(2026, 11, 1), Decimal.fromInt(90))]);
  });

  test('formatMoney использует валюту из справочника', () async {
    final vm = build(_Queries())..init();
    await pumpEventQueue();

    expect(
      vm.formatMoney(const Money(minorUnits: 123450, currencyCode: 'RUB')),
      '1\u00A0234,50 ₽',
    );
  });
}
