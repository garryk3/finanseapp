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
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AssetRepositoryImpl repository;
  late int bankId;

  setUp(() async {
    db = openTestDatabase();
    repository = AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
    );
    bankId = await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
  });

  tearDown(() async {
    await db.close();
  });

  AccountDraft draft({
    String name = 'Вклад',
    int opening = 10000000,
    String rate = '12',
    LocalDate? end,
    String currency = 'RUB',
  }) => AccountDraft(
    name: name,
    currencyCode: currency,
    openingValue: Money(minorUnits: opening, currencyCode: currency),
    bankId: bankId,
    annualRate: Decimal.parse(rate),
    startDate: LocalDate(2026, 1, 1),
    endDate: end,
  );

  test('CALC-009: opening 1 000 + 250,50 − 100 = 1 150,50', () async {
    final id = await repository.create(draft(opening: 100000));
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: id,
        kind: AssetTransactionKind.deposit,
        amountMinor: 25050,
        occurredOn: LocalDate(2026, 1, 10),
        rateToRub: Decimal.one,
        amountRubMinor: 25050,
      ),
    );
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: id,
        kind: AssetTransactionKind.withdrawal,
        amountMinor: 10000,
        occurredOn: LocalDate(2026, 1, 11),
        rateToRub: Decimal.one,
        amountRubMinor: 10000,
      ),
    );

    final snapshot = await repository.getById(id);

    expect(snapshot.asset, isA<AccountAsset>());
    expect(snapshot.currentValue.minorUnits, 115050);
  });

  test('update меняет счёт и проверяет диапазоны', () async {
    final id = await repository.create(draft());
    await repository.update(id, draft(name: 'Новый', opening: 5000000));

    final snapshot = await repository.getById(id);
    expect(snapshot.asset.name, 'Новый');
    expect(snapshot.currentValue.minorUnits, 5000000);

    await expectLater(
      repository.update(id, draft(rate: '100.01')),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.update(id, draft(end: LocalDate(2025, 12, 31))),
      throwsA(isA<DomainException>()),
    );
  });

  test('смена валюты запрещена при операциях (BR-VAL-8)', () async {
    final id = await repository.create(draft());
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: id,
        kind: AssetTransactionKind.deposit,
        amountMinor: 100,
        occurredOn: LocalDate(2026, 1, 10),
        rateToRub: Decimal.one,
        amountRubMinor: 100,
      ),
    );

    await expectLater(
      repository.update(id, draft(currency: 'USD')),
      throwsA(
        isA<DomainException>().having(
          (error) => error.fieldErrors,
          'fieldErrors',
          containsPair('currencyCode', 'validationCurrencyLocked'),
        ),
      ),
    );
  });

  test('удаление свободного счёта и запрет при ссылках', () async {
    final id = await repository.create(draft());

    await repository.archive(id);
    final archived = await repository.getById(id);
    expect(archived.asset.archivedAt, isNotNull);

    final list = await repository.watchAll().first;
    expect(list.any((snapshot) => snapshot.asset.id == id), isFalse);

    await repository.deleteIfUnused(id);
    expect(
      await repository
          .watchAll(includeArchived: true)
          .first
          .then((items) => items.any((snapshot) => snapshot.asset.id == id)),
      isFalse,
    );

    final used = await repository.create(draft());
    await db.cashflowDao.create(
      CashflowEntryInput(
        kind: CashflowKind.expense,
        categoryId:
            (await (db.select(db.categories)
                      ..where((c) => c.kind.equalsValue(CashflowKind.expense))
                      ..limit(1))
                    .getSingle())
                .id,
        amountMinor: 100,
        currencyCode: 'RUB',
        occurredOn: LocalDate(2026, 1, 10),
        rateToRub: Decimal.one,
        amountRubMinor: 100,
        affectsBalance: true,
        accountId: used,
      ),
    );
    await expectLater(
      repository.deleteIfUnused(used),
      throwsA(isA<DomainException>()),
    );
  });

  test('невалидный draft отклоняется', () async {
    await expectLater(
      repository.create(draft(opening: -1)),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.create(draft(name: '   ')),
      throwsA(isA<DomainException>()),
    );
  });
}
