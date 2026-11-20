import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_operation_list_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../core/database/database_fixtures.dart';

void main() {
  testWidgets('10k операций: журнал строит ограниченное число tile', (
    tester,
  ) async {
    const total = 10000;
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final db = openTestDatabase();
    final accountId = await createAccount(
      db,
      name: 'Счёт',
      openingValueMinor: 100000000,
    );
    final now = db.clock();
    await db.batch((batch) {
      batch.insertAll(db.assetTransactions, [
        for (var i = 0; i < total; i++)
          AssetTransactionsCompanion.insert(
            assetId: accountId,
            kind: AssetTransactionKind.deposit,
            amountMinor: 100,
            occurredOn: LocalDate(2026, 11, 17),
            rateToRub: Decimal.one,
            amountRubMinor: 100,
            revisionNo: 1,
            createdAt: now,
            updatedAt: now,
          ),
      ]);
    });

    final vm = TransactionsViewModel(
      repository: AssetTransactionRepositoryImpl(db),
      assetRepository: AssetRepositoryImpl(
        db.assetsDao,
        db.transactionsDao,
        db.valuationsDao,
      ),
      today: LocalDate(2026, 11, 17),
    );
    addTearDown(db.close);
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: TransactionsScreen(viewModel: vm, onTabChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    expect(find.text(l10n.transactionsEmptyTitle), findsNothing);
    final tiles = find.byType(AppOperationListTile).evaluate().length;
    expect(tiles, greaterThan(0));
    expect(tiles, lessThan(100), reason: 'builder не должен строить 10k tile');
    final list = tester.widget<AppListView>(find.byType(AppListView));
    expect(list.itemBuilder, isNotNull);
    expect(list.itemCount, lessThan(TransactionsViewModel.pageSize * 2 + 2));
    expect(await db.select(db.assetTransactions).get(), hasLength(total));

    vm.loadMore();
    await tester.pumpAndSettle();
    final expanded = tester.widget<AppListView>(find.byType(AppListView));
    expect(expanded.itemCount, greaterThan(TransactionsViewModel.pageSize));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
