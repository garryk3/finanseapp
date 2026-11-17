import 'package:finanseapp/core/features/applock/data/biometric_gateway.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:signals/signals.dart';

enum ApplockInputError { wrongPin, locked }

/// ViewModel экрана блокировки: ввод PIN до длины установленного кода,
/// ошибки, lockout-таймер и опциональная биометрия (BR-Sec-4…6).
class ApplockViewModel {
  ApplockViewModel({
    required this._service,
    required this._biometrics,
    required this._controller,
  });
  final ApplockService _service;
  final BiometricGateway _biometrics;
  final ApplockController _controller;

  final Signal<String> entered = signal('');
  final Signal<ApplockInputError?> error = signal(null);
  final Signal<Duration?> lockoutRemaining = signal(null);
  final Signal<bool> biometricVisible = signal(false);

  Future<void>? _submitFuture;
  Future<void>? get submitFuture => _submitFuture;

  int get pinLength => _service.pinLength;

  Future<void> init() async {
    biometricVisible.value =
        _service.biometricEnabled && await _biometrics.isAvailable();
    await refreshLockout();
  }

  void onDigit(String digit) {
    if (digit.length != 1 || !PinCode.parseAllowedDigit(digit)) return;
    if (lockoutRemaining.value != null) return;
    if (entered.value.length >= _service.pinLength) return;
    if (error.value == ApplockInputError.wrongPin) error.value = null;
    entered.value = entered.value + digit;
    if (entered.value.length == _service.pinLength) {
      _submitFuture = _submit();
    }
  }

  void onBackspace() {
    final value = entered.value;
    if (value.isEmpty) return;
    entered.value = value.substring(0, value.length - 1);
  }

  Future<void> refreshLockout() async {
    lockoutRemaining.value = _service.lockoutRemaining();
    if (lockoutRemaining.value == null &&
        error.value == ApplockInputError.locked) {
      error.value = null;
    }
  }

  Future<void> _submit() async {
    final result = await _service.verify(PinCode.parse(entered.value));
    switch (result) {
      case ApplockVerifyResult.success:
        entered.value = '';
        error.value = null;
        _controller.unlock();
      case ApplockVerifyResult.wrongPin:
        entered.value = '';
        error.value = ApplockInputError.wrongPin;
      case ApplockVerifyResult.locked:
        entered.value = '';
        error.value = ApplockInputError.locked;
    }
    await refreshLockout();
  }

  Future<void> authenticateBiometric({required String reason}) async {
    if (!biometricVisible.value) return;
    final ok = await _biometrics.authenticate(reason: reason);
    if (ok) {
      entered.value = '';
      error.value = null;
      _controller.unlock();
    }
  }
}
