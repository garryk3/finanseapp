import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry_revision.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';

/// Repository журналов ревизий (domain_model §9).
abstract interface class AuditRepository {
  Stream<List<AssetTransactionRevision>> watchAssetTransactionRevisions(int id);

  Stream<List<CashflowEntryRevision>> watchCashflowRevisions(int id);
}
