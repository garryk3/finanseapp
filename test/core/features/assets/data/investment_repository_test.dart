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
