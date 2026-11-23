import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_events.dart';
import 'package:finanseapp/core/features/dashboard/logic/safety_cushion.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_progress.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/goals/logic/calculate_goal_progress.dart';
import 'package:finanseapp/core/features/goals/logic/goal_calculator.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Цель на главной с прогрессом (статус может быть вычислен, не записан).
final class DashboardGoal {
  const DashboardGoal({
    required this.goal,
    required this.progress,
    required this.displayStatus,
  });

  final FinancialGoal goal;
  final GoalProgress? progress;
  final GoalStatus displayStatus;
}

/// Главная: net worth, цели и последние операции (10.1).
class DashboardViewModel {
  DashboardViewModel({
    required this.queries,
    required this.goalRepository,
    required this.assetRepository,
    required this.transactionRepository,
    required this.cashflowRepository,
    required this.settingsRepository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.now,
  });

  final AnalyticsQueries queries;
  final GoalRepository goalRepository;
  final AssetRepository assetRepository;
  final AssetTransactionRepository transactionRepository;
  final CashflowRepository cashflowRepository;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate Function() now;

  static const recentLimit = 5;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<NetWorthSummary?> netWorth = signal(null);
  final Signal<DomainErrorCode?> netWorthError = signal(null);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<List<DashboardGoal>> goals = signal(const []);
  final Signal<List<AssetTransaction>> recentOperations = signal(const []);
  final Signal<Map<int, String>> assetNames = signal(const {});
  final Signal<CashflowSummary?> cashflowSummary = signal(null);
  final Signal<List<CashflowPeriodPoint>> cashflowPoints = signal(const []);
  final Signal<DomainErrorCode?> cashflowError = signal(null);
  final Signal<LocalDate> today = signal(
    LocalDate.fromDateTime(DateTime.now()),
  );

  /// Неархивные счета с истёкшим сроком окончания (today > endDate).
  final Signal<List<AccountAsset>> overdueAccounts = signal(const []);

  /// Подушка безопасности; null — нет расходов/счетов/курса.
  final Signal<SafetyCushion?> safetyCushion = signal(null);

  final CalculateGoalProgress _goalCalculator = const CalculateGoalProgress();
  final Map<String, Decimal> _rateCache = {};

  List<FinancialGoal> _goals = const [];
  Map<int, AssetSnapshot> _snapshots = const {};
  Map<String, Currency> _currencies = const {};
  int _goalToken = 0;
  int _netWorthToken = 0;
  int _cashflowToken = 0;
  bool _assetsReady = false;
  bool _fatal = false;
  bool _netWorthReady = false;
  bool _cashflowReady = false;
  bool _goalsReady = false;
  bool _transactionsReady = false;
  bool _disposed = false;

  StreamSubscription<List<AssetSnapshot>>? _assetsSubscription;
  StreamSubscription<List<FinancialGoal>>? _goalsSubscription;
  StreamSubscription<List<AssetTransaction>>? _transactionsSubscription;
  StreamSubscription<Currency>? _baseSubscription;
  StreamSubscription<List<CashflowEntry>>? _cashflowSubscription;
  StreamSubscription<List<CashflowEntry>>? _safetySubscription;
  EffectCleanup? _rateCleanup;

  CashflowSummary? _safetySummary;
  int _safetyToken = 0;
  bool _safetyReady = false;

