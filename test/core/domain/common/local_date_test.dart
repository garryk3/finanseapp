import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher throwsValidation() => throwsA(
  isA<DomainException>().having(
    (error) => error.code,
    'code',
    DomainErrorCode.validation,
  ),
);

void main() {
  group('LocalDate.parse', () {
    test('принимает реальную високосную дату', () {
      final date = LocalDate.parse('2024-02-29');

      expect(date.year, 2024);
      expect(date.month, 2);
      expect(date.day, 29);
      expect(date.toIsoString(), '2024-02-29');
    });

    test('отклоняет 29 февраля невисокосного года', () {
      expect(() => LocalDate.parse('2023-02-29'), throwsValidation());
    });

    test('отклоняет несуществующие дни и месяцы', () {
      for (final raw in [
        '2024-02-30',
        '2024-04-31',
        '2024-13-01',
        '2024-00-10',
        '2024-01-00',
      ]) {
        expect(() => LocalDate.parse(raw), throwsValidation(), reason: raw);
      }
    });

    test('требует строгий формат yyyy-MM-dd', () {
      for (final raw in [
        '2024-2-03',
        '2024-02-3',
        ' 2024-02-03',
        '2024-02-03 ',
        '2024/02/03',
        '2024-02-03T00:00:00',
        '03.02.2024',
        '',
      ]) {
        expect(() => LocalDate.parse(raw), throwsValidation(), reason: raw);
      }
    });
  });

  group('LocalDate', () {
    test('конструктор проверяет календарную дату', () {
      expect(() => LocalDate(2023, 2, 29), throwsValidation());
      expect(() => LocalDate(2024, 4, 31), throwsValidation());
      expect(LocalDate(2024, 2, 29).day, 29);
    });

    test('fromDateTime берёт локальные поля и отбрасывает время', () {
      final date = LocalDate.fromDateTime(DateTime(2026, 11, 17, 23, 59, 59));

      expect(date.toIsoString(), '2026-11-17');
    });

    test('toUtcDateTime возвращает полночь UTC', () {
      final date = LocalDate(2026, 2, 3).toUtcDateTime();

      expect(date.isUtc, isTrue);
      expect(date, DateTime.utc(2026, 2, 3));
    });

    test('сравнение и равенство по календарным полям', () {
      final earlier = LocalDate(2026, 1, 31);
      final later = LocalDate(2026, 2, 1);

      expect(earlier.compareTo(later), lessThan(0));
      expect(later.compareTo(earlier), greaterThan(0));
      expect(earlier.compareTo(LocalDate(2026, 1, 31)), 0);
      expect(LocalDate(2026, 1, 31), earlier);
      expect(LocalDate(2026, 1, 31).hashCode, earlier.hashCode);
      expect(LocalDate(2026, 1, 30), isNot(earlier));
    });

    test('сортируется по возрастанию даты', () {
      final dates = [
        LocalDate(2026, 2, 1),
        LocalDate(2025, 12, 31),
        LocalDate(2026, 1, 15),
      ]..sort();

      expect(dates.map((date) => date.toIsoString()), [
        '2025-12-31',
        '2026-01-15',
        '2026-02-01',
      ]);
    });
  });

  group('LocalDate.plusMonthsClamped', () {
    test('сохраняет день месяца при переходе между месяцами', () {
      expect(
        LocalDate(2026, 1, 15).plusMonthsClamped(1).toIsoString(),
        '2026-02-15',
      );
      expect(
        LocalDate(2026, 1, 15).plusMonthsClamped(12).toIsoString(),
        '2027-01-15',
      );
      expect(
        LocalDate(2026, 12, 31).plusMonthsClamped(1).toIsoString(),
        '2027-01-31',
      );
    });

    test('clamp до последнего дня короткого месяца', () {
      expect(
        LocalDate(2026, 1, 31).plusMonthsClamped(1).toIsoString(),
        '2026-02-28',
      );
      expect(
        LocalDate(2026, 3, 31).plusMonthsClamped(1).toIsoString(),
        '2026-04-30',
      );
      expect(
        LocalDate(2026, 5, 31).plusMonthsClamped(1).toIsoString(),
        '2026-06-30',
      );
    });

    test('високосный февраль и возврат к 29-му', () {
      expect(
        LocalDate(2024, 1, 31).plusMonthsClamped(1).toIsoString(),
        '2024-02-29',
      );
      expect(
        LocalDate(2024, 2, 29).plusMonthsClamped(12).toIsoString(),
        '2025-02-28',
      );
      expect(
        LocalDate(2024, 2, 29).plusMonthsClamped(48).toIsoString(),
        '2028-02-29',
      );
    });

    test('ноль и переход через год', () {
      final date = LocalDate(2026, 11, 17);

      expect(date.plusMonthsClamped(0), date);
      expect(date.plusMonthsClamped(14).toIsoString(), '2028-01-17');
      expect(date.plusMonthsClamped(12000).year, 2026 + 1000);
    });

    test('отрицательный сдвиг отклоняется', () {
      expect(
        () => LocalDate(2026, 1, 1).plusMonthsClamped(-1),
        throwsValidation(),
      );
    });
  });

  group('DateRange', () {
    final start = LocalDate(2026, 1, 1);
    final end = LocalDate(2026, 1, 31);

    test('включает обе границы', () {
      final range = DateRange(start: start, end: end);

      expect(range.contains(start), isTrue);
      expect(range.contains(end), isTrue);
      expect(range.contains(LocalDate(2026, 1, 15)), isTrue);
      expect(range.contains(LocalDate(2026, 2, 1)), isFalse);
      expect(range.contains(LocalDate(2025, 12, 31)), isFalse);
    });

    test('допускает период из одного дня', () {
      final range = DateRange(start: start, end: start);

      expect(range.contains(start), isTrue);
    });

    test('отклоняет перевёрнутый период', () {
      expect(() => DateRange(start: end, end: start), throwsValidation());
    });
  });
}
