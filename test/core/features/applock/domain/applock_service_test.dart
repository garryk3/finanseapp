import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/domain/applock_snapshot.dart';
import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStorage implements ApplockStorage {
  ApplockSnapshot snapshot = const ApplockSnapshot();
  int saveCount = 0;

  @override
  Future<ApplockSnapshot> load() async => snapshot;

  @override
  Future<void> save(ApplockSnapshot value) async {
    snapshot = value;
    saveCount++;
  }
}

void main() {
  const pin = PinCode('1234');
  const wrong = PinCode('9999');

  late _FakeStorage storage;
  late DateTime now;
  late ApplockService service;

  setUp(() {
    storage = _FakeStorage();
    now = DateTime(2026, 11, 17, 12);
    service = ApplockService(storage: storage, clock: () => now);
  });

  group('fresh install (BR-Sec-7)', () {
    test('защита выключена, verify отклонён', () async {
      await service.init();
      expect(service.isEnabled, isFalse);
      expect(await service.verify(pin), ApplockVerifyResult.wrongPin);
    });
  });

  group('enable / disable / change (BR-Sec-3)', () {
    test('enable сохраняет хэш с солью, не храня открытый PIN', () async {
      await service.init();
      await service.enable(pin);

      expect(service.isEnabled, isTrue);
      expect(storage.snapshot.hasPin, isTrue);
      expect(storage.snapshot.pinLength, 4);
      expect(storage.snapshot.pinHash, isNot(contains('1234')));
      expect(storage.snapshot.salt, isNotNull);
    });

    test('disable по верному PIN выключает защиту и очищает хэш', () async {
      await service.init();
      await service.enable(pin);

      expect(await service.disable(pin), isTrue);
      expect(service.isEnabled, isFalse);
      expect(storage.snapshot.hasPin, isFalse);
    });

    test('disable по неверному PIN запрещён и состояние не меняется', () async {
      await service.init();
      await service.enable(pin);

      expect(await service.disable(wrong), isFalse);
      expect(service.isEnabled, isTrue);
      expect(storage.snapshot.hasPin, isTrue);
    });

    test('change требует верный текущий PIN и меняет хэш', () async {
      await service.init();
      await service.enable(pin);
      final oldHash = storage.snapshot.pinHash;

      expect(await service.changePin(wrong, PinCode('5678')), isFalse);
      expect(storage.snapshot.pinHash, oldHash);

      expect(await service.changePin(pin, PinCode('5678')), isTrue);
      expect(storage.snapshot.pinHash, isNot(oldHash));
      expect(
        await service.verify(PinCode('5678')),
        ApplockVerifyResult.success,
      );
      expect(await service.verify(pin), isNot(ApplockVerifyResult.success));
    });
  });

  group('политика попыток (BR-Sec-5)', () {
    test('5 неудачных подряд → locked; задержка 30с', () async {
      await service.init();
      await service.enable(pin);

      for (var i = 0; i < 4; i++) {
        expect(await service.verify(wrong), ApplockVerifyResult.wrongPin);
      }
      expect(await service.verify(wrong), ApplockVerifyResult.locked);
      expect(service.lockoutRemaining(), const Duration(seconds: 30));
      // Даже верный PIN не принимается во время блокировки.
      expect(await service.verify(pin), ApplockVerifyResult.locked);
    });

    test('блокировка переживает перезапуск приложения', () async {
      await service.init();
      await service.enable(pin);
      for (var i = 0; i < 5; i++) {
        await service.verify(wrong);
      }

      final restarted = ApplockService(storage: storage, clock: () => now);
      await restarted.init();

      expect(await restarted.verify(pin), ApplockVerifyResult.locked);
      expect(restarted.lockoutRemaining(), const Duration(seconds: 30));
    });

    test('задержка удваивается с каждым интервалом (30 → 60 → 120)', () async {
      await service.init();
      await service.enable(pin);

      // Счётчик сбрасывается только успешным вводом: удвоение нарастает
      // сериями подряд (5 неудачных → 30с, 10 → 60с, 15 → 120с).
      Future<void> failFive() async {
        for (var i = 0; i < 5; i++) {
          await service.verify(wrong);
        }
      }

      await failFive();
      expect(service.lockoutRemaining(), const Duration(seconds: 30));

      now = now.add(const Duration(seconds: 31));
      await failFive();
      expect(service.lockoutRemaining(), const Duration(seconds: 60));

      now = now.add(const Duration(seconds: 61));
      await failFive();
      expect(service.lockoutRemaining(), const Duration(seconds: 120));
    });

    test('успешный ввод сбрасывает счётчик неудачных попыток', () async {
      await service.init();
      await service.enable(pin);

      for (var i = 0; i < 4; i++) {
        await service.verify(wrong);
      }
      expect(await service.verify(pin), ApplockVerifyResult.success);
      expect(storage.snapshot.failedAttempts, 0);
      expect(service.lockoutRemaining(), isNull);

      // Счётчик с нуля: снова нужно 5 неудачных до блокировки.
      for (var i = 0; i < 4; i++) {
        expect(await service.verify(wrong), ApplockVerifyResult.wrongPin);
      }
    });
  });

  group('настройки защиты', () {
    test('биометрия недоступна без PIN (BR-Sec-4)', () async {
      await service.init();
      expect(service.setBiometricEnabled(true), throwsStateError);
    });

    test('auto-lock: 0 — сразу, N — после N минут в фоне (BR-Sec-6)', () async {
      await service.init();
      await service.enable(pin);

      expect(
        service.shouldLockAfterBackground(const Duration(minutes: 10)),
        isTrue,
      );

      await service.setAutoLockMinutes(5);
      expect(
        service.shouldLockAfterBackground(const Duration(minutes: 4)),
        isFalse,
      );
      expect(
        service.shouldLockAfterBackground(const Duration(minutes: 5)),
        isTrue,
      );
      expect(storage.snapshot.autoLockMinutes, 5);
    });
  });
}
