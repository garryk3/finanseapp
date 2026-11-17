import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';
import 'package:finanseapp/core/database/tables/goals.dart';
import 'package:finanseapp/core/database/tables/goal_assets.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';

part 'goals_dao.g.dart';

/// Финансовые цели и явные связи с активами.
@DriftAccessor(tables: [Assets, Currencies, Goals, GoalAssets])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<GoalRow>> watchAll() =>
      (select(goals)
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.asc(g.name)]))
          .watch();

  Future<GoalRow> getById(int id) async {
    final row = await (select(
      goals,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'goalId': 'validationGoalNotFound'},
      );
    }
    return row;
  }

  Future<Set<int>> assetIdsFor(int goalId) async {
    final rows = await (select(
      goalAssets,
    )..where((link) => link.goalId.equals(goalId))).get();
    return rows.map((row) => row.assetId).toSet();
  }

  Future<int> create({
    required String name,
    required GoalCategory category,
    required int targetAmountMinor,
    required String currencyCode,
    required Set<int> assetIds,
    GoalStatus status = GoalStatus.active,
    LocalDate? targetDate,
  }) => transaction(() async {
    final trimmed = _requireName(name);
    _requirePositiveTarget(targetAmountMinor);
    await _requireCurrency(currencyCode);
    await _requireCompatibleAssets(category, assetIds);

    final now = attachedDatabase.clock();
    final id = await into(goals).insert(
      GoalsCompanion.insert(
        name: trimmed,
        category: category,
        targetAmountMinor: targetAmountMinor,
        currencyCode: currencyCode,
        status: status,
        createdAt: now,
        updatedAt: now,
        targetDate: Value(targetDate),
      ),
    );
    await _replaceLinks(id, assetIds);
    return id;
  });

  Future<void> updateGoal(
    int id, {
    required String name,
    required GoalCategory category,
    required int targetAmountMinor,
    required String currencyCode,
    required Set<int> assetIds,
    LocalDate? targetDate,
  }) => transaction(() async {
    final current = await getById(id);
    if (current.deletedAt != null) throw _conflict('validationGoalDeleted');
    final trimmed = _requireName(name);
    _requirePositiveTarget(targetAmountMinor);
    await _requireCurrency(currencyCode);
    await _requireCompatibleAssets(category, assetIds);

    await (update(goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(
        name: Value(trimmed),
        category: Value(category),
        targetAmountMinor: Value(targetAmountMinor),
        currencyCode: Value(currencyCode),
        targetDate: Value(targetDate),
        updatedAt: Value(attachedDatabase.clock()),
      ),
    );
    await _replaceLinks(id, assetIds);
  });

  Future<void> setStatus(int id, GoalStatus status) async {
    await getById(id);
    await (update(goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(
        status: Value(status),
        updatedAt: Value(attachedDatabase.clock()),
      ),
    );
  }

  Future<void> softDelete(int id) async {
    final current = await getById(id);
    if (current.deletedAt != null) throw _conflict('validationGoalDeleted');
    final now = attachedDatabase.clock();
    await (update(goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> _replaceLinks(int goalId, Set<int> assetIds) async {
    await (delete(
      goalAssets,
    )..where((link) => link.goalId.equals(goalId))).go();
    for (final assetId in assetIds) {
      await into(goalAssets)
          .insert(GoalAssetsCompanion.insert(goalId: goalId, assetId: assetId));
    }
  }

  Future<void> _requireCompatibleAssets(
    GoalCategory category,
    Set<int> assetIds,
  ) async {
    for (final assetId in assetIds) {
      final asset = await (select(
        assets,
      )..where((a) => a.id.equals(assetId))).getSingleOrNull();
      if (asset == null) {
        throw const DomainException(
          DomainErrorCode.notFound,
          fieldErrors: {'assetId': 'validationAssetNotFound'},
        );
      }
      final expected = category == GoalCategory.accounts
          ? AssetKind.account
          : AssetKind.investment;
      if (asset.kind != expected) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'assetId': 'validationGoalAssetKind'},
        );
      }
    }
  }

  Future<void> _requireCurrency(String code) async {
    final exists = await (select(
      currencies,
    )..where((c) => c.code.equals(code))).getSingleOrNull();
    if (exists == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'currencyCode': 'validationCurrencyNotFound'},
      );
    }
  }

  static String _requireName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'name': 'validationNameRequired'},
      );
    }
    return trimmed;
  }

  static void _requirePositiveTarget(int amountMinor) {
    if (amountMinor <= 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'targetAmount': 'validationAmountPositive'},
      );
    }
  }

  static DomainException _conflict(String key) => DomainException(
    DomainErrorCode.conflict,
    fieldErrors: {'operation': key},
  );
}
