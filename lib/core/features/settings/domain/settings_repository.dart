import 'package:finanseapp/core/domain/common/currency.dart';

/// Ставка налога с процентов по вкладам по умолчанию, % (D21.6/X2).
const int defaultTaxRatePercent = 13;

/// Нижняя граница ставки налога, % (D21.6/X2).
const int minTaxRatePercent = 0;

/// Верхняя граница ставки налога, % (D21.6/X2).
const int maxTaxRatePercent = 100;

/// Repository настроек приложения (domain_model §9).
///
/// Контракт проверки обновлений (`UpdateService`) относится к задаче 10.5.
abstract interface class SettingsRepository {
  Stream<Currency> watchBaseCurrency();

  Future<Currency> getBaseCurrency();

  Future<void> setBaseCurrency(String code);

  /// Ставка налога с процентов по вкладам, % (D21.6/X2).
  ///
  /// Отсутствие ключа или нечисловое/вне диапазона значение трактуется как
  /// [defaultTaxRatePercent].
  Future<int> getTaxRatePercent();

  /// Сохраняет ставку налога; вне [minTaxRatePercent]..[maxTaxRatePercent] —
  /// `DomainException(validation)`.
  Future<void> setTaxRatePercent(int percent);
}
