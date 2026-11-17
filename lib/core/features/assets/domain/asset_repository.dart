import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';

/// Repository активов и их оценок (domain_model §9).
abstract interface class AssetRepository {
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false});

  Stream<AssetSnapshot?> watchById(int id);

  Future<AssetSnapshot> getById(int id);

  Future<int> create(AssetDraft draft);

  Future<void> update(int id, AssetDraft draft);

  Future<void> deleteIfUnused(int id);

  Future<void> archive(int id);

  Future<void> recordValuation(AssetValuationDraft draft);
}
