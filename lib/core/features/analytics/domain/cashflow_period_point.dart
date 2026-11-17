import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';

/// Точка графика денежного потока по календарному периоду.
final class CashflowPeriodPoint {
  const CashflowPeriodPoint({required this.periodStart, required this.summary});

  final LocalDate periodStart;
  final CashflowSummary summary;
}
