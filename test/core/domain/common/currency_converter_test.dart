import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/currency_converter.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
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

const _eur = Currency(
  code: 'EUR',
  name: 'Евро',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

Matcher throwsDomain(DomainErrorCode code) =>
    throwsA(isA<DomainException>().having((error) => error.code, 'code', code));

void main() {
  group('CurrencyConverter.convertWithRates', () {
    test('CALC-001: 100 USD по 90.25 → 9 025,00 RUB', () {
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 10000, currencyCode: 'USD'),
        source: _usd,
        target: _rub,
        sourceRateToRub: Decimal.parse('90.25'),
      );

      expect(result, const Money(minorUnits: 902500, currencyCode: 'RUB'));
    });

    test('CALC-002: 250,50 EUR по 100,10 → 25 075,05 RUB', () {
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 25050, currencyCode: 'EUR'),
        source: _eur,
        target: _rub,
        sourceRateToRub: Decimal.parse('100.10'),
      );

      expect(result, const Money(minorUnits: 2507505, currencyCode: 'RUB'));
    });

    test('CALC-003: RUB не требует курса и не меняется', () {
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 12345, currencyCode: 'RUB'),
        source: _rub,
        target: _rub,
        sourceRateToRub: Decimal.zero,
      );

      expect(result, const Money(minorUnits: 12345, currencyCode: 'RUB'));
    });

    test('CALC-004: 100 USD → EUR по USD 90 / EUR 100 даёт 90,00 EUR', () {
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 10000, currencyCode: 'USD'),
        source: _usd,
        target: _eur,
        sourceRateToRub: Decimal.fromInt(90),
        targetRateToRub: Decimal.fromInt(100),
      );

      expect(result, const Money(minorUnits: 9000, currencyCode: 'EUR'));
    });

    test('кратный курс EUR 10 × 93,4567 даёт 93457 копеек', () {
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 1000, currencyCode: 'EUR'),
        source: _eur,
        target: _rub,
        sourceRateToRub: Decimal.parse('93.4567'),
      );

      expect(result, const Money(minorUnits: 93457, currencyCode: 'RUB'));
    });

    test('CALC-005: 0,01 USD по 90,555 → 0,91 RUB одним округлением', () {
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 1, currencyCode: 'USD'),
        source: _usd,
        target: _rub,
        sourceRateToRub: Decimal.parse('90.555'),
      );

      expect(result, const Money(minorUnits: 91, currencyCode: 'RUB'));
    });

    test('точное деление без промежуточной потери хвоста', () {
      // 1 RUB / 90,555 = 0,011042... USD → 0,01 USD (1 цент).
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 100, currencyCode: 'RUB'),
        source: _rub,
        target: _usd,
        sourceRateToRub: Decimal.one,
        targetRateToRub: Decimal.parse('90.555'),
      );

      expect(result, const Money(minorUnits: 1, currencyCode: 'USD'));
    });

    test('конверсия в ту же валюту — identity', () {
      const value = Money(minorUnits: 777, currencyCode: 'USD');

      final result = CurrencyConverter.convertWithRates(
        value: value,
        source: _usd,
        target: _usd,
        sourceRateToRub: Decimal.zero,
        targetRateToRub: Decimal.zero,
      );

      expect(result, value);
    });

    test('CALC-007: нулевой и отрицательный курс — validation', () {
      for (final rate in [Decimal.zero, Decimal.fromInt(-1)]) {
        expect(
          () => CurrencyConverter.convertWithRates(
            value: const Money(minorUnits: 100, currencyCode: 'USD'),
            source: _usd,
            target: _rub,
            sourceRateToRub: rate,
          ),
          throwsDomain(DomainErrorCode.validation),
          reason: rate.toString(),
        );
      }
    });

    test('CALC-007: отсутствие target-курса — rateUnavailable', () {
      expect(
        () => CurrencyConverter.convertWithRates(
          value: const Money(minorUnits: 100, currencyCode: 'USD'),
          source: _usd,
          target: _eur,
          sourceRateToRub: Decimal.fromInt(90),
        ),
        throwsDomain(DomainErrorCode.rateUnavailable),
      );
    });

    test('нулевой target-курс — validation', () {
      expect(
        () => CurrencyConverter.convertWithRates(
          value: const Money(minorUnits: 100, currencyCode: 'USD'),
          source: _usd,
          target: _eur,
          sourceRateToRub: Decimal.fromInt(90),
          targetRateToRub: Decimal.zero,
        ),
        throwsDomain(DomainErrorCode.validation),
      );
    });

    test('валюта Money не совпадает с source — validation', () {
      expect(
        () => CurrencyConverter.convertWithRates(
          value: const Money(minorUnits: 100, currencyCode: 'EUR'),
          source: _usd,
          target: _rub,
          sourceRateToRub: Decimal.fromInt(90),
        ),
        throwsDomain(DomainErrorCode.validation),
      );
    });

    test('RUB как source игнорирует переданный курс (CALC-003)', () {
      for (final ignoredRate in [Decimal.zero, Decimal.parse('90.555')]) {
        final result = CurrencyConverter.convertWithRates(
          value: const Money(minorUnits: 12345, currencyCode: 'RUB'),
          source: _rub,
          target: _usd,
          sourceRateToRub: ignoredRate,
          targetRateToRub: Decimal.fromInt(90),
        );

        // 123,45 RUB / 90 = 1,371666… → 1,37 USD.
        expect(
          result,
          const Money(minorUnits: 137, currencyCode: 'USD'),
          reason: ignoredRate.toString(),
        );
      }
    });

    test('конверсия и прямое округление используют одно правило', () {
      final converted = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 1, currencyCode: 'USD'),
        source: _usd,
        target: _rub,
        sourceRateToRub: Decimal.parse('90.555'),
      );
      final direct = MoneyMath.fromDecimal(
        Decimal.parse('0.01') * Decimal.parse('90.555'),
        _rub,
      );

      expect(converted, direct);
    });

    test('RUB как target не требует target-курса', () {
      final result = CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 100, currencyCode: 'USD'),
        source: _usd,
        target: _rub,
        sourceRateToRub: Decimal.fromInt(1),
        targetRateToRub: Decimal.zero,
      );

      expect(result, const Money(minorUnits: 100, currencyCode: 'RUB'));
    });
  });
}
