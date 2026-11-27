import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_events.dart';
import 'package:finanseapp/core/features/currencies/logic/rate_refresh_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../database/database_fixtures.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

const _rub = Currency(
  code: 'RUB',
  name: 'Российский рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _usd = Currency(
  code: 'USD',
  name: 'Доллар США',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _eur = Currency(
  code: 'EUR',
  name: 'Евро',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

ExchangeRate _rate(String code, LocalDate date, [String value = '90']) =>
    ExchangeRate(
      id: 1,
      currencyCode: code,
      date: date,
      rateToRub: Decimal.parse(value),
      source: ExchangeRateSource.cbr,
      fetchedAt: DateTime.utc(2026, 11, 18),
    );

final class _FakeCurrencyRepository implements CurrencyRepository {
  _FakeCurrencyRepository(this.enabled);

  List<Currency> enabled;

  @override
  Future<List<Currency>> getEnabled() async => enabled;

  @override
  Stream<List<Currency>> watchAll() => const Stream.empty();

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(
    String code,
    String name,
    int fractionDigits,
  ) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class _FakeRateRepository implements ExchangeRateRepository {
  final Set<String> cached = <String>{};
  final Map<String, Object> failures = <String, Object>{};
  final List<String> fetched = <String>[];

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async =>
      cached.contains(currencyCode) ? _rate(currencyCode, date) : null;

  @override
  Future<ExchangeRate?> findLatestOnOrBefore(
    String currencyCode,
    LocalDate date,
  ) async => null;

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) async {
    fetched.add(currencyCode);
    final error = failures[currencyCode];
    if (error != null) throw error;
    return _rate(currencyCode, date);
  }

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) async => _rate(currencyCode, date, rateToRub.toString());
}

void main() {
  final date = LocalDate(2026, 11, 18);

  RateRefreshService build({
    required _FakeCurrencyRepository currencies,
    required _FakeRateRepository rates,
    LocalDate Function()? today,
  }) => RateRefreshService(
    currencyRepository: currencies,
    rateRepository: rates,
    today: today ?? (() => date),
  );

  test('обновляет только включённые не-RUB валюты', () async {
    final rates = _FakeRateRepository();
    final service = build(
      currencies: _FakeCurrencyRepository(const [_rub, _usd, _eur]),
      rates: rates,
    );

    final report = await service.refreshToday();

    expect(report.refreshed, 2);
    expect(report.failures, isEmpty);
    expect(rates.fetched, ['USD', 'EUR']);
  });

  test('пропускает уже закэшированный курс', () async {
    final rates = _FakeRateRepository()..cached.add('USD');
    final service = build(
      currencies: _FakeCurrencyRepository(const [_rub, _usd, _eur]),
      rates: rates,
    );

    final report = await service.refreshToday();

    expect(report.refreshed, 1);
    expect(report.skipped, 1);
    expect(rates.fetched, ['EUR']);
  });

  test('повторный вызов в тот же день без force — no-op', () async {
    final rates = _FakeRateRepository();
    final service = build(
      currencies: _FakeCurrencyRepository(const [_rub, _usd]),
      rates: rates,
    );

    await service.refreshToday();
    final second = await service.refreshToday();

    expect(second.noOp, isTrue);
    expect(rates.fetched, ['USD']);
  });

  test('force повторяет обновление в тот же день', () async {
    final rates = _FakeRateRepository();
    final service = build(
      currencies: _FakeCurrencyRepository(const [_rub, _usd]),
      rates: rates,
    );

    await service.refreshToday();
    final second = await service.refreshToday(force: true);

    expect(second.noOp, isFalse);
    expect(rates.fetched, ['USD', 'USD']);
  });

  test('новая локальная дата снимает guard', () async {
    final rates = _FakeRateRepository();
    var today = date;
    final service = build(
      currencies: _FakeCurrencyRepository(const [_rub, _usd]),
      rates: rates,
      today: () => today,
    );

    await service.refreshToday();
    today = LocalDate(2026, 11, 19);
    final second = await service.refreshToday();

    expect(second.noOp, isFalse);
    expect(rates.fetched, ['USD', 'USD']);
  });

  test('ошибка одной валюты не мешает другим', () async {
    final rates = _FakeRateRepository()
      ..failures['USD'] = const DomainException(
        DomainErrorCode.networkUnavailable,
      );
    final service = build(
      currencies: _FakeCurrencyRepository(const [_rub, _usd, _eur]),
      rates: rates,
    );

    final report = await service.refreshToday();

    expect(report.refreshed, 1);
    expect(report.failures.map((failure) => failure.currencyCode), ['USD']);
    expect(
      report.failures.single.error.code,
      DomainErrorCode.networkUnavailable,
    );
  });

  test(
    'успешное обновление инкрементит revision (дашборд пересчитается)',
    () async {
      final db = openTestDatabase();
      addTearDown(db.close);
      final repository = ExchangeRateRepositoryImpl(
        db.currenciesDao,
        CbrExchangeRateClient(
          client: MockClient(
            (_) async =>
                http.Response.bytes(utf8.encode(fixture('cbr_daily.xml')), 200),
          ),
        ),
      );
      final service = RateRefreshService(
        currencyRepository: _FakeCurrencyRepository(const [_rub, _usd]),
        rateRepository: repository,
        today: () => date,
      );
      final before = exchangeRateRevision.value;

      final report = await service.refreshToday();

      expect(report.refreshed, 1);
      expect(exchangeRateRevision.value, before + 1);
      expect(
        (await repository.find('USD', date))!.rateToRub,
        Decimal.parse('93.4567'),
      );
    },
  );
}
