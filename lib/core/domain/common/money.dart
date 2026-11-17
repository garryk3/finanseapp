/// Деньги в минорных единицах валюты (BR-VAL-1).
///
/// [minorUnits] — целое число копеек/центов. Отрицательное значение допустимо
/// только для вычисленной разницы; пользовательские суммы операций всегда
/// положительны. Складывать [Money] разных [currencyCode] нельзя —
/// только через `CurrencyConverter`.
final class Money {
  const Money({required this.minorUnits, required this.currencyCode});

  final int minorUnits;
  final String currencyCode;

  bool get isNegative => minorUnits < 0;

  bool get isZero => minorUnits == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          other.minorUnits == minorUnits &&
          other.currencyCode == currencyCode;

  @override
  int get hashCode => Object.hash(minorUnits, currencyCode);

  @override
  String toString() => 'Money($minorUnits, $currencyCode)';
}