  void init() {
    today.value = now();
    _rateCache.clear();
    _assetsReady = false;
    _fatal = false;
    _netWorthReady = false;
    _cashflowReady = false;
    _goalsReady = false;
    _transactionsReady = false;
    state.value = const ViewLoading();
    netWorthError.value = null;
    _loadCurrencies();
    _subscribeBaseCurrency();
    cashflowError.value = null;
    _rateCleanup?.call();
    var seenRateRevision = exchangeRateRevision.value;
    _rateCleanup = exchangeRateRevision.subscribe((revision) {
      if (_disposed || revision == seenRateRevision) return;
      seenRateRevision = revision;
      _rateCache.clear();
      unawaited(_reloadNetWorth());
      unawaited(_reloadCashflow());
      unawaited(_reloadSafety());
      unawaited(_recomputeGoals());
    });
    _cashflowSubscription?.cancel();
    _cashflowSubscription = cashflowRepository
        .watch(CashflowFilter(period: _monthRange))
        .listen(
          (_) => unawaited(_reloadCashflow()),
          onError: _failLocalCashflow,
        );
    _safetySummary = null;
    _safetyReady = false;
    safetyCushion.value = null;
    _safetySubscription?.cancel();
    _safetySubscription = cashflowRepository
        .watch(CashflowFilter(period: _safetyRange))
        .listen(
          (_) => unawaited(_reloadSafety()),
          onError: (_) {
            _safetySummary = null;
            safetyCushion.value = null;
          },
        );
    unawaited(_reloadSafety());
    _assetsSubscription?.cancel();
    _assetsSubscription = assetRepository
        .watchAll(includeArchived: true)
        .listen((snapshots) {
          _assetsReady = true;
          _snapshots = {
            for (final snapshot in snapshots) snapshot.asset.id: snapshot,
          };
          _updateOverdueAccounts(snapshots);
          _recomputeSafety();
          assetNames.value = {
            for (final snapshot in snapshots)
              snapshot.asset.id: snapshot.asset.name,
          };
          unawaited(_recomputeGoals());
          unawaited(_reloadNetWorth());
        }, onError: _fail);
    _goalsSubscription?.cancel();
    _goalsSubscription = goalRepository.watchAll().listen((goals) {
      _goals = goals;
      _goalsReady = true;
      unawaited(_recomputeGoals());
    }, onError: _fail);
    _transactionsSubscription?.cancel();
    _transactionsSubscription = transactionRepository
        .watch(const TransactionFilter())
        .listen((operations) {
          recentOperations.value = operations.take(recentLimit).toList();
          _transactionsReady = true;
          _emit();
        }, onError: _fail);
  }

