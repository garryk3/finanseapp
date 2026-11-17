import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';

/// Фильтр журнала операций по активам (domain_model §8).
final class TransactionFilter {
  const TransactionFilter({
    this.period,
    this.assetId,
    this.assetKind,
    this.currencyCode,
    this.query = '',
  });

  final DateRange? period;
  final int? assetId;
  final AssetKind? assetKind;
  final String? currencyCode;
  final String query;
}
