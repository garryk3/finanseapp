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
}
