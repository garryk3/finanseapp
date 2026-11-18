import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';

/// Разрешает курс на точную дату (domain_model §10, BR-C-1/2).
///
/// RUB — фиксированная 1 без сети; явный ручной курс сохраняется и имеет
/// приоритет; кэш точной даты используется до сети; иначе запрос ЦБ.
abstract final class ResolveExchangeRate {
  static Future<ExchangeRate> call(
    ExchangeRateRepository repository,
    String currencyCode,
    LocalDate date, {
    Decimal? manualRate,
  }) async {
    if (currencyCode == 'RUB') {
      return ExchangeRate(
        id: 0,
        currencyCode: 'RUB',
        date: date,
        rateToRub: Decimal.one,
        source: ExchangeRateSource.manual,
        fetchedAt: DateTime.now().toUtc(),
      );
    }
    if (manualRate != null) {
      return repository.saveManual(currencyCode, date, manualRate);
    }
    final cached = await repository.find(currencyCode, date);
    if (cached != null) return cached;
    return repository.fetchFromCbr(currencyCode, date);
  }
}
