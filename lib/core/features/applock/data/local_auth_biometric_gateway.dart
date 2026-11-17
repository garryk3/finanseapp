import 'package:finanseapp/core/features/applock/data/biometric_gateway.dart';
import 'package:local_auth/local_auth.dart';

/// [BiometricGateway] поверх `local_auth`. Linux/desktop без сенсора —
/// graceful fallback на PIN (BR-Sec-4).
class LocalAuthBiometricGateway implements BiometricGateway {
  LocalAuthBiometricGateway([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.any(
        (type) =>
            type == BiometricType.fingerprint ||
            type == BiometricType.face ||
            type == BiometricType.strong ||
            type == BiometricType.weak,
      );
    } catch (_) {
      // Linux/desktop без регистрации плагина бросает MissingPluginException
      // (не PlatformException): graceful fallback на PIN (BR-Sec-4).
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }
}
