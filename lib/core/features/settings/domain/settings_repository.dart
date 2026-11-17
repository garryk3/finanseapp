import 'package:finanseapp/core/domain/common/currency.dart';

/// Repository настроек приложения (domain_model §9).
///
/// Контракт проверки обновлений (`UpdateService`) относится к задаче 10.5.
abstract interface class SettingsRepository {
  Stream<Currency> watchBaseCurrency();

  Future<Currency> getBaseCurrency();

  Future<void> setBaseCurrency(String code);
}
