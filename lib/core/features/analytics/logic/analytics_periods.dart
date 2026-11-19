import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';

/// Период аналитики: календарные диапазоны с включительными границами
/// (calculations §10).
enum AnalyticsPeriod { month, threeMonths, sixMonths, year, all }

/// Строит диапазон периода. [earliest] — самая ранняя дата активов для «всё
/// время»; без неё серия начинается с сегодня.
DateRange analyticsRange({
  required AnalyticsPeriod period,
  required LocalDate today,
  LocalDate? earliest,
}) {
  switch (period) {
    case AnalyticsPeriod.month:
      return DateRange(
        start: LocalDate(today.year, today.month, 1),
        end: _endOfMonth(today.year, today.month),
      );
    case AnalyticsPeriod.threeMonths:
      final start = _monthsBack(today, 2);
      return DateRange(start: start, end: _endOfMonth(today.year, today.month));
    case AnalyticsPeriod.sixMonths:
      final start = _monthsBack(today, 5);
      return DateRange(start: start, end: _endOfMonth(today.year, today.month));
    case AnalyticsPeriod.year:
      return DateRange(
        start: LocalDate(today.year, 1, 1),
        end: LocalDate(today.year, 12, 31),
      );
    case AnalyticsPeriod.all:
      final start = earliest ?? today;
      return DateRange(
        start: start.compareTo(today) > 0 ? today : start,
        end: today,
      );
  }
}

LocalDate _monthsBack(LocalDate today, int months) {
  var month = today.month - months;
  var year = today.year;
  while (month < 1) {
    month += 12;
    year -= 1;
  }
  return LocalDate(year, month, 1);
}

LocalDate _endOfMonth(int year, int month) =>
    LocalDate(year, month, DateTime.utc(year, month + 1, 0).day);
