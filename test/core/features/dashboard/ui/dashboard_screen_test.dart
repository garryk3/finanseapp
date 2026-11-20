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
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_events.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_screen.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_cashflow_summary.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

const _usd = Currency(
  code: 'USD',
  name: 'Доллар США',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final _today = LocalDate(2026, 11, 19);

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

final class _Queries implements AnalyticsQueries {
  _Queries(
    this.total, {
    this.error,
    this.cashflowResult = const CashflowSummary(
      income: Money(minorUnits: 0, currencyCode: 'RUB'),
      expense: Money(minorUnits: 0, currencyCode: 'RUB'),
      net: Money(minorUnits: 0, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    ),
    this.cashflowPoints = const [],
    this.cashflowError,
  });

  Money total;
  Object? error;
  CashflowSummary cashflowResult;
  CashflowFilter? lastCashflowFilter;
  final List<CashflowPeriodPoint> cashflowPoints;
  Object? cashflowError;

  @override
  Future<NetWorthSummary> netWorth(LocalDate onDate) async {
    final failure = error;
    if (failure != null) throw failure;
    return NetWorthSummary(
      total: total,
      byAssetKind: {for (final kind in AssetKind.values) kind: total},
    );
  }

  @override
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind}) async => null;

  @override
  Future<bool> hasAnyCashflow() async => false;

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
    int? assetId,
  }) => throw UnimplementedError();

  @override
  Future<CashflowSummary> cashflow(CashflowFilter filter) async {
    lastCashflowFilter = filter;
    final failure = cashflowError;
    if (failure != null) throw failure;
    return cashflowResult;
  }

  @override
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter) =>
      throw UnimplementedError();

  @override
  Future<List<CashflowPeriodPoint>> cashflowSeries(
    CashflowFilter filter,
  ) async => cashflowPoints;
}

final class _Goals implements GoalRepository {
  _Goals(this.goals);

  final List<FinancialGoal> goals;

  @override
  Stream<List<FinancialGoal>> watchAll() => Stream.value(goals);

  @override
  Future<FinancialGoal> getById(int id) async =>
      goals.firstWhere((goal) => goal.id == id);

  @override
  Future<int> create(GoalDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(int id, GoalDraft draft) => throw UnimplementedError();

  @override
  Future<void> setStatus(int id, GoalStatus status) =>
      throw UnimplementedError();

  @override
  Future<void> softDelete(int id) => throw UnimplementedError();
}

final class _Assets implements AssetRepository {
  _Assets(this.snapshots, {this.controller});

  final List<AssetSnapshot> snapshots;
  final StreamController<List<AssetSnapshot>>? controller;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      controller?.stream ?? Stream.value(snapshots);

  @override
  Stream<AssetSnapshot?> watchById(int id) => throw UnimplementedError();

  @override
  Future<AssetSnapshot> getById(int id) => throw UnimplementedError();

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
  Future<AssetReferenceCounts> referenceCounts(int id) =>
      throw UnimplementedError();

  @override
  Future<List<AssetValuation>> valuations(int id) => throw UnimplementedError();
}

final class _Transactions implements AssetTransactionRepository {
  _Transactions(this.operations, {this.controller});

  final List<AssetTransaction> operations;
  final StreamController<List<AssetTransaction>>? controller;

  @override
  Stream<List<AssetTransaction>> watch(TransactionFilter filter) =>
      controller?.stream ?? Stream.value(operations);

  @override
  Future<AssetTransaction> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(AssetTransactionDraft draft) => throw UnimplementedError();

  @override
  Future<void> revise(int id, AssetTransactionDraft draft) =>
      throw UnimplementedError();

  @override
  Future<void> softDelete(int id) => throw UnimplementedError();

  @override
  Future<void> restore(int id) => throw UnimplementedError();

  @override
  Future<int> transfer(TransferDraft draft) => throw UnimplementedError();

  @override
  Future<void> reviseTransfer(int transferId, TransferDraft draft) =>
      throw UnimplementedError();

  @override
  Future<void> softDeleteTransfer(int transferId) => throw UnimplementedError();

  @override
  Future<void> restoreTransfer(int transferId) => throw UnimplementedError();
}

final class _Cashflows implements CashflowRepository {
  _Cashflows({this.controller});

  final StreamController<List<CashflowEntry>>? controller;

