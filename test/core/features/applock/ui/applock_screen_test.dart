import 'dart:async';

import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_screen.dart';
import 'package:finanseapp/core/features/applock/ui/pin_keypad.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes.dart';

void main() {
  late TestApplockHarness harness;
  late ApplockController controller;
  late ApplockViewModel viewModel;
  late AppLocalizations l10n;

  setUp(() async {
    harness = TestApplockHarness();
    await harness.enable('1234');
    controller = ApplockController(
      service: harness.service,
      clock: () => harness.now,
    );
    await controller.init();
    viewModel = ApplockViewModel(
      service: harness.service,
      biometrics: FakeBiometricGateway(),
      controller: controller,
    );
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    // Хэширование — в отдельном изоляте (compute): дожидаемся submit.
    await viewModel.submitFuture;
    await tester.pump();
  }

  testWidgets('показывает заголовок и индикатор ввода', (tester) async {
    await tester.pumpWidget(
      applockTestHost(ApplockScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.appLockLockTitle), findsOneWidget);
    expect(find.bySemanticsLabel('Введено 0 из 4'), findsOneWidget);
  });

  testWidgets('неверный PIN показывает ошибку', (tester) async {
    await tester.pumpWidget(
      applockTestHost(ApplockScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await enterPin(tester, '9999');

    expect(find.text(l10n.appLockWrongPin), findsOneWidget);
    expect(controller.locked.value, isTrue);
  });

  testWidgets('верный PIN разблокирует приложение', (tester) async {
    await tester.pumpWidget(
      applockTestHost(ApplockScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await enterPin(tester, '1234');

    expect(controller.locked.value, isFalse);
    expect(find.text(l10n.appLockWrongPin), findsNothing);
  });

  testWidgets('биометрия скрыта при недоступном сенсоре (BR-Sec-4)', (
    tester,
  ) async {
    await tester.pumpWidget(
      applockTestHost(ApplockScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.appLockBiometricUnlock), findsNothing);
  });

  testWidgets('биометрия видна при включённой настройке и доступном сенсоре', (
    tester,
  ) async {
    final bio = FakeBiometricGateway()..available = true;
    await harness.service.setBiometricEnabled(true);
    viewModel = ApplockViewModel(
      service: harness.service,
      biometrics: bio,
      controller: controller,
    );
    await tester.pumpWidget(
      applockTestHost(ApplockScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.appLockBiometricUnlock), findsOneWidget);

    bio.authenticateResult = true;
    await tester.tap(find.text(l10n.appLockBiometricUnlock));
    await tester.pump(const Duration(milliseconds: 100));

    expect(controller.locked.value, isFalse);
  });

  testWidgets('a11y-матрица: 320dp и font scale 1.3 — без overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      applockA11yHost(ApplockScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('авто-биометрия (D21.7)', () {
    ApplockViewModel withBiometrics(FakeBiometricGateway bio) {
      viewModel = ApplockViewModel(
        service: harness.service,
        biometrics: bio,
        controller: controller,
      );
      return viewModel;
    }

    testWidgets('включённая биометрия: авто-вызов разблокирует без PIN', (
      tester,
    ) async {
      final bio = FakeBiometricGateway()
        ..available = true
        ..authenticateResult = true;
      await harness.service.setBiometricEnabled(true);
      withBiometrics(bio);

      await tester.pumpWidget(
        applockTestHost(ApplockScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expect(bio.lastReason, l10n.appLockBiometricReason);
      expect(controller.locked.value, isFalse);
    });

    testWidgets('неудача биометрии показывает клавиатуру PIN', (tester) async {
      final bio = FakeBiometricGateway()..available = true;
      await harness.service.setBiometricEnabled(true);
      withBiometrics(bio);

      await tester.pumpWidget(
        applockTestHost(ApplockScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expect(controller.locked.value, isTrue);
      expect(find.byType(PinKeypad), findsOneWidget);
      expect(find.text(l10n.appLockEnterPin), findsNothing);
    });

    testWidgets(
      'пока идёт биометрия — кнопка «Ввести PIN-код», клавиатуры нет',
      (tester) async {
        final bio = FakeBiometricGateway()
          ..available = true
          ..pending = Completer<bool>();
        await harness.service.setBiometricEnabled(true);
        withBiometrics(bio);

        await tester.pumpWidget(
          applockTestHost(ApplockScreen(viewModel: viewModel)),
        );
        await tester.pump();
        await tester.pump();

        expect(find.byType(PinKeypad), findsNothing);
        expect(find.text(l10n.appLockEnterPin), findsOneWidget);

        await tester.tap(find.text(l10n.appLockEnterPin));
        await tester.pump();

        expect(find.byType(PinKeypad), findsOneWidget);
        expect(viewModel.pinVisible.value, isTrue);

        bio.pending!.complete(false);
        await tester.pumpAndSettle();
      },
    );

    testWidgets('ручной показ PIN не вызывает сенсор повторно', (tester) async {
      final bio = FakeBiometricGateway()
        ..available = true
        ..pending = Completer<bool>();
      await harness.service.setBiometricEnabled(true);
      withBiometrics(bio);

      await tester.pumpWidget(
        applockTestHost(ApplockScreen(viewModel: viewModel)),
      );
      await tester.pump();
      await tester.pump();
      expect(bio.authenticateCount, 1);

      await tester.tap(find.text(l10n.appLockEnterPin));
      await tester.pump();

      expect(bio.authenticateCount, 1);

      bio.pending!.complete(false);
      await tester.pumpAndSettle();
    });

    testWidgets('биометрия выключена — авто-вызова нет, виден PIN', (
      tester,
    ) async {
      final bio = FakeBiometricGateway()..available = true;
      withBiometrics(bio);

      await tester.pumpWidget(
        applockTestHost(ApplockScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expect(bio.authenticateCount, 0);
      expect(find.byType(PinKeypad), findsOneWidget);
    });
  });
}
