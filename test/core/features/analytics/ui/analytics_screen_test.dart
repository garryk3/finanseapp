import 'dart:async';

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
import 'package:finanseapp/core/features/analytics/ui/analytics_screen.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
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

final class _Queries implements AnalyticsQueries {
  _Queries({
    LocalDate? earliest,
    this.hasEarliest = true,
    this.earliestForKind,
    this.error,
    this.earliestGate,
    this.netWorthPoints = const [],
    this.cashflowResult = const CashflowSummary(
      income: Money(minorUnits: 0, currencyCode: 'RUB'),
      expense: Money(minorUnits: 0, currencyCode: 'RUB'),
      net: Money(minorUnits: 0, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    ),
    this.filteredCashflowResult,
    this.hasCashflow = false,
    this.cashflowPoints = const [],
    this.categoryTotals = const [],
  }) : earliest = earliest ?? LocalDate(2024, 3, 5);

  final LocalDate earliest;
  final bool hasEarliest;
  final LocalDate? earliestForKind;
  final Object? error;
  final Completer<LocalDate?>? earliestGate;
  final List<NetWorthPoint> netWorthPoints;
  final CashflowSummary cashflowResult;
  final CashflowSummary? filteredCashflowResult;
  final bool hasCashflow;
  final List<CashflowPeriodPoint> cashflowPoints;
  final List<CategoryTotal> categoryTotals;
  CashflowFilter? lastCashflowFilter;
  AssetKind? lastKind;

  @override
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind}) async {
    final gate = earliestGate;
    if (gate != null) return gate.future;
    if (assetKind == null) return hasEarliest ? earliest : null;
    return earliestForKind;
  }

  @override
  Future<bool> hasAnyCashflow() async => hasCashflow;

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
    int? assetId,
  }) async {
    lastKind = assetKind;
    final failure = error;
    if (failure != null) throw failure;
    return netWorthPoints;
  }

  @override
  Future<NetWorthSummary> netWorth(LocalDate onDate) =>
      throw UnimplementedError();

  @override
  Future<CashflowSummary> cashflow(CashflowFilter filter) async {
    lastCashflowFilter = filter;
    final isAllTime =
        filter.period == null &&
        filter.kind == null &&
        filter.categoryId == null;
    return isAllTime
        ? cashflowResult
        : filteredCashflowResult ?? cashflowResult;
  }

  @override
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter) async =>
      categoryTotals;

  @override
  Future<List<CashflowPeriodPoint>> cashflowSeries(
    CashflowFilter filter,
  ) async => cashflowPoints;
}

final class _Categories implements CategoryRepository {
  _Categories([this.items = const []]);

  final List<CashflowCategory> items;

