import 'package:finanseapp/core/features/applock/data/local_auth_biometric_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Linux/desktop без регистрации плагина: graceful fallback (BR-Sec-4)',
    () async {
      final gateway = LocalAuthBiometricGateway();

      // Канал local_auth не имеет хендлера в тестовом окружении —
      // плагин бросает MissingPluginException (не PlatformException).
      expect(await gateway.isAvailable(), isFalse);
      expect(await gateway.authenticate(reason: 'тест'), isFalse);
    },
  );
}
