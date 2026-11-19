import 'package:finanseapp/app/app_restart.dart';
import 'package:finanseapp/core/database/app_database_path.dart';
import 'package:finanseapp/core/features/backup/data/local_database_backup_service.dart';
import 'package:finanseapp/core/features/backup/data/platform_backup_file_gateway.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:finanseapp/core/features/backup/logic/backup_view_model.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/di/register_core_services.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/applock/data/local_auth_biometric_gateway.dart';
import 'package:finanseapp/core/features/applock/data/secure_storage_applock_storage.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/app_info/ui/not_found_view_model.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/settings/ui/about_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/settings_view_model.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/more_view_model.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppRestartHost(build: buildAppLocator));
}

Future<ServiceLocator> buildAppLocator() async {
  final ServiceLocator locator = ServiceLocator();
  await registerCoreServices(locator);

  final storage = SecureStorageApplockStorage();
  final biometrics = LocalAuthBiometricGateway();
  final service = ApplockService(storage: storage);
  final controller = ApplockController(service: service);
  // Cold start (BR-Sec-6): до runApp известно, показан ли лок-скрин.
  await controller.init();

  locator
    ..registerFactory<DashboardViewModel>(
      () => DashboardViewModel(
        queries: locator.get<AnalyticsQueries>(),
        goalRepository: locator.get<GoalRepository>(),
        assetRepository: locator.get<AssetRepository>(),
        transactionRepository: locator.get<AssetTransactionRepository>(),
        cashflowRepository: locator.get<CashflowRepository>(),
        settingsRepository: locator.get<SettingsRepository>(),
        currencyRepository: locator.get<CurrencyRepository>(),
        rateRepository: locator.get<ExchangeRateRepository>(),
        now: () => LocalDate.fromDateTime(DateTime.now()),
      ),
    )
    ..registerFactory<CashflowViewModel>(
      () => CashflowViewModel(
        repository: locator.get<CashflowRepository>(),
        categoryRepository: locator.get<CategoryRepository>(),
        currencyRepository: locator.get<CurrencyRepository>(),
        assetRepository: locator.get<AssetRepository>(),
        today: LocalDate.fromDateTime(DateTime.now()),
      ),
    )
    ..registerFactory<TransactionsViewModel>(
      () => TransactionsViewModel(
        repository: locator.get<AssetTransactionRepository>(),
        assetRepository: locator.get<AssetRepository>(),
        today: LocalDate.fromDateTime(DateTime.now()),
      ),
    )
    ..registerFactory<GoalsViewModel>(
      () => GoalsViewModel(
        repository: locator.get<GoalRepository>(),
        currencyRepository: locator.get<CurrencyRepository>(),
        assetRepository: locator.get<AssetRepository>(),
        rateRepository: locator.get<ExchangeRateRepository>(),
        now: () => LocalDate.fromDateTime(DateTime.now()),
      ),
    )
    ..registerFactory<AnalyticsViewModel>(
      () => AnalyticsViewModel(
        queries: locator.get<AnalyticsQueries>(),
        settingsRepository: locator.get<SettingsRepository>(),
        currencyRepository: locator.get<CurrencyRepository>(),
        rateRepository: locator.get<ExchangeRateRepository>(),
        categoryRepository: locator.get<CategoryRepository>(),
        now: () => LocalDate.fromDateTime(DateTime.now()),
      ),
    )
    ..registerFactory<SettingsViewModel>(
      () => SettingsViewModel(repository: locator.get<SettingsRepository>()),
    )
    ..registerFactory<AboutViewModel>(AboutViewModel.new)
    ..registerFactory<MoreViewModel>(MoreViewModel.new)
    ..registerFactory<NotFoundViewModel>(NotFoundViewModel.new)
    ..register<ApplockService>(service)
    ..register<ApplockController>(controller)
    ..register<ApplockViewModel>(
      ApplockViewModel(
        service: service,
        biometrics: biometrics,
        controller: controller,
      ),
    )
    ..register<ApplockSettingsViewModel>(
      ApplockSettingsViewModel(service: service, biometrics: biometrics),
    );

  locator.register<BackupServiceFactory>(
    () => LocalDatabaseBackupService(
      databaseProvider: () => locator.get<AppDatabase>(),
      databasePath: appDatabaseFilePath,
      closeDatabase: () => locator.get<AppDatabase>().close(),
      installedSchemaVersion: locator.get<AppDatabase>().schemaVersion,
    ),
  );
  locator.register<BackupViewModel>(
    BackupViewModel(
      locator.get<BackupServiceFactory>(),
      const PlatformBackupFileGateway(),
    ),
    dispose: (value) => value.dispose(),
  );

  return locator;
}