  @override
  Stream<List<CashflowEntry>> watch(CashflowFilter filter) =>
      controller?.stream ?? Stream.value(const []);

  @override
  Future<CashflowEntry> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(CashflowEntryDraft draft) => throw UnimplementedError();

  @override
  Future<int> createLinked(
    CashflowEntryDraft draft, {
    required int assetTransactionId,
  }) => throw UnimplementedError();

  @override
  Future<void> revise(int id, CashflowEntryDraft draft) =>
      throw UnimplementedError();

  @override
  Future<void> softDelete(int id) => throw UnimplementedError();

  @override
  Future<void> restore(int id) => throw UnimplementedError();
}

final class _Settings implements SettingsRepository {
  _Settings({this.controller, this.base = _rub});

  final StreamController<Currency>? controller;
  final Currency base;

  @override
  Stream<Currency> watchBaseCurrency() =>
      controller?.stream ?? Stream.value(base);

  @override
  Future<Currency> getBaseCurrency() async => base;

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
  ) => throw UnimplementedError();
}

AssetSnapshot _snapshot(int id, Money value) => AssetSnapshot(
  asset: AccountAsset(
    id: id,
    name: 'Счёт $id',
    currencyCode: 'RUB',
    openingValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    createdAt: DateTime.utc(2024, 1, 1),
    bankId: 1,
    annualRate: Decimal.zero,
    startDate: LocalDate(2024, 1, 1),
  ),
  currentValue: value,
);

AssetTransaction _operation(int id, int assetId, int major) => AssetTransaction(
  id: id,
  assetId: assetId,
  kind: AssetTransactionKind.deposit,
  amount: _rubles(major),
  occurredOn: _today,
  rateToRub: Decimal.one,
  amountRub: _rubles(major),
  revisionNo: 1,
  createdAt: DateTime.utc(2026, 11, 19),
  updatedAt: DateTime.utc(2026, 11, 19),
);

