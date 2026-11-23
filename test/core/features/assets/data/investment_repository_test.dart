import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AssetRepositoryImpl repository;
  late int brokerId;

  setUp(() async {
    db = openTestDatabase();
    repository = AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
      db.currenciesDao,
    );
    brokerId = await db.referencesDao.createSubgroup(
      SubgroupKind.broker,
      'Брокер',
    );
  });

  tearDown(() async {
    await db.close();
  });

  InvestmentDraft draft({int opening = 100000}) => InvestmentDraft(
    name: 'Инвестиция',
    currencyCode: 'RUB',
    openingValue: Money(minorUnits: opening, currencyCode: 'RUB'),
    brokerId: brokerId,
  );

  test('CALC-014: оценка и последующие операции', () async {
    final id = await repository.create(draft(opening: 100000));
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 150000, currencyCode: 'RUB'),
        rateToRub: Decimal.one,
      ),
    );
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: id,
        kind: AssetTransactionKind.deposit,
        amountMinor: 5000,
        occurredOn: LocalDate(2026, 1, 3),
        rateToRub: Decimal.one,
        amountRubMinor: 5000,
      ),
    );

    final snapshot = await repository.getById(id);

    expect(snapshot.asset, isA<InvestmentAsset>());
    expect((snapshot.asset as InvestmentAsset).brokerId, brokerId);
    expect(snapshot.currentValue.minorUnits, 155000);
    expect(await repository.valuations(id), hasLength(1));
    final counts = await repository.referenceCounts(id);
    expect(counts.transactions, 1);
    expect(counts.valuations, 1);
    expect(counts.cashflow, 0);
  });

  test('две оценки одной даты: последняя по id', () async {
    final id = await repository.create(draft());
    for (final value in [150000, 160000]) {
      await repository.recordValuation(
        AssetValuationDraft(
          assetId: id,
          effectiveOn: LocalDate(2026, 1, 2),
          value: Money(minorUnits: value, currencyCode: 'RUB'),
          rateToRub: Decimal.one,
        ),
      );
    }

    final snapshot = await repository.getById(id);
    expect(snapshot.currentValue.minorUnits, 160000);
  });

  test('оценка не создаёт транзакций и денежного потока', () async {
    final id = await repository.create(draft());
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 150000, currencyCode: 'RUB'),
        rateToRub: Decimal.one,
      ),
    );

    final transactions = await db.transactionsDao.watchByAsset(id).first;
    final counts = await repository.referenceCounts(id);
    expect(transactions, isEmpty);
    expect(counts.transactions, 0);
    expect(counts.cashflow, 0);
    expect(counts.valuations, 1);
  });

  test('рублёвый snapshot учитывает fractionDigits валюты', () async {
    await db.currenciesDao.createCustom('JPY', 'Иена', 0);
    final id = await repository.create(
      InvestmentDraft(
        name: 'Иена',
        currencyCode: 'JPY',
        openingValue: const Money(minorUnits: 0, currencyCode: 'JPY'),
        brokerId: brokerId,
      ),
    );
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 1000, currencyCode: 'JPY'),
        rateToRub: Decimal.parse('0.5'),
      ),
    );

    final valuations = await repository.valuations(id);
    expect(valuations.single.valueRub.minorUnits, 50000);
  });

  test('RUB-снимок оценки берёт fractionDigits из справочника валют', () async {
    final id = await repository.create(draft(opening: 100000));
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 1234, currencyCode: 'USD'),
        rateToRub: Decimal.fromInt(90),
        // Намеренно неверно: репозиторий должен взять 2 знака из справочника.
      ),
    );

    final valuations = await repository.valuations(id);
    expect(valuations.single.valueRub.minorUnits, 111060);
  });

  test('отрицательная и будущая оценка отклоняются', () async {
    final id = await repository.create(draft());
    await expectLater(
      repository.recordValuation(
        AssetValuationDraft(
          assetId: id,
          effectiveOn: LocalDate(2026, 1, 2),
          value: const Money(minorUnits: -1, currencyCode: 'RUB'),
          rateToRub: Decimal.one,
        ),
      ),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.recordValuation(
        AssetValuationDraft(
          assetId: id,
          effectiveOn: LocalDate(2030, 1, 2),
          value: const Money(minorUnits: 100, currencyCode: 'RUB'),
          rateToRub: Decimal.one,
        ),
      ),
      throwsA(isA<DomainException>()),
    );
  });

  test('оценка в валюте актива нормализуется в NULL (M1)', () async {
    final id = await repository.create(draft());
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 150000, currencyCode: 'RUB'),
        rateToRub: Decimal.one,
      ),
    );

    final row = await (db.select(
      db.assetValuations,
    )..where((v) => v.assetId.equals(id))).getSingle();
    expect(row.currencyCode, isNull);
  });

  test('оценка инвестиции в EUR пишется с валютой и RUB по курсу', () async {
    final id = await repository.create(draft(opening: 100000));
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 12000, currencyCode: 'EUR'),
        rateToRub: Decimal.fromInt(100),
      ),
    );

    final row = await (db.select(
      db.assetValuations,
    )..where((v) => v.assetId.equals(id))).getSingle();
    expect(row.currencyCode, 'EUR');
    expect(row.valueMinor, 12000);
    expect(row.valueRubMinor, 1200000);

    final snapshot = await repository.getById(id);
    expect(
      snapshot.currentValue,
      const Money(minorUnits: 100000, currencyCode: 'RUB'),
    );
    expect(snapshot.breakdown, [
      const Money(minorUnits: 100000, currencyCode: 'RUB'),
      const Money(minorUnits: 12000, currencyCode: 'EUR'),
    ]);
  });

  test('снапшот мультивалютной инвестиции: breakdown по M4', () async {
    final id = await repository.create(draft(opening: 100000));
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 12000, currencyCode: 'USD'),
        rateToRub: Decimal.fromInt(90),
      ),
    );
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: id,
        kind: AssetTransactionKind.deposit,
        amountMinor: 5000,
        currencyCode: 'USD',
        occurredOn: LocalDate(2026, 1, 3),
        rateToRub: Decimal.fromInt(90),
        amountRubMinor: 450000,
      ),
    );

    final snapshot = await repository.getById(id);
    expect(
      snapshot.currentValue,
      const Money(minorUnits: 100000, currencyCode: 'RUB'),
    );
    expect(snapshot.breakdown, [
      const Money(minorUnits: 100000, currencyCode: 'RUB'),
      const Money(minorUnits: 17000, currencyCode: 'USD'),
    ]);

    final all = await repository.watchAll().first;
    expect(all.single.breakdown, snapshot.breakdown);
  });

  test('запрет смены валюты инвестиции при отметках', () async {
    final id = await repository.create(draft());
    await repository.setLockedAmount(
      id,
      'RUB',
      const Money(minorUnits: 100, currencyCode: 'RUB'),
    );

    await expectLater(
      repository.update(
        id,
        InvestmentDraft(
          name: 'Инвестиция',
          currencyCode: 'USD',
          openingValue: const Money(minorUnits: 200000, currencyCode: 'USD'),
          brokerId: brokerId,
        ),
      ),
      throwsA(
        isA<DomainException>().having(
          (error) => error.fieldErrors['currencyCode'],
          'currencyCode',
          'validationCurrencyLocked',
        ),
      ),
    );
    expect((await repository.getById(id)).asset.currencyCode, 'RUB');
  });

  test('watchById обновляется после setLockedAmount', () async {
    final id = await repository.create(draft());
    final initial = await repository.watchById(id).first;
    expect(initial!.locked, isEmpty);

    final updatedFuture = repository
        .watchById(id)
        .firstWhere((snapshot) => snapshot?.locked.isNotEmpty ?? false);
    await repository.setLockedAmount(
      id,
      'RUB',
      const Money(minorUnits: 100, currencyCode: 'RUB'),
    );

    final updated = await updatedFuture.timeout(const Duration(seconds: 2));
    expect(updated!.locked, const [
      Money(minorUnits: 100, currencyCode: 'RUB'),
    ]);
  });

  test('update инвестиции и запрет смены валюты при операциях', () async {
    final id = await repository.create(draft());
    await repository.update(id, draft(opening: 200000));
    expect((await repository.getById(id)).currentValue.minorUnits, 200000);

    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: id,
        kind: AssetTransactionKind.deposit,
        amountMinor: 100,
        occurredOn: LocalDate(2026, 1, 1),
        rateToRub: Decimal.one,
        amountRubMinor: 100,
      ),
    );
    await expectLater(
      repository.update(
        id,
        InvestmentDraft(
          name: 'Инвестиция',
          currencyCode: 'USD',
          openingValue: const Money(minorUnits: 200000, currencyCode: 'USD'),
          brokerId: brokerId,
        ),
      ),
      throwsA(isA<DomainException>()),
    );
  });

  test('L1/L2: отметка upsert и снятие нулём', () async {
    final id = await repository.create(draft());
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 10000, currencyCode: 'USD'),
        rateToRub: Decimal.fromInt(90),
      ),
    );

    await repository.setLockedAmount(
      id,
      'USD',
      const Money(minorUnits: 9900, currencyCode: 'USD'),
    );
    expect(await repository.lockedAmounts(id), const [
      Money(minorUnits: 9900, currencyCode: 'USD'),
    ]);
    final row = (await db.assetsDao.lockedRowsForAsset(id)).single;
    expect(row.currencyCode, 'USD');
    expect(row.amountMinor, 9900);
    expect(row.createdAt, testNow());

    await repository.setLockedAmount(
      id,
      'USD',
      const Money(minorUnits: 5000, currencyCode: 'USD'),
    );
    final rows = await db.select(db.investmentLockedAmounts).get();
    expect(rows, hasLength(1));
    expect(rows.single.amountMinor, 5000);

    await repository.setLockedAmount(
      id,
      'USD',
      const Money(minorUnits: 0, currencyCode: 'USD'),
    );
    expect(await repository.lockedAmounts(id), isEmpty);
    expect(await db.select(db.investmentLockedAmounts).get(), isEmpty);
  });

  test('L2: превышение баланса, чужая позиция и отрицательная сумма', () async {
    final id = await repository.create(draft());
    await repository.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 10000, currencyCode: 'USD'),
        rateToRub: Decimal.fromInt(90),
      ),
    );

    await expectLater(
      repository.setLockedAmount(
        id,
        'USD',
        const Money(minorUnits: 10001, currencyCode: 'USD'),
      ),
      throwsA(_lockedFailure('validationLockedExceedsBalance')),
    );
    await expectLater(
      repository.setLockedAmount(
        id,
        'EUR',
        const Money(minorUnits: 100, currencyCode: 'EUR'),
      ),
      throwsA(_lockedFailure('validationLockedExceedsBalance')),
    );
    await expectLater(
      repository.setLockedAmount(
        id,
        'USD',
        const Money(minorUnits: -1, currencyCode: 'USD'),
      ),
      throwsA(_lockedFailure('validationAmountNegative')),
    );
    expect(await repository.lockedAmounts(id), isEmpty);
  });

  test('L2: счёт и квартира не принимают отметки', () async {
    final accountId = await createAccount(db, openingValueMinor: 100000);
    final propertyId = await createProperty(db, openingValueMinor: 100000);

    await expectLater(
      repository.setLockedAmount(
        accountId,
        'RUB',
        const Money(minorUnits: 100, currencyCode: 'RUB'),
      ),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.setLockedAmount(
        propertyId,
        'RUB',
        const Money(minorUnits: 100, currencyCode: 'RUB'),
      ),
      throwsA(isA<DomainException>()),
    );
  });

  test('DAO: отметка только для инвестиции и известной валюты', () async {
    final accountId = await createAccount(db);
    final investmentId = await repository.create(draft());

    await expectLater(
      db.assetsDao.setLockedAmount(
        assetId: accountId,
        currencyCode: 'RUB',
        amountMinor: 100,
      ),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      db.assetsDao.setLockedAmount(
        assetId: investmentId,
        currencyCode: 'XXX',
        amountMinor: 100,
      ),
      throwsA(isA<DomainException>()),
    );
    expect(await db.assetsDao.allLockedRows(), isEmpty);
  });

  test(
    'L4: снапшот инвестиции содержит lockedBalances, счёт — пусто',
    () async {
      final id = await repository.create(draft(opening: 100000));
      await repository.recordValuation(
        AssetValuationDraft(
          assetId: id,
          effectiveOn: LocalDate(2026, 1, 2),
          value: const Money(minorUnits: 10000, currencyCode: 'USD'),
          rateToRub: Decimal.fromInt(90),
        ),
      );
      await repository.recordValuation(
        AssetValuationDraft(
          assetId: id,
          effectiveOn: LocalDate(2026, 1, 2),
          value: const Money(minorUnits: 500, currencyCode: 'EUR'),
          rateToRub: Decimal.fromInt(100),
        ),
      );
      await repository.setLockedAmount(
        id,
        'USD',
        const Money(minorUnits: 9900, currencyCode: 'USD'),
      );
      await repository.setLockedAmount(
        id,
        'EUR',
        const Money(minorUnits: 500, currencyCode: 'EUR'),
      );

      final snapshot = await repository.getById(id);
      expect(
        snapshot.currentValue,
        const Money(minorUnits: 100000, currencyCode: 'RUB'),
      );
      expect(
        snapshot.locked,
        unorderedEquals(const [
          Money(minorUnits: 9900, currencyCode: 'USD'),
          Money(minorUnits: 500, currencyCode: 'EUR'),
        ]),
      );

      final all = await repository.watchAll().first;
      expect(all.single.locked, unorderedEquals(snapshot.locked));

      final accountId = await createAccount(db, openingValueMinor: 100);
      final account = await repository.getById(accountId);
      expect(account.lockedBalances, isNull);
      expect(account.locked, isEmpty);
    },
  );

  test(
    'L3: referenceCounts не считает отметки, deleteIfUnused чистит их',
    () async {
      final id = await repository.create(draft(opening: 100000));
      await repository.setLockedAmount(
        id,
        'RUB',
        const Money(minorUnits: 50000, currencyCode: 'RUB'),
      );

      final counts = await repository.referenceCounts(id);
      expect(counts.isUsed, isFalse);
      expect(await db.select(db.investmentLockedAmounts).get(), hasLength(1));

      await repository.deleteIfUnused(id);

      expect(await db.select(db.investmentLockedAmounts).get(), isEmpty);
      expect(await db.assetsDao.findById(id), isNull);
    },
  );
}

Matcher _lockedFailure(String fieldKey) => isA<DomainException>().having(
  (error) => error.fieldErrors['amount'],
  'fieldErrors[amount]',
  fieldKey,
);
