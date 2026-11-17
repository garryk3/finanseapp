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

/// Эталоны calculations §9, относящиеся к денежным типам и курсам.
///
/// CALC-009…015 — расчёты активов; их закрывают задачи 5.1–5.2, сводный прогон
/// всех 36 эталонов — 11.1.
void main() {
  test('CALC-001…005: конвертация по эталонным курсам', () {
    final cases = [
      (
        id: 'CALC-001',
        value: const Money(minorUnits: 10000, currencyCode: 'USD'),
        source: _usd,
        target: _rub,
        sourceRate: '90.25',
        targetRate: null,
        expected: const Money(minorUnits: 902500, currencyCode: 'RUB'),
      ),
      (
        id: 'CALC-002',
        value: const Money(minorUnits: 25050, currencyCode: 'EUR'),
        source: _eur,
        target: _rub,
        sourceRate: '100.10',
        targetRate: null,
        expected: const Money(minorUnits: 2507505, currencyCode: 'RUB'),
      ),
      (
        id: 'CALC-003',
        value: const Money(minorUnits: 12345, currencyCode: 'RUB'),
        source: _rub,
        target: _rub,
        sourceRate: '0',
        targetRate: null,
        expected: const Money(minorUnits: 12345, currencyCode: 'RUB'),
      ),
      (
        id: 'CALC-004',
        value: const Money(minorUnits: 10000, currencyCode: 'USD'),
        source: _usd,
        target: _eur,
        sourceRate: '90',
        targetRate: '100',
        expected: const Money(minorUnits: 9000, currencyCode: 'EUR'),
      ),
      (
        id: 'CALC-005',
        value: const Money(minorUnits: 1, currencyCode: 'USD'),
        source: _usd,
        target: _rub,
        sourceRate: '90.555',
        targetRate: null,
        expected: const Money(minorUnits: 91, currencyCode: 'RUB'),
      ),
    ];

    for (final testCase in cases) {
      final targetRate = testCase.targetRate;
      final result = CurrencyConverter.convertWithRates(
        value: testCase.value,
        source: testCase.source,
        target: testCase.target,
        sourceRateToRub: Decimal.parse(testCase.sourceRate),
        targetRateToRub: targetRate == null ? null : Decimal.parse(targetRate),
      );

      expect(result, testCase.expected, reason: testCase.id);
    }
  });

  test('CALC-006: 1,005 при округлении до минорной единицы даёт 1,01', () {
    final money = MoneyMath.fromDecimal(Decimal.parse('1.005'), _usd);

    expect(money, const Money(minorUnits: 101, currencyCode: 'USD'));
  });

  test('CALC-007: нулевой/отрицательный/отсутствующий курс — ошибка', () {
    expect(
      () => CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 100, currencyCode: 'USD'),
        source: _usd,
        target: _rub,
        sourceRateToRub: Decimal.zero,
      ),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.validation,
        ),
      ),
    );
    expect(
      () => CurrencyConverter.convertWithRates(
        value: const Money(minorUnits: 100, currencyCode: 'USD'),
        source: _usd,
        target: _eur,
        sourceRateToRub: Decimal.fromInt(90),
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

  test('-0 нормализуется в ноль', () {
    final money = MoneyMath.fromDecimal(Decimal.parse('-0.001'), _usd);

    expect(money.minorUnits, 0);
    expect(money.isNegative, isFalse);
  });
}
