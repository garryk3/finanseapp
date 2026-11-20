import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Фильтр журнала операций по активам (domain_model §8).
final class TransactionFilter {
  const TransactionFilter({
    this.period,
    this.assetId,
    this.kind,
    this.assetKind,
    this.currencyCode,
    this.query = '',
    this.limit,
  });

  final DateRange? period;
  final int? assetId;
  final AssetTransactionKind? kind;
  final AssetKind? assetKind;
  final String? currencyCode;
  final String query;
  final int? limit;
}
