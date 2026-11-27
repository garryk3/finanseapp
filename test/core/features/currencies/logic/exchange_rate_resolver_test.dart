import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRates implements ExchangeRateRepository {
  _FakeRates({this.exact, this.latest});

  final ExchangeRate? exact;
  final ExchangeRate? latest;
  int latestCalls = 0;

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async =>
      exact;

  @override
  Future<ExchangeRate?> findLatestOnOrBefore(
    String currencyCode,
    LocalDate date,
  ) async {
    latestCalls++;
    return latest;
  }

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw UnimplementedError();

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => throw UnimplementedError();
}

ExchangeRate _rate(String code, LocalDate date, String rate) => ExchangeRate(
  id: 1,
  currencyCode: code,
  date: date,
  rateToRub: Decimal.parse(rate),
  source: ExchangeRateSource.cbr,
  fetchedAt: DateTime.utc(2026, 11, 18),
);

void main() {
  final date = LocalDate(2026, 11, 18);

  test('RUB — 1 без обращения к репозиторию', () async {
    final repository = _FakeRates();

    final resolved = await ExchangeRateResolver.resolve(
      repository,
      'RUB',
      date,
    );

    expect(resolved!.rateToRub, Decimal.one);
    expect(resolved.stale, isFalse);
    expect(repository.latestCalls, 0);
  });

  test('точный курс → stale = false', () async {
    final repository = _FakeRates(exact: _rate('USD', date, '91'));

    final resolved = await ExchangeRateResolver.resolve(
      repository,
      'USD',
      date,
    );

    expect(resolved!.rateToRub, Decimal.parse('91'));
    expect(resolved.effectiveDate, date);
    expect(resolved.stale, isFalse);
    expect(repository.latestCalls, 0);
  });

  test(
    'CALC-048: нет точного, есть прошлый → резервный курс, stale = true',
    () async {
      final past = LocalDate(2026, 11, 15);
      final repository = _FakeRates(latest: _rate('USD', past, '90'));

      final resolved = await ExchangeRateResolver.resolve(
        repository,
        'USD',
        date,
      );

      expect(resolved!.rateToRub, Decimal.parse('90'));
      expect(resolved.effectiveDate, past);
      expect(resolved.stale, isTrue);
      expect(repository.latestCalls, 1);
    },
  );

  test('CALC-049: нет ни точного, ни прошлого → null', () async {
    final resolved = await ExchangeRateResolver.resolve(
      _FakeRates(),
      'USD',
      date,
    );

    expect(resolved, isNull);
  });
}
