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

  /// Переизлучается при изменении активов, их операций и оценок, чтобы
  /// список/детали показывали актуальную стоимость без ручной перезагрузки.
  Stream<List<AssetRow>> watchAll({bool includeArchived = false}) {
    final where = includeArchived ? '' : ' WHERE archived_at IS NULL';
    return customSelect(
      'SELECT * FROM assets$where ORDER BY name',
      readsFrom: {
        assets,
        attachedDatabase.assetValuations,
        attachedDatabase.assetTransactions,
      },
    ).watch().map((rows) => [for (final row in rows) assets.map(row.data)]);
  }

  Stream<AssetRow?> watchById(int id) => customSelect(
    'SELECT * FROM assets WHERE id = ?',
    variables: [Variable<int>(id)],
    readsFrom: {
      assets,
      attachedDatabase.assetValuations,
      attachedDatabase.assetTransactions,
    },
  ).watchSingleOrNull().map((row) => row == null ? null : assets.map(row.data));

  /// Все активы, включая архивные и удалённые из выборов (analytics 9.1).
  Future<List<AssetRow>> allRows() => select(assets).get();

  /// Все detail-строки для батч-сборки снапшотов без N+1.
  Future<List<AccountDetailRow>> allAccountDetails() =>
      select(accountDetails).get();

  Future<List<InvestmentDetailRow>> allInvestmentDetails() =>
      select(investmentDetails).get();

  Future<List<PropertyDetailRow>> allPropertyDetails() =>
      select(propertyDetails).get();

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

  Future<PropertyDetailRow?> propertyDetailsFor(int assetId) => (select(
    propertyDetails,
  )..where((d) => d.assetId.equals(assetId))).getSingleOrNull();

  Future<InvestmentDetailRow?> investmentDetailsFor(int assetId) => (select(
    investmentDetails,
  )..where((d) => d.assetId.equals(assetId))).getSingleOrNull();

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

  Future<({int transactions, int valuations, int goals, int cashflow})>
  referenceCounts(int assetId) async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM asset_transactions WHERE asset_id = ?1) AS tx, '
      '(SELECT COUNT(*) FROM asset_valuations WHERE asset_id = ?1) AS val, '
      '(SELECT COUNT(*) FROM goal_assets WHERE asset_id = ?1) AS goals, '
      '(SELECT COUNT(*) FROM cashflow_entries '
      'WHERE property_id = ?1 OR account_id = ?1) AS cashflow',
      variables: [Variable<int>(assetId)],
    ).getSingle();
    return (
      transactions: row.read<int>('tx'),
      valuations: row.read<int>('val'),
      goals: row.read<int>('goals'),
      cashflow: row.read<int>('cashflow'),
    );
  }

  /// Обновляет инвестицию; смена валюты запрещена при связях (BR-VAL-8).
  Future<void> updateInvestment({
    required int assetId,
    required String name,
    required String currencyCode,
    required int openingValueMinor,
    required int brokerId,
  }) => transaction(() async {
    final asset = await getById(assetId);
    if (asset.kind != AssetKind.investment) {
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
    await (update(investmentDetails)..where((d) => d.assetId.equals(assetId)))
        .write(InvestmentDetailsCompanion(brokerId: Value(brokerId)));
  });

  /// Обновляет квартиру; смена валюты запрещена при связях (BR-VAL-8).
  Future<void> updateProperty({
    required int assetId,
    required String name,
    required String currencyCode,
    required int openingValueMinor,
    String? address,
    int? purchasePriceMinor,
  }) => transaction(() async {
    final asset = await getById(assetId);
    if (asset.kind != AssetKind.property) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'kind': 'validationAssetKindImmutable'},
      );
    }
    if (openingValueMinor < 0 ||
        (purchasePriceMinor != null && purchasePriceMinor < 0)) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'openingValue': 'validationAmountNegative'},
      );
    }
    if (currencyCode != asset.currencyCode &&
        await countReferences(assetId) > 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyLocked'},
      );
    }
    final trimmed = address?.trim();
    await (update(assets)..where((a) => a.id.equals(assetId))).write(
      AssetsCompanion(
        name: Value(name.trim()),
        currencyCode: Value(currencyCode),
        openingValueMinor: Value(openingValueMinor),
      ),
    );
    await (update(
      propertyDetails,
    )..where((d) => d.assetId.equals(assetId))).write(
      PropertyDetailsCompanion(
        address: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        purchasePriceMinor: Value(purchasePriceMinor),
      ),
    );
  });

  Future<int> countReferences(int assetId) async {
    final counts = await referenceCounts(assetId);
    return counts.transactions +
        counts.valuations +
        counts.goals +
        counts.cashflow;
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
