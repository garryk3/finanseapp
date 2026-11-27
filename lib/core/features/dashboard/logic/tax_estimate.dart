import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';

/// Предполагаемый налог с процентов по вкладам за текущий год (D21.6/X1–X2).
///
/// [base] — сумма процентов в базовой валюте, [tax] — налог по ставке
/// [ratePercent]. Расчёт целочисленный в minor units (BigInt, half away from
/// zero), без double, по образцу `MoneyMath`.
final class TaxEstimate {
  const TaxEstimate({
    required this.base,
    required this.ratePercent,
    required this.tax,
  });

  final Money base;
  final int ratePercent;
  final Money tax;

  /// `tax = round(base × ratePercent / 100)`.
  static TaxEstimate calculate({
    required Money base,
    required int ratePercent,
  }) {
    final numerator = BigInt.from(base.minorUnits) * BigInt.from(ratePercent);
    final hundred = BigInt.from(100);
    final magnitude = numerator.abs();
    var units = magnitude ~/ hundred;
    if ((magnitude % hundred) * BigInt.two >= hundred) {
      units += BigInt.one;
    }
    final taxMinor = numerator.isNegative ? -units : units;
    return TaxEstimate(
      base: base,
      ratePercent: ratePercent,
      tax: Money(minorUnits: taxMinor.toInt(), currencyCode: base.currencyCode),
    );
  }

  /// Входит ли [percent] в допустимый диапазон ставки (D21.6/X2).
  static bool isValidRatePercent(int percent) =>
      percent >= minTaxRatePercent && percent <= maxTaxRatePercent;
}
