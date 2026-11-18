import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/references_dao.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';

/// Реализация справочника банков/брокеров поверх `ReferencesDao`.
final class SubgroupRepositoryImpl implements SubgroupRepository {
  const SubgroupRepositoryImpl(this._dao);

  final ReferencesDao _dao;

  @override
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind) => _dao
      .watchSubgroups(kind)
      .map((rows) => rows.map(_map).toList(growable: false));

  @override
  Future<int> create(SubgroupKind kind, String name) =>
      _dao.createSubgroup(kind, name);

  @override
  Future<void> rename(int id, String name) => _dao.renameSubgroup(id, name);

  @override
  Future<int> countAssets(int id) => _dao.countAssets(id);

  @override
  Future<void> deleteIfUnused(int id) => _dao.deleteSubgroupIfUnused(id);

  @override
  Future<void> moveAssetsAndDelete(int id, int targetId) =>
      _dao.moveAssetsAndDelete(id, targetId);

  static Subgroup _map(SubgroupRow row) =>
      Subgroup(id: row.id, kind: row.kind, name: row.name);
}
