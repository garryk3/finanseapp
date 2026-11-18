import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AssetTransactionRepositoryImpl repository;
  late AssetRepositoryImpl assets;
  late int fromId;
  late int toId;

  setUp(() async {
    db = openTestDatabase();
    repository = AssetTransactionRepositoryImpl(db);
    assets = AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
    );
    fromId = await createAccount(db, name: 'Счёт А', openingValueMinor: 500000);
    toId = await createAccount(db, name: 'Счёт Б', openingValueMinor: 0);
  });

  tearDown(() async {
    await db.close();
  });

  TransferDraft draft({int amount = 100000, int? destination}) => TransferDraft(
    fromAccountId: fromId,
    toAccountId: toId,
    amount: Money(minorUnits: amount, currencyCode: 'RUB'),
    destinationAmount: Money(
      minorUnits: destination ?? amount,
      currencyCode: 'RUB',
    ),
    occurredOn: LocalDate(2026, 1, 2),
    fromRateToRub: Decimal.one,
    toRateToRub: Decimal.one,
  );

  test('перевод двигает оба баланса и не создаёт денежный поток', () async {
    await repository.transfer(draft());

    expect((await assets.getById(fromId)).currentValue.minorUnits, 400000);
    expect((await assets.getById(toId)).currentValue.minorUnits, 100000);
    expect(await db.select(db.cashflowEntries).get(), isEmpty);
    final legs = await db.transactionsDao.allRows();
    expect(legs, hasLength(2));
    expect(legs.map((leg) => leg.transferId).toSet(), hasLength(1));
    expect(
      legs.every((leg) => leg.occurredOn == LocalDate(2026, 1, 2)),
      isTrue,
    );
  });

  test('одинаковые счета и нехватка средств отклоняются без следов', () async {
    await expectLater(
      repository.transfer(
        TransferDraft(
          fromAccountId: fromId,
          toAccountId: fromId,
          amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
          destinationAmount: const Money(
            minorUnits: 100000,
            currencyCode: 'RUB',
          ),
          occurredOn: LocalDate(2026, 1, 2),
          fromRateToRub: Decimal.one,
          toRateToRub: Decimal.one,
        ),
      ),
      throwsA(isA<DomainException>()),
    );

    await expectLater(
      repository.transfer(draft(amount: 600000)),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.negativeBalance,
        ),
      ),
    );

    expect(await db.transactionsDao.allRows(), isEmpty);
  });
}
