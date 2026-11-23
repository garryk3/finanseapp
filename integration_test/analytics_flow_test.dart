import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/core/database/database_fixtures.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('аналитика открывается из «Ещё» и переключает период', (
    tester,
  ) async {
    final l10n = await loadL10n();
    final locator = await pumpApp(tester);
    await openMore(tester, l10n);

    await tester.tap(find.text(l10n.analyticsTitle));
    await tester.pumpAndSettle();

    expect(find.text(l10n.analyticsTitle), findsWidgets);
    expect(find.text(l10n.analyticsNoAssetsTitle), findsOneWidget);

    await tester.tap(find.text(l10n.analyticsPeriodYear));
    await tester.pumpAndSettle();

    expect(find.text(l10n.analyticsNoAssetsTitle), findsOneWidget);
    await shutdownApp(tester, locator);
  });

  testWidgets('аналитика показывает денежный поток и категории', (
    tester,
  ) async {
    final l10n = await loadL10n();
    final db = openE2eDatabase();
    await createAccount(db, name: 'Вклад', openingValueMinor: 100000);
    final incomeCategoryId = await categoryId(db, CashflowKind.income);
    final incomeCategoryName = (await (db.select(
      db.categories,
    )..where((row) => row.id.equals(incomeCategoryId))).getSingle()).name;
    await db.cashflowDao.create(
      CashflowEntryInput(
        kind: CashflowKind.income,
        categoryId: incomeCategoryId,
        amountMinor: 100000,
        currencyCode: 'RUB',
        occurredOn: db.today(),
        rateToRub: Decimal.one,
        amountRubMinor: 100000,
        affectsBalance: false,
      ),
    );
    final locator = await pumpApp(tester, database: db);
    await openMore(tester, l10n);
    await tester.tap(find.text(l10n.analyticsTitle));
    await tester.pumpAndSettle();

    expect(find.text(l10n.analyticsCashflowTitle), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(l10n.analyticsCategoriesTitle),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(l10n.analyticsCategoriesTitle), findsOneWidget);
    await tester.drag(
      find.text(l10n.analyticsCategoriesTitle),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.analyticsCategoriesEmptyExpense), findsOneWidget);
    final incomeTab = find.descendant(
      of: find.byType(AppSegmentedControl<CashflowKind>),
      matching: find.text(l10n.analyticsCashflowIncome),
    );
    expect(incomeTab, findsOneWidget);
    await tester.tap(incomeTab);
    await tester.pumpAndSettle();
    expect(find.text(incomeCategoryName), findsOneWidget);
    expect(find.text(l10n.analyticsNoAssetsTitle), findsNothing);

    await shutdownApp(tester, locator);
  });
}
