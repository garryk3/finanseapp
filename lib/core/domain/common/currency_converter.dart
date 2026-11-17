import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/domain/common/validation.dart';

/// Конвертация между валютами через курсы к рублю (calculations §2).
///
/// `rateToRub` — количество RUB за одну единицу валюты. Промежуточные значения
/// считаются точной рациональной арифметикой; округление до минорной единицы
/// целевой валюты выполняется один раз на итоге.
abstract final class CurrencyConverter {
  static Money convertWithRates({
    required Money value,
    required Currency source,
    required Currency target,
    required Decimal sourceRateToRub,
    Decimal? targetRateToRub,
  }) {
    if (value.currencyCode != source.code) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
      );
    }
    if (source.code == target.code) return value;

    final sourceRate = source.isRub
        ? Decimal.one
        : requirePositiveRate(sourceRateToRub, field: 'sourceRateToRub');
    final targetRate = target.isRub
        ? Decimal.one
        : _requireTargetRate(targetRateToRub);

    final sourceAmount = MoneyMath.toDecimal(value, source);
    final targetAmount =
        sourceAmount.toRational() *
        sourceRate.toRational() /
        targetRate.toRational();

    // Единое округление на итоге: тот же хелпер, что и для пользовательского
    // ввода, поэтому конверсия и прямое округление не расходятся.
    return MoneyMath.fromRational(targetAmount, target);
  }

  static Decimal _requireTargetRate(Decimal? targetRateToRub) {
    if (targetRateToRub == null) {
      throw const DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'targetRateToRub': 'validationRateUnavailable'},
      );
    }
    return requirePositiveRate(targetRateToRub, field: 'targetRateToRub');
  }
}
