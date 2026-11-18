import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/app_database_path.dart';
import 'package:finanseapp/core/database/daos/assets_dao.dart';
import 'package:finanseapp/core/database/daos/audit_dao.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/database/daos/goals_dao.dart';
import 'package:finanseapp/core/database/daos/references_dao.dart';
import 'package:finanseapp/core/database/daos/settings_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/database/daos/valuations_dao.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/assets/data/subgroup_repository_impl.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';
import 'package:finanseapp/core/features/categories/data/category_repository_impl.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/categories/ui/categories_view_model.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/ui/base_currency_view_model.dart';
import 'package:finanseapp/core/features/currencies/ui/currencies_view_model.dart';
import 'package:finanseapp/core/features/currencies/ui/currency_form_view_model.dart';
import 'package:finanseapp/core/features/references/ui/subgroups_view_model.dart';
import 'package:finanseapp/core/features/settings/data/settings_repository_impl.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';

/// Регистрирует БД, DAO и общие presentation-сервисы.
///
/// Feature-repositories регистрируются в своих задачах вместе с реализациями
/// (3.3 создаёт только контракты). [database] подменяется в тестах.
Future<ServiceLocator> registerCoreServices(
  ServiceLocator locator, {
  AppDatabase? database,
}) async {
  final db = database ?? openAppDatabase();

  locator.register<AppDatabase>(db, dispose: (value) => value.close());
  locator.register<AssetsDao>(db.assetsDao);
  locator.register<ValuationsDao>(db.valuationsDao);
  locator.register<TransactionsDao>(db.transactionsDao);
  locator.register<CashflowDao>(db.cashflowDao);
  locator.register<ReferencesDao>(db.referencesDao);
  locator.register<CurrenciesDao>(db.currenciesDao);
  locator.register<GoalsDao>(db.goalsDao);
  locator.register<SettingsDao>(db.settingsDao);
  locator.register<AuditDao>(db.auditDao);

  locator.register<SubgroupRepository>(
    SubgroupRepositoryImpl(db.referencesDao),
  );
  locator.registerFactory<SubgroupsViewModel>(
    () => SubgroupsViewModel(repository: locator.get<SubgroupRepository>()),
  );

  locator.register<CbrExchangeRateClient>(CbrExchangeRateClient());
  locator.register<AssetRepository>(
    AssetRepositoryImpl(db.assetsDao, db.transactionsDao, db.valuationsDao),
  );
  locator.registerFactory<AssetsViewModel>(
    () => AssetsViewModel(repository: locator.get<AssetRepository>()),
  );

  locator.register<CurrencyRepository>(
    CurrencyRepositoryImpl(db.currenciesDao),
  );
  locator.register<ExchangeRateRepository>(
    ExchangeRateRepositoryImpl(
      db.currenciesDao,
      locator.get<CbrExchangeRateClient>(),
    ),
  );
  locator.register<SettingsRepository>(SettingsRepositoryImpl(db.settingsDao));
  locator.registerFactory<CurrenciesViewModel>(
    () => CurrenciesViewModel(
      repository: locator.get<CurrencyRepository>(),
      settingsRepository: locator.get<SettingsRepository>(),
    ),
  );
  locator.registerFactory<CurrencyFormViewModel>(
    () => CurrencyFormViewModel(repository: locator.get<CurrencyRepository>()),
  );
  locator.register<CategoryRepository>(
    CategoryRepositoryImpl(db.referencesDao),
  );
  locator.registerFactory<CategoriesViewModel>(
    () => CategoriesViewModel(repository: locator.get<CategoryRepository>()),
  );
  locator.registerFactory<BaseCurrencyViewModel>(
    () => BaseCurrencyViewModel(
      currencyRepository: locator.get<CurrencyRepository>(),
      settingsRepository: locator.get<SettingsRepository>(),
    ),
  );

  locator.register<MoneyFormatter>(const MoneyFormatter());
  locator.register<DateFormatter>(const DateFormatter());

  return locator;
}
