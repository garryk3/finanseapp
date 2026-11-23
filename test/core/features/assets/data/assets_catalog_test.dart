import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AssetRepositoryImpl repository;
  late int brokerId;
  late int bankId;

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
    bankId = await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> createInvestment({String name = 'Инвестиция'}) =>
      repository.create(
        InvestmentDraft(
          name: name,
          currencyCode: 'RUB',
          openingValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
          brokerId: brokerId,
        ),
      );

  Future<int> createAccount({String name = 'Счёт'}) => repository.create(
    AccountDraft(
      name: name,
      currencyCode: 'RUB',
      openingValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
      bankId: bankId,
      annualRate: Decimal.zero,
      startDate: LocalDate(2026, 1, 1),
    ),
  );

  test('неиспользуемый актив удаляется физически', () async {
    final id = await createInvestment();
    expect(await repository.watchAll().first, hasLength(1));

    await repository.deleteIfUnused(id);

    expect(await repository.watchAll().first, isEmpty);
    await expectLater(repository.getById(id), throwsA(isA<DomainException>()));
  });

  test(
    'актив с оценкой не удаляется, архивируется и скрывается из списка',
    () async {
      final id = await createInvestment();
      await repository.recordValuation(
        AssetValuationDraft(
          assetId: id,
          effectiveOn: LocalDate(2026, 1, 2),
          value: const Money(minorUnits: 150000, currencyCode: 'RUB'),
          rateToRub: Decimal.one,
        ),
      );

      await expectLater(
        repository.deleteIfUnused(id),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.conflict,
          ),
        ),
      );
      expect((await repository.getById(id)).asset.id, id);

      await repository.archive(id);

      expect(await repository.watchAll().first, isEmpty);
      final archived = await repository.watchAll(includeArchived: true).first;
      expect(archived, hasLength(1));
      final asset = (await repository.getById(id)).asset;
      expect(asset.archivedAt, isNotNull);
      expect(asset.archivedAt!.isUtc, isTrue);
      expect(await repository.valuations(id), hasLength(1));
    },
  );

  test('актив с операцией не удаляется, пока операция не удалена', () async {
    final id = await createInvestment();
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: id,
        kind: AssetTransactionKind.deposit,
        amountMinor: 1000,
        occurredOn: LocalDate(2026, 1, 2),
        rateToRub: Decimal.one,
        amountRubMinor: 1000,
      ),
    );

    await expectLater(
      repository.deleteIfUnused(id),
      throwsA(isA<DomainException>()),
    );
    expect((await repository.getById(id)).currentValue.minorUnits, 101000);
  });

  test('актив в цели не удаляется', () async {
    final id = await createInvestment();
    await db.goalsDao.create(
      name: 'Цель',
      category: GoalCategory.investments,
      targetAmountMinor: 1000000,
      currencyCode: 'RUB',
      assetIds: {id},
    );

    await expectLater(
      repository.deleteIfUnused(id),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.conflict,
        ),
      ),
    );
  });

  test('счёт в денежном потоке не удаляется', () async {
    final id = await createAccount();
    final category = (await db.select(db.categories).get()).firstWhere(
      (row) => row.kind == CashflowKind.expense,
    );
    await db.cashflowDao.create(
      CashflowEntryInput(
        kind: CashflowKind.expense,
        categoryId: category.id,
        amountMinor: 1000,
        currencyCode: 'RUB',
        occurredOn: LocalDate(2026, 1, 2),
        rateToRub: Decimal.one,
        amountRubMinor: 1000,
        affectsBalance: true,
        accountId: id,
      ),
    );

    await expectLater(
      repository.deleteIfUnused(id),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.conflict,
        ),
      ),
    );
    expect((await repository.getById(id)).asset.id, id);
  });

  test('watchAll переизлучается после оценки и операции', () async {
    final id = await createInvestment();
    final updated = repository.watchAll().firstWhere(
      (list) => list.isNotEmpty && list.first.currentValue.minorUnits == 155000,
    );

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

    final snapshots = await updated.timeout(const Duration(seconds: 5));
    expect(snapshots.single.currentValue.minorUnits, 155000);
    expect(snapshots.single.asset, isA<InvestmentAsset>());
  });
}
