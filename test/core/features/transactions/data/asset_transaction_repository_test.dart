import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_classification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AssetTransactionRepositoryImpl repository;
  late int incomeCategoryId;
  late int expenseCategoryId;

  setUp(() async {
    db = openTestDatabase();
    repository = AssetTransactionRepositoryImpl(db);
    final categories = await db.select(db.categories).get();
    incomeCategoryId = categories
        .firstWhere((row) => row.kind == CashflowKind.income)
        .id;
    expenseCategoryId = categories
        .firstWhere((row) => row.kind == CashflowKind.expense)
        .id;
  });

  tearDown(() async {
    await db.close();
  });

  AssetTransactionDraft draft(
    int assetId, {
    AssetTransactionKind kind = AssetTransactionKind.deposit,
    int amount = 10000,
    String rate = '90',
    String currency = 'USD',
    LocalDate? occurredOn,
    TransactionClassification? classification,
    String? comment,
  }) => AssetTransactionDraft(
    assetId: assetId,
    kind: kind,
    amount: Money(minorUnits: amount, currencyCode: currency),
    occurredOn: occurredOn ?? LocalDate(2026, 1, 2),
    rateToRub: Decimal.parse(rate),
    comment: comment,
    classification: classification,
  );

  int snapshotAmountRub(AssetTransactionRevisionRow row) =>
      (jsonDecode(row.snapshotJson) as Map<String, dynamic>)['amountRubMinor']
          as int;

  test('deposit 100 USD создаёт RUB snapshot и связанный доход', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');
    final id = await repository.create(
      draft(
        assetId,
        classification: TransactionClassification(
          kind: CashflowKind.income,
          categoryId: incomeCategoryId,
        ),
        comment: 'Зарплата',
      ),
    );

    final transaction = await repository.getById(id);
    expect(transaction.amount.minorUnits, 10000);
    expect(transaction.amountRub.minorUnits, 900000);
    expect(transaction.cashflowEntryId, isNotNull);
    expect(await repository.getById(id), isA<AssetTransaction>());

    final linked = await db.cashflowDao.findLinked(id);
    expect(linked, isNotNull);
    expect(linked!.kind, CashflowKind.income);
    expect(linked.amountRubMinor, 900000);
    expect(linked.accountId, assetId);
    expect(linked.affectsBalance, isTrue);

    expect(await db.transactionsDao.revisions(id), hasLength(1));
    expect(await db.cashflowDao.revisions(linked.id), hasLength(1));
  });

  test('снятие больше баланса отклоняется без cashflow', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');

    await expectLater(
      repository.create(
        draft(
          assetId,
          kind: AssetTransactionKind.withdrawal,
          classification: TransactionClassification(
            kind: CashflowKind.expense,
            categoryId: expenseCategoryId,
          ),
        ),
      ),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.negativeBalance,
        ),
      ),
    );

    expect(await db.transactionsDao.allRows(), isEmpty);
    final entries = await db.select(db.cashflowEntries).get();
    expect(entries, isEmpty);
  });

  test('вид дохода обязан совпадать с видом операции', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');

    await expectLater(
      repository.create(
        draft(
          assetId,
          classification: TransactionClassification(
            kind: CashflowKind.expense,
            categoryId: expenseCategoryId,
          ),
        ),
      ),
      throwsA(isA<DomainException>()),
    );
    expect(await db.transactionsDao.allRows(), isEmpty);
  });

  test('правка суммы обновляет обе проекции и ревизии', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');
    final id = await repository.create(
      draft(
        assetId,
        classification: TransactionClassification(
          kind: CashflowKind.income,
          categoryId: incomeCategoryId,
        ),
      ),
    );
    final linked = await db.cashflowDao.findLinked(id);

    await repository.revise(
      id,
      draft(
        assetId,
        amount: 20000,
        classification: TransactionClassification(
          kind: CashflowKind.income,
          categoryId: incomeCategoryId,
        ),
      ),
    );

    final transaction = await repository.getById(id);
    expect(transaction.revisionNo, 2);
    expect(transaction.amount.minorUnits, 20000);
    expect(transaction.amountRub.minorUnits, 1800000);
    final revised = await db.cashflowDao.findLinked(id);
    expect(revised!.id, linked!.id);
    expect(revised.revisionNo, 2);
    expect(revised.amountRubMinor, 1800000);
    expect(await db.transactionsDao.revisions(id), hasLength(2));
    expect(await db.cashflowDao.revisions(linked.id), hasLength(2));
  });

  test('нулевая сумма и будущая дата отклоняются', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');

    await expectLater(
      repository.create(draft(assetId, amount: 0)),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.create(draft(assetId, occurredOn: LocalDate(2030, 1, 1))),
      throwsA(isA<DomainException>()),
    );
    expect(await db.transactionsDao.allRows(), isEmpty);
  });

  test('revise добавляет классификацию и сохраняет связь', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');
    final id = await repository.create(draft(assetId));

    await repository.revise(
      id,
      draft(
        assetId,
        classification: TransactionClassification(
          kind: CashflowKind.income,
          categoryId: incomeCategoryId,
        ),
      ),
    );

    final linked = await db.cashflowDao.findLinked(id);
    expect(linked, isNotNull);
    expect((await repository.getById(id)).cashflowEntryId, linked!.id);
    expect(await db.cashflowDao.findLinked(id), isNotNull);
  });

  test('снятие классификации мягко удаляет связанный доход', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');
    final id = await repository.create(
      draft(
        assetId,
        classification: TransactionClassification(
          kind: CashflowKind.income,
          categoryId: incomeCategoryId,
        ),
      ),
    );
    final linked = await db.cashflowDao.findLinked(id);

    await repository.revise(
      id,
      draft(assetId, amount: 20000, comment: 'Без классификации'),
    );

    expect(await db.cashflowDao.findLinked(id), isNull);
    final rows = await (db.select(
      db.cashflowEntries,
    )..where((e) => e.id.equals(linked!.id))).getSingle();
    expect(rows.deletedAt, isNotNull);
  });

  test('CALC-011: правка суммы сохраняет revision 1 и даёт +950 RUB', () async {
    final assetId = await createAccount(db, currencyCode: 'EUR');
    final occurredOn = LocalDate(2026, 1, 1);
    final id = await repository.create(
      draft(
        assetId,
        amount: 10000,
        rate: '95',
        currency: 'EUR',
        occurredOn: occurredOn,
      ),
    );

    await repository.revise(
      id,
      draft(
        assetId,
        amount: 11000,
        rate: '95',
        currency: 'EUR',
        occurredOn: occurredOn,
      ),
    );

    final current = await repository.getById(id);
    expect(current.amount.minorUnits, 11000);
    expect(current.amountRub.minorUnits, 1045000);
    final revisions = await db.transactionsDao.revisions(id);
    expect(revisions, hasLength(2));
    expect(snapshotAmountRub(revisions[0]), 950000);
    expect(snapshotAmountRub(revisions[1]), 1045000);
    expect(current.amountRub.minorUnits - 950000, 95000);
  });

  test('CALC-012: правка даты сохраняет курс каждой ревизии', () async {
    final assetId = await createAccount(db, currencyCode: 'EUR');
    final id = await repository.create(
      draft(
        assetId,
        amount: 10000,
        rate: '95',
        currency: 'EUR',
        occurredOn: LocalDate(2026, 1, 1),
      ),
    );

    await repository.revise(
      id,
      draft(
        assetId,
        amount: 10000,
        rate: '100',
        currency: 'EUR',
        occurredOn: LocalDate(2026, 2, 1),
      ),
    );

    final current = await repository.getById(id);
    expect(current.occurredOn, LocalDate(2026, 2, 1));
    expect(current.amountRub.minorUnits, 1000000);
    final revisions = await db.transactionsDao.revisions(id);
    expect(revisions, hasLength(2));
    expect(snapshotAmountRub(revisions[0]), 950000);
    expect(snapshotAmountRub(revisions[1]), 1000000);
  });

  test('CALC-033: deposit без классификации не создаёт доход', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');
    final id = await repository.create(draft(assetId));

    expect((await repository.getById(id)).amount.minorUnits, 10000);
    expect(await db.select(db.cashflowEntries).get(), isEmpty);
    expect(await db.cashflowDao.findLinked(id), isNull);
  });

  test('property запрещён', () async {
    final assetId = await createProperty(db);
    await expectLater(
      repository.create(
        AssetTransactionDraft(
          assetId: assetId,
          kind: AssetTransactionKind.deposit,
          amount: const Money(minorUnits: 100, currencyCode: 'RUB'),
          occurredOn: LocalDate(2026, 1, 2),
          rateToRub: Decimal.one,
        ),
      ),
      throwsA(isA<DomainException>()),
    );
  });

  test('сбой cashflow откатывает операцию и ревизию', () async {
    final assetId = await createAccount(db, currencyCode: 'USD');
    await db.referencesDao.archiveCategory(incomeCategoryId);

    await expectLater(
      repository.create(
        draft(
          assetId,
          classification: TransactionClassification(
            kind: CashflowKind.income,
            categoryId: incomeCategoryId,
          ),
        ),
      ),
      throwsA(isA<DomainException>()),
    );

    expect(await db.transactionsDao.allRows(), isEmpty);
    final revisions = await db.select(db.assetTransactionRevisions).get();
    expect(revisions, isEmpty);
    expect(await db.select(db.cashflowEntries).get(), isEmpty);
  });
}
