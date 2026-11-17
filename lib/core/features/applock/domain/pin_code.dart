/// PIN-код: 4–6 цифр (BR-Sec-1). Каноническое значение — [digits].
class PinCode {
  const PinCode(this.digits);

  factory PinCode.parse(String raw) {
    final isValid =
        raw.length >= minLength &&
        raw.length <= maxLength &&
        raw.codeUnits.every(_isDigit);
    if (!isValid) {
      throw FormatException('PIN должен состоять из 4–6 цифр');
    }
    return PinCode(raw);
  }

  static const minLength = 4;
  static const maxLength = 6;

  final String digits;

  static bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;

  /// Одиночный символ-цифра (для пошагового ввода с клавиатуры).
  static bool parseAllowedDigit(String char) =>
      char.length == 1 && _isDigit(char.codeUnitAt(0));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PinCode && other.digits == digits;

  @override
  int get hashCode => digits.hashCode;
}
