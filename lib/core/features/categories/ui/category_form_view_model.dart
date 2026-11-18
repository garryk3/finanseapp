import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:signals/signals.dart';

/// ViewModel формы категории: create (kind фиксирован из query) и rename.
class CategoryFormViewModel {
  CategoryFormViewModel({required this.repository, required this.kind});

  final CategoryRepository repository;
  final CashflowKind kind;

  final Signal<bool> busy = signal(false);

  Future<Result<int>> create(String name) async {
    busy.value = true;
    try {
      return Success(
        await repository.create(CashflowCategoryDraft(kind: kind, name: name)),
      );
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
