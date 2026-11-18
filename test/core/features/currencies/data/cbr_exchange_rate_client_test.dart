import 'dart:convert';
import 'dart:io';

import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  final date = LocalDate(2026, 11, 18);

  test('запрашивает точную дату и парсит курс', () async {
    String? requested;
    final client = CbrExchangeRateClient(
      client: MockClient((request) async {
        requested = request.url.queryParameters['date_req'];
        return http.Response.bytes(utf8.encode(fixture('cbr_daily.xml')), 200);
      }),
    );

    final quote = await client.fetch('USD', date);

    expect(requested, '18/11/2026');
    expect(quote.rateToRub.toString(), '93.4567');
  });

  test('ответ ЦБ другой даты → rateUnavailable', () async {
    final client = CbrExchangeRateClient(
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(fixture('cbr_daily_wrong_date.xml')),
          200,
        ),
      ),
    );

    await expectLater(
      client.fetch('USD', date),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.rateUnavailable,
        ),
      ),
    );
  });

  test('битый XML с кодом 200 → rateUnavailable', () async {
    final client = CbrExchangeRateClient(
      client: MockClient((_) async => http.Response('<broken', 200)),
    );

    await expectLater(
      client.fetch('USD', date),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.rateUnavailable,
        ),
      ),
    );
  });

  test('HTTP-ошибка → networkUnavailable', () async {
    final client = CbrExchangeRateClient(
      client: MockClient((_) async => http.Response('', 500)),
    );

    await expectLater(
      client.fetch('USD', date),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.networkUnavailable,
        ),
      ),
    );
  });
}
