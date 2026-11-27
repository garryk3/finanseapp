import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/references_dao.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';

/// Реализация категорий денежного потока поверх `ReferencesDao`.
final class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._dao);

  final ReferencesDao _dao;

  @override
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  }) => _dao
      .watchCategories(kind, includeArchived: includeArchived)
      .map((rows) => rows.map(_map).toList(growable: false));

  @override
  Future<int> create(CashflowCategoryDraft draft) => _dao.createCategory(
    draft.kind,
    draft.name,
    colorKey: draft.colorKey,
    iconKey: draft.iconKey,
  );

  @override
  Future<int?> findActiveIdByName(String name, CashflowKind kind) =>
      _dao.findActiveIdByName(name, kind);

  @override
  Future<void> update(CashflowCategory category) async {
    await _dao.renameCategory(category.id, category.name);
    await _dao.updateCategoryAppearance(
      category.id,
      colorKey: category.colorKey,
      iconKey: category.iconKey,
    );
  }

  @override
  Future<int> countEntries(int id) => _dao.countEntries(id);

  @override
  Future<void> archive(int id) => _dao.archiveCategory(id);

  @override
  Future<void> moveEntriesAndDelete(int id, int targetId) =>
      _dao.moveEntriesAndDelete(id, targetId);

  @override
  Future<void> deleteIfUnused(int id) => _dao.deleteCategoryIfUnused(id);

  static CashflowCategory _map(CategoryRow row) => CashflowCategory(
    id: row.id,
    kind: row.kind,
    name: row.name,
    isPreset: row.isPreset,
    colorKey: row.colorKey,
    iconKey: row.iconKey,
    archivedAt: row.archivedAt,
  );
}
