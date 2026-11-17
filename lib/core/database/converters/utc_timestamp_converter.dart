import 'package:drift/drift.dart';

/// Хранит UTC timestamp как ISO-8601 TEXT с микросекундами.
///
/// Drift `dateTime()` пишет unix-время, а контракт схемы требует TEXT
/// (data_schema §1), поэтому timestamp идёт через этот конвертер.
final class UtcTimestampConverter extends TypeConverter<DateTime, String> {
  const UtcTimestampConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) {
    // Фиксированная ширина (6 знаков): иначе timestamp'ы с нулевыми
    // микросекундами лексикографически расходятся с хронологией в ORDER BY.
    final iso = value.toUtc().toIso8601String();
    final dot = iso.indexOf('.');
    if (dot < 0) return '${iso.substring(0, iso.length - 1)}.000000Z';
    final fraction = iso.substring(dot + 1, iso.length - 1);
    return '${iso.substring(0, dot + 1)}${fraction.padRight(6, '0')}Z';
  }
}
