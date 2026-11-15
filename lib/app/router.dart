import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/home/ui/home_screen.dart';
import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:go_router/go_router.dart';

/// Единая точка маршрутизации приложения (go_router).
GoRouter buildRouter({required ServiceLocator locator}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            HomeScreen(viewModel: locator.get<HomeViewModel>()),
      ),
    ],
  );
}
