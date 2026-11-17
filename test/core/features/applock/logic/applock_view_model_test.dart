import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

ApplockViewModel buildViewModel(
  TestApplockHarness harness,
  FakeBiometricGateway bio,
  ApplockController controller,
) {
  return ApplockViewModel(
    service: harness.service,
    biometrics: bio,
    controller: controller,
  );
}

void main() {
  late TestApplockHarness harness;
  late FakeBiometricGateway bio;
  late ApplockController controller;
  late ApplockViewModel viewModel;

  setUp(() async {
    harness = TestApplockHarness();
    await harness.enable('1234');
    controller = ApplockController(service: harness.service);
    await controller.init();
    bio = FakeBiometricGateway();
    viewModel = ApplockViewModel(
      service: harness.service,
      biometrics: bio,
      controller: controller,
    );
    await viewModel.init();
  });

  test('ввод цифр копится и останавливается на длине PIN', () {
    viewModel.onDigit('1');
    viewModel.onDigit('2');
    expect(viewModel.entered.value, '12');

    '3456'.split('').forEach(viewModel.onDigit);
    expect(viewModel.entered.value, '1234');
  });

  test('полный верный PIN разблокирует приложение', () async {
    '1234'.split('').forEach(viewModel.onDigit);
    await viewModel.submitFuture;

    expect(controller.locked.value, isFalse);
    expect(viewModel.error.value, isNull);
  });

  test(
    'неверный PIN: ошибка, ввод очищен; следующая цифра сбрасывает ошибку',
    () async {
      '9999'.split('').forEach(viewModel.onDigit);
      await viewModel.submitFuture;

      expect(viewModel.error.value, ApplockInputError.wrongPin);
      expect(viewModel.entered.value, isEmpty);

      viewModel.onDigit('1');
      expect(viewModel.error.value, isNull);
      expect(viewModel.entered.value, '1');
    },
  );

  test('backspace убирает последнюю цифру', () {
    viewModel.onDigit('1');
    viewModel.onDigit('2');
    viewModel.onBackspace();
    expect(viewModel.entered.value, '1');
    viewModel.onBackspace();
    expect(viewModel.entered.value, isEmpty);
    viewModel.onBackspace();
    expect(viewModel.entered.value, isEmpty);
  });

  test(
    'во время блокировки ввод игнорируется и показана ошибка locked',
    () async {
      // 5 неудачных попыток через сервис → локаут.
      for (var i = 0; i < 5; i++) {
        await harness.service.verify(PinCode.parse('9999'));
      }
      viewModel.refreshLockout();
      expect(viewModel.lockoutRemaining.value, isNotNull);

      viewModel.onDigit('1');
      expect(viewModel.entered.value, isEmpty);

      // Ввод игнорируется до конца lockout — submit не вызывается,
      // ошибка locked уже отражена через lockoutRemaining.
      '9999'.split('').forEach(viewModel.onDigit);
      expect(viewModel.entered.value, isEmpty);
      expect(viewModel.lockoutRemaining.value, isNotNull);
    },
  );

  test('после окончания lockout ввод снова разрешён', () async {
    for (var i = 0; i < 5; i++) {
      await harness.service.verify(PinCode.parse('9999'));
    }
    harness.now = harness.now.add(const Duration(seconds: 31));
    viewModel.refreshLockout();

    expect(viewModel.lockoutRemaining.value, isNull);
    expect(viewModel.error.value, isNull);

    '1234'.split('').forEach(viewModel.onDigit);
    await viewModel.submitFuture;
    expect(controller.locked.value, isFalse);
  });

  group('биометрия (BR-Sec-4)', () {
    test(
      'кнопка видна только при включённой настройке и доступном сенсоре',
      () async {
        expect(viewModel.biometricVisible.value, isFalse);

        bio.available = true;
        await harness.service.setBiometricEnabled(true);
        final vm2 = buildViewModel(harness, bio, controller);
        await vm2.init();
        expect(vm2.biometricVisible.value, isTrue);
      },
    );

    test('успешная биометрия разблокирует; отмена — остаёмся на PIN', () async {
      bio.available = true;
      await harness.service.setBiometricEnabled(true);
      final vm2 = buildViewModel(harness, bio, controller);
      await vm2.init();

      bio.authenticateResult = false;
      await vm2.authenticateBiometric(reason: 'Разблокировка');
      expect(controller.locked.value, isTrue);
      expect(bio.lastReason, 'Разблокировка');

      bio.authenticateResult = true;
      await vm2.authenticateBiometric(reason: 'Разблокировка');
      expect(controller.locked.value, isFalse);
    });
  });
}
