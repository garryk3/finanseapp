import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
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

CashflowAmount _amount(
  CashflowKind kind,
  int major,
  LocalDate date, {
  int categoryId = 1,
}) => CashflowAmount(
  kind: kind,
  categoryId: categoryId,
  occurredOn: date,
  amount: Rational.fromInt(major),
);

void main() {
  final date = LocalDate(2026, 11, 10);

  test('summary: income/expense/net и округление на итоге', () {
    final summary = CashflowAnalytics.summarize([
      _amount(CashflowKind.income, 1000, date),
      _amount(CashflowKind.income, 500, date),
      _amount(CashflowKind.expense, 250, date),
    ], _rub);

    expect(
      summary.income,
      const Money(minorUnits: 150000, currencyCode: 'RUB'),
    );
    expect(
      summary.expense,
      const Money(minorUnits: 25000, currencyCode: 'RUB'),
    );
    expect(summary.net, const Money(minorUnits: 125000, currencyCode: 'RUB'));
  });

  test('byCategory группирует и суммирует', () {
    final totals = CashflowAnalytics.byCategory([
      _amount(CashflowKind.expense, 10, date, categoryId: 1),
      _amount(CashflowKind.expense, 20, date, categoryId: 1),
      _amount(CashflowKind.expense, 30, date, categoryId: 2),
    ], _rub);

    expect(
      {for (final total in totals) total.categoryId: total.total.minorUnits},
      {1: 3000, 2: 3000},
    );
  });

  test('короткий период — дневные бакеты с нулями', () {
    final points = CashflowAnalytics.series(
      values: [_amount(CashflowKind.income, 100, LocalDate(2026, 11, 11))],
      period: DateRange(
        start: LocalDate(2026, 11, 10),
        end: LocalDate(2026, 11, 12),
      ),
      baseCurrency: _rub,
    );

    expect(points, hasLength(3));
    expect(points[1].periodStart, LocalDate(2026, 11, 11));
    expect(points[1].summary.income.minorUnits, 10000);
    expect(points[0].summary.income.minorUnits, 0);
  });

  test('период >62 дней — месячные бакеты, включая пустые месяцы', () {
    final points = CashflowAnalytics.series(
      values: [_amount(CashflowKind.expense, 50, LocalDate(2026, 10, 15))],
      period: DateRange(
        start: LocalDate(2026, 9, 1),
        end: LocalDate(2026, 11, 17),
      ),
      baseCurrency: _rub,
    );

    expect(
      [for (final point in points) point.periodStart],
      [LocalDate(2026, 9, 1), LocalDate(2026, 10, 1), LocalDate(2026, 11, 1)],
    );
    expect(points[0].summary.expense.minorUnits, 0);
    expect(points[1].summary.expense.minorUnits, 5000);
  });

  test('61 день — ещё дни, 63 дня — месяцы', () {
    final days = CashflowAnalytics.series(
      values: const [],
      period: DateRange(
        start: LocalDate(2026, 1, 1),
        end: LocalDate(2026, 3, 2),
      ),
      baseCurrency: _rub,
    );
    final months = CashflowAnalytics.series(
      values: const [],
      period: DateRange(
        start: LocalDate(2026, 1, 1),
        end: LocalDate(2026, 3, 4),
      ),
      baseCurrency: _rub,
    );

    expect(days, hasLength(61));
    expect(
      [for (final point in months) point.periodStart],
      [LocalDate(2026, 1, 1), LocalDate(2026, 2, 1), LocalDate(2026, 3, 1)],
    );
  });
}
