import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/features/applock/fakes.dart';

/// Собирает locator как в `main.dart`, но на fake-хранилище защиты:
/// fresh install (BR-Sec-7) → защита выключена, гейт прозрачен.
Future<ServiceLocator> buildTestLocator() async {
  final storage = FakeApplockStorage();
  final biometrics = FakeBiometricGateway();
  final service = ApplockService(storage: storage);
  final controller = ApplockController(service: service);
  await controller.init();
  return ServiceLocator()
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
}

void main() {
  testWidgets('Приложение поднимается, домашний экран показывает заголовок', (
    tester,
  ) async {
    final ServiceLocator locator = await buildTestLocator();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('ru'),
    );

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.text(l10n.homeDemoSection), findsOneWidget);
    expect(find.text(l10n.increment), findsOneWidget);
    expect(find.text(l10n.appLockTitle), findsOneWidget);
  });

  testWidgets('Демо-счётчик увеличивается по нажатию', (tester) async {
    final ServiceLocator locator = await buildTestLocator();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('ru'),
    );

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.text('${l10n.counterLabel}: 0'), findsOneWidget);
    await tester.tap(find.text(l10n.increment));
    await tester.pumpAndSettle();
    expect(find.text('${l10n.counterLabel}: 1'), findsOneWidget);
  });

  testWidgets('Переход в управление защитой и обратно', (tester) async {
    final ServiceLocator locator = await buildTestLocator();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('ru'),
    );

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.appLockTitle));
    await tester.pumpAndSettle();
    expect(find.text(l10n.appLockStatusOff), findsOneWidget);

    // context.go не оставляет back-stack — возврат явный.
    final context = tester.element(find.text(l10n.appLockStatusOff));
    GoRouter.of(context).go('/');
    await tester.pumpAndSettle();
    expect(find.text(l10n.homeDemoSection), findsOneWidget);
  });
}
