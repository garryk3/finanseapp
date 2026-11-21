import 'package:finanseapp/core/domain/common/local_date.dart';

/// Расписание ежемесячных платежей (calculations §4a, BR-RC-2/3).
///
/// Даты — месячные годовщины [startDate] с clamp до конца короткого месяца.
/// [firstPeriodOffset] = 0 для фиксированных правил (первый платёж в дату
/// начала) и 1 для процентов по вкладу (первая годовщина через месяц).
abstract final class RecurringSchedule {
  /// Страховка от экстремальных дат: 1000 лет по месяцам.
  static const int maxPeriods = 12000;

  /// Ключ периода 'YYYY-MM' для маркера `last_generated_period`.
  static String periodKey(LocalDate date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}';

  /// Все непогашенные периоды правила до [today] включительно.
  ///
  /// Периоды с ключом ≤ [lastGeneratedPeriod] уже сгенерированы и пропускаются.
  /// [endDate] включается; пусто = бессрочно. Возвращает по возрастанию.
  static List<LocalDate> dueDates({
    required LocalDate startDate,
    LocalDate? endDate,
    required LocalDate today,
    required String? lastGeneratedPeriod,
    required int firstPeriodOffset,
  }) {
    final dates = <LocalDate>[];
    for (var k = firstPeriodOffset; k <= maxPeriods; k++) {
      final date = startDate.plusMonthsClamped(k);
      if (date.compareTo(today) > 0) break;
      if (endDate != null && date.compareTo(endDate) > 0) break;
      if (lastGeneratedPeriod != null &&
          periodKey(date).compareTo(lastGeneratedPeriod) <= 0) {
        continue;
      }
      dates.add(date);
    }
    return dates;
  }

  /// Первый период после [lastGeneratedPeriod] без фильтра «не позже today».
  ///
  /// Для UI «следующий платёж»; null, если `endDate` уже пройдена.
  static LocalDate? nextPayment({
    required LocalDate startDate,
    LocalDate? endDate,
    required String? lastGeneratedPeriod,
    required int firstPeriodOffset,
  }) {
    var k = firstPeriodOffset;
    if (lastGeneratedPeriod != null) {
      while (k <= maxPeriods &&
          periodKey(startDate.plusMonthsClamped(k))
                  .compareTo(lastGeneratedPeriod) <=
              0) {
        k++;
      }
    }
    final date = startDate.plusMonthsClamped(k);
    if (endDate != null && date.compareTo(endDate) > 0) return null;
    return date;
  }
}
