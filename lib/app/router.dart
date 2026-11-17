import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_manage_screen.dart';
import 'package:finanseapp/core/features/home/ui/home_screen.dart';
import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:go_router/go_router.dart';

/// Единая точка маршрутизации приложения (go_router).
/// Системный BACK перехватывается в `ApplockBackDispatcher` на уровне
/// MaterialApp (см. app.dart), а не здесь: go_router не принимает диспетчер.
GoRouter buildRouter({required ServiceLocator locator}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            HomeScreen(viewModel: locator.get<HomeViewModel>()),
      ),
      GoRoute(
        path: AppRoutes.applockManage,
        builder: (context, state) => ApplockManageScreen(
          viewModel: locator.get<ApplockSettingsViewModel>(),
        ),
      ),
    ],
  );
}
