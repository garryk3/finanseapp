import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
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

final class _Queries implements AnalyticsQueries {
  _Queries(this.points);

  final List<NetWorthPoint> points;
  DateRange? lastRange;
  AssetKind? lastKind;
  Object? error;
  LocalDate? earliest = LocalDate(2024, 3, 5);
  LocalDate? earliestForKind;

  @override
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind}) async =>
      assetKind == null ? earliest : earliestForKind;

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
  }) async {
    lastRange = period;
    lastKind = assetKind;
    final failure = error;
    if (failure != null) throw failure;
    return points;
  }

  @override
  Future<NetWorthSummary> netWorth(LocalDate onDate) =>
      throw UnimplementedError();

  @override
  Future<CashflowSummary> cashflow(CashflowFilter filter) =>
      throw UnimplementedError();

  @override
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter) =>
      throw UnimplementedError();

  @override
  Future<List<CashflowPeriodPoint>> cashflowSeries(CashflowFilter filter) =>
      throw UnimplementedError();
}

final class _Settings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async => _rub;

  @override
  Future<void> setBaseCurrency(String code) async {}
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
  final points = [
    NetWorthPoint(
      date: LocalDate(2026, 11, 1),
      value: const Money(minorUnits: 100000, currencyCode: 'RUB'),
    ),
  ];
  final today = LocalDate(2026, 11, 19);

  AnalyticsViewModel build(_Queries queries, {_Rates? rates}) =>
      AnalyticsViewModel(
        queries: queries,
        settingsRepository: _Settings(),
        currencyRepository: _Currencies(),
        rateRepository: rates ?? _Rates(),
        now: () => today,
      );

  test('init строит месяц и отдаёт точки в base currency', () async {
    final queries = _Queries(points);
    final vm = build(queries)..init();
    await pumpEventQueue();

    expect(
      queries.lastRange,
      DateRange(start: LocalDate(2026, 11, 1), end: LocalDate(2026, 11, 30)),
    );
    expect(queries.lastKind, isNull);
    expect(vm.state.value, isA<ViewData<void>>());
    expect(vm.points.value, points);
    expect(vm.formatMoney(points.single.value), contains('₽'));
  });

  test('смена периода пересчитывает диапазон', () async {
    final queries = _Queries(points);
    final vm = build(queries)..init();
    await pumpEventQueue();

    vm.selectPeriod(AnalyticsPeriod.year);
    await pumpEventQueue();

    expect(
      queries.lastRange,
      DateRange(start: LocalDate(2026, 1, 1), end: LocalDate(2026, 12, 31)),
    );
  });

  test('kind-фильтр передаётся и all берёт самый ранний актив', () async {
    final queries = _Queries(points)..earliestForKind = LocalDate(2024, 3, 5);
    final vm = build(queries)..init();
    await pumpEventQueue();

    vm.selectPeriod(AnalyticsPeriod.all);
    vm.selectKind(AssetKind.account);
    await pumpEventQueue();

    expect(queries.lastKind, AssetKind.account);
    expect(
      queries.lastRange,
      DateRange(start: LocalDate(2024, 3, 5), end: today),
    );
  });

  test('отсутствие курса — ViewError, не пустой график', () async {
    final queries = _Queries(points)
      ..error = const DomainException(DomainErrorCode.rateUnavailable);
    final vm = build(queries)..init();
    await pumpEventQueue();

    expect(
      vm.state.value,
      isA<ViewError>().having(
        (state) => state.errorCode,
        'errorCode',
        DomainErrorCode.rateUnavailable,
      ),
    );
  });

  test('сброс фильтров возвращает месяц и все активы', () async {
    final queries = _Queries(points);
    final vm = build(queries)..init();
    await pumpEventQueue();
    vm.selectPeriod(AnalyticsPeriod.year);
    vm.selectKind(AssetKind.property);
    await pumpEventQueue();

    vm.resetFilters();
    await pumpEventQueue();

    expect(vm.period.value, AnalyticsPeriod.month);
    expect(vm.kind.value, isNull);
    expect(queries.lastKind, isNull);
  });

  test('нет активов — пустая серия, filtersActive false', () async {
    final queries = _Queries(const [])..earliest = null;
    final vm = build(queries)..init();
    await pumpEventQueue();

    expect(vm.points.value, isEmpty);
    expect(vm.hasAnyAssets.value, isFalse);
    expect(vm.filtersActive, isFalse);
  });

  test(
    'отсутствующий курс сохраняется вручную и серия пересчитывается',
    () async {
      final queries = _Queries(points)
        ..error = const DomainException(
          DomainErrorCode.rateUnavailable,
          fieldErrors: {'currencyCode': 'USD', 'date': '2026-11-01'},
        );
      final rates = _Rates();
      final vm = build(queries, rates: rates)..init();
      await pumpEventQueue();

      expect(vm.missingRate.value?.currencyCode, 'USD');
      expect(vm.missingRate.value?.date, LocalDate(2026, 11, 1));

      queries.error = null;
      await vm.submitManualRate(Decimal.fromInt(90));
      await pumpEventQueue();

      expect(vm.missingRate.value, isNull);
      expect(vm.state.value, isA<ViewData<void>>());
      expect(rates.saved, [
        ('USD', LocalDate(2026, 11, 1), Decimal.fromInt(90)),
      ]);
    },
  );

  test(
    'kind без активов: данные есть, но фильтр пуст — reset доступен',
    () async {
      final queries = _Queries(const [])
        ..earliest = LocalDate(2024, 3, 5)
        ..earliestForKind = null;
      final vm = build(queries)..init();
      await pumpEventQueue();

      vm.selectKind(AssetKind.property);
      await pumpEventQueue();

      expect(vm.hasAnyAssets.value, isTrue);
      expect(vm.points.value, isEmpty);
      expect(vm.filtersActive, isTrue);
    },
  );
}
