import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_xml_parser.dart';
import 'package:flutter_test/flutter_test.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  const parser = CbrXmlParser();
  final date = LocalDate(2026, 11, 18);

  test('USD Value 93,4567 при Nominal 1 → 93.4567', () {
    final quote = parser.parse(
      fixture('cbr_daily.xml'),
      currencyCode: 'USD',
      requestedDate: date,
    );

    expect(quote.date, date);
    expect(quote.rateToRub, Decimal.parse('93.4567'));
  });

  test('HKD Nominal 10 делится точно: 11,99 / 10 = 1.199', () {
    final quote = parser.parse(
      fixture('cbr_daily.xml'),
      currencyCode: 'HKD',
      requestedDate: date,
    );

    expect(quote.rateToRub, Decimal.parse('1.199'));
  });

  test('дата документа не совпадает с запрошенной → rateUnavailable', () {
    expect(
      () => parser.parse(
        fixture('cbr_daily_wrong_date.xml'),
        currencyCode: 'USD',
        requestedDate: date,
      ),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.rateUnavailable,
        ),
      ),
    );
  });

  test('неизвестный код валюты → rateUnavailable', () {
    expect(
      () => parser.parse(
        fixture('cbr_daily.xml'),
        currencyCode: 'GBP',
        requestedDate: date,
      ),
      throwsA(isA<DomainException>()),
    );
  });
}
