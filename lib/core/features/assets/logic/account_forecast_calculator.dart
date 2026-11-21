import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';

/// Прогноз вклада с ежемесячной капитализацией (calculations §4).
///
/// Возвращает `null`, если дата окончания не задана; ноль ставки и истёкший
/// срок дают текущий баланс. Это оценка, а не факт: деньги остаются minor
/// units, `double` применяется только к дробной степени.
abstract final class AccountForecastCalculator {
  static Money? call({
    required AccountAsset account,
    required Money currentBalance,
    required LocalDate asOf,
    Currency? currency,
  }) {
    final endDate = account.endDate;
    if (endDate == null) return null;
    if (endDate.compareTo(asOf) <= 0 || account.annualRate == Decimal.zero) {
      return currentBalance;
    }

    final fullMonths = _fullMonths(asOf, endDate);
    final lastAnniversary = _addMonthsClamped(asOf, fullMonths);
    final nextAnniversary = _addMonthsClamped(asOf, fullMonths + 1);
    final remainingDays = _daysBetween(lastAnniversary, endDate);
    final monthDays = _daysBetween(lastAnniversary, nextAnniversary);
    final months =
        fullMonths + (monthDays == 0 ? 0 : remainingDays / monthDays);

    final rate = account.annualRate.toDouble() / 1200;
    final current = _toDouble(currentBalance, currency);
    final future = current * math.pow(1 + rate, months);
    return MoneyMath.fromDecimal(
      Decimal.parse(future.toStringAsFixed(10)),
      currency ??
          Currency(
            code: currentBalance.currencyCode,
            name: currentBalance.currencyCode,
            fractionDigits: 2,
            isPreset: true,
            isEnabled: true,
          ),
    );
  }

  static int _fullMonths(LocalDate asOf, LocalDate endDate) {
    var months = 0;
    while (_addMonthsClamped(asOf, months + 1).compareTo(endDate) <= 0) {
      months++;
      if (months > 12000) break; // страховка от экстремальных дат
    }
    return months;
  }

  /// Anniversary-дата от исходного дня; 31 января → 28/29 февраля.
  static LocalDate _addMonthsClamped(LocalDate date, int months) =>
      date.plusMonthsClamped(months);

  static int _daysBetween(LocalDate from, LocalDate to) =>
      to.toUtcDateTime().difference(from.toUtcDateTime()).inDays;

  /// Только для оценочного прогноза; итог снова округляется в Decimal.
  static double _toDouble(Money money, Currency? currency) {
    final digits = currency?.fractionDigits ?? 2;
    return money.minorUnits / math.pow(10, digits);
  }
}
