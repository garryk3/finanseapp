import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurringSchedule.periodKey', () {
    test('дополняет месяц нулём и не зависит от дня', () {
      expect(RecurringSchedule.periodKey(LocalDate(2026, 1, 5)), '2026-01');
      expect(RecurringSchedule.periodKey(LocalDate(2026, 11, 17)), '2026-11');
      expect(RecurringSchedule.periodKey(LocalDate(2026, 12, 31)), '2026-12');
    });
  });

  group('RecurringSchedule.dueDates', () {
    test('первый платёж в startDate, без периода в будущем', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(2026, 1, 31),
        today: LocalDate(2026, 11, 17),
        lastGeneratedPeriod: null,
        firstPeriodOffset: 0,
      );

      expect(dates.map((date) => date.toIsoString()), [
        '2026-01-31',
        '2026-02-28',
        '2026-03-31',
        '2026-04-30',
        '2026-05-31',
        '2026-06-30',
        '2026-07-31',
        '2026-08-31',
        '2026-09-30',
        '2026-10-31',
      ]);
    });

    test('offset 1 для процентов: первая годовщина через месяц', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(2026, 1, 15),
        today: LocalDate(2026, 4, 20),
        lastGeneratedPeriod: null,
        firstPeriodOffset: 1,
      );

      expect(dates.map((date) => date.toIsoString()), [
        '2026-02-15',
        '2026-03-15',
        '2026-04-15',
      ]);
    });

    test('маркер исключает уже сгенерированные периоды', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(2026, 1, 15),
        today: LocalDate(2026, 11, 17),
        lastGeneratedPeriod: '2026-09',
        firstPeriodOffset: 0,
      );

      expect(dates.map((date) => date.toIsoString()), [
        '2026-10-15',
        '2026-11-15',
      ]);
    });

    test('маркер текущего периода даёт пусто', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(2026, 1, 15),
        today: LocalDate(2026, 11, 17),
        lastGeneratedPeriod: '2026-11',
        firstPeriodOffset: 0,
      );

      expect(dates, isEmpty);
    });

    test('endDate включается', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(2026, 1, 15),
        endDate: LocalDate(2026, 10, 15),
        today: LocalDate(2026, 11, 17),
        lastGeneratedPeriod: null,
        firstPeriodOffset: 0,
      );

      expect(dates.map((date) => date.toIsoString()), [
        '2026-01-15',
        '2026-02-15',
        '2026-03-15',
        '2026-04-15',
        '2026-05-15',
        '2026-06-15',
        '2026-07-15',
        '2026-08-15',
        '2026-09-15',
        '2026-10-15',
      ]);
      expect(dates.last, LocalDate(2026, 10, 15));
    });

    test('будущий startDate не даёт операций', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(2027, 1, 15),
        today: LocalDate(2026, 11, 17),
        lastGeneratedPeriod: null,
        firstPeriodOffset: 0,
      );

      expect(dates, isEmpty);
    });

    test('clamp високосного февраля', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(2024, 1, 31),
        today: LocalDate(2024, 3, 31),
        lastGeneratedPeriod: null,
        firstPeriodOffset: 0,
      );

      expect(dates.map((date) => date.toIsoString()), [
        '2024-01-31',
        '2024-02-29',
        '2024-03-31',
      ]);
    });

    test('страховка не генерирует больше 12001 периода', () {
      final dates = RecurringSchedule.dueDates(
        startDate: LocalDate(1900, 1, 1),
        today: LocalDate(2026, 11, 17),
        lastGeneratedPeriod: null,
        firstPeriodOffset: 0,
      );

      expect(dates.length, lessThanOrEqualTo(12001));
      expect(
        dates.last.compareTo(LocalDate(2026, 11, 17)),
        lessThanOrEqualTo(0),
      );
    });
  });

  group('RecurringSchedule.nextPayment', () {
    test('возвращает первую будущую дату без фильтра today', () {
      final next = RecurringSchedule.nextPayment(
        startDate: LocalDate(2027, 1, 15),
        lastGeneratedPeriod: null,
        firstPeriodOffset: 0,
      );

      expect(next, LocalDate(2027, 1, 15));
    });

    test('после маркера берёт следующий период', () {
      final next = RecurringSchedule.nextPayment(
        startDate: LocalDate(2026, 1, 15),
        lastGeneratedPeriod: '2026-11',
        firstPeriodOffset: 0,
      );

      expect(next, LocalDate(2026, 12, 15));
    });

    test('endDate раньше следующего платежа даёт null', () {
      final next = RecurringSchedule.nextPayment(
        startDate: LocalDate(2026, 1, 15),
        endDate: LocalDate(2026, 3, 15),
        lastGeneratedPeriod: '2026-03',
        firstPeriodOffset: 0,
      );

      expect(next, isNull);
    });
  });
}
