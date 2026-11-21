import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../database/database_fixtures.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> add(
    int accountId,
    AssetTransactionKind kind,
    int amountMinor,
    LocalDate date,
  ) => db.transactionsDao.create(
    AssetTransactionInput(
      assetId: accountId,
      kind: kind,
      amountMinor: amountMinor,
      occurredOn: date,
      rateToRub: Decimal.one,
      amountRubMinor: amountMinor,
    ),
  );

  test('opening + операции на дату, soft-deleted исключены', () async {
    final account = await createAccount(db, openingValueMinor: 100000);
    await add(
      account,
      AssetTransactionKind.deposit,
      50000,
      LocalDate(2026, 1, 10),
    );
    final deleted = await add(
      account,
      AssetTransactionKind.deposit,
      9999,
      LocalDate(2026, 1, 15),
    );
    await db.transactionsDao.softDelete(deleted);
    await add(
      account,
      AssetTransactionKind.withdrawal,
      20000,
      LocalDate(2026, 1, 20),
    );
    await add(
      account,
      AssetTransactionKind.deposit,
      10000,
      LocalDate(2026, 2, 1),
    );

    expect(
      await db.transactionsDao.balanceAsOfMinor(account, LocalDate(2026, 1, 9)),
      100000,
    );
    expect(
      await db.transactionsDao.balanceAsOfMinor(
        account,
        LocalDate(2026, 1, 10),
      ),
      150000,
    );
    expect(
      await db.transactionsDao.balanceAsOfMinor(
        account,
        LocalDate(2026, 1, 19),
      ),
      150000,
    );
    expect(
      await db.transactionsDao.balanceAsOfMinor(
        account,
        LocalDate(2026, 1, 20),
      ),
      130000,
    );
    expect(
      await db.transactionsDao.balanceAsOfMinor(account, LocalDate(2026, 2, 1)),
      140000,
    );
  });

  test('несуществующий счёт — notFound', () async {
    await expectLater(
      db.transactionsDao.balanceAsOfMinor(999, LocalDate(2026, 1, 1)),
      throwsA(isA<DomainException>()),
    );
  });
}