FinancialGoal _goal(int assetId) => FinancialGoal(
  id: 1,
  name: 'Отпуск',
  category: GoalCategory.accounts,
  targetAmount: _rubles(1000),
  status: GoalStatus.active,
  assetIds: {assetId},
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  DashboardViewModel viewModel({
    Money? total,
    Object? error,
    List<FinancialGoal> goals = const [],
    List<AssetSnapshot> snapshots = const [],
    List<AssetTransaction> operations = const [],
    StreamController<List<AssetSnapshot>>? assetController,
    StreamController<List<AssetTransaction>>? transactionController,
    CashflowSummary? cashflowResult,
    List<CashflowPeriodPoint> cashflowPoints = const [],
    Object? cashflowError,
    Currency base = _rub,
    _Queries? queries,
    StreamController<Currency>? settingsController,
  }) => DashboardViewModel(
    queries:
        queries ??
        _Queries(
          total ?? _rubles(0),
          error: error,
          cashflowResult:
              cashflowResult ??
              const CashflowSummary(
                income: Money(minorUnits: 0, currencyCode: 'RUB'),
                expense: Money(minorUnits: 0, currencyCode: 'RUB'),
                net: Money(minorUnits: 0, currencyCode: 'RUB'),
                currencyCode: 'RUB',
              ),
          cashflowPoints: cashflowPoints,
          cashflowError: cashflowError,
        ),
    goalRepository: _Goals(goals),
    assetRepository: _Assets(snapshots, controller: assetController),
    transactionRepository: _Transactions(
      operations,
      controller: transactionController,
    ),
    cashflowRepository: _Cashflows(),
    settingsRepository: _Settings(controller: settingsController, base: base),
    currencyRepository: _Currencies(),
    rateRepository: _Rates(),
    now: () => _today,
  );

  Future<DashboardViewModel> pump(
    WidgetTester tester, {
    Money? total,
    Object? error,
    List<FinancialGoal> goals = const [],
    List<AssetSnapshot> snapshots = const [],
    List<AssetTransaction> operations = const [],
    Object? cashflowError,
    Currency base = _rub,
    _Queries? queries,
    StreamController<Currency>? settingsController,
    double width = 1000,
    bool dark = false,
    bool largeText = false,
  }) async {
    final vm = viewModel(
      total: total,
      error: error,
      goals: goals,
      snapshots: snapshots,
      operations: operations,
      cashflowError: cashflowError,
      base: base,
      queries: queries,
      settingsController: settingsController,
    );
    tester.view.physicalSize = Size(width, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        builder: largeText
            ? (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              )
            : null,
        home: DashboardScreen(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();
    return vm;
  }

  testWidgets('пустая БД — нулевой net worth и quick actions', (tester) async {
    await pump(tester);

    expect(find.text(l10n.dashboardNetWorthTitle), findsOneWidget);
    expect(find.text(l10n.cashflowIncome), findsOneWidget);
    expect(find.text(l10n.cashflowExpense), findsOneWidget);
    expect(find.text(l10n.transferAction), findsOneWidget);
    expect(find.text(l10n.dashboardGoalsEmpty), findsOneWidget);
    expect(find.text(l10n.dashboardRecentEmpty), findsOneWidget);
    expect(find.text(l10n.dashboardCashflowEmpty), findsOneWidget);
    expect(find.text(l10n.dashboardAddExpense), findsOneWidget);
    expect(find.text(l10n.dashboardEmptyTitle), findsNothing);
  });

  testWidgets('данные: net worth, достигнутая цель и последняя операция', (
    tester,
  ) async {
    final vm = await pump(
      tester,
      total: _rubles(1500),
      goals: [_goal(1)],
      snapshots: [_snapshot(1, _rubles(1500))],
      operations: [_operation(1, 1, 500)],
    );

    expect(find.text(l10n.dashboardNetWorthTitle), findsOneWidget);
    expect(find.text('Отпуск'), findsOneWidget);
    expect(find.text(l10n.goalStatusAchieved), findsOneWidget);
    expect(find.text('Счёт 1'), findsOneWidget);
    expect(find.text(l10n.dashboardGoalsEmpty), findsNothing);
    expect(find.text(l10n.dashboardRecentEmpty), findsNothing);
    expect(find.text(vm.formatMoney(_rubles(1500))), findsWidgets);
  });

  testWidgets('ошибка курса net worth не скрывает цели и операции', (
    tester,
  ) async {
    await pump(
      tester,
      error: const DomainException(DomainErrorCode.rateUnavailable),
    );

    expect(find.text(l10n.assetBaseUnavailable), findsOneWidget);
    expect(find.text(l10n.dashboardGoalsEmpty), findsOneWidget);
    expect(find.text(l10n.dashboardRecentEmpty), findsOneWidget);
    expect(find.text(l10n.errorStateTitle), findsNothing);
  });

  testWidgets('ошибка курса: устаревший RUB-снимок не протекает в подпись', (
    tester,
  ) async {
    final queries = _Queries(_rubles(1500));
    final settings = StreamController<Currency>.broadcast();
    addTearDown(settings.close);
    final vm = await pump(
      tester,
      queries: queries,
      settingsController: settings,
    );
    expect(vm.netWorth.value, isNotNull);
    expect(find.textContaining('· RUB'), findsOneWidget);

    queries.error = const DomainException(DomainErrorCode.rateUnavailable);
    settings.add(_usd);
    await tester.pumpAndSettle();

    expect(find.text(l10n.assetBaseUnavailable), findsOneWidget);
    expect(find.textContaining('· USD'), findsOneWidget);
    expect(find.textContaining('· RUB'), findsNothing);
  });

  testWidgets('событие изменения курса пересчитывает Главную', (tester) async {
    final queries = _Queries(_rubles(1500));
    final vm = await pump(tester, queries: queries);
    expect(find.text(vm.formatMoney(_rubles(1500))), findsWidgets);

    queries.total = _rubles(2000);
    markExchangeRateChanged();
    await tester.pumpAndSettle();

    expect(find.text(vm.formatMoney(_rubles(2000))), findsWidgets);
  });

  testWidgets('ошибка курса скрывает stale cashflow-суммы', (tester) async {
    final queries = _Queries(
      _rubles(1500),
      cashflowResult: const CashflowSummary(
        income: Money(minorUnits: 100000, currencyCode: 'RUB'),
        expense: Money(minorUnits: 0, currencyCode: 'RUB'),
        net: Money(minorUnits: 100000, currencyCode: 'RUB'),
        currencyCode: 'RUB',
      ),
    );
    final vm = await pump(tester, queries: queries);
    expect(find.text(vm.formatMoney(_rubles(1000))), findsWidgets);

    queries.cashflowError = const DomainException(
      DomainErrorCode.rateUnavailable,
    );
    markExchangeRateChanged();
    await tester.pumpAndSettle();

    expect(find.text(l10n.dashboardCashflowRateUnavailable), findsOneWidget);
    expect(find.text(l10n.analyticsEnterRate), findsOneWidget);
    expect(find.text(l10n.dashboardCashflowTitle), findsOneWidget);
    expect(find.text(vm.formatMoney(_rubles(1000))), findsNothing);
  });

  testWidgets('ошибка курса в обоих блоках не дублирует сообщение', (
    tester,
  ) async {
    await pump(
      tester,
      error: const DomainException(DomainErrorCode.rateUnavailable),
      cashflowError: const DomainException(DomainErrorCode.rateUnavailable),
    );

    expect(find.text(l10n.assetBaseUnavailable), findsOneWidget);
    expect(find.text(l10n.dashboardCashflowRateUnavailable), findsOneWidget);
    expect(find.text(l10n.analyticsEnterRate), findsOneWidget);
  });

  testWidgets('ошибка курса: 320dp, 1.3, тёмная тема — без overflow', (
    tester,
  ) async {
    await pump(
      tester,
      error: const DomainException(DomainErrorCode.rateUnavailable),
      cashflowError: const DomainException(DomainErrorCode.rateUnavailable),
      width: 320,
      dark: true,
      largeText: true,
    );

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.dashboardCashflowRateUnavailable), findsOneWidget);
  });

  testWidgets('320dp, font 1.3, тёмная тема — без overflow', (tester) async {
    await pump(tester, width: 320, dark: true, largeText: true);

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.dashboardNetWorthTitle), findsOneWidget);
    expect(find.text(l10n.dashboardQuickActions), findsOneWidget);
  });

  testWidgets('повторная эмиссия обновляет данные, dispose отменяет подписки', (
    tester,
  ) async {
    final assets = StreamController<List<AssetSnapshot>>.broadcast();
    final operations = StreamController<List<AssetTransaction>>.broadcast();
    addTearDown(assets.close);
    addTearDown(operations.close);
    final queries = _Queries(_rubles(0));
    final vm = DashboardViewModel(
      queries: queries,
      goalRepository: _Goals(const []),
      assetRepository: _Assets(const [], controller: assets),
      transactionRepository: _Transactions(const [], controller: operations),
      cashflowRepository: _Cashflows(),
      settingsRepository: _Settings(),
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
      now: () => _today,
    );
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: DashboardScreen(viewModel: vm),
      ),
    );
    queries.total = _rubles(1000);
    assets.add([_snapshot(1, _rubles(1000))]);
    operations.add([_operation(1, 1, 500)]);
    await tester.pumpAndSettle();

    expect(find.text(vm.formatMoney(_rubles(1000))), findsWidgets);
    expect(find.text('Счёт 1'), findsOneWidget);

    queries.total = _rubles(2000);
    assets.add([_snapshot(1, _rubles(2000)), _snapshot(2, _rubles(0))]);
    operations.add([_operation(1, 1, 500), _operation(2, 2, 700)]);
    await tester.pumpAndSettle();

    expect(find.text(vm.formatMoney(_rubles(2000))), findsWidgets);
    expect(find.text('Счёт 2'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(assets.hasListener, isFalse);
    expect(operations.hasListener, isFalse);
  });

  testWidgets('quick actions открывают формы с prefill', (tester) async {
    final vm = viewModel();
    addTearDown(vm.dispose);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => DashboardScreen(viewModel: vm),
        ),
        GoRoute(
          path: '/cashflow/new',
          builder: (context, state) =>
              AppText('KIND:${state.uri.queryParameters['kind']}'),
        ),
        GoRoute(
          path: '/transactions/transfer/new',
          builder: (context, state) => const AppText('TRANSFER'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.cashflowIncome));
    await tester.pumpAndSettle();
    expect(find.text('KIND:income'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.cashflowExpense));
    await tester.pumpAndSettle();
    expect(find.text('KIND:expense'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.transferAction));
    await tester.pumpAndSettle();
    expect(find.text('TRANSFER'), findsOneWidget);
  });

  testWidgets('cashflow месяца и переход в аналитику с периодом', (
    tester,
  ) async {
    const summary = CashflowSummary(
      income: Money(minorUnits: 100000, currencyCode: 'RUB'),
      expense: Money(minorUnits: 25000, currencyCode: 'RUB'),
      net: Money(minorUnits: 75000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    );
    final vm = viewModel(
      cashflowResult: summary,
      cashflowPoints: [
        CashflowPeriodPoint(
          periodStart: LocalDate(2026, 11, 5),
          summary: summary,
        ),
      ],
    );
    addTearDown(vm.dispose);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => DashboardScreen(viewModel: vm),
        ),
        GoRoute(
          path: '/more/analytics',
          builder: (context, state) =>
              AppText('PERIOD:${state.uri.queryParameters['period']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.dashboardCashflowTitle), findsWidgets);
    expect(find.text(vm.formatMoney(summary.income)), findsWidgets);
    expect(
      vm.cashflowRange,
      DateRange(start: LocalDate(2026, 11, 1), end: LocalDate(2026, 11, 30)),
    );

    await tester.tap(find.byType(AppCashflowSummary));
    await tester.pumpAndSettle();

    expect(find.text('PERIOD:month'), findsOneWidget);
  });

  testWidgets('пустой месяц: CTA ведёт на добавление расхода', (tester) async {
    final vm = viewModel();
    addTearDown(vm.dispose);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => DashboardScreen(viewModel: vm),
        ),
        GoRoute(
          path: '/cashflow/new',
          builder: (context, state) =>
              AppText('KIND:${state.uri.queryParameters['kind']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.dashboardAddExpense));
    await tester.pumpAndSettle();

    expect(find.text('KIND:expense'), findsOneWidget);
  });

  testWidgets('ошибка курса cashflow не скрывает секцию молча', (tester) async {
    await pump(
      tester,
      cashflowError: const DomainException(DomainErrorCode.rateUnavailable),
    );

    expect(find.text(l10n.dashboardCashflowTitle), findsOneWidget);
    expect(find.text(l10n.dashboardCashflowRateUnavailable), findsOneWidget);
    expect(find.text(l10n.analyticsEnterRate), findsOneWidget);
    expect(find.text(l10n.dashboardGoalsEmpty), findsOneWidget);
  });

  testWidgets('cashflow обновляется по стриму и при смене базовой валюты', (
    tester,
  ) async {
    final cashflows = StreamController<List<CashflowEntry>>.broadcast();
    final settings = StreamController<Currency>.broadcast();
    addTearDown(cashflows.close);
    addTearDown(settings.close);
    const first = CashflowSummary(
      income: Money(minorUnits: 100000, currencyCode: 'RUB'),
      expense: Money(minorUnits: 0, currencyCode: 'RUB'),
      net: Money(minorUnits: 100000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    );
    final queries = _Queries(
      _rubles(0),
      cashflowResult: first,
      cashflowPoints: [
        CashflowPeriodPoint(
          periodStart: LocalDate(2026, 11, 5),
          summary: first,
        ),
      ],
    );
    final vm = DashboardViewModel(
      queries: queries,
      goalRepository: _Goals(const []),
      assetRepository: _Assets(const []),
      transactionRepository: _Transactions(const []),
      cashflowRepository: _Cashflows(controller: cashflows),
      settingsRepository: _Settings(controller: settings),
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
      now: () => _today,
    );
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: DashboardScreen(viewModel: vm),
      ),
    );
    cashflows.add(const []);
    await tester.pumpAndSettle();
    expect(find.text(vm.formatMoney(first.income)), findsWidgets);

    const second = CashflowSummary(
      income: Money(minorUnits: 200000, currencyCode: 'RUB'),
      expense: Money(minorUnits: 0, currencyCode: 'RUB'),
      net: Money(minorUnits: 200000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    );
    queries.cashflowResult = second;
    cashflows.add(const []);
    await tester.pumpAndSettle();
    expect(find.text(vm.formatMoney(second.income)), findsWidgets);

    const third = CashflowSummary(
      income: Money(minorUnits: 300000, currencyCode: 'RUB'),
      expense: Money(minorUnits: 0, currencyCode: 'RUB'),
      net: Money(minorUnits: 300000, currencyCode: 'RUB'),
      currencyCode: 'RUB',
    );
    queries.cashflowResult = third;
    settings.add(_rub);
    await tester.pumpAndSettle();
    expect(find.text(vm.formatMoney(third.income)), findsWidgets);
  });
}
