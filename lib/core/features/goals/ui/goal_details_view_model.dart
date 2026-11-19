import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
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
  });

  final GoalRepository repository;
  final AssetRepository assetRepository;
  final int goalId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<FinancialGoal?> goal = signal(null);
  final Signal<List<Asset>> assets = signal(const []);
  final Signal<bool> busy = signal(false);

  Future<void> load() async {
    try {
      final current = await repository.getById(goalId);
      if (current.deletedAt != null) {
        state.value = const ViewError(DomainErrorCode.notFound);
        return;
      }
      goal.value = current;
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
    }
  }

  Future<Result<void>> delete() async {
    busy.value = true;
    try {
      await repository.softDelete(goalId);
      return const Success(null);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }

  void dispose() {}
}