  void _updateOverdueAccounts(List<AssetSnapshot> snapshots) {
    final today = this.today.value;
    final overdue = <AccountAsset>[];
    for (final snapshot in snapshots) {
      final asset = snapshot.asset;
      if (asset is! AccountAsset) continue;
      final endDate = asset.endDate;
      if (asset.archivedAt != null || endDate == null) continue;
      if (today.compareTo(endDate) > 0) overdue.add(asset);
    }
    overdue.sort((a, b) {
      final byDate = a.endDate!.compareTo(b.endDate!);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    overdueAccounts.value = overdue;
  }

  Future<void> _loadCurrencies() async {
    try {
      final list = await currencyRepository.watchAll().first;
      _currencies = {for (final currency in list) currency.code: currency};
      unawaited(_recomputeGoals());
    } on Exception {
      // Итоги показываются без эквивалента, если справочник недоступен.
    }
  }

  void _subscribeBaseCurrency() {
    _baseSubscription?.cancel();
    _baseSubscription = settingsRepository.watchBaseCurrency().listen((
      currency,
    ) {
      baseCurrency.value = currency;
      unawaited(_reloadCashflow());
      unawaited(_reloadNetWorth());
      unawaited(_reloadSafety());
    }, onError: _fail);
  }

  DateRange get cashflowRange =>
      analyticsRange(period: AnalyticsPeriod.month, today: today.value);

  DateRange get _monthRange => cashflowRange;

  /// Три полных месяца до текущего (например, для 23.11 — август–октябрь).
  DateRange get _safetyRange {
    final firstOfMonth = DateTime(today.value.year, today.value.month);
    final end = firstOfMonth.subtract(const Duration(days: 1));
    final start = DateTime(end.year, end.month - 2, 1);
    return DateRange(
      start: LocalDate.fromDateTime(start),
      end: LocalDate.fromDateTime(end),
    );
  }

  Future<void> _reloadCashflow() async {
    final token = ++_cashflowToken;
    final filter = CashflowFilter(period: _monthRange);
    try {
      final summary = await queries.cashflow(filter);
      final points = await queries.cashflowSeries(filter);
      if (_disposed || token != _cashflowToken) return;
      cashflowSummary.value = summary;
      cashflowPoints.value = points;
      cashflowError.value = null;
      _cashflowReady = true;
      _emit();
    } on DomainException catch (error) {
      if (_disposed || token != _cashflowToken) return;
      cashflowError.value = error.code;
      _cashflowReady = true;
      _emit();
    } on Exception {
      if (_disposed || token != _cashflowToken) return;
      cashflowError.value = DomainErrorCode.storageFailure;
      _cashflowReady = true;
      _emit();
    }
  }

  void _failLocalCashflow(Object _) {
    if (_disposed) return;
    cashflowError.value = DomainErrorCode.storageFailure;
    _cashflowReady = true;
    _emit();
  }

  Future<void> _reloadSafety() async {
    final token = ++_safetyToken;
    try {
      final summary = await queries.cashflow(
        CashflowFilter(period: _safetyRange),
      );
      if (_disposed || token != _safetyToken) return;
      _safetySummary = summary;
      _safetyReady = true;
      _recomputeSafety();
      _emit();
    } on Exception {
      if (_disposed || token != _safetyToken) return;
      _safetySummary = null;
      _safetyReady = true;
      safetyCushion.value = null;
      _emit();
    }
  }

  bool get _hasActiveAccounts => _snapshots.values.any(
    (snapshot) =>
        snapshot.asset is AccountAsset && snapshot.asset.archivedAt == null,
  );

  void _recomputeSafety() {
    final netWorth = this.netWorth.value;
    final summary = _safetySummary;
    if (netWorthError.value != null ||
        netWorth == null ||
        summary == null ||
        !_hasActiveAccounts) {
      safetyCushion.value = null;
      return;
    }
    final cash =
        netWorth.byAssetKind[AssetKind.account] ??
        Money(minorUnits: 0, currencyCode: netWorth.total.currencyCode);
    safetyCushion.value = SafetyCushion.calculate(
      cash: cash,
      lastThreeMonths: summary,
    );
  }

  Future<void> _reloadNetWorth() async {
    final token = ++_netWorthToken;
    final onDate = today.value;
    try {
      final summary = await queries.netWorth(onDate);
      if (_disposed || token != _netWorthToken) return;
      netWorth.value = summary;
      netWorthError.value = null;
      _netWorthReady = true;
      _recomputeSafety();
      _emit();
    } on DomainException catch (error) {
      if (_disposed || token != _netWorthToken) return;
      // Недоступный курс не должен скрывать остальные блоки главной.
      netWorthError.value = error.code;
      _netWorthReady = true;
      _recomputeSafety();
      _emit();
    } on Exception {
      if (_disposed || token != _netWorthToken) return;
      netWorthError.value = DomainErrorCode.storageFailure;
      _netWorthReady = true;
      _recomputeSafety();
      _emit();
    }
  }

  Future<void> _recomputeGoals() async {
    if (!_assetsReady || _fatal) return;
    final token = ++_goalToken;
    final views = <DashboardGoal>[];
    for (final goal in _goals) {
      final values = <int, List<Money>>{};
      for (final id in goal.assetIds) {
        final snapshot = _snapshots[id];
        if (snapshot != null) values[id] = snapshot.breakdown;
      }
      final progress = await _goalCalculator.load(
        goal: goal,
        assetValues: values,
        currencies: _currencies,
        rateRepository: rateRepository,
        today: today.value,
        rateCache: _rateCache,
      );
      if (_disposed || token != _goalToken) return;
      views.add(
        DashboardGoal(
          goal: goal,
          progress: progress,
          displayStatus: progress == null
              ? goal.status
              : GoalCalculator.resolveStatus(
                  current: goal.status,
                  progress: progress,
                ),
        ),
      );
    }
    if (_disposed || token != _goalToken) return;
    goals.value = views;
    _goalsReady = true;
    _emit();
  }

  void _emit() {
    if (_disposed || _fatal) return;
    if (!_netWorthReady ||
        !_cashflowReady ||
        !_goalsReady ||
        !_transactionsReady ||
        !_safetyReady) {
      return;
    }
    state.value = const ViewData(null);
  }

  void _fail(Object _) {
    if (_disposed) return;
    _fatal = true;
    state.value = const ViewError(DomainErrorCode.storageFailure);
  }

  void reload() => init();

  Currency currencyOf(String code) =>
      _currencies[code] ??
      baseCurrency.value ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  String formatMoney(Money money) =>
      const MoneyFormatter().format(money, currencyOf(money.currencyCode));

  void dispose() {
    _disposed = true;
    _goalToken++;
    _netWorthToken++;
    _safetyToken++;
    _assetsSubscription?.cancel();
    _goalsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _cashflowSubscription?.cancel();
    _safetySubscription?.cancel();
    _baseSubscription?.cancel();
    _rateCleanup?.call();
    _rateCleanup = null;
  }
}
