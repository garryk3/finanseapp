import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/dashboard/logic/safety_cushion.dart';
import 'package:flutter_test/flutter_test.dart';

Money _rub(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

CashflowSummary _flow({required int income, required int expense}) =>
    CashflowSummary(
      income: _rub(income),
      expense: _rub(expense),
      net: _rub(income - expense),
      currencyCode: 'RUB',
    );

void main() {
  test('runway = деньги / средние расходы, цель 6 мес, ETA по прибыли', () {
    final cushion = SafetyCushion.calculate(
      cash: _rub(3000),
      lastThreeMonths: _flow(income: 3600, expense: 3000),
    )!;

    expect(cushion.months, 3);
    expect(cushion.avgExpenses, _rub(1000));
    expect(cushion.avgIncome, _rub(1200));
    expect(cushion.monthlyProfit, _rub(200));
    expect(cushion.target, _rub(6000));
    expect(cushion.monthsToTarget, 15);
  });

  test('нет расходов — подушки нет', () {
    expect(
      SafetyCushion.calculate(
        cash: _rub(1000),
        lastThreeMonths: _flow(income: 500, expense: 0),
      ),
      isNull,
    );
  });

  test('цель достигнута — срок 0', () {
    final cushion = SafetyCushion.calculate(
      cash: _rub(10000),
      lastThreeMonths: _flow(income: 3000, expense: 3000),
    )!;
    expect(cushion.months, 10);
    expect(cushion.monthsToTarget, 0);
  });

  test('нулевые деньги — 0 месяцев', () {
    final cushion = SafetyCushion.calculate(
      cash: _rub(0),
      lastThreeMonths: _flow(income: 300, expense: 300),
    )!;
    expect(cushion.months, 0);
    expect(cushion.monthsToTarget, isNull);
  });

  test('прибыль не покрывает расходы — срока цели нет', () {
    final cushion = SafetyCushion.calculate(
      cash: _rub(500),
      lastThreeMonths: _flow(income: 1000, expense: 3000),
    )!;
    expect(cushion.monthsToTarget, isNull);
  });

  test('разные валюты — расчёт не строится', () {
    expect(
      SafetyCushion.calculate(
        cash: const Money(minorUnits: 100, currencyCode: 'USD'),
        lastThreeMonths: _flow(income: 100, expense: 100),
      ),
      isNull,
    );
  });

  test('runway floor с остатком', () {
    final cushion = SafetyCushion.calculate(
      cash: _rub(1000),
      lastThreeMonths: _flow(income: 3000, expense: 1200),
    )!;
    // 1000 × 3 / 1200 = 2.5 → 2 месяца.
    expect(cushion.months, 2);
  });

  test('отрицательный cash приравнивается к нулю во всех формулах', () {
    final cushion = SafetyCushion.calculate(
      cash: const Money(minorUnits: -500000, currencyCode: 'RUB'),
      lastThreeMonths: _flow(income: 3600, expense: 3000),
    )!;
    expect(cushion.cash, _rub(0));
    expect(cushion.months, 0);
    expect(cushion.monthsToTarget, 30);
  });

  test('ETA округляется вверх', () {
    final cushion = SafetyCushion.calculate(
      cash: _rub(1000),
      lastThreeMonths: _flow(income: 3700, expense: 3000),
    )!;
    // Цель 6000, остаток 5000, прибыль 700 за 3 месяца → 15000/700 = 21.4 → 22.
    expect(cushion.monthsToTarget, 22);
  });
}
