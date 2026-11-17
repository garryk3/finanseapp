import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

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

const _jpy = Currency(
  code: 'JPY',
  name: 'Японская иена',
  fractionDigits: 0,
  isPreset: false,
  isEnabled: true,
);

/// Неразрывный пробел — разделитель разрядов ru_RU.
const _nbsp = '\u00A0';

void main() {
  group('MoneyFormatter', () {
    const formatter = MoneyFormatter();

    test('RUB: 123 456,70 ₽', () {
      expect(
        formatter.format(
          const Money(minorUnits: 12345670, currencyCode: 'RUB'),
          _rub,
        ),
        '123${_nbsp}456,70 ₽',
      );
    });

    test('Decimal округляется по правилам валюты', () {
      expect(
        formatter.formatDecimal(Decimal.parse('123456.7'), _rub),
        '123${_nbsp}456,70 ₽',
      );
      expect(formatter.formatDecimal(Decimal.parse('0.004'), _usd), '0,00 \$');
    });

    test('отрицательная разница и ноль', () {
      expect(
        formatter.format(
          const Money(minorUnits: -12345, currencyCode: 'RUB'),
          _rub,
        ),
        '-123,45 ₽',
      );
      expect(
        formatter.format(const Money(minorUnits: 0, currencyCode: 'RUB'), _rub),
        '0,00 ₽',
      );
    });

    test('несовпадение Money.currencyCode и Currency.code — validation', () {
      expect(
        () => formatter.format(
          const Money(minorUnits: 12345, currencyCode: 'USD'),
          _rub,
        ),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.validation,
          ),
        ),
      );
    });

    test('валюта без дробной части', () {
      expect(
        formatter.format(
          const Money(minorUnits: 123457, currencyCode: 'JPY'),
          _jpy,
        ),
        '123${_nbsp}457 JPY',
      );
    });

    test('неизвестная валюта — код вместо символа', () {
      const custom = Currency(
        code: 'XYZ',
        name: 'Тестовая',
        fractionDigits: 2,
        isPreset: false,
        isEnabled: true,
      );

      expect(
        formatter.format(
          const Money(minorUnits: 12345, currencyCode: 'XYZ'),
          custom,
        ),
        '123,45 XYZ',
      );
    });

    test('крупная сумма форматируется без потери точности', () {
      expect(
        formatter.format(
          const Money(minorUnits: 9007199254740993, currencyCode: 'RUB'),
          _rub,
        ),
        '90${_nbsp}071${_nbsp}992${_nbsp}547${_nbsp}409,93 ₽',
      );
    });
  });

  group('DateFormatter', () {
    const formatter = DateFormatter();

    test('дата однозначна: 03.02.2026', () {
      expect(formatter.format(LocalDate(2026, 2, 3)), '03.02.2026');
      expect(formatter.format(LocalDate(2026, 12, 31)), '31.12.2026');
    });

    test('ISO-формат для отладки', () {
      expect(formatter.formatIso(LocalDate(2026, 2, 3)), '2026-02-03');
    });
  });
}
