import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/recurring_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/categories/data/category_repository_impl.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/data/recurring_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_screen.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_section.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AppLocalizations l10n;

  setUp(() async {
    db = openTestDatabase();
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  tearDown(() async {
    await db.close();
  });

  RecurringRulesViewModel viewModel() => RecurringRulesViewModel(
    repository: RecurringRepositoryImpl(db.recurringDao),
    categoryRepository: CategoryRepositoryImpl(db.referencesDao),
    currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
    assetRepository: AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
    ),
    rateRepository: ExchangeRateRepositoryImpl(
      db.currenciesDao,
      CbrExchangeRateClient(),
    ),
    today: LocalDate(2026, 11, 17),
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: child,
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 20));
    });
  }

  Future<int> createRule({
    required int propertyId,
    String currencyCode = 'RUB',
    int? accountId,
    bool affectsBalance = false,
  }) async {
    final category = await categoryId(db, CashflowKind.expense);
    return db.recurringDao.create(
      RecurringRuleInput(
        strategy: RecurringStrategy.fixed,
        kind: CashflowKind.expense,
        categoryId: category,
        amountMinor: 100000,
        currencyCode: currencyCode,
        propertyId: accountId == null ? propertyId : null,
        accountId: accountId,
        affectsBalance: affectsBalance,
        startDate: LocalDate(2026, 9, 15),
      ),
    );
  }

  testWidgets('пустой список предлагает добавить платёж', (tester) async {
    await pump(
      tester,
      RecurringRulesScreen(viewModel: viewModel(), onTabChanged: (_) {}),
    );

    expect(find.text(l10n.recurringEmpty), findsOneWidget);
    expect(find.text(l10n.recurringEmptyHint), findsOneWidget);
    expect(find.text(l10n.recurringAdd), findsWidgets);
  });

  testWidgets('список показывает правило и ожидание курса', (tester) async {
    final property = await createProperty(db);
    final account = await createAccount(
      db,
      name: 'Валютный',
      currencyCode: 'USD',
    );
    await createRule(propertyId: property);
    await createRule(
      propertyId: property,
      currencyCode: 'USD',
      accountId: account,
    );

    await pump(
      tester,
      RecurringRulesScreen(viewModel: viewModel(), onTabChanged: (_) {}),
    );

    expect(find.text(l10n.recurringEmpty), findsNothing);
    expect(find.textContaining(l10n.recurringPendingRate), findsOneWidget);
    expect(find.textContaining('·'), findsWidgets);
  });

  testWidgets('секция актива показывает правило и CTA, архив — только чтение', (
    tester,
  ) async {
    final property = await createProperty(db);
    await createRule(propertyId: property);

    await pump(
      tester,
      AppScaffold(
        body: AppListView(
          children: [
            RecurringRulesSection(
              repository: RecurringRepositoryImpl(db.recurringDao),
              categoryRepository: CategoryRepositoryImpl(db.referencesDao),
              currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
              rateRepository: ExchangeRateRepositoryImpl(
                db.currenciesDao,
                CbrExchangeRateClient(),
              ),
              assetId: property,
              isAccount: false,
              today: LocalDate(2026, 11, 17),
            ),
          ],
        ),
      ),
    );

    expect(find.text(l10n.recurringTitle), findsOneWidget);
    expect(find.text(l10n.recurringAdd), findsOneWidget);
    expect(
      tester.widget<AppListTile>(find.byType(AppListTile)).onTap,
      isNotNull,
    );

    await pump(
      tester,
      AppScaffold(
        body: AppListView(
          children: [
            RecurringRulesSection(
              repository: RecurringRepositoryImpl(db.recurringDao),
              categoryRepository: CategoryRepositoryImpl(db.referencesDao),
              currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
              rateRepository: ExchangeRateRepositoryImpl(
                db.currenciesDao,
                CbrExchangeRateClient(),
              ),
              assetId: property,
              isAccount: false,
              today: LocalDate(2026, 11, 17),
              readOnly: true,
            ),
          ],
        ),
      ),
    );

    expect(find.text(l10n.recurringAdd), findsNothing);
    expect(tester.widget<AppListTile>(find.byType(AppListTile)).onTap, isNull);
  });
}
