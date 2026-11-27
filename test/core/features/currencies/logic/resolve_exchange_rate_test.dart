import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/resolve_exchange_rate.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRates implements ExchangeRateRepository {
  int finds = 0;
  int fetches = 0;
  int manuals = 0;
  ExchangeRate? cached;
  Object? fetchError;

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    finds++;
    return cached;
  }

  @override
  Future<ExchangeRate?> findLatestOnOrBefore(
    String currencyCode,
    LocalDate date,
  ) async => null;

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) async {
    fetches++;
    final error = fetchError;
    if (error != null) throw error;
    return _rate(
      currencyCode,
      date,
      Decimal.parse('93.4567'),
      ExchangeRateSource.cbr,
    );
  }

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) async {
    manuals++;
    return _rate(currencyCode, date, rateToRub, ExchangeRateSource.manual);
  }

  ExchangeRate _rate(
    String code,
    LocalDate date,
    Decimal rate,
    ExchangeRateSource source,
  ) => ExchangeRate(
    id: 1,
    currencyCode: code,
    date: date,
    rateToRub: rate,
    source: source,
    fetchedAt: DateTime.utc(2026, 11, 18),
  );
}

void main() {
  final date = LocalDate(2026, 11, 18);

  test('RUB — фиксированная 1 без сети', () async {
    final repository = _FakeRates();

    final rate = await ResolveExchangeRate.call(repository, 'RUB', date);

    expect(rate.rateToRub, Decimal.one);
    expect(repository.finds, 0);
    expect(repository.fetches, 0);
  });

  test('ручной курс сохраняется и приоритетнее сети', () async {
    final repository = _FakeRates();

    final rate = await ResolveExchangeRate.call(
      repository,
      'USD',
      date,
      manualRate: Decimal.parse('90'),
    );

    expect(rate.rateToRub, Decimal.parse('90'));
    expect(repository.manuals, 1);
    expect(repository.fetches, 0);
  });

  test('кэш точной даты используется до сети', () async {
    final repository = _FakeRates()
      ..cached = ExchangeRate(
        id: 2,
        currencyCode: 'USD',
        date: date,
        rateToRub: Decimal.parse('91'),
        source: ExchangeRateSource.cbr,
        fetchedAt: DateTime.utc(2026, 11, 18),
      );

    final rate = await ResolveExchangeRate.call(repository, 'USD', date);

    expect(rate.rateToRub, Decimal.parse('91'));
    expect(repository.fetches, 0);
  });

  test('пустой кэш → запрос ЦБ', () async {
    final repository = _FakeRates();

    final rate = await ResolveExchangeRate.call(repository, 'USD', date);

    expect(rate.rateToRub, Decimal.parse('93.4567'));
    expect(repository.fetches, 1);
  });

  test('offline + пустой кэш пробрасывает rate/network ошибку', () async {
    final repository = _FakeRates()
      ..fetchError = const DomainException(DomainErrorCode.networkUnavailable);

    await expectLater(
      ResolveExchangeRate.call(repository, 'USD', date),
      throwsA(isA<DomainException>()),
    );
  });
}
