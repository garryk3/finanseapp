import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/subgroups.dart';
import 'package:finanseapp/core/database/tables/asset_details.dart';
import 'package:finanseapp/core/database/tables/categories.dart';
import 'package:finanseapp/core/database/tables/cashflow_entries.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/domain/common/validation.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';

part 'references_dao.g.dart';

/// Справочники банков/брокеров и категорий денежного потока.
///
/// Перенос ссылок и удаление одной транзакцией (TX-REFERENCE-MOVE-DELETE)
/// добавляется задачами 4.1/4.3 вместе с диалогами переноса.
@DriftAccessor(
  tables: [
    Subgroups,
    AccountDetails,
    InvestmentDetails,
    Categories,
    CashflowEntries,
  ],
)
class ReferencesDao extends DatabaseAccessor<AppDatabase>
    with _$ReferencesDaoMixin {
  ReferencesDao(super.db);

  Stream<List<SubgroupRow>> watchSubgroups(SubgroupKind kind) {
    final query = select(subgroups)
      ..where((s) => s.kind.equalsValue(kind))
      ..orderBy([(s) => OrderingTerm.asc(s.name)]);
    return query.watch();
  }

  Future<List<SubgroupRow>> getSubgroups(SubgroupKind kind) =>
      (select(subgroups)
            ..where((s) => s.kind.equalsValue(kind))
            ..orderBy([(s) => OrderingTerm.asc(s.name)]))
          .get();

  Future<int> createSubgroup(SubgroupKind kind, String name) =>
      transaction(() async {
        final trimmed = _requireName(name);
        await _requireSubgroupNameFree(kind, trimmed);
        return into(subgroups).insert(
          SubgroupsCompanion.insert(
            kind: kind,
            name: trimmed,
            normalizedName: normalizeEntityName(trimmed),
            createdAt: attachedDatabase.clock(),
          ),
        );
      });

  Future<void> renameSubgroup(int id, String name) => transaction(() async {
    final trimmed = _requireName(name);
    final current = await (select(
      subgroups,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    if (current == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'subgroupId': 'validationSubgroupNotFound'},
      );
    }
    await _requireSubgroupNameFree(current.kind, trimmed, exceptId: id);
    await (update(subgroups)..where((s) => s.id.equals(id))).write(
      SubgroupsCompanion(
        name: Value(trimmed),
        normalizedName: Value(normalizeEntityName(trimmed)),
      ),
    );
  });

  /// Сколько активов ссылается на банк или брокера.
  Future<int> countAssets(int subgroupId) async {
    final accounts = selectOnly(accountDetails)
      ..addColumns([accountDetails.assetId.count()])
      ..where(accountDetails.bankId.equals(subgroupId));
    final investments = selectOnly(investmentDetails)
      ..addColumns([investmentDetails.assetId.count()])
      ..where(investmentDetails.brokerId.equals(subgroupId));
    final accountCount =
        (await accounts.getSingle()).read(accountDetails.assetId.count()) ?? 0;
    final investmentCount =
        (await investments.getSingle()).read(
          investmentDetails.assetId.count(),
        ) ??
        0;
    return accountCount + investmentCount;
  }

  Future<void> deleteSubgroupIfUnused(int id) => transaction(() async {
    if (await countAssets(id) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'subgroupId': 'validationSubgroupInUse'},
      );
    }
    final deleted = await (delete(
      subgroups,
    )..where((s) => s.id.equals(id))).go();
    if (deleted == 0) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'subgroupId': 'validationSubgroupNotFound'},
      );
    }
  });

  /// Переносит все активы исходного справочника в target того же вида и
  /// удаляет source одной транзакцией (TX-REFERENCE-MOVE-DELETE).
  Future<void> moveAssetsAndDelete(int sourceId, int targetId) =>
      transaction(() async {
        if (sourceId == targetId) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'targetId': 'validationSubgroupSameTarget'},
          );
        }
        final source = await (select(
          subgroups,
        )..where((s) => s.id.equals(sourceId))).getSingleOrNull();
        final target = await (select(
          subgroups,
        )..where((s) => s.id.equals(targetId))).getSingleOrNull();
        if (source == null || target == null) {
          throw const DomainException(
            DomainErrorCode.notFound,
            fieldErrors: {'subgroupId': 'validationSubgroupNotFound'},
          );
        }
        if (source.kind != target.kind) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'targetId': 'validationSubgroupKindMismatch'},
          );
        }

        if (source.kind == SubgroupKind.bank) {
          await (update(accountDetails)
                ..where((d) => d.bankId.equals(sourceId)))
              .write(AccountDetailsCompanion(bankId: Value(targetId)));
        } else {
          await (update(investmentDetails)
                ..where((d) => d.brokerId.equals(sourceId)))
              .write(InvestmentDetailsCompanion(brokerId: Value(targetId)));
        }

        if (await countAssets(sourceId) != 0) {
          throw const DomainException(
            DomainErrorCode.conflict,
            fieldErrors: {'subgroupId': 'validationSubgroupInUse'},
          );
        }
        await (delete(subgroups)..where((s) => s.id.equals(sourceId))).go();
      });

  /// Переносит все записи (включая soft-deleted) в активную категорию того же
  /// типа и удаляет source одной транзакцией (BR-CAT-4).
  Future<void> moveEntriesAndDelete(int sourceId, int targetId) =>
      transaction(() async {
        if (sourceId == targetId) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'targetId': 'validationCategorySameTarget'},
          );
        }
        final source = await (select(
          categories,
        )..where((c) => c.id.equals(sourceId))).getSingleOrNull();
        final target = await (select(
          categories,
        )..where((c) => c.id.equals(targetId))).getSingleOrNull();
        if (source == null || target == null) {
          throw const DomainException(
            DomainErrorCode.notFound,
            fieldErrors: {'categoryId': 'validationCategoryNotFound'},
          );
        }
        if (source.kind != target.kind) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'targetId': 'validationCategoryKindMismatch'},
          );
        }
        if (target.archivedAt != null) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'targetId': 'validationCategoryArchived'},
          );
        }

        await (update(cashflowEntries)
              ..where((e) => e.categoryId.equals(sourceId)))
            .write(CashflowEntriesCompanion(categoryId: Value(targetId)));

        if (await countEntries(sourceId) != 0) {
          throw const DomainException(
            DomainErrorCode.conflict,
            fieldErrors: {'categoryId': 'validationCategoryInUse'},
          );
        }
        await (delete(categories)..where((c) => c.id.equals(sourceId))).go();
      });

  Stream<List<CategoryRow>> watchCategories(
    CashflowKind kind, {
    bool includeArchived = false,
  }) {
    final query = select(categories)
      ..where((c) => c.kind.equalsValue(kind))
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    if (!includeArchived) {
      query.where((c) => c.archivedAt.isNull());
    }
    return query.watch();
  }

  /// id активной (неархивной) категории с нормализованным [name] и видом
  /// [kind]; null — категории нет или она архивирована (D21.6/X1).
  ///
  /// Используется для поиска служебных категорий по имени («Проценты по
  /// вкладу»), которые пользователь может переименовать/архивировать.
  Future<int?> findActiveIdByName(String name, CashflowKind kind) async {
    final normalized = normalizeEntityName(name);
    final query = select(categories)
      ..where((c) => c.kind.equalsValue(kind))
      ..where((c) => c.normalizedName.equals(normalized))
      ..where((c) => c.archivedAt.isNull())
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.id;
  }

  Future<int> createCategory(
    CashflowKind kind,
    String name, {
    String? colorKey,
    String? iconKey,
  }) => transaction(() async {
    final trimmed = _requireName(name);
    await _requireCategoryNameFree(kind, trimmed);
    return into(categories).insert(
      CategoriesCompanion.insert(
        kind: kind,
        name: trimmed,
        normalizedName: normalizeEntityName(trimmed),
        colorKey: Value(colorKey),
        iconKey: Value(iconKey),
      ),
    );
  });

  Future<void> renameCategory(int id, String name) => transaction(() async {
    final trimmed = _requireName(name);
    final current = await (select(
      categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (current == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'categoryId': 'validationCategoryNotFound'},
      );
    }
    await _requireCategoryNameFree(current.kind, trimmed, exceptId: id);
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(trimmed),
        normalizedName: Value(normalizeEntityName(trimmed)),
      ),
    );
  });

  Future<void> updateCategoryAppearance(
    int id, {
    String? colorKey,
    String? iconKey,
  }) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(colorKey: Value(colorKey), iconKey: Value(iconKey)),
    );
  }

  Future<void> archiveCategory(int id, {DateTime? archivedAt}) async {
    final current = await (select(
      categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (current == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'categoryId': 'validationCategoryNotFound'},
      );
    }
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        archivedAt: Value((archivedAt ?? attachedDatabase.clock()).toUtc()),
      ),
    );
  }

  /// Сколько записей денежного потока ссылается на категорию (включая
  /// soft-deleted: физическое удаление сломало бы историю).
  Future<int> countEntries(int categoryId) async {
    final query = selectOnly(cashflowEntries)
      ..addColumns([cashflowEntries.id.count()])
      ..where(cashflowEntries.categoryId.equals(categoryId));
    return (await query.getSingle()).read(cashflowEntries.id.count()) ?? 0;
  }

  Future<void> deleteCategoryIfUnused(int id) => transaction(() async {
    if (await countEntries(id) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'categoryId': 'validationCategoryInUse'},
      );
    }
    final deleted = await (delete(
      categories,
    )..where((c) => c.id.equals(id))).go();
    if (deleted == 0) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'categoryId': 'validationCategoryNotFound'},
      );
    }
  });

  Future<void> _requireSubgroupNameFree(
    SubgroupKind kind,
    String name, {
    int? exceptId,
  }) async {
    final normalized = normalizeEntityName(name);
    final query = select(subgroups)
      ..where(
        (s) =>
            s.kind.equalsValue(kind) &
            s.normalizedName.equals(normalized) &
            (exceptId == null
                ? const Constant(true)
                : s.id.equals(exceptId).not()),
      )
      ..limit(1);
    if (await query.getSingleOrNull() != null) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'name': 'validationSubgroupDuplicate'},
      );
    }
  }

  Future<void> _requireCategoryNameFree(
    CashflowKind kind,
    String name, {
    int? exceptId,
  }) async {
    final normalized = normalizeEntityName(name);
    final query = select(categories)
      ..where(
        (c) =>
            c.kind.equalsValue(kind) &
            c.normalizedName.equals(normalized) &
            c.archivedAt.isNull() &
            (exceptId == null
                ? const Constant(true)
                : c.id.equals(exceptId).not()),
      )
      ..limit(1);
    if (await query.getSingleOrNull() != null) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'name': 'validationCategoryDuplicate'},
      );
    }
  }

  static String _requireName(String name) {
    final trimmed = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'name': 'validationNameRequired'},
      );
    }
    return trimmed;
  }
}
