import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/logic/property_yield_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

void main() {
  test('CALC-036: 120 000 при 5 000 000 → 2.4% gross, 2.0% net', () {
    final yieldValue = PropertyYieldCalculator.calculate(
      incomeRub: _rubles(120000),
      expenseRub: _rubles(20000),
      valueRub: _rubles(5000000),
    );

    expect(yieldValue.grossPercent, Decimal.parse('2.4'));
    expect(yieldValue.netPercent, Decimal.parse('2'));
    expect(yieldValue.available, isTrue);
  });

  test('нулевая стоимость → null', () {
    final yieldValue = PropertyYieldCalculator.calculate(
      incomeRub: _rubles(120000),
      expenseRub: _rubles(20000),
      valueRub: _rubles(0),
    );

    expect(yieldValue.grossPercent, isNull);
    expect(yieldValue.netPercent, isNull);
    expect(yieldValue.available, isFalse);
  });

  test('расходы больше доходов дают отрицательный net', () {
    final yieldValue = PropertyYieldCalculator.calculate(
      incomeRub: _rubles(10000),
      expenseRub: _rubles(30000),
      valueRub: _rubles(1000000),
    );

    expect(yieldValue.grossPercent, Decimal.parse('1'));
    expect(yieldValue.netPercent, Decimal.parse('-2'));
  });

  test('trailingYear: 12 месяцев и clamp 29 февраля', () {
    expect(
      PropertyYieldCalculator.trailingYear(LocalDate(2026, 11, 20)).start,
      LocalDate(2025, 11, 20),
    );
    expect(
      PropertyYieldCalculator.trailingYear(LocalDate(2028, 2, 29)).start,
      LocalDate(2027, 2, 28),
    );
  });
}
