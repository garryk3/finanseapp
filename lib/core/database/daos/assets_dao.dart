import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/asset_details.dart';
import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
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

  Stream<AssetRow?> watchById(int id) {
    final query = select(assets)..where((a) => a.id.equals(id));
    return query.watchSingleOrNull();
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

  Future<AccountDetailRow?> accountDetailsFor(int assetId) => (select(
    accountDetails,
  )..where((d) => d.assetId.equals(assetId))).getSingleOrNull();

  /// Обновляет счёт; смена валюты запрещена при связях (BR-VAL-8).
  Future<void> updateAccount({
    required int assetId,
    required String name,
    required String currencyCode,
    required int openingValueMinor,
    required int bankId,
    required Decimal annualRate,
    required LocalDate startDate,
    LocalDate? endDate,
  }) => transaction(() async {
    final asset = await getById(assetId);
    if (asset.kind != AssetKind.account) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'kind': 'validationAssetKindImmutable'},
      );
    }
    if (openingValueMinor < 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'openingValue': 'validationAmountNegative'},
      );
    }
    if (annualRate < Decimal.zero || annualRate > Decimal.fromInt(100)) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'annualRate': 'validationRateRange'},
      );
    }
    if (endDate != null && endDate.compareTo(startDate) < 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'endDate': 'validationDateRangeInvalid'},
      );
    }
    if (currencyCode != asset.currencyCode &&
        await countReferences(assetId) > 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyLocked'},
      );
    }
    await (update(assets)..where((a) => a.id.equals(assetId))).write(
      AssetsCompanion(
        name: Value(name.trim()),
        currencyCode: Value(currencyCode),
        openingValueMinor: Value(openingValueMinor),
      ),
    );
    await (update(
      accountDetails,
    )..where((d) => d.assetId.equals(assetId))).write(
      AccountDetailsCompanion(
        bankId: Value(bankId),
        annualRate: Value(annualRate),
        startDate: Value(startDate),
        endDate: Value(endDate),
      ),
    );
  });

  Future<int> countReferences(int assetId) async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM asset_transactions WHERE asset_id = ?1) + '
      '(SELECT COUNT(*) FROM asset_valuations WHERE asset_id = ?1) + '
      '(SELECT COUNT(*) FROM goal_assets WHERE asset_id = ?1) + '
      '(SELECT COUNT(*) FROM cashflow_entries '
      'WHERE property_id = ?1 OR account_id = ?1) AS total',
      variables: [Variable<int>(assetId)],
    ).getSingle();
    return row.read<int>('total');
  }

  Future<void> deleteIfUnused(int assetId) => transaction(() async {
    if (await countReferences(assetId) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'assetId': 'validationAssetInUse'},
      );
    }
    final asset = await getById(assetId);
    switch (asset.kind) {
      case AssetKind.account:
        await (delete(
          accountDetails,
        )..where((d) => d.assetId.equals(assetId))).go();
      case AssetKind.investment:
        await (delete(
          investmentDetails,
        )..where((d) => d.assetId.equals(assetId))).go();
      case AssetKind.property:
        await (delete(
          propertyDetails,
        )..where((d) => d.assetId.equals(assetId))).go();
    }
    await (delete(assets)..where((a) => a.id.equals(assetId))).go();
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
