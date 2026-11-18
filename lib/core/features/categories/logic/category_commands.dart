import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';

/// Команды справочника категорий: единая точка маппинга ошибок в `Result`.
abstract final class CategoryCommands {
  static Future<Result<int>> create(
    CategoryRepository repository,
    CashflowCategoryDraft draft,
  ) => _run(() => repository.create(draft));

  static Future<Result<void>> update(
    CategoryRepository repository,
    CashflowCategory category,
  ) => _run(() => repository.update(category));

  static Future<Result<void>> archive(CategoryRepository repository, int id) =>
      _run(() => repository.archive(id));

  static Future<Result<void>> moveEntriesAndDelete(
    CategoryRepository repository,
    int id,
    int targetId,
  ) => _run(() => repository.moveEntriesAndDelete(id, targetId));

  static Future<Result<void>> deleteIfUnused(
    CategoryRepository repository,
    int id,
  ) => _run(() => repository.deleteIfUnused(id));

  static Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    }
  }
}
