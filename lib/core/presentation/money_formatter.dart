import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';

/// Форматирование денег для UI по правилам calculations §1.
///
/// Группировка разрядов — неразрывный пробел (`\u00A0`), десятичный разделитель —
/// запятая. Число формируется из minor units целочисленно, без `double`, чтобы
/// крупные суммы не теряли точность.
final class MoneyFormatter {
  const MoneyFormatter();

  static const _symbols = <String, String>{
    'RUB': '₽',
    'USD': '\u0024',
    'EUR': '€',
    'CNY': '¥',
    'HKD': 'HK\u0024',
  };

  /// Форматирует деньги в минорных единицах; неизвестная валюта — код суффиксом.
  ///
  /// `Money.currencyCode` обязан совпадать с [currency]: иначе сумма была бы
  /// показана в чужой валюте/масштабе.
  String format(Money value, Currency currency) {
    if (value.currencyCode != currency.code) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
      );
    }
    return _formatMinorUnits(value.minorUnits, currency);
  }

  /// Округляет `Decimal` по правилу валюты и форматирует.
  String formatDecimal(Decimal value, Currency currency) => _formatMinorUnits(
    MoneyMath.fromDecimal(value, currency).minorUnits,
    currency,
  );

  static String _formatMinorUnits(int minorUnits, Currency currency) {
    final digits = currency.fractionDigits;
    final negative = minorUnits < 0;
    final absolute = minorUnits.abs();
    final scale = _powerOfTen(digits);
    final whole = absolute ~/ scale;
    final fraction = digits == 0
        ? ''
        : ',${(absolute % scale).toString().padLeft(digits, '0')}';
    final grouped = _groupThousands(whole.toString());
    final symbol = _symbols[currency.code];
    final suffix = symbol == null ? ' ${currency.code}' : ' $symbol';
    return '${negative ? '-' : ''}$grouped$fraction$suffix';
  }

  static String _groupThousands(String digits) =>
      digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '\u00A0');

  static int _powerOfTen(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
