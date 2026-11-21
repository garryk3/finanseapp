import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:rational/rational.dart';

/// Валовая/чистая доходность недвижимости за 12 месяцев (RE-6).
///
/// Значения — проценты; null при нулевой/отрицательной текущей стоимости.
final class PropertyYield {
  const PropertyYield({this.grossPercent, this.netPercent});

  final Decimal? grossPercent;
  final Decimal? netPercent;

  bool get available => grossPercent != null && netPercent != null;
}

abstract final class PropertyYieldCalculator {
  /// Последние 12 календарных месяцев, включая [today].
  static DateRange trailingYear(LocalDate today) {
    final previousMonthLastDay = DateTime(
      today.year - 1,
      today.month + 1,
      0,
    ).day;
    final day = today.day > previousMonthLastDay
        ? previousMonthLastDay
        : today.day;
    return DateRange(
      start: LocalDate(today.year - 1, today.month, day),
      end: today,
    );
  }

  static PropertyYield calculate({
    required Money incomeRub,
    required Money expenseRub,
    required Money? valueRub,
  }) {
    if (valueRub == null || valueRub.minorUnits <= 0) {
      return const PropertyYield();
    }
    final value = Rational.fromInt(valueRub.minorUnits);
    Decimal percent(Rational units) => (units / value * Rational.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 4);

    final income = Rational.fromInt(incomeRub.minorUnits);
    final net = income - Rational.fromInt(expenseRub.minorUnits);
    return PropertyYield(
      grossPercent: percent(income),
      netPercent: percent(net),
    );
  }
}
