import 'package:finanseapp/core/features/assets/domain/subgroup.dart';

/// Repository справочников банков и брокеров (domain_model §9).
abstract interface class SubgroupRepository {
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind);

  Future<int> create(SubgroupKind kind, String name);

  Future<void> rename(int id, String name);

  Future<int> countAssets(int id);

  Future<void> deleteIfUnused(int id);

  Future<void> moveAssetsAndDelete(int id, int targetId);
}
