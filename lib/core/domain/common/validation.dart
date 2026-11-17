import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';

/// Проверяет, что курс строго больше нуля (BR-VAL-4).
///
/// Возвращает [rate] для использования в цепочке вычислений.
Decimal requirePositiveRate(Decimal rate, {String field = 'rate'}) {
  if (rate <= Decimal.zero) {
    throw DomainException(
      DomainErrorCode.validation,
      fieldErrors: {field: 'validationRatePositive'},
    );
  }
  return rate;
}

/// Проверяет, что пользовательская сумма строго больше нуля (BR-T-5,
/// BR-IE-10).
///
/// Проверяется уже округлённый итог в минорных единицах: `0,004 USD`
/// округляется до нуля и отклоняется, а не сохраняется пустой операцией.
Money requirePositiveMoney(Money amount, {String field = 'amount'}) {
  if (amount.minorUnits <= 0) {
    throw DomainException(
      DomainErrorCode.validation,
      fieldErrors: {field: 'validationAmountPositive'},
    );
  }
  return amount;
}
