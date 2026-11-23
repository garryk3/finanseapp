import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_progress.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/goals/logic/calculate_goal_progress.dart';
import 'package:finanseapp/core/features/goals/logic/goal_calculator.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Детали цели: прогресс, статусы и удаление (8.1–8.2).
class GoalDetailsViewModel {
  GoalDetailsViewModel({
    required this.repository,
    required this.assetRepository,
    required this.goalId,
    required this.currencyRepository,
    required this.rateRepository,
    required this.today,
  });

  final GoalRepository repository;
  final AssetRepository assetRepository;
  final int goalId;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<FinancialGoal?> goal = signal(null);
  final Signal<List<Asset>> assets = signal(const []);
  final Signal<GoalProgress?> progress = signal(null);
  final Signal<bool> busy = signal(false);
  final Signal<GoalStatus?> pendingStatus = signal(null);
  final Signal<bool> deleteBusy = signal(false);
  final Signal<Map<String, Currency>> currencies = signal(const {});

  final CalculateGoalProgress _calculator = const CalculateGoalProgress();
  final Map<String, Decimal> _rateCache = {};

  StreamSubscription<List<FinancialGoal>>? _goalsSubscription;
  StreamSubscription<List<AssetSnapshot>>? _assetsSubscription;
  bool _reloading = false;
  bool _reloadQueued = false;
  bool _disposed = false;
  bool _firstGoalsEvent = true;
  bool _firstAssetsEvent = true;

  /// Подписывается на цель и связанные активы и загружает снимок.
  Future<void> load() async {
    _subscribe();
    if (_reloading) {
      _reloadQueued = true;
      return;
    }
    await _reload();
  }

  void _subscribe() {
    if (_disposed || _goalsSubscription != null) return;
    _goalsSubscription = repository.watchAll().listen((_) {
      if (_firstGoalsEvent) {
        _firstGoalsEvent = false;
        return;
      }
      _scheduleReload();
    }, onError: (Object _) => _onStreamError());
    _assetsSubscription = assetRepository
        .watchAll(includeArchived: true)
        .listen((_) {
          if (_firstAssetsEvent) {
            _firstAssetsEvent = false;
            return;
          }
          _scheduleReload();
        }, onError: (Object _) => _onStreamError());
  }

  void _onStreamError() {
    if (_disposed) return;
    state.value = const ViewError(DomainErrorCode.storageFailure);
  }

  void _scheduleReload() {
    if (_disposed) return;
    if (_reloading) {
      _reloadQueued = true;
      return;
    }
    unawaited(_reload());
  }

  Future<void> _reload() async {
    if (_disposed) return;
    _reloading = true;
    try {
      var current = await repository.getById(goalId);
      if (_disposed) return;
      if (current.deletedAt != null) {
        state.value = const ViewError(DomainErrorCode.notFound);
        return;
      }
      try {
        final list = await currencyRepository.watchAll().first;
        currencies.value = {for (final item in list) item.code: item};
      } on Exception {
        // Валюта не блокирует детали.
      }
      final snapshots = await assetRepository
          .watchAll(includeArchived: true)
          .first;
      if (_disposed) return;
      final byId = {
        for (final snapshot in snapshots) snapshot.asset.id: snapshot,
      };
      final linked = <Asset>[];
      final values = <int, List<Money>>{};
      for (final id in current.assetIds) {
        final snapshot = byId[id];
        if (snapshot == null) continue;
        linked.add(snapshot.asset);
        values[id] = snapshot.breakdown;
      }
      assets.value = linked;

      final computed = await _calculator.load(
        goal: current,
        assetValues: values,
        currencies: currencies.value,
        rateRepository: rateRepository,
        today: today,
        rateCache: _rateCache,
      );
      if (_disposed) return;
      if (computed != null) {
        final resolved = GoalCalculator.resolveStatus(
          current: current.status,
          progress: computed,
        );
        if (resolved != current.status) {
          await repository.setStatus(goalId, resolved);
          if (_disposed) return;
          current = await repository.getById(goalId);
          if (_disposed) return;
        }
      }
      progress.value = computed;
      goal.value = current;
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    } finally {
      _reloading = false;
      if (_reloadQueued) {
        _reloadQueued = false;
        _scheduleReload();
      }
    }
  }

  Future<Result<void>> setStatus(GoalStatus status) async {
    busy.value = true;
    pendingStatus.value = status;
    try {
      await repository.setStatus(goalId, status);
      await load();
      return const Success(null);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
      pendingStatus.value = null;
    }
  }

  Future<Result<void>> delete() async {
    busy.value = true;
    deleteBusy.value = true;
    try {
      await repository.softDelete(goalId);
      return const Success(null);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
      deleteBusy.value = false;
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(_goalsSubscription?.cancel());
    unawaited(_assetsSubscription?.cancel());
    _goalsSubscription = null;
    _assetsSubscription = null;
  }
}
