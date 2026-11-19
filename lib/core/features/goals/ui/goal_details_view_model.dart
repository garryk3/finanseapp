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

  Future<void> load() async {
    try {
      var current = await repository.getById(goalId);
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
      final byId = {
        for (final snapshot in snapshots) snapshot.asset.id: snapshot,
      };
      final linked = <Asset>[];
      final values = <int, Money>{};
      for (final id in current.assetIds) {
        final snapshot = byId[id];
        if (snapshot == null) continue;
        linked.add(snapshot.asset);
        values[id] = snapshot.currentValue;
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
      if (computed != null) {
        final resolved = GoalCalculator.resolveStatus(
          current: current.status,
          progress: computed,
        );
        if (resolved != current.status) {
          await repository.setStatus(goalId, resolved);
          current = await repository.getById(goalId);
        }
      }
      progress.value = computed;
      goal.value = current;
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
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

  void dispose() {}
}
