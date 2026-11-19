import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';

/// Агрегаты, которым нужны курсы и БД (domain_model §10).
abstract interface class AnalyticsQueries {
  Future<NetWorthSummary> netWorth(LocalDate onDate);

  /// Самая ранняя дата активности (создание актива, операция, оценка) —
  /// начало периода «всё время» (calculations §10).
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind});

  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
  });

  Future<CashflowSummary> cashflow(CashflowFilter filter);

  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter);

  Future<List<CashflowPeriodPoint>> cashflowSeries(CashflowFilter filter);
}
