import 'dart:async';

import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Элемент списка: справочник и число привязанных активов (BR-P-3/4).
final class SubgroupItem {
  const SubgroupItem({required this.subgroup, required this.assetCount});

  final Subgroup subgroup;
  final int assetCount;
}

/// ViewModel справочника банков/брокеров (BR-P-1…5).
class SubgroupsViewModel {
  SubgroupsViewModel({required this.repository});

  final SubgroupRepository repository;

  final Signal<SubgroupKind> kind = signal(SubgroupKind.bank);
  final Signal<ViewState<List<SubgroupItem>>> state = signal(
    const ViewLoading(),
  );
  final Signal<bool> busy = signal(false);

  StreamSubscription<List<Subgroup>>? _subscription;
  bool _disposed = false;

  void init(SubgroupKind initial) {
    kind.value = initial;
    _watch();
  }

  void selectKind(SubgroupKind next) {
    if (next == kind.value) return;
    kind.value = next;
    _watch();
  }

  /// Принудительная перезагрузка (кнопка «Повторить»).
  void retry() => _watch();

  Future<Result<int>> countAssets(int id) =>
      _run(() => repository.countAssets(id));

  Future<Result<int>> create(String name) =>
      _run(() => repository.create(kind.value, name));

  Future<Result<void>> rename(int id, String name) =>
      _run(() => repository.rename(id, name));

  /// Удаление свободного справочника; занятый вернёт conflict (BR-P-3).
  Future<Result<void>> deleteIfUnused(int id) =>
      _run(() => repository.deleteIfUnused(id));

  /// Перенос активов и удаление исходного справочника (BR-P-4).
  Future<Result<void>> moveAndDelete(int sourceId, int targetId) =>
      _run(() => repository.moveAssetsAndDelete(sourceId, targetId));

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
  }

  void _watch() {
    final selectedKind = kind.value;
    state.value = const ViewLoading();
    _subscription?.cancel();
    _subscription = repository
        .watchByKind(selectedKind)
        .listen(
          (subgroups) {
            unawaited(_loadCounts(selectedKind, subgroups));
          },
          onError: (Object _) {
            state.value = const ViewError(DomainErrorCode.storageFailure);
          },
        );
  }

  Future<void> _loadCounts(
    SubgroupKind selectedKind,
    List<Subgroup> subgroups,
  ) async {
    try {
      final items = await Future.wait<SubgroupItem>([
        for (final subgroup in subgroups)
          repository
              .countAssets(subgroup.id)
              .then(
                (count) => SubgroupItem(subgroup: subgroup, assetCount: count),
              ),
      ]);
      if (_disposed || kind.value != selectedKind) return;
      state.value = ViewData(items);
    } on Exception {
      if (_disposed || kind.value != selectedKind) return;
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    busy.value = true;
    try {
      return Success(await action());
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }
}
