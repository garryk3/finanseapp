import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_back_dispatcher.dart';
import 'package:finanseapp/core/features/applock/ui/applock_gate.dart';
import 'package:finanseapp/core/features/applock/ui/applock_screen.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes.dart';

void main() {
  Future<ApplockController> lockedController(TestApplockHarness harness) async {
    final controller = ApplockController(
      service: harness.service,
      clock: () => harness.now,
    );
    await controller.init();
    return controller;
  }

  testWidgets('лок перекрывает содержимое, unlock убирает экран блокировки', (
    tester,
  ) async {
    final harness = TestApplockHarness();
    await harness.enable('1234');
    final controller = await lockedController(harness);
    final viewModel = ApplockViewModel(
      service: harness.service,
      biometrics: FakeBiometricGateway(),
      controller: controller,
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));

    await tester.pumpWidget(
      applockTestHost(
        AppLockGate(
          controller: controller,
          lockViewModel: viewModel,
          child: const TestChild(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Cold start (BR-Sec-6): лок-скрин поверх содержимого.
    expect(find.byType(ApplockScreen), findsOneWidget);
    expect(find.text('защищённый контент'), findsOneWidget);

    controller.unlock();
    await tester.pumpAndSettle();
    expect(find.byType(ApplockScreen), findsNothing);
    expect(find.text(l10n.appLockLockTitle), findsNothing);
  });

  testWidgets('под локом семантика содержимого скрыта (QA TC-094)', (
    tester,
  ) async {
    final harness = TestApplockHarness();
    await harness.enable('1234');
    final controller = await lockedController(harness);
    final viewModel = ApplockViewModel(
      service: harness.service,
      biometrics: FakeBiometricGateway(),
      controller: controller,
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      applockTestHost(
        AppLockGate(
          controller: controller,
          lockViewModel: viewModel,
          child: const TestChild(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('защищённый контент'), findsNothing);
    expect(find.bySemanticsLabel(l10n.appLockLockTitle), findsWidgets);

    controller.unlock();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('защищённый контент'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('защита выключена → гейт прозрачен', (tester) async {
    final harness = TestApplockHarness();
    await harness.init();
    final controller = await lockedController(harness);
    final viewModel = ApplockViewModel(
      service: harness.service,
      biometrics: FakeBiometricGateway(),
      controller: controller,
    );

    await tester.pumpWidget(
      applockTestHost(
        AppLockGate(
          controller: controller,
          lockViewModel: viewModel,
          child: const TestChild(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ApplockScreen), findsNothing);
    expect(find.text('защищённый контент'), findsOneWidget);
  });

  testWidgets('системный BACK под локом не снимает маршрут (BR-Sec-6)', (
    tester,
  ) async {
    final harness = TestApplockHarness();
    await harness.enable('1234');
    final controller = await lockedController(harness);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AppScaffold(
            body: Center(
              child: AppButton(
                label: 'на второй',
                onPressed: () => context.push('/second'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/second',
          builder: (context, state) => const AppText('второй маршрут'),
        ),
      ],
    );

    await tester.pumpWidget(
      applockTestHost(
        MaterialApp.router(
          routeInformationProvider: router.routeInformationProvider,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: ApplockBackDispatcher(controller),
          localizationsDelegates: const [
            ...GlobalMaterialLocalizations.delegates,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ru')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('на второй'), findsOneWidget);

    // На второй маршрут — back-stack у go_router при context.go пуст,
    // поэтому используем push.
    router.push('/second');
    await tester.pumpAndSettle();
    expect(find.text('второй маршрут'), findsOneWidget);

    // BACK под локом: маршрут остаётся.
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      SystemChannels.navigation.codec.encodeMethodCall(
        const MethodCall('popRoute'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(find.text('второй маршрут'), findsOneWidget);

    // После разблокировки BACK работает как обычно.
    controller.unlock();
    await tester.pumpAndSettle();
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      SystemChannels.navigation.codec.encodeMethodCall(
        const MethodCall('popRoute'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(find.text('на второй'), findsOneWidget);
  });
}

class TestChild extends StatelessWidget {
  const TestChild({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppText('защищённый контент');
  }
}
