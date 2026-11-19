import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:rational/rational.dart';

/// Запись денежного потока в базовой валюте (exact, без округления).
final class CashflowAmount {
  const CashflowAmount({
    required this.kind,
    required this.categoryId,
    required this.occurredOn,
    required this.amount,
  });

  final CashflowKind kind;
  final int categoryId;
  final LocalDate occurredOn;
  final Rational amount;
}

/// Агрегаты денежного потока в базовой валюте (calculations §6).
abstract final class CashflowAnalytics {
  static CashflowSummary summarize(
    List<CashflowAmount> values,
    Currency baseCurrency,
  ) {
    final income = _sum(values, CashflowKind.income);
    final expense = _sum(values, CashflowKind.expense);
    final incomeMoney = MoneyMath.fromRational(income, baseCurrency);
    final expenseMoney = MoneyMath.fromRational(expense, baseCurrency);
    return CashflowSummary(
      income: incomeMoney,
      expense: expenseMoney,
      net: MoneyMath.subtract(incomeMoney, expenseMoney),
      currencyCode: baseCurrency.code,
    );
  }

  static List<CategoryTotal> byCategory(
    List<CashflowAmount> values,
    Currency baseCurrency,
  ) {
    final totals = <int, Rational>{};
    for (final value in values) {
      totals.update(
        value.categoryId,
        (existing) => existing + value.amount,
        ifAbsent: () => value.amount,
      );
    }
    return [
      for (final entry in totals.entries)
        CategoryTotal(
          categoryId: entry.key,
          total: MoneyMath.fromRational(entry.value, baseCurrency),
        ),
    ];
  }

  /// Группирует по календарным месяцам для периода >62 дней, иначе по дням;
  /// каждый бакет присутствует, отсутствие операций — нулевой summary.
  static List<CashflowPeriodPoint> series({
    required List<CashflowAmount> values,
    required DateRange period,
    required Currency baseCurrency,
  }) {
    final starts = _bucketStarts(period);
    final grouped = <LocalDate, List<CashflowAmount>>{
      for (final start in starts) start: <CashflowAmount>[],
    };
    final byMonth = _groupByMonth(period);
    for (final value in values) {
      final start = byMonth
          ? LocalDate(value.occurredOn.year, value.occurredOn.month, 1)
          : value.occurredOn;
      grouped[start]?.add(value);
    }
    return [
      for (final start in starts)
        CashflowPeriodPoint(
          periodStart: start,
          summary: summarize(grouped[start] ?? const [], baseCurrency),
        ),
    ];
  }

  static bool _groupByMonth(DateRange period) => _days(period) > 62;

  static int _days(DateRange period) =>
      period.end
          .toUtcDateTime()
          .difference(period.start.toUtcDateTime())
          .inDays +
      1;

  static List<LocalDate> _bucketStarts(DateRange period) {
    if (_groupByMonth(period)) {
      final starts = <LocalDate>[];
      var year = period.start.year;
      var month = period.start.month;
      while (true) {
        final start = LocalDate(year, month, 1);
        if (start.compareTo(period.end) > 0) break;
        starts.add(start);
        month += 1;
        if (month > 12) {
          month = 1;
          year += 1;
        }
      }
      return starts;
    }
    final starts = <LocalDate>[];
    var date = period.start;
    while (date.compareTo(period.end) <= 0) {
      starts.add(date);
      date = LocalDate.fromDateTime(
        date.toUtcDateTime().add(const Duration(days: 1)),
      );
    }
    return starts;
  }

  static Rational _sum(List<CashflowAmount> values, CashflowKind kind) {
    var total = Rational.zero;
    for (final value in values) {
      if (value.kind == kind) total += value.amount;
    }
    return total;
  }
}
