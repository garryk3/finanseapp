import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

void main() {
  group('cold start (BR-Sec-6)', () {
    test('PIN установлен → приложение стартует заблокированным', () async {
      final harness = TestApplockHarness();
      await harness.enable('1234');
      final controller = ApplockController(
        service: harness.service,
        clock: () => harness.now,
      );

      await controller.init();

      expect(controller.enabled, isTrue);
      expect(controller.locked.value, isTrue);
    });

    test('PIN не установлен → приложение стартует разблокированным', () async {
      final harness = TestApplockHarness();
      final controller = ApplockController(
        service: harness.service,
        clock: () => harness.now,
      );

      await controller.init();

      expect(controller.enabled, isFalse);
      expect(controller.locked.value, isFalse);
    });
  });

  group('auto-lock при возврате из фона (BR-Sec-6)', () {
    test('политика «сразу» → любой возврат из фона блокирует', () async {
      final harness = TestApplockHarness();
      await harness.enable('1234');
      final controller = ApplockController(service: harness.service);
      await controller.init();
      controller.unlock();
      expect(controller.locked.value, isFalse);

      harness.now = harness.now.add(const Duration(seconds: 5));
      controller.onAppPaused();
      harness.now = harness.now.add(const Duration(seconds: 3));
      controller.onAppResumed();

      expect(controller.locked.value, isTrue);
    });

    test(
      'политика «через 5 минут» → 4 минуты в фоне не блокируют, 5 — блокируют',
      () async {
        final harness = TestApplockHarness();
        await harness.enable('1234');
        await harness.service.setAutoLockMinutes(5);
        final controller = ApplockController(
          service: harness.service,
          clock: () => harness.now,
        );
        await controller.init();
        controller.unlock();

        controller.onAppPaused();
        harness.now = harness.now.add(const Duration(minutes: 4));
        controller.onAppResumed();
        expect(controller.locked.value, isFalse);

        controller.onAppPaused();
        harness.now = harness.now.add(const Duration(minutes: 5));
        controller.onAppResumed();
        expect(controller.locked.value, isTrue);
      },
    );

    test('защита выключена → возврат из фона не блокирует', () async {
      final harness = TestApplockHarness();
      final controller = ApplockController(
        service: harness.service,
        clock: () => harness.now,
      );
      await controller.init();

      controller.onAppPaused();
      harness.now = harness.now.add(const Duration(hours: 1));
      controller.onAppResumed();

      expect(controller.locked.value, isFalse);
    });
  });
}
