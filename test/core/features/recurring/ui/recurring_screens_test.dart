import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/recurring_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/categories/data/category_repository_impl.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/data/recurring_repository_impl.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_screen.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_section.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../database/database_fixtures.dart';

final class _FakeAutoRepository implements RecurringRepository {
  _FakeAutoRepository(this.rule, this.amount, this.date);

  final RecurringRule rule;
  final Money amount;
  final LocalDate date;

  @override
  Stream<List<RecurringRule>> watchByAccount(int accountId) =>
      Stream.value([rule]);

  @override
  Future<({Money amount, LocalDate date})?> lastGenerated(int ruleId) async =>
      (amount: amount, date: date);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _EmptyAutoRepository implements RecurringRepository {
  @override
  Stream<List<RecurringRule>> watchByAccount(int accountId) =>
      Stream.value(const []);

  @override
  Future<({Money amount, LocalDate date})?> lastGenerated(int ruleId) async =>
      null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

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

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(900, 1600),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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

  testWidgets('справочники обновляют строку без перезахода', (tester) async {
    final property = await createProperty(db);
    final ruleId = await createRule(propertyId: property);
    final rule = await db.recurringDao.getById(ruleId);
    final vm = viewModel();

    await pump(
      tester,
      RecurringRulesScreen(viewModel: vm, onTabChanged: (_) {}),
    );

    vm.categoryNames.value = {rule.categoryId: 'Новая категория'};
    vm.assets.value = {
      property: PropertyAsset(
        id: property,
        name: 'Новый объект',
        currencyCode: 'RUB',
        openingValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
        createdAt: DateTime.utc(2026),
      ),
    };
    vm.ratePending.value = {ruleId};
    await tester.pump();

    expect(find.text('Новая категория'), findsOneWidget);
    expect(find.textContaining('Новый объект'), findsOneWidget);
    expect(find.textContaining(l10n.recurringPendingRate), findsOneWidget);
  });

  testWidgets('автоправило в списке показывает чип Авто без дубля названия', (
    tester,
  ) async {
    final account = await createAccount(db, name: 'Вклад');
    final category = await categoryId(db, CashflowKind.income);
    await db
        .into(db.recurringCashflowRules)
        .insert(
          RecurringCashflowRulesCompanion.insert(
            strategy: RecurringStrategy.depositInterest,
            kind: CashflowKind.income,
            categoryId: category,
            currencyCode: 'RUB',
            accountId: Value(account),
            affectsBalance: true,
            startDate: LocalDate(2026, 1, 15),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    await pump(
      tester,
      RecurringRulesScreen(viewModel: viewModel(), onTabChanged: (_) {}),
    );

    expect(
      find.textContaining(l10n.recurringAutoInterestTitle),
      findsOneWidget,
    );
    expect(find.text(l10n.recurringAutoChip), findsOneWidget);
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

  testWidgets('карточка процентов показывает ставку и последнее начисление', (
    tester,
  ) async {
    final rule = RecurringRule(
      id: 1,
      strategy: RecurringStrategy.depositInterest,
      kind: CashflowKind.income,
      categoryId: 1,
      currencyCode: 'RUB',
      accountId: 1,
      affectsBalance: true,
      startDate: LocalDate(2026, 1, 15),
      lastGeneratedPeriod: '2026-11',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final account = AccountAsset(
      id: 1,
      name: 'Вклад',
      currencyCode: 'RUB',
      openingValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
      createdAt: DateTime.utc(2026),
      bankId: 1,
      annualRate: Decimal.parse('12'),
      startDate: LocalDate(2026, 1, 15),
    );
    final repository = _FakeAutoRepository(
      rule,
      const Money(minorUnits: 102010, currencyCode: 'RUB'),
      LocalDate(2026, 4, 15),
    );

    await pump(
      tester,
      AppScaffold(
        body: AppListView(
          children: [
            RecurringRulesSection(
              repository: repository,
              categoryRepository: CategoryRepositoryImpl(db.referencesDao),
              currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
              rateRepository: ExchangeRateRepositoryImpl(
                db.currenciesDao,
                CbrExchangeRateClient(),
              ),
              assetId: 1,
              isAccount: true,
              today: LocalDate(2026, 11, 17),
              account: account,
            ),
          ],
        ),
      ),
      size: const Size(320, 900),
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.recurringAutoChip), findsOneWidget);
    expect(find.textContaining('12% годовых'), findsOneWidget);
    expect(find.text('${l10n.recurringLastAccrualLabel}:'), findsOneWidget);
    expect(find.textContaining('15.04.2026'), findsOneWidget);
    expect(
      find.textContaining(l10n.recurringNextAccrual('15.12.2026')),
      findsOneWidget,
    );
  });

  testWidgets('архивный вклад показывает остановку начислений', (tester) async {
    final rule = RecurringRule(
      id: 1,
      strategy: RecurringStrategy.depositInterest,
      kind: CashflowKind.income,
      categoryId: 1,
      currencyCode: 'RUB',
      accountId: 1,
      affectsBalance: true,
      startDate: LocalDate(2026, 1, 15),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final account = AccountAsset(
      id: 1,
      name: 'Вклад',
      currencyCode: 'RUB',
      openingValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
      createdAt: DateTime.utc(2026),
      bankId: 1,
      annualRate: Decimal.parse('12'),
      startDate: LocalDate(2026, 1, 15),
      archivedAt: DateTime.utc(2026, 2, 1),
    );

    await pump(
      tester,
      AppScaffold(
        body: AppListView(
          children: [
            RecurringRulesSection(
              repository: _FakeAutoRepository(
                rule,
                const Money(minorUnits: 102010, currencyCode: 'RUB'),
                LocalDate(2026, 4, 15),
              ),
              categoryRepository: CategoryRepositoryImpl(db.referencesDao),
              currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
              rateRepository: ExchangeRateRepositoryImpl(
                db.currenciesDao,
                CbrExchangeRateClient(),
              ),
              assetId: 1,
              isAccount: true,
              today: LocalDate(2026, 11, 17),
              account: account,
              readOnly: true,
            ),
          ],
        ),
      ),
    );

    expect(find.text(l10n.recurringAccrualStoppedArchive), findsOneWidget);
    expect(tester.widget<AppCard>(find.byType(AppCard)).onTap, isNull);
  });

  testWidgets('недоступное автоправило не обещает начислений', (tester) async {
    final account = AccountAsset(
      id: 1,
      name: 'Вклад',
      currencyCode: 'RUB',
      openingValue: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
      createdAt: DateTime.utc(2026),
      bankId: 1,
      annualRate: Decimal.parse('12'),
      startDate: LocalDate(2026, 1, 15),
    );

    await pump(
      tester,
      AppScaffold(
        body: AppListView(
          children: [
            RecurringRulesSection(
              repository: _EmptyAutoRepository(),
              categoryRepository: CategoryRepositoryImpl(db.referencesDao),
              currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
              rateRepository: ExchangeRateRepositoryImpl(
                db.currenciesDao,
                CbrExchangeRateClient(),
              ),
              assetId: 1,
              isAccount: true,
              today: LocalDate(2026, 11, 17),
              account: account,
            ),
          ],
        ),
      ),
    );

    expect(find.text(l10n.recurringAccrualUnavailable), findsOneWidget);
  });

  testWidgets('валютный вклад без курса показывает ожидание', (tester) async {
    final rule = RecurringRule(
      id: 1,
      strategy: RecurringStrategy.depositInterest,
      kind: CashflowKind.income,
      categoryId: 1,
      currencyCode: 'USD',
      accountId: 1,
      affectsBalance: true,
      startDate: LocalDate(2026, 1, 15),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final account = AccountAsset(
      id: 1,
      name: 'Валютный вклад',
      currencyCode: 'USD',
      openingValue: const Money(minorUnits: 10000000, currencyCode: 'USD'),
      createdAt: DateTime.utc(2026),
      bankId: 1,
      annualRate: Decimal.parse('12'),
      startDate: LocalDate(2026, 1, 15),
    );

    await pump(
      tester,
      AppScaffold(
        body: AppListView(
          children: [
            RecurringRulesSection(
              repository: _FakeAutoRepository(
                rule,
                const Money(minorUnits: 100000, currencyCode: 'USD'),
                LocalDate(2026, 1, 15),
              ),
              categoryRepository: CategoryRepositoryImpl(db.referencesDao),
              currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
              rateRepository: ExchangeRateRepositoryImpl(
                db.currenciesDao,
                CbrExchangeRateClient(),
              ),
              assetId: 1,
              isAccount: true,
              today: LocalDate(2026, 11, 17),
              account: account,
            ),
          ],
        ),
      ),
    );

    expect(find.textContaining(l10n.recurringPendingRate), findsOneWidget);
  });
}
