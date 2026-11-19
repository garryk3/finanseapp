import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('месяц: календарные границы текущего месяца', () {
    final range = analyticsRange(
      period: AnalyticsPeriod.month,
      today: LocalDate(2026, 2, 15),
    );

    expect(range.start, LocalDate(2026, 2, 1));
    expect(range.end, LocalDate(2026, 2, 28));
  });

  test('3 и 6 месяцев включают текущий месяц', () {
    final three = analyticsRange(
      period: AnalyticsPeriod.threeMonths,
      today: LocalDate(2027, 1, 15),
    );
    final six = analyticsRange(
      period: AnalyticsPeriod.sixMonths,
      today: LocalDate(2027, 1, 15),
    );

    expect(three.start, LocalDate(2026, 11, 1));
    expect(three.end, LocalDate(2027, 1, 31));
    expect(six.start, LocalDate(2026, 8, 1));
    expect(six.end, LocalDate(2027, 1, 31));
  });

  test('год: 1 января — 31 декабря', () {
    final range = analyticsRange(
      period: AnalyticsPeriod.year,
      today: LocalDate(2026, 7, 4),
    );

    expect(range.start, LocalDate(2026, 1, 1));
    expect(range.end, LocalDate(2026, 12, 31));
  });

  test('всё время: от самого раннего актива до сегодня', () {
    final range = analyticsRange(
      period: AnalyticsPeriod.all,
      today: LocalDate(2026, 11, 19),
      earliest: LocalDate(2024, 3, 5),
    );
    final fallback = analyticsRange(
      period: AnalyticsPeriod.all,
      today: LocalDate(2026, 11, 19),
    );

    expect(range.start, LocalDate(2024, 3, 5));
    expect(range.end, LocalDate(2026, 11, 19));
    expect(fallback.start, LocalDate(2026, 11, 19));
  });

  test('високосный февраль', () {
    final range = analyticsRange(
      period: AnalyticsPeriod.month,
      today: LocalDate(2028, 2, 10),
    );

    expect(range.end, LocalDate(2028, 2, 29));
  });
}
