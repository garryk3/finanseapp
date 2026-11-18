import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/logic/account_forecast_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Российский рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

AccountAsset _account({
  required LocalDate start,
  LocalDate? end,
  String rate = '12',
}) => AccountAsset(
  id: 1,
  name: 'Вклад',
  currencyCode: 'RUB',
  openingValue: Money(minorUnits: 10000000, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  bankId: 1,
  annualRate: Decimal.parse(rate),
  startDate: start,
  endDate: end,
);

void main() {
  final current = const Money(minorUnits: 10000000, currencyCode: 'RUB');

  test('CALC-016: 100000, 12%, 01.01.2026 → 01.01.2027 = 112 682,50', () {
    final result = AccountForecastCalculator.call(
      account: _account(
        start: LocalDate(2026, 1, 1),
        end: LocalDate(2027, 1, 1),
      ),
      currentBalance: current,
      asOf: LocalDate(2026, 1, 1),
      currency: _rub,
    );

    expect(result!.minorUnits, 11268250);
  });

  test('CALC-017: 100000, 12%, 01.01 → 01.07 = 106 152,02', () {
    final result = AccountForecastCalculator.call(
      account: _account(
        start: LocalDate(2026, 1, 1),
        end: LocalDate(2026, 7, 1),
      ),
      currentBalance: current,
      asOf: LocalDate(2026, 1, 1),
      currency: _rub,
    );

    expect(result!.minorUnits, 10615202);
  });

  test('CALC-018: 15.01 → 14.02 = 100 967,59', () {
    final result = AccountForecastCalculator.call(
      account: _account(
        start: LocalDate(2026, 1, 15),
        end: LocalDate(2026, 2, 14),
      ),
      currentBalance: current,
      asOf: LocalDate(2026, 1, 15),
      currency: _rub,
    );

    expect(result!.minorUnits, 10096759);
  });

  test('CALC-019: 31.01.2028 → 30.03.2028 = 101 977,26 (clamp февраля)', () {
    final result = AccountForecastCalculator.call(
      account: _account(
        start: LocalDate(2028, 1, 31),
        end: LocalDate(2028, 3, 30),
      ),
      currentBalance: current,
      asOf: LocalDate(2028, 1, 31),
      currency: _rub,
    );

    expect(result!.minorUnits, 10197726);
  });

  test('CALC-020: 50 000, 7,5%, 10.02 → 10.11 = 52 883,85', () {
    final account = AccountAsset(
      id: 1,
      name: 'Вклад',
      currencyCode: 'RUB',
      openingValue: const Money(minorUnits: 5000000, currencyCode: 'RUB'),
      createdAt: DateTime.utc(2026),
      bankId: 1,
      annualRate: Decimal.parse('7.5'),
      startDate: LocalDate(2026, 2, 10),
      endDate: LocalDate(2026, 11, 10),
    );
    final result = AccountForecastCalculator.call(
      account: account,
      currentBalance: const Money(minorUnits: 5000000, currencyCode: 'RUB'),
      asOf: LocalDate(2026, 2, 10),
      currency: _rub,
    );

    expect(result!.minorUnits, 5288385);
  });

  test('CALC-021: ставка 0, нет endDate и истёкший срок', () {
    final zero = AccountForecastCalculator.call(
      account: _account(
        start: LocalDate(2026, 1, 1),
        end: LocalDate(2027, 1, 1),
        rate: '0',
      ),
      currentBalance: current,
      asOf: LocalDate(2026, 1, 1),
      currency: _rub,
    );
    final noEnd = AccountForecastCalculator.call(
      account: _account(start: LocalDate(2026, 1, 1)),
      currentBalance: current,
      asOf: LocalDate(2026, 1, 1),
      currency: _rub,
    );
    final expired = AccountForecastCalculator.call(
      account: _account(
        start: LocalDate(2025, 1, 1),
        end: LocalDate(2025, 6, 1),
      ),
      currentBalance: current,
      asOf: LocalDate(2026, 1, 1),
      currency: _rub,
    );

    expect(zero, current);
    expect(noEnd, isNull);
    expect(expired, current);
  });
}
