import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/dashboard/logic/tax_estimate.dart';
import 'package:flutter_test/flutter_test.dart';

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

void main() {
  test('13% от суммы процентов', () {
    final estimate = TaxEstimate.calculate(
      base: _rubles(10000),
      ratePercent: 13,
    );

    expect(estimate.tax, _rubles(1300));
    expect(estimate.base, _rubles(10000));
    expect(estimate.ratePercent, 13);
  });

  test('ставка 0 → налог 0', () {
    final estimate = TaxEstimate.calculate(base: _rubles(1234), ratePercent: 0);

    expect(estimate.tax, const Money(minorUnits: 0, currencyCode: 'RUB'));
  });

  test('ставка 100% → весь доход', () {
    final estimate = TaxEstimate.calculate(
      base: _rubles(500),
      ratePercent: 100,
    );

    expect(estimate.tax, _rubles(500));
  });

  test('округление до копейки half away from zero', () {
    // 333 коп × 13% = 43.29 коп → 43.
    expect(
      TaxEstimate.calculate(
        base: const Money(minorUnits: 333, currencyCode: 'RUB'),
        ratePercent: 13,
      ).tax.minorUnits,
      43,
    );
    // 335 коп × 13% = 43.55 коп → 44.
    expect(
      TaxEstimate.calculate(
        base: const Money(minorUnits: 335, currencyCode: 'RUB'),
        ratePercent: 13,
      ).tax.minorUnits,
      44,
    );
  });

  test('валюту базы сохраняет', () {
    final estimate = TaxEstimate.calculate(
      base: const Money(minorUnits: 1000, currencyCode: 'USD'),
      ratePercent: 13,
    );

    expect(estimate.tax.currencyCode, 'USD');
  });

  test('диапазон ставки 0..100', () {
    expect(TaxEstimate.isValidRatePercent(0), isTrue);
    expect(TaxEstimate.isValidRatePercent(13), isTrue);
    expect(TaxEstimate.isValidRatePercent(100), isTrue);
    expect(TaxEstimate.isValidRatePercent(-1), isFalse);
    expect(TaxEstimate.isValidRatePercent(101), isFalse);
  });
}
