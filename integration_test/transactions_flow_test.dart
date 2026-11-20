import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/core/database/database_fixtures.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('пополнение счёта и перевод между счетами', (tester) async {
    final l10n = await loadL10n();
    final db = openE2eDatabase();
    await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
    await createAccount(db, name: 'Основной', openingValueMinor: 100000);
    await createAccount(db, name: 'Резерв', openingValueMinor: 50000);
    final locator = await pumpApp(tester, database: db);

    await openAssets(tester, l10n);
    expect(find.text('Основной'), findsOneWidget);
    await tester.tap(find.text('Основной'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.transactionAddDeposit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '500');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();
    expect(find.textContaining('1\u00A0500'), findsWidgets);

    await tester.tap(find.text(l10n.transferAction));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '200');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();
    expect(find.textContaining('1\u00A0300'), findsWidgets);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await openOperations(tester, l10n);
    await tester.tap(find.text(l10n.operationsTransactionsTab));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(l10n.transactionKindTransferOut),
      findsOneWidget,
    );

    await shutdownApp(tester, locator);
  });
}
