import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

void main() {
  late TestApplockHarness harness;
  late FakeBiometricGateway bio;
  late ApplockSettingsViewModel viewModel;

  setUp(() async {
    harness = TestApplockHarness();
    bio = FakeBiometricGateway();
    viewModel = ApplockSettingsViewModel(
      service: harness.service,
      biometrics: bio,
    );
    await viewModel.init();
  });

  group('включение защиты (BR-Sec-3)', () {
    test('двойной ввод: совпадение включает защиту, расхождение — ошибка', () async {
      expect(viewModel.enabled.value, isFalse);

      viewModel.startEnable();
      expect(viewModel.step.value, ApplockSettingsStep.enterNew);

      // Первый ввод — через кнопку «Продолжить» (длина выбирает пользователь).
      '1234'.split('').forEach(viewModel.onDigit);
      await viewModel.submit();
      expect(viewModel.step.value, ApplockSettingsStep.confirmNew);

      // Расхождение → ошибка, возврат к первому вводу.
      '5678'.split('').forEach(viewModel.onDigit);
      await viewModel.submit();
      expect(viewModel.error.value, ApplockSettingsError.pinsMismatch);
      expect(viewModel.step.value, ApplockSettingsStep.enterNew);

      // Совпадение → включено.
      '1234'.split('').forEach(viewModel.onDigit);
      await viewModel.submit();
      '1234'.split('').forEach(viewModel.onDigit);
      await viewModel.submit();
      expect(viewModel.error.value, isNull);
      expect(viewModel.step.value, ApplockSettingsStep.manage);
      expect(viewModel.enabled.value, isTrue);
      expect(harness.service.isEnabled, isTrue);
    });

    test('короткий PIN (<4) не отправляется', () async {
      viewModel.startEnable();
      '123'.split('').forEach(viewModel.onDigit);

      expect(viewModel.canSubmit.value, isFalse);
    });
  });

  group('смена и отключение (BR-Sec-3)', () {
    setUp(() async {
      await harness.enable('1234');
      await viewModel.syncFromService();
    });

    test('смена требует верный текущий PIN', () async {
      viewModel.startChange();
      expect(viewModel.step.value, ApplockSettingsStep.enterCurrent);

      '9999'.split('').forEach(viewModel.onDigit);
      await viewModel.submitFuture;
      expect(viewModel.error.value, ApplockSettingsError.wrongPin);
      expect(viewModel.step.value, ApplockSettingsStep.enterCurrent);

      '1234'.split('').forEach(viewModel.onDigit);
      await viewModel.submitFuture;
      expect(viewModel.step.value, ApplockSettingsStep.enterNew);

      '5678'.split('').forEach(viewModel.onDigit);
      await viewModel.submit();
      '5678'.split('').forEach(viewModel.onDigit);
      await viewModel.submit();

      expect(viewModel.enabled.value, isTrue);
      // Новый PIN принимается, старый отклоняется (BR-Sec-3).
      expect(
        await harness.service.verify(PinCode.parse('5678')),
        ApplockVerifyResult.success,
      );
      expect(
        await harness.service.verify(PinCode.parse('1234')),
        isNot(ApplockVerifyResult.success),
      );
    });

    test('отключение требует верный текущий PIN', () async {
      viewModel.startDisable();
      expect(viewModel.step.value, ApplockSettingsStep.enterCurrent);

      '9999'.split('').forEach(viewModel.onDigit);
      await viewModel.submitFuture;
      expect(viewModel.error.value, ApplockSettingsError.wrongPin);
      expect(viewModel.enabled.value, isTrue);

      '1234'.split('').forEach(viewModel.onDigit);
      await viewModel.submitFuture;
      expect(viewModel.step.value, ApplockSettingsStep.manage);
      expect(viewModel.enabled.value, isFalse);
      expect(harness.service.isEnabled, isFalse);
    });

    test('cancelInput возвращает к управлению без изменений', () async {
      viewModel.startChange();
      viewModel.cancelInput();
      expect(viewModel.step.value, ApplockSettingsStep.manage);
      expect(harness.service.isEnabled, isTrue);
    });
  });

  group('настройки', () {
    setUp(() async {
      await harness.enable('1234');
      await viewModel.syncFromService();
    });

    test(
      'биометрия без доступного сенсора — ошибка, состояние не меняется',
      () async {
        bio.available = false;
        await viewModel.setBiometric(true);
        expect(
          viewModel.error.value,
          ApplockSettingsError.biometricUnavailable,
        );
        expect(viewModel.biometricEnabled.value, isFalse);
      },
    );

    test('биометрия при доступном сенсоре включается (BR-Sec-4)', () async {
      bio.available = true;
      final fresh = ApplockSettingsViewModel(
        service: harness.service,
        biometrics: bio,
      );
      await fresh.init();

      await fresh.setBiometric(true);
      expect(fresh.error.value, isNull);
      expect(fresh.biometricEnabled.value, isTrue);
      expect(harness.service.biometricEnabled, isTrue);
    });

    test('auto-lock минуты сохраняются (BR-Sec-6)', () async {
      await viewModel.setAutoLockMinutes(5);
      expect(viewModel.autoLockMinutes.value, 5);
      expect(harness.service.autoLockMinutes, 5);
    });
  });
}
