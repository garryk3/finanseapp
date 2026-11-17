import 'package:finanseapp/core/features/applock/data/secure_storage_applock_storage.dart';
import 'package:finanseapp/core/features/applock/domain/applock_snapshot.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage plugin;
  late SecureStorageApplockStorage storage;

  setUp(() {
    plugin = _MockSecureStorage();
    storage = SecureStorageApplockStorage(plugin);
  });

  void stubRead(Map<String, String?> values) {
    when(() => plugin.read(key: any(named: 'key'))).thenAnswer(
      (invocation) async => values[invocation.namedArguments[#key] as String],
    );
  }

  test('пустое хранилище → снимок по умолчанию (защита выключена)', () async {
    stubRead(const {});

    final snapshot = await storage.load();

    expect(snapshot.hasPin, isFalse);
    expect(snapshot.biometricEnabled, isFalse);
    expect(snapshot.autoLockMinutes, 0);
    expect(snapshot.failedAttempts, 0);
    expect(snapshot.lockedUntil, isNull);
  });

  test('частичные данные: только хэш/соль, остальное — дефолты', () async {
    stubRead({'applock.pin_hash': 'abc', 'applock.salt': 'def'});

    final snapshot = await storage.load();

    expect(snapshot.hasPin, isTrue);
    expect(snapshot.autoLockMinutes, 0);
  });

  test('save → load roundtrip, включая lockout', () async {
    final values = <String, String?>{};
    when(() => plugin.read(key: any(named: 'key'))).thenAnswer(
      (invocation) async => values[invocation.namedArguments[#key] as String],
    );
    when(
      () => plugin.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      values[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
    when(() => plugin.delete(key: any(named: 'key')))
        .thenAnswer((invocation) async {
          values.remove(invocation.namedArguments[#key] as String);
        });

    final lockedUntil = DateTime.utc(2026, 11, 17, 12, 0, 30);
    await storage.save(
      ApplockSnapshot(
        pinHash: 'hash',
        salt: 'salt',
        pinLength: 6,
        biometricEnabled: true,
        autoLockMinutes: 5,
        failedAttempts: 5,
        lockedUntil: lockedUntil,
      ),
    );

    final restored = await storage.load();
    expect(restored.pinHash, 'hash');
    expect(restored.salt, 'salt');
    expect(restored.pinLength, 6);
    expect(restored.biometricEnabled, isTrue);
    expect(restored.autoLockMinutes, 5);
    expect(restored.failedAttempts, 5);
    expect(restored.lockedUntil, lockedUntil);

    // Отключение защиты удаляет хэш и lockout из хранилища.
    await storage.save(const ApplockSnapshot());
    final cleared = await storage.load();
    expect(cleared.hasPin, isFalse);
    expect(cleared.failedAttempts, 0);
    expect(cleared.lockedUntil, isNull);
  });
}
