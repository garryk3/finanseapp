import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/domain/common/validation.dart';
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

void main() {
  group('MoneyMath.fromDecimal', () {
    test('RUB 1234.56 → 123456 минорных единиц', () {
      final money = MoneyMath.fromDecimal(Decimal.parse('1234.56'), _rub);

      expect(money, const Money(minorUnits: 123456, currencyCode: 'RUB'));
    });

    test('округляет half away from zero один раз', () {
      expect(MoneyMath.fromDecimal(Decimal.parse('0.005'), _usd).minorUnits, 1);
      expect(MoneyMath.fromDecimal(Decimal.parse('0.004'), _usd).minorUnits, 0);
      expect(
        MoneyMath.fromDecimal(Decimal.parse('-1.005'), _usd).minorUnits,
        -101,
      );
      expect(
        MoneyMath.fromDecimal(Decimal.parse('-0.004'), _usd).minorUnits,
        0,
      );
    });

    test('EUR 10 × 93.4567 = 934.567 → 93457 копеек', () {
      final money = MoneyMath.fromDecimal(Decimal.parse('934.567'), _rub);

      expect(money.minorUnits, 93457);
    });

    test('валюта без дробной части округляет до целого', () {
      expect(
        MoneyMath.fromDecimal(Decimal.parse('100.6'), _jpy).minorUnits,
        101,
      );
    });

    test('переполнение 64-битного диапазона — domain validation', () {
      final huge = Decimal.fromBigInt(BigInt.parse('1${'0' * 30}'));

      expect(
        () => MoneyMath.fromDecimal(huge, _rub),
        throwsA(
          isA<DomainException>()
              .having((error) => error.code, 'code', DomainErrorCode.validation)
              .having(
                (error) => error.fieldErrors,
                'fieldErrors',
                containsPair('amount', 'validationAmountOverflow'),
              ),
        ),
      );
    });
  });

  group('MoneyMath.toDecimal', () {
    test('разворачивает минорные единицы точно', () {
      expect(
        MoneyMath.toDecimal(
          const Money(minorUnits: 123456, currencyCode: 'RUB'),
          _rub,
        ),
        Decimal.parse('1234.56'),
      );
    });

    test('отрицательная разница сохраняет знак', () {
      expect(
        MoneyMath.toDecimal(
          const Money(minorUnits: -501, currencyCode: 'USD'),
          _usd,
        ),
        Decimal.parse('-5.01'),
      );
    });

    test('валюта без дробной части', () {
      expect(
        MoneyMath.toDecimal(
          const Money(minorUnits: 100, currencyCode: 'JPY'),
          _jpy,
        ),
        Decimal.fromInt(100),
      );
    });

    test('несовпадение валюты — domain validation', () {
      expect(
        () => MoneyMath.toDecimal(
          const Money(minorUnits: 100, currencyCode: 'USD'),
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
  });

  group('MoneyMath.add/subtract', () {
    const opening = Money(minorUnits: 100000, currencyCode: 'RUB');
    const deposit = Money(minorUnits: 25050, currencyCode: 'RUB');
    const withdrawal = Money(minorUnits: 10000, currencyCode: 'RUB');

    test('складывает и вычитает без округления', () {
      final withDeposit = MoneyMath.add(opening, deposit);
      final result = MoneyMath.subtract(withDeposit, withdrawal);

      expect(withDeposit, const Money(minorUnits: 125050, currencyCode: 'RUB'));
      expect(result, const Money(minorUnits: 115050, currencyCode: 'RUB'));
    });

    test('разная валюта не складывается', () {
      const usd = Money(minorUnits: 100, currencyCode: 'USD');

      expect(
        () => MoneyMath.add(opening, usd),
        throwsA(
          isA<DomainException>()
              .having((error) => error.code, 'code', DomainErrorCode.validation)
              .having(
                (error) => error.fieldErrors,
                'fieldErrors',
                containsPair('currencyCode', 'validationCurrencyMismatch'),
              ),
        ),
      );
      expect(
        () => MoneyMath.subtract(opening, usd),
        throwsA(isA<DomainException>()),
      );
    });

    test('вычисленная разница может быть отрицательной', () {
      final result = MoneyMath.subtract(deposit, opening);

      expect(result.minorUnits, -74950);
      expect(result.isNegative, isTrue);
    });

    test('переполнение при сложении/вычитании — domain validation', () {
      const max = Money(minorUnits: 9223372036854775807, currencyCode: 'RUB');
      const one = Money(minorUnits: 1, currencyCode: 'RUB');

      expect(
        () => MoneyMath.add(max, one),
        throwsA(
          isA<DomainException>()
              .having((error) => error.code, 'code', DomainErrorCode.validation)
              .having(
                (error) => error.fieldErrors,
                'fieldErrors',
                containsPair('amount', 'validationAmountOverflow'),
              ),
        ),
      );
      expect(
        () => MoneyMath.subtract(
          const Money(minorUnits: -9223372036854775808, currencyCode: 'RUB'),
          one,
        ),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('validation', () {
    test('сумма проверяется после округления (BR-T-5, BR-IE-10)', () {
      const positive = Money(minorUnits: 1, currencyCode: 'USD');

      expect(requirePositiveMoney(positive), positive);
      expect(
        () => requirePositiveMoney(
          MoneyMath.fromDecimal(Decimal.parse('0.004'), _usd),
        ),
        throwsA(
          isA<DomainException>()
              .having((error) => error.code, 'code', DomainErrorCode.validation)
              .having(
                (error) => error.fieldErrors,
                'fieldErrors',
                containsPair('amount', 'validationAmountPositive'),
              ),
        ),
      );
      expect(
        () => requirePositiveMoney(
          const Money(minorUnits: -1, currencyCode: 'USD'),
        ),
        throwsA(isA<DomainException>()),
      );
    });

    test('курс строго больше нуля (BR-VAL-4)', () {
      expect(requirePositiveRate(Decimal.parse('0.01')), Decimal.parse('0.01'));
      for (final rate in [Decimal.zero, Decimal.fromInt(-1)]) {
        expect(
          () => requirePositiveRate(rate),
          throwsA(
            isA<DomainException>()
                .having(
                  (error) => error.code,
                  'code',
                  DomainErrorCode.validation,
                )
                .having(
                  (error) => error.fieldErrors,
                  'fieldErrors',
                  containsPair('rate', 'validationRatePositive'),
                ),
          ),
          reason: rate.toString(),
        );
      }
    });
  });
}
