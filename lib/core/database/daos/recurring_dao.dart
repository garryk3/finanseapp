import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/cashflow_entries.dart';
import 'package:finanseapp/core/database/tables/categories.dart';
import 'package:finanseapp/core/database/tables/recurring_cashflow_rules.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';

part 'recurring_dao.g.dart';

/// Вход правила регулярного платежа.
final class RecurringRuleInput {
  const RecurringRuleInput({
    required this.strategy,
    required this.kind,
    required this.categoryId,
    required this.currencyCode,
    required this.affectsBalance,
    required this.startDate,
    this.amountMinor,
    this.accountId,
    this.propertyId,
    this.endDate,
    this.comment,
  });

  final RecurringStrategy strategy;
  final CashflowKind kind;
  final int categoryId;
  final int? amountMinor;
  final String currencyCode;
  final int? accountId;
  final int? propertyId;
  final bool affectsBalance;
  final LocalDate startDate;
  final LocalDate? endDate;
  final String? comment;
}

/// Правила регулярных платежей: CRUD с валидацией и служебные запросы
/// генератора (BR-RC-1…4).
@DriftAccessor(
  tables: [RecurringCashflowRules, Assets, Categories, CashflowEntries],
)
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {
  RecurringDao(super.db);

  /// Активные правила; [strategy] сужает выборку для генератора.
  Stream<List<RecurringCashflowRuleRow>> watchActive({
    RecurringStrategy? strategy,
  }) {
    final query = select(recurringCashflowRules)
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.asc(r.id)]);
    if (strategy != null) {
      query.where((r) => r.strategy.equalsValue(strategy));
    }
    return query.watch();
  }

  Stream<List<RecurringCashflowRuleRow>> watchByAccount(int accountId) =>
      (select(recurringCashflowRules)
            ..where((r) => r.accountId.equals(accountId) & r.deletedAt.isNull())
            ..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .watch();

  Stream<List<RecurringCashflowRuleRow>> watchByProperty(int propertyId) =>
      (select(recurringCashflowRules)
            ..where(
              (r) => r.propertyId.equals(propertyId) & r.deletedAt.isNull(),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .watch();

  /// Один снимок активных правил для [RecurringGenerator].
  Future<List<RecurringCashflowRuleRow>> activeRules() =>
      (select(recurringCashflowRules)
            ..where((r) => r.deletedAt.isNull())
            ..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .get();

  /// Автоправило процентов счёта; [includeDeleted] нужен для восстановления
  /// после паузы со ставкой 0 (BR-RC-9).
  Future<RecurringCashflowRuleRow?> findDepositInterestRule(
    int accountId, {
    bool includeDeleted = false,
  }) {
    final query = select(recurringCashflowRules)
      ..where(
        (r) =>
            r.accountId.equals(accountId) &
            r.strategy.equalsValue(RecurringStrategy.depositInterest),
      )
      ..orderBy([(r) => OrderingTerm.desc(r.id)])
      ..limit(1);
    if (!includeDeleted) query.where((r) => r.deletedAt.isNull());
    return query.getSingleOrNull();
  }

  /// Создаёт или восстанавливает автоправило процентов, сохраняя маркер.
  ///
  /// Публичный [create] намеренно не принимает `deposit_interest`: такие
  /// правила создаёт только генератор.
  Future<int> upsertDepositInterestRule({
    required int accountId,
    required int categoryId,
    required String currencyCode,
    required LocalDate startDate,
    LocalDate? endDate,
  }) => transaction(() async {
    final existing = await findDepositInterestRule(
      accountId,
      includeDeleted: true,
    );
    final now = attachedDatabase.clock();
    if (existing != null) {
      await (update(
        recurringCashflowRules,
      )..where((r) => r.id.equals(existing.id))).write(
        RecurringCashflowRulesCompanion(
          kind: const Value(CashflowKind.income),
          categoryId: Value(categoryId),
          amountMinor: const Value(null),
          currencyCode: Value(currencyCode),
          accountId: Value(accountId),
          propertyId: const Value(null),
          affectsBalance: const Value(true),
          startDate: Value(startDate),
          endDate: Value(endDate),
          comment: const Value(null),
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
      return existing.id;
    }
    return into(recurringCashflowRules).insert(
      RecurringCashflowRulesCompanion.insert(
        strategy: RecurringStrategy.depositInterest,
        kind: CashflowKind.income,
        categoryId: categoryId,
        currencyCode: currencyCode,
        affectsBalance: true,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
        accountId: Value(accountId),
        endDate: Value(endDate),
      ),
    );
  });

  /// Останавливает проценты (ставка 0/архив), не трогая историю.
  Future<void> softDeleteDepositInterestRule(int accountId) async {
    final existing = await findDepositInterestRule(accountId);
    if (existing == null) return;
    await softDelete(existing.id);
  }

  /// Последнее начисление правила для карточки в деталях счёта.
  Future<CashflowEntryRow?> findLastGeneratedEntry(int ruleId) =>
      (select(cashflowEntries)
            ..where(
              (e) => e.recurringRuleId.equals(ruleId) & e.deletedAt.isNull(),
            )
            ..orderBy([
              (e) => OrderingTerm.desc(e.occurredOn),
              (e) => OrderingTerm.desc(e.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<RecurringCashflowRuleRow> getById(int id) async {
    final row = await (select(
      recurringCashflowRules,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'ruleId': 'validationRuleNotFound'},
      );
    }
    return row;
  }

  Future<int> create(RecurringRuleInput input) => transaction(() async {
    await _validate(input);
    if (input.strategy != RecurringStrategy.fixed) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'strategy': 'validationRecurringStrategy'},
      );
    }
    final now = attachedDatabase.clock();
    final id = await into(recurringCashflowRules).insert(
      RecurringCashflowRulesCompanion.insert(
        strategy: input.strategy,
        kind: input.kind,
        categoryId: input.categoryId,
        currencyCode: input.currencyCode,
        affectsBalance: input.affectsBalance,
        startDate: input.startDate,
        createdAt: now,
        updatedAt: now,
        amountMinor: Value(input.amountMinor),
        accountId: Value(input.accountId),
        propertyId: Value(input.propertyId),
        endDate: Value(input.endDate),
        comment: Value(input.comment),
      ),
    );
    return id;
  });

  /// Меняет поля правила; strategy и маркер периодов не меняются (BR-RC-7).
  Future<void> revise(int id, RecurringRuleInput input) =>
      transaction(() async {
        final current = await getById(id);
        if (current.deletedAt != null) {
          throw _conflict('validationRuleDeleted');
        }
        if (input.strategy != current.strategy) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'strategy': 'validationRecurringStrategy'},
          );
        }
        await _validate(input);
        final now = attachedDatabase.clock();
        await (update(
          recurringCashflowRules,
        )..where((r) => r.id.equals(id))).write(
          RecurringCashflowRulesCompanion(
            kind: Value(input.kind),
            categoryId: Value(input.categoryId),
            amountMinor: Value(input.amountMinor),
            currencyCode: Value(input.currencyCode),
            accountId: Value(input.accountId),
            propertyId: Value(input.propertyId),
            affectsBalance: Value(input.affectsBalance),
            startDate: Value(input.startDate),
            endDate: Value(input.endDate),
            comment: Value(input.comment),
            updatedAt: Value(now),
          ),
        );
      });

  Future<void> softDelete(int id) => transaction(() async {
    final current = await getById(id);
    if (current.deletedAt != null) {
      throw _conflict('validationRuleDeleted');
    }
    await (update(recurringCashflowRules)..where((r) => r.id.equals(id))).write(
      RecurringCashflowRulesCompanion(
        deletedAt: Value(attachedDatabase.clock()),
        updatedAt: Value(attachedDatabase.clock()),
      ),
    );
  });

  /// Двигает маркер catch-up в ту же транзакцию, что и операция (BR-RC-11).
  Future<void> updateLastGeneratedPeriod(int ruleId, String period) =>
      (update(recurringCashflowRules)..where((r) => r.id.equals(ruleId))).write(
        RecurringCashflowRulesCompanion(lastGeneratedPeriod: Value(period)),
      );

  /// Операция, уже созданная правилом на дату; включает soft-deleted,
  /// чтобы удалённая пользователем операция не пересоздавалась (BR-RC-4).
  Future<CashflowEntryRow?> findGeneratedEntry(int ruleId, LocalDate date) =>
      (select(cashflowEntries)
            ..where(
              (e) =>
                  e.recurringRuleId.equals(ruleId) &
                  e.occurredOn.equalsValue(date),
            )
            ..limit(1))
          .getSingleOrNull();

  Future<int> countActiveByAsset(int assetId) async {
    final count = countAll();
    final query = selectOnly(recurringCashflowRules)
      ..addColumns([count])
      ..where(
        recurringCashflowRules.deletedAt.isNull() &
            (recurringCashflowRules.accountId.equals(assetId) |
                recurringCashflowRules.propertyId.equals(assetId)),
      );
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<void> _validate(RecurringRuleInput input) async {
    if (input.strategy == RecurringStrategy.fixed &&
        (input.amountMinor == null || input.amountMinor! <= 0)) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'amount': 'validationAmountPositive'},
      );
    }
    if (input.propertyId != null && input.accountId != null) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'accountId': 'validationPropertyAndAccountExclusive'},
      );
    }
    if (input.affectsBalance && input.accountId == null) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'accountId': 'validationBalanceRequiresAccount'},
      );
    }
    if (input.endDate != null &&
        input.endDate!.compareTo(input.startDate) < 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'endDate': 'validationRecurringDates'},
      );
    }

    final category = await (select(
      categories,
    )..where((c) => c.id.equals(input.categoryId))).getSingleOrNull();
    if (category == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'categoryId': 'validationCategoryNotFound'},
      );
    }
    if (category.kind != input.kind) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'categoryId': 'validationCategoryKindMismatch'},
      );
    }
    if (category.archivedAt != null) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'categoryId': 'validationCategoryArchived'},
      );
    }

    if (input.propertyId != null) {
      final property = await _requireAsset(input.propertyId!);
      if (property.kind != AssetKind.property) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'propertyId': 'validationPropertyKind'},
        );
      }
    }
    if (input.accountId != null) {
      final account = await _requireAsset(input.accountId!);
      if (account.kind != AssetKind.account) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'accountId': 'validationAccountKind'},
        );
      }
      if (account.currencyCode != input.currencyCode) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
        );
      }
    }
  }

  Future<AssetRow> _requireAsset(int id) async {
    final row = await (select(
      assets,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'assetId': 'validationAssetNotFound'},
      );
    }
    return row;
  }

  static DomainException _conflict(String key) => DomainException(
    DomainErrorCode.conflict,
    fieldErrors: {'operation': key},
  );
}
