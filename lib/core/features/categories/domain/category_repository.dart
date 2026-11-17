import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Repository категорий денежного потока (domain_model §9).
abstract interface class CategoryRepository {
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  });

  Future<int> create(CashflowCategoryDraft draft);

  Future<void> update(CashflowCategory category);

  Future<int> countEntries(int id);

  Future<void> archive(int id);

  Future<void> moveEntriesAndDelete(int id, int targetId);

  Future<void> deleteIfUnused(int id);
}
