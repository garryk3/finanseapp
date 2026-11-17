import 'package:finanseapp/core/domain/common/local_date.dart';

/// Однозначное отображение календарной даты: `03.02.2026`.
final class DateFormatter {
  const DateFormatter();

  String format(LocalDate date) =>
      '${_twoDigits(date.day)}.${_twoDigits(date.month)}.${date.year}';

  /// ISO-представление для отладки и аудита, не для UI.
  String formatIso(LocalDate date) => date.toIsoString();

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
