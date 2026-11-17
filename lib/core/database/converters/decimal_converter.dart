import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Хранит `Decimal` канонической строкой без exponent-нотации.
///
/// `-0` нормализуется в `0`; невалидное значение при чтении — `FormatException`,
/// а не подмена нулём (data_schema §2).
final class DecimalConverter extends TypeConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => toCanonical(value);

  /// Каноническая запись для колонок и audit-snapshot: `-0 → 0`, без exponent.
  static String toCanonical(Decimal value) =>
      value == Decimal.zero ? '0' : value.toString();
}
