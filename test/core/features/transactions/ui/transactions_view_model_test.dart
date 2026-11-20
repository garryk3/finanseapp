import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  test('после dispose изменения БД не трогают состояние журнала', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final accountId = await createAccount(db, name: 'Счёт');
    final vm = TransactionsViewModel(
      repository: AssetTransactionRepositoryImpl(db),
      assetRepository: AssetRepositoryImpl(
        db.assetsDao,
        db.transactionsDao,
        db.valuationsDao,
      ),
      today: LocalDate(2026, 11, 17),
    );
    vm.init();
    await pumpEventQueue();
    vm.dispose();
    final state = vm.state.value;

    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: accountId,
        kind: AssetTransactionKind.deposit,
        amountMinor: 100,
        occurredOn: LocalDate(2026, 11, 17),
        rateToRub: Decimal.one,
        amountRubMinor: 100,
      ),
    );
    await pumpEventQueue();

    expect(vm.state.value, same(state));
  });
}