  @override
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  }) => Stream.value([
    for (final item in items)
      if (item.kind == kind && (includeArchived || item.archivedAt == null))
        item,
  ]);

  @override
  Future<int> create(CashflowCategoryDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(CashflowCategory category) => throw UnimplementedError();

  @override
  Future<int> countEntries(int id) => throw UnimplementedError();

  @override
  Future<void> archive(int id) => throw UnimplementedError();

  @override
  Future<void> moveEntriesAndDelete(int id, int targetId) =>
      throw UnimplementedError();

  @override
  Future<void> deleteIfUnused(int id) => throw UnimplementedError();
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

AnalyticsViewModel _viewModel(
  _Queries queries, {
  List<CashflowCategory> categories = const [],
}) => AnalyticsViewModel(
  queries: queries,
  settingsRepository: _Settings(),
  currencyRepository: _Currencies(),
  rateRepository: _Rates(),
  categoryRepository: _Categories(categories),
  now: () => LocalDate(2026, 11, 19),
);

Future<void> _pump(
  WidgetTester tester,
  AnalyticsViewModel viewModel, {
  double width = 1000,
}) async {
  tester.view.physicalSize = Size(width, 1800);
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
      home: AnalyticsScreen(viewModel: viewModel),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('фильтры видны во время загрузки, skeleton только в контенте', (
    tester,
  ) async {
    final gate = Completer<LocalDate?>();
    final vm = _viewModel(_Queries(earliestGate: gate));
    await _pump(tester, vm);

    expect(find.text(l10n.analyticsPeriodYear), findsOneWidget);
    expect(find.text(l10n.analyticsKindAll), findsOneWidget);

    gate.complete(null);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(l10n.analyticsNoAssetsTitle), findsOneWidget);
  });

  testWidgets('ошибка курса: фильтры и ручной ввод доступны', (tester) async {
    final queries = _Queries(
      error: const DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'currencyCode': 'USD', 'date': '2026-11-01'},
      ),
    );
    await _pump(tester, _viewModel(queries));

    expect(find.text(l10n.analyticsRateErrorTitle), findsOneWidget);
    expect(find.text(l10n.analyticsEnterRate), findsOneWidget);

    await tester.tap(find.text(l10n.analyticsPeriodYear));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.analyticsRateErrorTitle), findsOneWidget);
  });

  testWidgets('без активов — CTA в активы', (tester) async {
    await _pump(tester, _viewModel(_Queries(hasEarliest: false)));

    expect(find.text(l10n.analyticsNoAssetsTitle), findsOneWidget);
    expect(find.text(l10n.navAssets), findsOneWidget);
  });

  testWidgets('пустой kind даёт reset, сброс возвращает все активы', (
    tester,
  ) async {
    final queries = _Queries(earliestForKind: null);
    await _pump(tester, _viewModel(queries));

    await tester.tap(find.text(l10n.assetKindProperty));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.analyticsEmptyTitle), findsOneWidget);
    expect(find.text(l10n.assetsResetFilters), findsWidgets);
    expect(queries.lastKind, AssetKind.property);

    await tester.tap(find.text(l10n.assetsResetFilters).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(queries.lastKind, isNull);
  });

  testWidgets('cashflow-секция, категории и фильтр по типу', (tester) async {
    final incomeCategory = CashflowCategory(
      id: 1,
      kind: CashflowKind.income,
      name: 'Зарплата',
      isPreset: false,
    );
    final queries = _Queries(
      netWorthPoints: [
        NetWorthPoint(
          date: LocalDate(2026, 11, 1),
          value: const Money(minorUnits: 100000, currencyCode: 'RUB'),
        ),
        NetWorthPoint(
          date: LocalDate(2026, 11, 5),
          value: const Money(minorUnits: 150000, currencyCode: 'RUB'),
        ),
      ],
      cashflowResult: const CashflowSummary(
        income: Money(minorUnits: 100000, currencyCode: 'RUB'),
        expense: Money(minorUnits: 0, currencyCode: 'RUB'),
        net: Money(minorUnits: 100000, currencyCode: 'RUB'),
        currencyCode: 'RUB',
      ),
      cashflowPoints: [
        CashflowPeriodPoint(
          periodStart: LocalDate(2026, 11, 1),
          summary: const CashflowSummary(
            income: Money(minorUnits: 100000, currencyCode: 'RUB'),
            expense: Money(minorUnits: 0, currencyCode: 'RUB'),
            net: Money(minorUnits: 100000, currencyCode: 'RUB'),
            currencyCode: 'RUB',
          ),
        ),
      ],
      categoryTotals: const [
        CategoryTotal(
          categoryId: 1,
          total: Money(minorUnits: 100000, currencyCode: 'RUB'),
        ),
      ],
    );

    await _pump(tester, _viewModel(queries, categories: [incomeCategory]));

    expect(find.text(l10n.analyticsCashflowTitle), findsOneWidget);
    expect(find.text(l10n.analyticsCategoriesTitle), findsOneWidget);
    expect(find.text('Зарплата'), findsOneWidget);
    expect(find.textContaining('100%'), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowIncome), findsOneWidget);

    await tester.tap(find.text(l10n.analyticsCashflowIncome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(queries.lastCashflowFilter?.kind, CashflowKind.income);
    expect(find.text(l10n.analyticsCategoryFilterLabel), findsOneWidget);
  });

  testWidgets('нет активов, но есть cashflow — показывается cashflow', (
    tester,
  ) async {
    final incomeCategory = CashflowCategory(
      id: 1,
      kind: CashflowKind.income,
      name: 'Зарплата',
      isPreset: false,
    );
    final queries = _Queries(
      hasEarliest: false,
      hasCashflow: true,
      cashflowResult: const CashflowSummary(
        income: Money(minorUnits: 100000, currencyCode: 'RUB'),
        expense: Money(minorUnits: 0, currencyCode: 'RUB'),
        net: Money(minorUnits: 100000, currencyCode: 'RUB'),
        currencyCode: 'RUB',
      ),
      cashflowPoints: [
        CashflowPeriodPoint(
          periodStart: LocalDate(2026, 11, 1),
          summary: const CashflowSummary(
            income: Money(minorUnits: 100000, currencyCode: 'RUB'),
            expense: Money(minorUnits: 0, currencyCode: 'RUB'),
            net: Money(minorUnits: 100000, currencyCode: 'RUB'),
            currencyCode: 'RUB',
          ),
        ),
      ],
    );

    await _pump(tester, _viewModel(queries, categories: [incomeCategory]));

    expect(find.text(l10n.analyticsCashflowTitle), findsOneWidget);
    expect(find.text(l10n.analyticsNoAssetsTitle), findsNothing);
  });

  testWidgets('нет активов + фильтр без совпадений: фильтры остаются', (
    tester,
  ) async {
    const income = CashflowSummary(
      income: Money(minorUnits: 100000, currencyCode: 'RUB'),
      expense: Money(minorUnits: 0, currencyCode: 'RUB'),
      net: Money(minorUnits: 100000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    );
    const zero = CashflowSummary(
      income: Money(minorUnits: 0, currencyCode: 'RUB'),
      expense: Money(minorUnits: 0, currencyCode: 'RUB'),
      net: Money(minorUnits: 0, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    );
    final queries = _Queries(
      hasEarliest: false,
      hasCashflow: true,
      cashflowResult: income,
      filteredCashflowResult: zero,
    );

    await _pump(tester, _viewModel(queries));

    expect(find.text(l10n.analyticsNoAssetsTitle), findsNothing);
    expect(find.text(l10n.analyticsCashflowIncome), findsOneWidget);

    await tester.tap(find.text(l10n.analyticsCashflowIncome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.analyticsNoAssetsTitle), findsNothing);
    expect(find.text(l10n.analyticsCashflowIncome), findsOneWidget);
  });
}
