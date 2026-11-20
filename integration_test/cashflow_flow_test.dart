import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/core/database/database_fixtures.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('расход и доход создаются через форму', (tester) async {
    final l10n = await loadL10n();
    final db = openE2eDatabase();
    await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
    await createAccount(db, name: 'Основной', openingValueMinor: 100000);
    final locator = await pumpApp(tester, database: db);
    await openOperations(tester, l10n);

    await _addCashflow(tester, l10n, amount: '500', category: 'Питание');
    expect(find.text('Питание'), findsOneWidget);

    await _addCashflow(
      tester,
      l10n,
      amount: '1000',
      category: 'Зарплата',
      income: true,
    );
    expect(find.text('Зарплата'), findsOneWidget);
    expect(find.text(l10n.cashflowIncome), findsWidgets);

    // Расход со списанием со счёта создаёт связанную операцию (BR-IE).
    await tester.tap(find.byTooltip(l10n.cashflowAdd));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '300');
    await tester.tap(find.text(l10n.cashflowAffectsBalance));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.cashflowAccountHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Основной').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('—').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Питание').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    await openAssets(tester, l10n);
    await tester.tap(find.text('Основной'));
    await tester.pumpAndSettle();
    expect(find.textContaining('700'), findsWidgets);

    await shutdownApp(tester, locator);
  });
}

Future<void> _addCashflow(
  WidgetTester tester,
  AppLocalizations l10n, {
  required String amount,
  required String category,
  bool income = false,
}) async {
  await tester.tap(find.byTooltip(l10n.cashflowAdd));
  await tester.pumpAndSettle();
  if (income) {
    await tester.tap(find.text(l10n.cashflowIncome));
    await tester.pumpAndSettle();
  }
  await tester.enterText(find.byType(TextField).first, amount);
  await tester.tap(find.text('—').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(category).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.commonSave));
  await tester.pumpAndSettle();
}
