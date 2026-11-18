import 'dart:async';

import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/categories/logic/category_commands.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel категорий: вкладки типа, архивные labels и конфликты удаления.
class CategoriesViewModel {
  CategoriesViewModel({required this.repository});

  final CategoryRepository repository;

  final Signal<CashflowKind> kind = signal(CashflowKind.expense);
  final Signal<ViewState<List<CashflowCategory>>> state = signal(
    const ViewLoading(),
  );
  final Signal<bool> busy = signal(false);

  StreamSubscription<List<CashflowCategory>>? _subscription;
  bool _disposed = false;

  void init(CashflowKind initial) {
    kind.value = initial;
    _watch();
  }

  void selectKind(CashflowKind next) {
    if (next == kind.value) return;
    kind.value = next;
    _watch();
  }

  void retry() {
    _subscription?.cancel();
    _watch();
  }

  Future<Result<int>> create(String name) => CategoryCommands.create(
    repository,
    CashflowCategoryDraft(kind: kind.value, name: name),
  );

  Future<Result<void>> rename(CashflowCategory category, String name) =>
      CategoryCommands.update(
        repository,
        CashflowCategory(
          id: category.id,
          kind: category.kind,
          name: name,
          isPreset: category.isPreset,
          colorKey: category.colorKey,
          iconKey: category.iconKey,
          archivedAt: category.archivedAt,
        ),
      );

  Future<Result<void>> archive(int id) =>
      CategoryCommands.archive(repository, id);

  Future<Result<void>> deleteIfUnused(int id) =>
      CategoryCommands.deleteIfUnused(repository, id);

  Future<Result<void>> moveAndDelete(int id, int targetId) =>
      CategoryCommands.moveEntriesAndDelete(repository, id, targetId);

  Future<Result<int>> countEntries(int id) async {
    try {
      return Success(await repository.countEntries(id));
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
  }

  void _watch() {
    final selected = kind.value;
    state.value = const ViewLoading();
    _subscription?.cancel();
    _subscription = repository
        .watchByKind(selected, includeArchived: true)
        .listen(
          (categories) {
            if (_disposed || kind.value != selected) return;
            state.value = ViewData(categories);
          },
          onError: (Object _) {
            if (_disposed) return;
            state.value = const ViewError(DomainErrorCode.storageFailure);
          },
        );
  }
}
