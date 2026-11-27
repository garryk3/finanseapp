/// Настройки отображения (D21.4): начальное состояние блюра сумм на Главной.
///
/// Отдельный узкий контракт: потребителям базовой валюты не нужно знать о
/// настройках отображения. Реализуется `SettingsRepositoryImpl`.
abstract interface class DisplaySettingsRepository {
  /// Поток настройки «скрывать суммы при входе»; отсутствие ключа — `false`.
  Stream<bool> watchAmountsHidden();

  Future<bool> getAmountsHidden();

  Future<void> setAmountsHidden(bool hidden);
}
