import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/di/register_core_services.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/applock/data/local_auth_biometric_gateway.dart';
import 'package:finanseapp/core/features/applock/data/secure_storage_applock_storage.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ServiceLocator locator = ServiceLocator();
  await registerCoreServices(locator);

  final storage = SecureStorageApplockStorage();
  final biometrics = LocalAuthBiometricGateway();
  final service = ApplockService(storage: storage);
  final controller = ApplockController(service: service);
  // Cold start (BR-Sec-6): до runApp известно, показан ли лок-скрин.
  await controller.init();

  locator
    ..register<HomeViewModel>(HomeViewModel())
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

  runApp(FinanseApp(locator: locator));
}
