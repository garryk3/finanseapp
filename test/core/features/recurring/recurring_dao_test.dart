import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/recurring_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../database/database_fixtures.dart';

Matcher throwsValidation(String field, String key) => throwsA(
  isA<DomainException>()
      .having((error) => error.code, 'code', DomainErrorCode.validation)
      .having(
        (error) => error.fieldErrors,
        'fieldErrors',
        containsPair(field, key),
      ),
);

Matcher throwsConflict(String key) => throwsA(
  isA<DomainException>()
      .having((error) => error.code, 'code', DomainErrorCode.conflict)
      .having(
        (error) => error.fieldErrors,
        'fieldErrors',
        containsPair('operation', key),
      ),
);

void main() {
  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  RecurringRuleInput input({
    RecurringStrategy strategy = RecurringStrategy.fixed,
    CashflowKind kind = CashflowKind.expense,
    int? categoryId,
    int? amountMinor = 100000,
    String currencyCode = 'RUB',
    int? accountId,
    int? propertyId,
    bool affectsBalance = false,
    LocalDate? startDate,
    LocalDate? endDate,
    String? comment,
  }) => RecurringRuleInput(
    strategy: strategy,
    kind: kind,
    categoryId: categoryId ?? 1,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    accountId: accountId,
    propertyId: propertyId,
    affectsBalance: affectsBalance,
    startDate: startDate ?? LocalDate(2026, 1, 15),
    endDate: endDate,
    comment: comment,
  );

  group('создание и чтение', () {
    test('создаёт правило и отдаёт его в watchActive/getById', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final ruleId = await db.recurringDao.create(
        input(categoryId: category, comment: 'Содержание'),
      );

      final byId = await db.recurringDao.getById(ruleId);
      expect(byId.id, ruleId);
      expect(byId.strategy, RecurringStrategy.fixed);
      expect(byId.amountMinor, 100000);
      expect(byId.startDate, LocalDate(2026, 1, 15));
      expect(byId.lastGeneratedPeriod, isNull);

      final active = await db.recurringDao.watchActive().first;
      expect(active.map((row) => row.id), [ruleId]);
    });

    test('deposit_interest пользовательским create запрещён', () async {
      final category = await categoryId(db, CashflowKind.income);
      final account = await createAccount(db);

      await expectLater(
        db.recurringDao.create(
          input(
            strategy: RecurringStrategy.depositInterest,
            kind: CashflowKind.income,
            categoryId: category,
            amountMinor: null,
            accountId: account,
            affectsBalance: true,
          ),
        ),
        throwsValidation('strategy', 'validationRecurringStrategy'),
      );
    });

    test('фильтры watchByAccount/watchByProperty не видят удалённые', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final property = await createProperty(db);
      final ruleId = await db.recurringDao.create(
        input(categoryId: category, propertyId: property),
      );

      expect(
        (await db.recurringDao.watchByProperty(property).first),
        hasLength(1),
      );
      await db.recurringDao.softDelete(ruleId);
      expect(await db.recurringDao.watchByProperty(property).first, isEmpty);
      expect(await db.recurringDao.watchActive().first, isEmpty);
      expect((await db.recurringDao.getById(ruleId)).deletedAt, isNotNull);
    });
  });

  group('валидация', () {
    test('fixed без положительной суммы', () async {
      final category = await categoryId(db, CashflowKind.expense);

      await expectLater(
        db.recurringDao.create(input(categoryId: category, amountMinor: 0)),
        throwsValidation('amount', 'validationAmountPositive'),
      );
      await expectLater(
        db.recurringDao.create(input(categoryId: category, amountMinor: null)),
        throwsValidation('amount', 'validationAmountPositive'),
      );
    });

    test('категория: не найдена, другой вид, архивная', () async {
      final expense = await categoryId(db, CashflowKind.expense);
      final income = await categoryId(db, CashflowKind.income);

      await expectLater(
        db.recurringDao.create(input(categoryId: 999999)),
        throwsA(
          isA<DomainException>()
              .having((error) => error.code, 'code', DomainErrorCode.notFound)
              .having(
                (error) => error.fieldErrors,
                'fieldErrors',
                containsPair('categoryId', 'validationCategoryNotFound'),
              ),
        ),
      );
      await expectLater(
        db.recurringDao.create(input(categoryId: income)),
        throwsValidation('categoryId', 'validationCategoryKindMismatch'),
      );

      await db.customStatement(
        'UPDATE categories SET archived_at = ? WHERE id = ?',
        ['2026-01-01T00:00:00.000000Z', expense],
      );
      await expectLater(
        db.recurringDao.create(input(categoryId: expense)),
        throwsValidation('categoryId', 'validationCategoryArchived'),
      );
    });

    test('property/account: вид, валюта, взаимоисключение', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final account = await createAccount(db, currencyCode: 'USD');
      final property = await createProperty(db);

      await expectLater(
        db.recurringDao.create(
          input(categoryId: category, propertyId: account),
        ),
        throwsValidation('propertyId', 'validationPropertyKind'),
      );
      await expectLater(
        db.recurringDao.create(
          input(categoryId: category, accountId: property),
        ),
        throwsValidation('accountId', 'validationAccountKind'),
      );
      await expectLater(
        db.recurringDao.create(input(categoryId: category, accountId: account)),
        throwsValidation('currencyCode', 'validationCurrencyMismatch'),
      );
      await expectLater(
        db.recurringDao.create(
          input(categoryId: category, accountId: account, propertyId: property),
        ),
        throwsValidation('accountId', 'validationPropertyAndAccountExclusive'),
      );
    });

    test('affectsBalance требует счёт', () async {
      final category = await categoryId(db, CashflowKind.expense);

      await expectLater(
        db.recurringDao.create(
          input(categoryId: category, affectsBalance: true),
        ),
        throwsValidation('accountId', 'validationBalanceRequiresAccount'),
      );
    });

    test('endDate не раньше startDate', () async {
      final category = await categoryId(db, CashflowKind.expense);

      await expectLater(
        db.recurringDao.create(
          input(
            categoryId: category,
            startDate: LocalDate(2026, 2, 1),
            endDate: LocalDate(2026, 1, 31),
          ),
        ),
        throwsValidation('endDate', 'validationRecurringDates'),
      );
    });
  });

  group('изменение и удаление', () {
    test('revise меняет сумму, сохраняет strategy и маркер', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final property = await createProperty(db);
      final ruleId = await db.recurringDao.create(
        input(categoryId: category, propertyId: property),
      );
      await db.recurringDao.updateLastGeneratedPeriod(ruleId, '2026-02');

      await db.recurringDao.revise(
        ruleId,
        input(categoryId: category, propertyId: property, amountMinor: 250000),
      );

      final rule = await db.recurringDao.getById(ruleId);
      expect(rule.amountMinor, 250000);
      expect(rule.strategy, RecurringStrategy.fixed);
      expect(rule.lastGeneratedPeriod, '2026-02');
    });

    test('revise удалённого правила — conflict', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final ruleId = await db.recurringDao.create(input(categoryId: category));
      await db.recurringDao.softDelete(ruleId);

      await expectLater(
        db.recurringDao.revise(ruleId, input(categoryId: category)),
        throwsConflict('validationRuleDeleted'),
      );
    });

    test('повторное удаление — conflict', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final ruleId = await db.recurringDao.create(input(categoryId: category));
      await db.recurringDao.softDelete(ruleId);

      await expectLater(
        db.recurringDao.softDelete(ruleId),
        throwsConflict('validationRuleDeleted'),
      );
    });

    test('countActiveByAsset видит только активные правила', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final property = await createProperty(db);
      final first = await db.recurringDao.create(
        input(categoryId: category, propertyId: property),
      );
      await db.recurringDao.create(
        input(categoryId: category, propertyId: property),
      );

      expect(await db.recurringDao.countActiveByAsset(property), 2);
      await db.recurringDao.softDelete(first);
      expect(await db.recurringDao.countActiveByAsset(property), 1);
    });
  });

  group('findGeneratedEntry', () {
    test('находит и удалённую операцию правила', () async {
      final category = await categoryId(db, CashflowKind.expense);
      final property = await createProperty(db);
      final ruleId = await db.recurringDao.create(
        input(categoryId: category, propertyId: property),
      );
      final entryId = await db.cashflowDao.create(
        CashflowEntryInput(
          kind: CashflowKind.expense,
          categoryId: category,
          amountMinor: 1000,
          currencyCode: 'RUB',
          occurredOn: LocalDate(2026, 1, 15),
          rateToRub: Decimal.one,
          amountRubMinor: 1000,
          affectsBalance: false,
          propertyId: property,
          recurringRuleId: ruleId,
        ),
      );

      expect(
        (await db.recurringDao.findGeneratedEntry(
          ruleId,
          LocalDate(2026, 1, 15),
        ))?.id,
        entryId,
      );
      expect(
        await db.recurringDao.findGeneratedEntry(
          ruleId,
          LocalDate(2026, 2, 15),
        ),
        isNull,
      );

      await db.cashflowDao.softDelete(entryId);
      expect(
        (await db.recurringDao.findGeneratedEntry(
          ruleId,
          LocalDate(2026, 1, 15),
        ))?.deletedAt,
        isNotNull,
      );
    });
  });
}
