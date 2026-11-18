import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';

/// Реализация кэша курсов: точная дата, ЦБ и ручной fallback (BR-C-2/3/7).
final class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  const ExchangeRateRepositoryImpl(this._dao, this._client);

  final CurrenciesDao _dao;
  final CbrExchangeRateClient _client;

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    final row = await _dao.findRate(currencyCode, date);
    return row == null ? null : _map(row);
  }

  /// Загружает курс на точную дату; ручной курс и кэш не перетираются.
  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) async {
    if (currencyCode == 'RUB') {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationRubRateFixed'},
      );
    }
    final cached = await find(currencyCode, date);
    if (cached != null) return cached;

    final quote = await _client.fetch(currencyCode, date);
    final row = await _dao.saveRate(
      currencyCode: currencyCode,
      date: date,
      rateToRub: quote.rateToRub,
      source: ExchangeRateSource.cbr,
    );
    return _map(row);
  }

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) async {
    final row = await _dao.saveManualRate(currencyCode, date, rateToRub);
    return _map(row);
  }

  static ExchangeRate _map(ExchangeRateRow row) => ExchangeRate(
    id: row.id,
    currencyCode: row.currencyCode,
    date: row.date,
    rateToRub: row.rateToRub,
    source: row.source,
    fetchedAt: row.fetchedAt,
  );
}
