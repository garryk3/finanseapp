import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
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
import 'package:finanseapp/core/features/analytics/ui/cashflow_details_screen.dart';
import 'package:finanseapp/core/features/analytics/ui/cashflow_details_view_model.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
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
  Object? error;
  final List<CashflowFilter> filters = [];

  CashflowFilter? get lastFilter => filters.isEmpty ? null : filters.last;

  @override
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind}) async =>
      LocalDate(2024, 3, 5);

  @override
  Future<bool> hasAnyCashflow() async => true;

  @override
  Future<CashflowSummary> cashflow(CashflowFilter filter) async {
    filters.add(filter);
    final failure = error;
    if (failure != null) throw failure;
    return _zeroSummary;
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
  ) async => ExchangeRate(
    id: 1,
    currencyCode: currencyCode,
    date: date,
    rateToRub: rateToRub,
    source: ExchangeRateSource.manual,
    fetchedAt: DateTime.utc(2026, 11, 19),
  );
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  CashflowDetailsViewModel viewModel(_Queries queries) =>
      CashflowDetailsViewModel(
        queries: queries,
        settingsRepository: _Settings(),
        currencyRepository: _Currencies(),
        rateRepository: _Rates(),
        now: () => LocalDate(2026, 11, 19),
      );

  Future<void> pump(WidgetTester tester, CashflowDetailsViewModel vm) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: CashflowDetailsScreen(viewModel: vm),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('строки периодов: дата, доход, расход, итог; нулевых нет', (
    tester,
  ) async {
    final queries = _Queries(
      series: [
        _point(LocalDate(2026, 11, 1), income: 100000, expense: 25000),
        _point(LocalDate(2026, 11, 2)),
        _point(LocalDate(2026, 10, 1), income: 50000),
      ],
    );
    await pump(tester, viewModel(queries));

    expect(find.text(l10n.analyticsDetailsTitle), findsOneWidget);
    expect(find.text('01.11.2026'), findsOneWidget);
    expect(find.text('01.10.2026'), findsOneWidget);
    expect(find.text('02.11.2026'), findsNothing);
    expect(find.text('Доход: 1\u00A0000,00 ₽'), findsOneWidget);
    expect(find.text('Расход: 250,00 ₽'), findsOneWidget);
    expect(find.text('Итого: 750,00 ₽'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('01.11.2026')).dy,
      lessThan(tester.getTopLeft(find.text('01.10.2026')).dy),
    );
  });

  testWidgets('месяц без операций — «Нет операций за месяц»', (tester) async {
    final queries = _Queries(
      series: [_point(LocalDate(2026, 11, 1)), _point(LocalDate(2026, 11, 2))],
    );
    await pump(tester, viewModel(queries));

    expect(find.text(l10n.analyticsCashflowEmptyMonthTitle), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowEmptyMonthMessage), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowEmptyTitle), findsNothing);
  });

  testWidgets('год без операций — «Нет операций за период»', (tester) async {
    final queries = _Queries(
      series: [_point(LocalDate(2026, 1, 1)), _point(LocalDate(2026, 5, 1))],
    );
    final vm = viewModel(queries)..setInitialPeriod(AnalyticsPeriod.year);
    await pump(tester, vm);

    expect(find.text(l10n.analyticsCashflowEmptyTitle), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowEmptyMessage), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowEmptyMonthTitle), findsNothing);
  });

  testWidgets('чип периода перезагружает серию', (tester) async {
    final queries = _Queries(
      series: [_point(LocalDate(2026, 11, 1), income: 100000)],
    );
    await pump(tester, viewModel(queries));

    queries.series = [_point(LocalDate(2026, 3, 1), expense: 50000)];
    await tester.tap(find.text(l10n.analyticsPeriodYear));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      queries.lastFilter?.period,
      analyticsRange(
        period: AnalyticsPeriod.year,
        today: LocalDate(2026, 11, 19),
      ),
    );
    expect(find.text('Март 2026'), findsOneWidget);
  });

  testWidgets('унаследованные фильтры видны и сбрасываются', (tester) async {
    final queries = _Queries(
      series: [_point(LocalDate(2026, 11, 1), expense: 50000)],
    );
    final vm = viewModel(queries)
      ..setInitialKind(CashflowKind.expense)
      ..setInitialCategoryId(7);
    await pump(tester, vm);

    expect(find.text(l10n.analyticsCashflowExpense), findsOneWidget);
    expect(find.text(l10n.analyticsDetailsCategoryFilter), findsOneWidget);

    await tester.tap(find.text(l10n.assetsResetFilters));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.analyticsDetailsCategoryFilter), findsNothing);
    expect(vm.cashflowKind.value, isNull);
    expect(vm.categoryId.value, isNull);
    expect(queries.lastFilter?.kind, isNull);
    expect(queries.lastFilter?.categoryId, isNull);
  });

  testWidgets('пусто при унаследованном фильтре — подсказка про фильтры', (
    tester,
  ) async {
    final queries = _Queries(series: [_point(LocalDate(2026, 11, 1))]);
    final vm = viewModel(queries)..setInitialKind(CashflowKind.income);
    await pump(tester, vm);

    expect(
      find.text(l10n.analyticsDetailsEmptyFilteredMessage),
      findsOneWidget,
    );
    expect(find.text(l10n.analyticsCashflowEmptyMonthMessage), findsNothing);
  });

  testWidgets('ошибка курса — AppErrorState и «Ввести курс»', (tester) async {
    final queries = _Queries()
      ..error = const DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'currencyCode': 'USD', 'date': '2026-11-01'},
      );
    await pump(tester, viewModel(queries));

    expect(find.text(l10n.analyticsRateErrorTitle), findsOneWidget);
    expect(
      find.text(l10n.analyticsRateErrorMessage('USD', '01.11.2026')),
      findsOneWidget,
    );
    expect(find.text(l10n.analyticsEnterRate), findsOneWidget);
  });
}
