import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';

/// Repository курсов валют (domain_model §9).
abstract interface class ExchangeRateRepository {
  Future<ExchangeRate?> find(String currencyCode, LocalDate date);

  /// Последний сохранённый курс не позже [date] (BR-C-9, только чтение).
  ///
  /// Используется read-резолвером, когда точного курса на дату нет; запись
  /// операций/оценок по-прежнему требует точный или ручной курс (BR-C-2).
  Future<ExchangeRate?> findLatestOnOrBefore(
    String currencyCode,
    LocalDate date,
  );

  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date);

  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  );
}
