/// Снимок состояния защиты доступа. Хранится целиком в secure storage (BR-Sec-2):
/// вне БД, backup/import его не переносит.
class ApplockSnapshot {
  const ApplockSnapshot({
    this.pinHash,
    this.salt,
    this.pinLength = 0,
    this.biometricEnabled = false,
    this.autoLockMinutes = 0,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  /// Salted hash PIN и соль; `null` — защита выключена (BR-Sec-7).
  final String? pinHash;
  final String? salt;

  /// Длина установленного PIN (4–6); 0 — защита выключена.
  /// Не секретно: лок-скрину нужно знать, когда ввод полон.
  final int pinLength;

  final bool biometricEnabled;

  /// 0 — блокировать сразу при сворачивании; N — после N минут в фоне.
  final int autoLockMinutes;

  final int failedAttempts;
  final DateTime? lockedUntil;

  bool get hasPin => pinHash != null && salt != null;

  ApplockSnapshot copyWith({
    Object? pinHash = _undefined,
    Object? salt = _undefined,
    int? pinLength,
    bool? biometricEnabled,
    int? autoLockMinutes,
    int? failedAttempts,
    Object? lockedUntil = _undefined,
  }) => ApplockSnapshot(
    pinHash: identical(pinHash, _undefined) ? this.pinHash : pinHash as String?,
    salt: identical(salt, _undefined) ? this.salt : salt as String?,
    pinLength: pinLength ?? this.pinLength,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lockedUntil: identical(lockedUntil, _undefined)
        ? this.lockedUntil
        : lockedUntil as DateTime?,
  );
}

const Object _undefined = Object();
