import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Детали цели: статусы и удаление (8.1).
class GoalDetailsViewModel {
  GoalDetailsViewModel({
    required this.repository,
    required this.assetRepository,
    required this.goalId,
    required this.currencyRepository,
  });

  final GoalRepository repository;
  final AssetRepository assetRepository;
  final int goalId;
  final CurrencyRepository currencyRepository;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<FinancialGoal?> goal = signal(null);
  final Signal<List<Asset>> assets = signal(const []);
  final Signal<bool> busy = signal(false);
  final Signal<GoalStatus?> pendingStatus = signal(null);
  final Signal<bool> deleteBusy = signal(false);
  final Signal<Map<String, Currency>> currencies = signal(const {});

  Future<void> load() async {
    try {
      final current = await repository.getById(goalId);
      if (current.deletedAt != null) {
        state.value = const ViewError(DomainErrorCode.notFound);
        return;
      }
      goal.value = current;
      try {
        final list = await currencyRepository.watchAll().first;
        currencies.value = {for (final item in list) item.code: item};
      } on Exception {
        // Валюта не блокирует детали.
      }
      final list = <Asset>[];
      for (final id in current.assetIds) {
        try {
          list.add((await assetRepository.getById(id)).asset);
        } on DomainException {
          // Связанный актив мог быть удалён только без ссылок.
        }
      }
      assets.value = list;
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
