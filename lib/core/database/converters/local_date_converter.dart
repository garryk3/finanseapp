import 'package:drift/drift.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';

/// Хранит `LocalDate` строго как `yyyy-MM-dd` (BR-VAL-2).
final class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIsoString();
}
