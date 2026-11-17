import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/asset_details.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';

part 'assets_dao.g.dart';

/// Активы и их detail-строки. Create выполняется одной транзакцией
/// (TX-ASSET-SAVE): общая строка плюс ровно одна detail-строка вида.
@DriftAccessor(
  tables: [Assets, AccountDetails, InvestmentDetails, PropertyDetails],
)
class AssetsDao extends DatabaseAccessor<AppDatabase> with _$AssetsDaoMixin {
  AssetsDao(super.db);

  Stream<List<AssetRow>> watchAll({bool includeArchived = false}) {
    final query = select(assets)..orderBy([(a) => OrderingTerm.asc(a.name)]);
    if (!includeArchived) {
      query.where((a) => a.archivedAt.isNull());
    }
    return query.watch();
  }

  Future<AssetRow?> findById(int id) =>
      (select(assets)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<AssetRow> getById(int id) async {
    final row = await findById(id);
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'assetId': 'validationAssetNotFound'},
      );
    }
    return row;
  }

  /// Создаёт актив с detail-строкой; несоответствие вида и деталей — validation.
  Future<int> create({
    required String name,
    required AssetKind kind,
    required String currencyCode,
    required int openingValueMinor,
    AccountDetailsCompanion? account,
    InvestmentDetailsCompanion? investment,
    PropertyDetailsCompanion? property,
  }) => transaction(() async {
    _requireDetailMatchesKind(kind, account, investment, property);
    final now = attachedDatabase.clock();
    final assetId = await into(assets).insert(
      AssetsCompanion.insert(
        name: name,
        kind: kind,
        currencyCode: currencyCode,
        openingValueMinor: openingValueMinor,
        createdAt: now,
      ),
    );
    switch (kind) {
      case AssetKind.account:
        await into(accountDetails)
            .insert(account!.copyWith(assetId: Value(assetId)));
      case AssetKind.investment:
        await into(investmentDetails)
            .insert(investment!.copyWith(assetId: Value(assetId)));
      case AssetKind.property:
        await into(propertyDetails)
            .insert(property!.copyWith(assetId: Value(assetId)));
    }
    return assetId;
  });

  Future<void> archive(int id, {DateTime? archivedAt}) async {
    await getById(id);
    await (update(assets)..where((a) => a.id.equals(id))).write(
      AssetsCompanion(
        archivedAt: Value((archivedAt ?? attachedDatabase.clock()).toUtc()),
      ),
    );
  }

  static void _requireDetailMatchesKind(
    AssetKind kind,
    AccountDetailsCompanion? account,
    InvestmentDetailsCompanion? investment,
    PropertyDetailsCompanion? property,
  ) {
    final matchesKind = switch (kind) {
      AssetKind.account =>
        account != null && investment == null && property == null,
      AssetKind.investment =>
        investment != null && account == null && property == null,
      AssetKind.property =>
        property != null && account == null && investment == null,
    };
    if (!matchesKind) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'kind': 'validationAssetDetailsMismatch'},
      );
    }
  }
}
