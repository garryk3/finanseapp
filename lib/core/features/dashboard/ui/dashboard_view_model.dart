import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
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
    required this.settingsRepository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.now,
  });

  final AnalyticsQueries queries;
  final GoalRepository goalRepository;
  final AssetRepository assetRepository;
  final AssetTransactionRepository transactionRepository;
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
  final Signal<LocalDate> today = signal(
    LocalDate.fromDateTime(DateTime.now()),
  );

  final CalculateGoalProgress _goalCalculator = const CalculateGoalProgress();
  final Map<String, Decimal> _rateCache = {};

  List<FinancialGoal> _goals = const [];
  Map<int, AssetSnapshot> _snapshots = const {};
  Map<String, Currency> _currencies = const {};
  int _goalToken = 0;
  int _netWorthToken = 0;
  bool _assetsReady = false;
  bool _fatal = false;
  bool _netWorthReady = false;
  bool _goalsReady = false;
  bool _transactionsReady = false;
  bool _disposed = false;

  StreamSubscription<List<AssetSnapshot>>? _assetsSubscription;
  StreamSubscription<List<FinancialGoal>>? _goalsSubscription;
  StreamSubscription<List<AssetTransaction>>? _transactionsSubscription;
  StreamSubscription<Currency>? _baseSubscription;

  void init() {
    today.value = now();
    _rateCache.clear();
    _assetsReady = false;
    _fatal = false;
    _netWorthReady = false;
    _goalsReady = false;
    _transactionsReady = false;
    state.value = const ViewLoading();
    netWorthError.value = null;
    _loadCurrencies();
    _subscribeBaseCurrency();
    _assetsSubscription?.cancel();
    _assetsSubscription = assetRepository
        .watchAll(includeArchived: true)
        .listen((snapshots) {
          _assetsReady = true;
          _snapshots = {
            for (final snapshot in snapshots) snapshot.asset.id: snapshot,
          };
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
      unawaited(_reloadNetWorth());
    }, onError: _fail);
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
      _emit();
    } on DomainException catch (error) {
      if (_disposed || token != _netWorthToken) return;
      // Недоступный курс не должен скрывать остальные блоки главной.
      netWorthError.value = error.code;
      _netWorthReady = true;
      _emit();
    } on Exception {
      if (_disposed || token != _netWorthToken) return;
      netWorthError.value = DomainErrorCode.storageFailure;
      _netWorthReady = true;
      _emit();
    }
  }

  Future<void> _recomputeGoals() async {
    if (!_assetsReady || _fatal) return;
    final token = ++_goalToken;
    final views = <DashboardGoal>[];
    for (final goal in _goals) {
      final values = <int, Money>{};
      for (final id in goal.assetIds) {
        final snapshot = _snapshots[id];
        if (snapshot != null) values[id] = snapshot.currentValue;
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
    if (!_netWorthReady || !_goalsReady || !_transactionsReady) return;
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
    _assetsSubscription?.cancel();
    _goalsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _baseSubscription?.cancel();
  }
}
