import 'package:finanseapp/core/features/applock/data/biometric_gateway.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:signals/signals.dart';

enum ApplockSettingsStep { manage, enterCurrent, enterNew, confirmNew }

enum ApplockSettingsError {
  wrongPin,
  pinsMismatch,
  biometricUnavailable,
  locked,
}

enum _PendingAction { change, disable }

/// ViewModel управления защитой: включение (двойной ввод), смена и отключение
/// по текущему PIN, биометрия и auto-lock (BR-Sec-3, BR-Sec-4, BR-Sec-6).
class ApplockSettingsViewModel {
  ApplockSettingsViewModel({required this._service, required this._biometrics});

  final ApplockService _service;
  final BiometricGateway _biometrics;

  final Signal<ApplockSettingsStep> step = signal(ApplockSettingsStep.manage);
  final Signal<String> entered = signal('');
  final Signal<ApplockSettingsError?> error = signal(null);
  final Signal<bool> enabled = signal(false);
  final Signal<bool> biometricEnabled = signal(false);
  final Signal<bool> biometricAvailable = signal(false);
  final Signal<int> autoLockMinutes = signal(0);
  final Signal<bool> canSubmit = signal(false);
  final Signal<Duration?> lockoutRemaining = signal(null);

  String? _candidate;
  PinCode? _currentVerified;
  _PendingAction? _pending;

  Future<void>? _submitFuture;
  Future<void>? get submitFuture => _submitFuture;

  /// Длина установленного PIN (для индикатора ввода текущего PIN).
  int get currentPinLength => _service.pinLength;

  Future<void> init() async {
    await _service.init();
    biometricAvailable.value = await _biometrics.isAvailable();
    await syncFromService();
  }

  Future<void> syncFromService() async {
    enabled.value = _service.isEnabled;
    biometricEnabled.value = _service.biometricEnabled;
    autoLockMinutes.value = _service.autoLockMinutes;
    _syncCanSubmit();
  }

  void startEnable() {
    _pending = null;
    _begin(ApplockSettingsStep.enterNew);
  }

  void startChange() {
    _pending = _PendingAction.change;
    _begin(ApplockSettingsStep.enterCurrent);
  }

  void startDisable() {
    _pending = _PendingAction.disable;
    _begin(ApplockSettingsStep.enterCurrent);
  }

  void cancelInput() {
    _pending = null;
    _candidate = null;
    _begin(ApplockSettingsStep.manage);
  }

  void onDigit(String digit) {
    if (!PinCode.parseAllowedDigit(digit)) return;
    final maxLength = switch (step.value) {
      ApplockSettingsStep.enterCurrent => _service.pinLength,
      _ => PinCode.maxLength,
    };
    if (entered.value.length >= maxLength) return;
    if (error.value != null) error.value = null;
    entered.value = entered.value + digit;
    _syncCanSubmit();
    if (step.value == ApplockSettingsStep.enterCurrent &&
        entered.value.length == _service.pinLength) {
      _submitFuture = _submitEnterCurrent();
    }
  }

  void onBackspace() {
    final value = entered.value;
    if (value.isEmpty) return;
    entered.value = value.substring(0, value.length - 1);
    _syncCanSubmit();
  }

  /// Отправка первого/повторного ввода нового PIN (кнопка «Продолжить»):
  /// длину (4–6) выбирает пользователь, поэтому авто-отправки нет.
  Future<void> submit() async {
    if (!canSubmit.value) return;
    switch (step.value) {
      case ApplockSettingsStep.enterNew:
        _candidate = entered.value;
        error.value = null;
        entered.value = '';
        canSubmit.value = false;
        step.value = ApplockSettingsStep.confirmNew;
      case ApplockSettingsStep.confirmNew:
        if (entered.value == _candidate) {
          final newPin = PinCode.parse(entered.value);
          final current = _currentVerified;
          if (_pending == _PendingAction.change && current != null) {
            // Смена — через доменный changePin (BR-Sec-3).
            await _service.changePin(current, newPin);
            enabled.value = true;
          } else {
            await _service.enable(newPin);
            enabled.value = true;
          }
          _candidate = null;
          _currentVerified = null;
          _begin(ApplockSettingsStep.manage);
        } else {
          _candidate = null;
          error.value = ApplockSettingsError.pinsMismatch;
          entered.value = '';
          canSubmit.value = false;
          step.value = ApplockSettingsStep.enterNew;
        }
      case ApplockSettingsStep.manage || ApplockSettingsStep.enterCurrent:
        break;
    }
  }

  Future<void> setBiometric(bool value) async {
    if (value && !biometricAvailable.value) {
      error.value = ApplockSettingsError.biometricUnavailable;
      return;
    }
    await _service.setBiometricEnabled(value);
    biometricEnabled.value = value;
    error.value = null;
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _service.setAutoLockMinutes(minutes);
    autoLockMinutes.value = _service.autoLockMinutes;
  }

  void _begin(ApplockSettingsStep target) {
    step.value = target;
    entered.value = '';
    error.value = null;
    canSubmit.value = false;
    lockoutRemaining.value = null;
    _currentVerified = null;
  }

  void _syncCanSubmit() {
    final length = entered.value.length;
    canSubmit.value = switch (step.value) {
      ApplockSettingsStep.enterNew || ApplockSettingsStep.confirmNew =>
        length >= PinCode.minLength && length <= PinCode.maxLength,
      _ => false,
    };
  }

  Future<void> _submitEnterCurrent() async {
    final pin = PinCode.parse(entered.value);
    entered.value = '';
    canSubmit.value = false;
    final result = await _service.verify(pin);
    switch (result) {
      case ApplockVerifyResult.success:
        error.value = null;
        if (_pending == _PendingAction.change) {
          _currentVerified = pin;
          _candidate = null;
          step.value = ApplockSettingsStep.enterNew;
        } else {
          await _service.disable(pin);
          await syncFromService();
          _pending = null;
          step.value = ApplockSettingsStep.manage;
        }
      case ApplockVerifyResult.wrongPin:
        error.value = ApplockSettingsError.wrongPin;
      case ApplockVerifyResult.locked:
        error.value = ApplockSettingsError.locked;
    }
    await refreshLockout();
  }

  Future<void> refreshLockout() async {
    lockoutRemaining.value = _service.lockoutRemaining();
    if (lockoutRemaining.value == null &&
        error.value == ApplockSettingsError.locked) {
      error.value = null;
    }
  }
}
