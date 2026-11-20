import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_screen.dart';
import 'package:finanseapp/core/features/analytics/ui/asset_comparison_screen.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_screen.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/assets_screen.dart';
import 'package:finanseapp/core/features/assets/ui/investment_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/property_form_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_form_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_screen.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goal_details_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goal_form_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goals_screen.dart';
import 'package:finanseapp/core/features/settings/ui/about_screen.dart';
import 'package:finanseapp/core/features/settings/ui/more_screen.dart';
import 'package:finanseapp/core/features/settings/ui/settings_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_form_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transfer_form_screen.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../app/test_app_locator.dart';
import '../core/database/database_fixtures.dart';

void main() {
  testWidgets('320dp/1.3: ключевые routes без overflow и с семантикой', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final db = openTestDatabase();
    await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
    final accountId = await createAccount(
      db,
      name: 'Счёт',
      openingValueMinor: 100000,
    );
    await createAccount(db, name: 'Второй', openingValueMinor: 50000);
    await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: accountId,
        kind: AssetTransactionKind.deposit,
        amountMinor: 10000,
        occurredOn: LocalDate(2026, 11, 17),
        rateToRub: Decimal.one,
        amountRubMinor: 10000,
      ),
    );
    final goalId = await db.goalsDao.create(
      name: 'Цель',
      category: GoalCategory.accounts,
      targetAmountMinor: 200000,
      currencyCode: 'RUB',
      assetIds: {accountId},
    );
    await db.cashflowDao.create(
      CashflowEntryInput(
        kind: CashflowKind.expense,
        categoryId: await categoryId(db, CashflowKind.expense),
        amountMinor: 50000,
        currencyCode: 'RUB',
        occurredOn: LocalDate(2026, 11, 17),
        rateToRub: Decimal.one,
        amountRubMinor: 50000,
        affectsBalance: false,
      ),
    );

    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final locator = await buildTestLocator(database: db);
    addTearDown(locator.reset);
    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.byType(DashboardScreen)));
    final routes = <({String path, Type screen})>[
      (path: AppRoutes.dashboard, screen: DashboardScreen),
      (path: AppRoutes.operations, screen: CashflowScreen),
      (
        path: AppRoutes.operationsTab(tab: 'transactions'),
        screen: TransactionsScreen,
      ),
      (path: AppRoutes.assets, screen: AssetsScreen),
      (
        path: AppRoutes.assetDetailsPath(accountId),
        screen: AccountDetailsScreen,
      ),
      (path: AppRoutes.accountNew, screen: AccountFormScreen),
      (path: AppRoutes.investmentNew, screen: InvestmentFormScreen),
      (path: AppRoutes.propertyNew, screen: PropertyFormScreen),
      (path: AppRoutes.goals, screen: GoalsScreen),
      (path: AppRoutes.goalDetailsPath(goalId), screen: GoalDetailsScreen),
      (path: AppRoutes.goalNew, screen: GoalFormScreen),
      (path: AppRoutes.more, screen: MoreScreen),
      (path: AppRoutes.analytics, screen: AnalyticsScreen),
      (path: AppRoutes.comparison, screen: AssetComparisonScreen),
      (path: AppRoutes.settings, screen: SettingsScreen),
      (path: AppRoutes.about, screen: AboutScreen),
      (path: AppRoutes.cashflowNew, screen: CashflowFormScreen),
      (
        path: AppRoutes.transactionNewFor(accountId),
        screen: TransactionFormScreen,
      ),
      (path: AppRoutes.transferNewFor(accountId), screen: TransferFormScreen),
    ];

    for (final route in routes) {
      router.go(route.path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: route.path);
      expect(find.byType(route.screen), findsOneWidget, reason: route.path);
    }

    router.go(AppRoutes.assets);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byTooltip(l10n.assetsAddAsset), findsOneWidget);

    router.go(AppRoutes.operations);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byTooltip(l10n.cashflowAdd), findsOneWidget);

    router.go(AppRoutes.operationsTab(tab: 'transactions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byTooltip(l10n.transactionsAdd), findsOneWidget);

    router.go(AppRoutes.analytics);
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsScreen), findsOneWidget);

    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    expect(find.text(l10n.backupImport), findsOneWidget);
    expect(find.text(l10n.updateCheck), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
    await locator.reset();
  });
}
