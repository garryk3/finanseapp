import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';

/// Итог чистого капитала на дату (domain_model §8).
final class NetWorthSummary {
  const NetWorthSummary({
    required this.total,
    required this.byAssetKind,
    this.staleRateDate,
  });

  final Money total;
  final Map<AssetKind, Money> byAssetKind;

  /// Самая свежая дата резервного курса, использованного при расчёте
  /// (BR-C-9); null — все курсы были точными.
  final LocalDate? staleRateDate;
}

/// Точка графика чистого капитала.
final class NetWorthPoint {
  const NetWorthPoint({required this.date, required this.value});

  final LocalDate date;
  final Money value;
}
