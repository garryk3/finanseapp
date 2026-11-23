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
      db.currenciesDao,
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

  test('кросс-валютный перевод пишет независимые RUB snapshot', () async {
    final usdId = await createAccount(
      db,
      name: 'USD',
      currencyCode: 'USD',
      openingValueMinor: 100000,
    );
    final eurId = await createAccount(
      db,
      name: 'EUR',
      currencyCode: 'EUR',
      openingValueMinor: 0,
    );

    await repository.transfer(
      TransferDraft(
        fromAccountId: usdId,
        toAccountId: eurId,
        amount: const Money(minorUnits: 1000, currencyCode: 'USD'),
        destinationAmount: const Money(minorUnits: 900, currencyCode: 'EUR'),
        occurredOn: LocalDate(2026, 1, 2),
        fromRateToRub: Decimal.fromInt(90),
        toRateToRub: Decimal.fromInt(100),
      ),
    );

    final legs = await db.transactionsDao.allRows();
    final out = legs.firstWhere(
      (leg) => leg.kind == AssetTransactionKind.transferOut,
    );
    final incoming = legs.firstWhere(
      (leg) => leg.kind == AssetTransactionKind.transferIn,
    );
    expect(out.amountRubMinor, 90000);
    expect(incoming.amountRubMinor, 90000);
    expect((await assets.getById(usdId)).currentValue.minorUnits, 99000);
    expect((await assets.getById(eurId)).currentValue.minorUnits, 900);
  });

  test('restore перевода восстанавливает обе ноги', () async {
    final transferId = await repository.transfer(draft());
    await repository.softDeleteTransfer(transferId);

    await repository.restoreTransfer(transferId);

    final legs = await db.select(db.assetTransactions).get();
    expect(legs.where((leg) => leg.transferId == transferId), hasLength(2));
    expect(legs.every((leg) => leg.deletedAt == null), isTrue);
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
