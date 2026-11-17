import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Одна append-only ревизия операции по активу (domain_model §5).
final class AssetTransactionRevision {
  const AssetTransactionRevision({
    required this.id,
    required this.transactionId,
    required this.revisionNo,
    required this.action,
    required this.snapshot,
    required this.changedAt,
  });

  final int id;
  final int transactionId;
  final int revisionNo;
  final RevisionAction action;
  final AssetTransaction snapshot;
  final DateTime changedAt;
}
