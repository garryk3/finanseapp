import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';

/// Источник курса валюты к рублю (BR-C-7).
enum ExchangeRateSource { cbr, manual }

/// Сохранённый курс валюты на конкретную дату.
final class ExchangeRate {
  const ExchangeRate({
    required this.id,
    required this.currencyCode,
    required this.date,
    required this.rateToRub,
    required this.source,
    required this.fetchedAt,
  });

  final int id;
  final String currencyCode;
  final LocalDate date;

  /// Количество RUB за одну единицу валюты; строго больше нуля.
  final Decimal rateToRub;
  final ExchangeRateSource source;

  /// UTC-момент получения или ручного ввода курса.
  final DateTime fetchedAt;
}
