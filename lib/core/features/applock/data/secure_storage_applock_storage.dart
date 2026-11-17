import 'package:finanseapp/core/features/applock/domain/applock_snapshot.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Реализация [ApplockStorage] поверх platform secure storage (BR-Sec-2):
/// хэш PIN и флаги вне БД, backup/import их не переносит.
class SecureStorageApplockStorage implements ApplockStorage {
  SecureStorageApplockStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _pinHashKey = 'applock.pin_hash';
  static const _saltKey = 'applock.salt';
  static const _pinLengthKey = 'applock.pin_length';
  static const _biometricKey = 'applock.biometric';
  static const _autoLockMinutesKey = 'applock.auto_lock_minutes';
  static const _failedAttemptsKey = 'applock.failed_attempts';
  static const _lockedUntilKey = 'applock.locked_until';

  final FlutterSecureStorage _storage;

  @override
  Future<ApplockSnapshot> load() async {
    final values = await Future.wait([
      _storage.read(key: _pinHashKey),
      _storage.read(key: _saltKey),
      _storage.read(key: _pinLengthKey),
      _storage.read(key: _biometricKey),
      _storage.read(key: _autoLockMinutesKey),
      _storage.read(key: _failedAttemptsKey),
      _storage.read(key: _lockedUntilKey),
    ]);
    final lockedUntilMillis = int.tryParse(values[6] ?? '');
    return ApplockSnapshot(
      pinHash: values[0],
      salt: values[1],
      pinLength: int.tryParse(values[2] ?? '') ?? 0,
      biometricEnabled: values[3] == '1',
      autoLockMinutes: int.tryParse(values[4] ?? '') ?? 0,
      failedAttempts: int.tryParse(values[5] ?? '') ?? 0,
      lockedUntil: lockedUntilMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lockedUntilMillis, isUtc: true),
    );
  }

  @override
  Future<void> save(ApplockSnapshot snapshot) async {
    final writes = <Future<void>>[
      _writeOrDelete(_pinHashKey, snapshot.pinHash),
      _writeOrDelete(_saltKey, snapshot.salt),
      _storage.write(key: _pinLengthKey, value: snapshot.pinLength.toString()),
      _storage.write(
        key: _biometricKey,
        value: snapshot.biometricEnabled ? '1' : '0',
      ),
      _storage.write(
        key: _autoLockMinutesKey,
        value: snapshot.autoLockMinutes.toString(),
      ),
      _storage.write(
        key: _failedAttemptsKey,
        value: snapshot.failedAttempts.toString(),
      ),
    ];
    if (snapshot.lockedUntil == null) {
      writes.add(_storage.delete(key: _lockedUntilKey));
    } else {
      writes.add(
        _storage.write(
          key: _lockedUntilKey,
          value: snapshot.lockedUntil!
              .toUtc()
              .millisecondsSinceEpoch
              .toString(),
        ),
      );
    }
    await Future.wait(writes);
  }

  Future<void> _writeOrDelete(String key, String? value) => value == null
      ? _storage.delete(key: key)
      : _storage.write(key: key, value: value);
}
