import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:rational/rational.dart';

/// Точная денежная арифметика: `Decimal`/`Rational` на входе, minor units на
/// границе результата (calculations §1).
///
/// Промежуточные значения не округляются; [fromDecimal]/[fromRational]
/// округляют один раз, half away from zero.
abstract final class MoneyMath {
  static final _minInt64 = BigInt.parse('-9223372036854775808');
  static final _maxInt64 = BigInt.parse('9223372036854775807');

  /// Округляет [value] до минорной единицы [currency].
  ///
  /// Бросает `DomainException(validation)`, если результат не помещается в
  /// 64-битное целое: молчаливое переполнение искажает учётные итоги.
  static Money fromDecimal(Decimal value, Currency currency) =>
      fromRational(value.toRational(), currency);

  /// Округляет точное рациональное значение до минорной единицы [currency].
  ///
  /// Единая точка правила half away from zero: сюда приходит и пользовательский
  /// `Decimal`, и результат конвертации, поэтому правила не могут разойтись.
  static Money fromRational(Rational value, Currency currency) => _fromUnits(
    _roundToMinorUnits(value, currency.fractionDigits),
    currency.code,
  );

  /// Разворачивает [value] в точное десятичное значение основных единиц.
  static Decimal toDecimal(Money value, Currency currency) {
    if (value.currencyCode != currency.code) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
      );
    }
    return Decimal.fromBigInt(BigInt.from(value.minorUnits))
        .shift(-currency.fractionDigits);
  }

  /// Складывает деньги одной валюты без округления.
  static Money add(Money left, Money right) {
    _requireSameCurrency(left, right);
    return _fromUnits(
      BigInt.from(left.minorUnits) + BigInt.from(right.minorUnits),
      left.currencyCode,
    );
  }

  /// Вычитает деньги одной валюты; результат может быть отрицательным.
  static Money subtract(Money left, Money right) {
    _requireSameCurrency(left, right);
    return _fromUnits(
      BigInt.from(left.minorUnits) - BigInt.from(right.minorUnits),
      left.currencyCode,
    );
  }

  /// Проверяет 64-битный диапазон: молчаливое переполнение искажает итоги.
  static Money _fromUnits(BigInt units, String currencyCode) {
    if (units < _minInt64 || units > _maxInt64) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'amount': 'validationAmountOverflow'},
      );
    }
    return Money(minorUnits: units.toInt(), currencyCode: currencyCode);
  }

  /// Округляет точное значение до минорных единиц half away from zero.
  ///
  /// Считается в `BigInt`, чтобы деление не теряло хвост: `Rational` хранит
  /// числитель и знаменатель в каноническом виде (знаменатель > 0).
  static BigInt _roundToMinorUnits(Rational value, int fractionDigits) {
    final scale = BigInt.from(10).pow(fractionDigits);
    final numerator = value.numerator * scale;
    final denominator = value.denominator;
    final magnitude = numerator.abs();
    var units = magnitude ~/ denominator;
    if ((magnitude % denominator) * BigInt.two >= denominator) {
      units += BigInt.one;
    }
    return numerator.isNegative ? -units : units;
  }

  static void _requireSameCurrency(Money left, Money right) {
    if (left.currencyCode != right.currencyCode) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
      );
    }
  }
}
