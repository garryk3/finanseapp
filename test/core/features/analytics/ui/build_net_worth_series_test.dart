import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/ui/build_net_worth_series.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

NetWorthPoint _point(int year, int month, int day, int minor) => NetWorthPoint(
  date: LocalDate(year, month, day),
  value: Money(minorUnits: minor, currencyCode: 'RUB'),
);

String _format(Money money) => '${money.minorUnits ~/ 100} ₽';

void main() {
  final builder = NetWorthSeriesBuilder(
    baseCurrency: _rub,
    formatMoney: _format,
  );

  test('точки конвертируются в chart-модель с точными подписями', () {
    final series = builder.build([
      _point(2026, 11, 1, 100000),
      _point(2026, 11, 12, 150000),
    ], label: 'Чистый капитал');

    expect(series.points, hasLength(2));
    expect(series.points.first.y, 1000);
    expect(series.points.first.label, '01.11.26');
    expect(series.points.first.valueText, '1000 ₽');
    expect(series.points.last.y, 1500);
  });

  test('статистика: last/min/max и направление', () {
    final stats = builder.stats([
      _point(2026, 11, 1, 100000),
      _point(2026, 11, 5, 50000),
      _point(2026, 11, 9, 200000),
      _point(2026, 11, 12, 150000),
    ])!;

    expect(stats.last.minorUnits, 150000);
    expect(stats.min.minorUnits, 50000);
    expect(stats.max.minorUnits, 200000);
    expect(stats.trend, NetWorthTrend.up);
  });

  test('падение и отсутствие изменений', () {
    final down = builder.stats([
      _point(2026, 11, 1, 200000),
      _point(2026, 11, 2, 100000),
    ])!;
    final flat = builder.stats([
      _point(2026, 11, 1, 100000),
      _point(2026, 11, 2, 100000),
    ])!;

    expect(down.trend, NetWorthTrend.down);
    expect(flat.trend, NetWorthTrend.flat);
  });

  test('пустая серия — null; одна точка finite', () {
    expect(builder.stats(const []), isNull);
    final series = builder.build([_point(2026, 11, 1, 0)], label: 'x');

    expect(series.points.single.y, 0);
    expect(series.points.single.y.isFinite, isTrue);
  });
}
