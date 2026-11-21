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
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late RecurringRulesViewModel vm;

  setUp(() {
    db = openTestDatabase();
    vm = RecurringRulesViewModel(
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
  });

  tearDown(() async {
    vm.dispose();
    await db.close();
  });

  Future<void> settle() => pumpEventQueue(times: 50);

  test('пустой список и следующий платёж после маркера', () async {
    final property = await createProperty(db);
    vm.init();
    await settle();
    expect((vm.state.value as ViewData<List<RecurringRule>>).value, isEmpty);

    final category = await categoryId(db, CashflowKind.expense);
    final ruleId = await db.recurringDao.create(
      RecurringRuleInput(
        strategy: RecurringStrategy.fixed,
        kind: CashflowKind.expense,
        categoryId: category,
        amountMinor: 100000,
        currencyCode: 'RUB',
        propertyId: property,
        affectsBalance: false,
        startDate: LocalDate(2026, 9, 15),
      ),
    );
    await settle();

    final rules = (vm.state.value as ViewData<List<RecurringRule>>).value;
    expect(rules, hasLength(1));
    expect(vm.categoryName(category), isNotEmpty);
    expect(vm.formatAmount(rules.single), contains('1'));
    expect(vm.nextPayment(rules.single), LocalDate(2026, 9, 15));
    expect(vm.currencies.value, isNotEmpty);
    expect(vm.categoryNames.value, isNotEmpty);
    expect(vm.assets.value, isNotEmpty);
    expect(vm.assetName(rules.single), 'Квартира');

    await db.recurringDao.updateLastGeneratedPeriod(ruleId, '2026-11');
    await settle();
    final updated = (vm.state.value as ViewData<List<RecurringRule>>).value;
    expect(vm.nextPayment(updated.single), LocalDate(2026, 12, 15));
  });

  test('валютное правило без курса помечается ожидающим', () async {
    final account = await createAccount(
      db,
      name: 'Валютный',
      currencyCode: 'USD',
    );
    final category = await categoryId(db, CashflowKind.income);
    final ruleId = await db.recurringDao.create(
      RecurringRuleInput(
        strategy: RecurringStrategy.fixed,
        kind: CashflowKind.income,
        categoryId: category,
        amountMinor: 100000,
        currencyCode: 'USD',
        accountId: account,
        affectsBalance: true,
        startDate: LocalDate(2026, 11, 1),
      ),
    );

    vm.init();
    await settle();

    expect(vm.ratePending.value, {ruleId});
    final rules = (vm.state.value as ViewData<List<RecurringRule>>).value;
    expect(vm.isAuto(rules.single), isFalse);
  });
}
