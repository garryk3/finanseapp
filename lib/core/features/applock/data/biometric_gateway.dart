/// Шлюз биометрии (BR-Sec-4): реализация — `local_auth`, в тестах — fake.
/// Недоступность сенсора, отмена и неудача возвращают `false` (fallback на PIN).
abstract class BiometricGateway {
  Future<bool> isAvailable();

  Future<bool> authenticate({required String reason});
}
