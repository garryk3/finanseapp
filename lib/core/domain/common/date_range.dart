import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';

/// Непрерывный период с включительными границами (calculations §10).
final class DateRange {
  DateRange({required this.start, required this.end}) {
    if (start.compareTo(end) > 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'range': 'validationDateRangeInvalid'},
      );
    }
  }

  final LocalDate start;
  final LocalDate end;

  /// Входит ли [date] в период, включая обе границы.
  bool contains(LocalDate date) =>
      date.compareTo(start) >= 0 && date.compareTo(end) <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start..$end';
}
