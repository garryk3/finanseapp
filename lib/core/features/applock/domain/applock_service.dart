import 'package:finanseapp/core/features/applock/domain/applock_snapshot.dart';
import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:finanseapp/core/features/applock/domain/pin_hasher.dart';

/// Хранилище снимка защиты. Реализация — в `data/` (secure storage, BR-Sec-2).
abstract class ApplockStorage {
  Future<ApplockSnapshot> load();
  Future<void> save(ApplockSnapshot snapshot);
}

enum ApplockVerifyResult { success, wrongPin, locked }

/// Доменный сервис защиты доступа (BR-Sec-1…7): установка/смена/отключение PIN,
/// verify с политикой попыток и настройки auto-lock/биометрии.
class ApplockService {
  ApplockService({
    required this._storage,
    this._hasher = const PinHasher(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const maxAttemptsPerRound = 5;
  static const baseLockout = Duration(seconds: 30);

  final ApplockStorage _storage;
  final PinHasher _hasher;
  final DateTime Function() _clock;

  late ApplockSnapshot _snapshot;
  bool _initialized = false;

  bool get isEnabled => _initialized && _snapshot.hasPin;
  bool get biometricEnabled => _snapshot.biometricEnabled;
  int get autoLockMinutes => _snapshot.autoLockMinutes;

  /// Длина установленного PIN (4–6); 0 — защита выключена.
  int get pinLength => _snapshot.pinLength;

  Future<void> init() async {
    _snapshot = await _storage.load();
    _initialized = true;
  }

  Future<void> enable(PinCode pin) async {
    _requireInit();
    final salt = _hasher.generateSalt();
    _snapshot = _snapshot.copyWith(
      pinHash: await _hasher.hash(pin, salt),
      salt: salt,
      pinLength: pin.digits.length,
      failedAttempts: 0,
      lockedUntil: null,
    );
    await _persist();
  }

  /// Отключение только по верному текущему PIN (BR-Sec-3).
  Future<bool> disable(PinCode current) async {
    _requireInit();
    if (!await _verifyHash(current)) return false;
    _snapshot = const ApplockSnapshot();
    await _persist();
    return true;
  }

  /// Смена только по верному текущему PIN (BR-Sec-3).
  Future<bool> changePin(PinCode current, PinCode next) async {
    _requireInit();
    if (!await _verifyHash(current)) return false;
    final salt = _hasher.generateSalt();
    _snapshot = _snapshot.copyWith(
      pinHash: await _hasher.hash(next, salt),
      salt: salt,
      pinLength: next.digits.length,
      failedAttempts: 0,
      lockedUntil: null,
    );
    await _persist();
    return true;
  }

  /// Проверка PIN с учётом блокировки и счётчика неудачных попыток (BR-Sec-5).
  Future<ApplockVerifyResult> verify(PinCode pin) async {
    _requireInit();
    if (!_snapshot.hasPin) return ApplockVerifyResult.wrongPin;
    if (lockoutRemaining() != null) return ApplockVerifyResult.locked;

    if (await _hasher.verify(pin, _snapshot.salt!, _snapshot.pinHash!)) {
      if (_snapshot.failedAttempts != 0 || _snapshot.lockedUntil != null) {
        _snapshot = _snapshot.copyWith(failedAttempts: 0, lockedUntil: null);
        await _persist();
      }
      return ApplockVerifyResult.success;
    }

    final failed = _snapshot.failedAttempts + 1;
    DateTime? lockedUntil;
    if (failed % maxAttemptsPerRound == 0) {
      final rounds = failed ~/ maxAttemptsPerRound;
      final delay = Duration(
        seconds: baseLockout.inSeconds * (1 << (rounds - 1)),
      );
      lockedUntil = _clock().add(delay);
    }
    _snapshot = _snapshot.copyWith(
      failedAttempts: failed,
      lockedUntil: lockedUntil,
    );
    await _persist();
    return lockedUntil == null
        ? ApplockVerifyResult.wrongPin
        : ApplockVerifyResult.locked;
  }

  /// Оставшееся время блокировки; `null` — ввод разрешён.
  Duration? lockoutRemaining() {
    final until = _snapshot.lockedUntil;
    if (until == null) return null;
    final remaining = until.difference(_clock());
    return remaining > Duration.zero ? remaining : null;
  }

  Future<void> setBiometricEnabled(bool value) async {
    _requireInit();
    if (value && !_snapshot.hasPin) {
      throw StateError('Биометрия доступна только при установленном PIN');
    }
    _snapshot = _snapshot.copyWith(biometricEnabled: value);
    await _persist();
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    _requireInit();
    if (minutes < 0) {
      throw ArgumentError.value(
        minutes,
        'minutes',
        'Не может быть отрицательным',
      );
    }
    _snapshot = _snapshot.copyWith(autoLockMinutes: minutes);
    await _persist();
  }

  /// Применять ли лок при возврате из фона спустя [background] (BR-Sec-6).
  bool shouldLockAfterBackground(Duration background) =>
      background.inMinutes >= _snapshot.autoLockMinutes;

  Future<bool> _verifyHash(PinCode pin) async {
    if (!_snapshot.hasPin) return false;
    return _hasher.verify(pin, _snapshot.salt!, _snapshot.pinHash!);
  }

  Future<void> _persist() => _storage.save(_snapshot);

  void _requireInit() {
    if (!_initialized) {
      throw StateError('ApplockService.init() не вызван');
    }
  }
}
