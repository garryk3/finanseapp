import 'dart:math' as math;

import 'package:finanseapp/core/domain/common/result.dart';

/// Календарная дата без времени и timezone (BR-VAL-2).
///
/// Конструктор проверяет реальность даты (`2024-02-29` допустима,
/// `2023-02-29` — нет), поэтому он не `const`: проверка числа дней в месяце
/// требует вычисления, недопустимого в const-assert.
final class LocalDate implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day) {
    if (!_isCalendarDate(year, month, day)) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'date': 'validationDateInvalid'},
      );
    }
  }

  /// Берёт локальные календарные поля [value]; время суток отбрасывается.
  factory LocalDate.fromDateTime(DateTime value) =>
      LocalDate(value.year, value.month, value.day);

  /// Строгий разбор `yyyy-MM-dd` без trim и пробелов (BR-VAL-2).
  factory LocalDate.parse(String isoDate) {
    final match = _isoPattern.firstMatch(isoDate);
    if (match == null) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'date': 'validationDateInvalid'},
      );
    }
    return LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// Каноническое представление для БД.
  String toIsoString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Полночь UTC этой даты (для разницы в днях и timestamps).
  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  /// Сдвиг на [months] месяцев с сохранением дня и clamp до конца месяца.
  ///
  /// 31 января + 1 месяц → 28/29 февраля; 31 марта + 1 месяц → 30 апреля.
  /// Отрицательный сдвиг отклоняется: расписание регулярных платежей идёт
  /// только вперёд.
  LocalDate plusMonthsClamped(int months) {
    if (months < 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'date': 'validationDateInvalid'},
      );
    }
    final total = year * 12 + (month - 1) + months;
    final nextYear = total ~/ 12;
    final nextMonth = total % 12 + 1;
    final nextDay = math.min(day, _daysInMonth(nextYear, nextMonth));
    return LocalDate(nextYear, nextMonth, nextDay);
  }

  @override
  int compareTo(LocalDate other) {
    final byYear = year.compareTo(other.year);
    if (byYear != 0) return byYear;
    final byMonth = month.compareTo(other.month);
    if (byMonth != 0) return byMonth;
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDate &&
          other.year == year &&
          other.month == month &&
          other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIsoString();

  static bool _isCalendarDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1) return false;
    if (day > _daysInMonth(year, month)) return false;
    return true;
  }

  static int _daysInMonth(int year, int month) => switch (month) {
    2 => _isLeapYear(year) ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  /// Григорианское правило високосного года.
  static bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}
