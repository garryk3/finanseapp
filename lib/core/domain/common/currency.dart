/// Валюта справочника (BR-C-8).
///
/// [fractionDigits] — число минорных единиц в основной единице: `2` для RUB,
/// USD, EUR, CNY и HKD (BR-C-8, §13). Код пишется заглавными; нормализация
/// ввода — задача repository, а не value object.
final class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.fractionDigits,
    required this.isPreset,
    required this.isEnabled,
  }) : assert(code != '', 'Код валюты не может быть пустым'),
       assert(
         fractionDigits >= 0 && fractionDigits <= 8,
         'fractionDigits вне диапазона 0..8',
       );

  /// Канонический код рубля: курс всегда 1, сетевой запрос не выполняется.
  static const rubCode = 'RUB';

  final String code;
  final String name;
  final int fractionDigits;
  final bool isPreset;
  final bool isEnabled;

  bool get isRub => code == rubCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          other.code == code &&
          other.name == name &&
          other.fractionDigits == fractionDigits &&
          other.isPreset == isPreset &&
          other.isEnabled == isEnabled;

  @override
  int get hashCode =>
      Object.hash(code, name, fractionDigits, isPreset, isEnabled);

  @override
  String toString() => 'Currency($code, $name)';
}
