import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/asset_valuations.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';

part 'valuations_dao.g.dart';

/// Абсолютные оценки инвестиций и квартир.
@DriftAccessor(tables: [Assets, AssetValuations])
class ValuationsDao extends DatabaseAccessor<AppDatabase>
    with _$ValuationsDaoMixin {
  ValuationsDao(super.db);

  Stream<List<AssetValuationRow>> watchByAsset(int assetId) {
    final query = select(assetValuations)
      ..where((v) => v.assetId.equals(assetId))
      ..orderBy([
        (v) => OrderingTerm.desc(v.effectiveOn),
        (v) => OrderingTerm.desc(v.id),
      ]);
    return query.watch();
  }

  /// Записывает оценку; суммы уже посчитаны через `MoneyMath`.
  Future<int> create({
    required int assetId,
    required LocalDate effectiveOn,
    required int valueMinor,
    required Decimal rateToRub,
    required int valueRubMinor,
  }) => transaction(() async {
    if (effectiveOn.compareTo(attachedDatabase.today()) > 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'effectiveOn': 'validationDateInFuture'},
      );
    }
    if (valueMinor < 0 || valueRubMinor < 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'value': 'validationAmountNegative'},
      );
    }
    if (rateToRub <= Decimal.zero) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'rate': 'validationRatePositive'},
      );
    }
    final asset = await (select(
      assets,
    )..where((a) => a.id.equals(assetId))).getSingleOrNull();
    if (asset == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'assetId': 'validationAssetNotFound'},
      );
    }
    if (asset.kind == AssetKind.account) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'assetId': 'validationValuationAssetKind'},
      );
    }
    return into(assetValuations).insert(
      AssetValuationsCompanion.insert(
        assetId: assetId,
        effectiveOn: effectiveOn,
        valueMinor: valueMinor,
        rateToRub: rateToRub,
        valueRubMinor: valueRubMinor,
        createdAt: attachedDatabase.clock(),
      ),
    );
  });
}
