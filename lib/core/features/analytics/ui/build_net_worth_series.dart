import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/app/theme/chart_series_colors.dart';
import 'package:finanseapp/uikit/app_chart_data.dart';

/// Направление серии для доступного summary.
enum NetWorthTrend { up, down, flat }

/// Статистика серии для accessible summary и текстовой альтернативы.
final class NetWorthSeriesStats {
  const NetWorthSeriesStats({
    required this.last,
    required this.min,
    required this.max,
    required this.trend,
  });

  final Money last, min, max;
  final NetWorthTrend trend;
}

/// Presentation mapper: domain-точки → chart-модель и точные строки.
///
/// Domain Money не превращается в double для учёта: double существует только
/// в графике, tooltip/text alternative используют [formatMoney].
final class NetWorthSeriesBuilder {
  const NetWorthSeriesBuilder({
    required this.baseCurrency,
    required this.formatMoney,
  });

  final Currency baseCurrency;
  final String Function(Money) formatMoney;

  AppLineChartSeries build(
    List<NetWorthPoint> points, {
    required String label,
  }) => AppLineChartSeries(
    id: 'net-worth',
    label: label,
    colorKey: AppChartSeriesKey.netWorth,
    points: [
      for (final point in points)
        AppChartPoint(
          x: point.date.toUtcDateTime(),
          y: MoneyMath.toDecimal(point.value, baseCurrency).toDouble(),
          label: _shortDate(point),
          valueText: formatMoney(point.value),
        ),
    ],
  );

  NetWorthSeriesStats? stats(List<NetWorthPoint> points) {
    if (points.isEmpty) return null;
    var min = points.first;
    var max = points.first;
    for (final point in points.skip(1)) {
      if (point.value.minorUnits < min.value.minorUnits) min = point;
      if (point.value.minorUnits > max.value.minorUnits) max = point;
    }
    final first = points.first.value.minorUnits;
    final last = points.last.value.minorUnits;
    return NetWorthSeriesStats(
      last: points.last.value,
      min: min.value,
      max: max.value,
      trend: last > first
          ? NetWorthTrend.up
          : last < first
          ? NetWorthTrend.down
          : NetWorthTrend.flat,
    );
  }

  static String _shortDate(NetWorthPoint point) =>
      '${_two(point.date.day)}.${_two(point.date.month)}.'
      '${_two(point.date.year % 100)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}
