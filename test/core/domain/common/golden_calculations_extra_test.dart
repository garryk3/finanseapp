import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/logic/cashflow_analytics.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rational/rational.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

CashflowAmount _amount(CashflowKind kind, int major) => CashflowAmount(
  kind: kind,
  categoryId: 1,
  occurredOn: LocalDate(2026, 11, 10),
  amount: Rational.fromInt(major),
);

/// Literal-эталоны calculations §9, дополняющие golden_calculations_test.
void main() {
  test('CALC-023: income 100 000, expense 30 000 → net 70 000', () {
    final summary = CashflowAnalytics.summarize([
      _amount(CashflowKind.income, 100000),
      _amount(CashflowKind.expense, 30000),
    ], _rub);

    expect(
      summary.income,
      const Money(minorUnits: 10000000, currencyCode: 'RUB'),
    );
    expect(
      summary.expense,
      const Money(minorUnits: 3000000, currencyCode: 'RUB'),
    );
    expect(summary.net, const Money(minorUnits: 7000000, currencyCode: 'RUB'));
  });

  test('CALC-024: property net 60 000 − 15 000 = 45 000', () {
    final summary = CashflowAnalytics.summarize([
      _amount(CashflowKind.income, 60000),
      _amount(CashflowKind.expense, 15000),
    ], _rub);

    expect(summary.net, const Money(minorUnits: 4500000, currencyCode: 'RUB'));
  });
}
