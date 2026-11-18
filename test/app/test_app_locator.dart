import 'package:finanseapp/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanseapp/core/di/register_core_services.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/app_info/ui/not_found_view_model.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/more_view_model.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';

import '../core/database/database_fixtures.dart';
import '../core/features/applock/fakes.dart';

/// Locator для widget-тестов: in-memory БД, fake-защита, factory ViewModel.
Future<ServiceLocator> buildTestLocator({AppDatabase? database}) async {
  final ServiceLocator locator = ServiceLocator();
  await registerCoreServices(locator, database: database ?? openTestDatabase());

  final storage = FakeApplockStorage();
  final biometrics = FakeBiometricGateway();
  final service = ApplockService(storage: storage);
  final controller = ApplockController(service: service);
  await controller.init();

  locator
    ..registerFactory<DashboardViewModel>(DashboardViewModel.new)
    ..registerFactory<CashflowViewModel>(CashflowViewModel.new)
    ..registerFactory<TransactionsViewModel>(
      () => TransactionsViewModel(
        repository: locator.get<AssetTransactionRepository>(),
        assetRepository: locator.get<AssetRepository>(),
        today: LocalDate.fromDateTime(DateTime.now()),
      ),
    )
    ..registerFactory<GoalsViewModel>(GoalsViewModel.new)
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
  return locator;
}
