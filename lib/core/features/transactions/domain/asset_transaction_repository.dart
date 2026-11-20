import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';

/// Repository операций по активам и переводов (domain_model §9).
abstract interface class AssetTransactionRepository {
  Stream<List<AssetTransaction>> watch(TransactionFilter filter);

  Future<AssetTransaction> getById(int id);

  Future<int> create(AssetTransactionDraft draft);

  Future<void> revise(int id, AssetTransactionDraft draft);

  Future<void> softDelete(int id);

  Future<void> restore(int id);

  Future<void> restoreTransfer(int transferId);

  Future<int> transfer(TransferDraft draft);

  Future<void> reviseTransfer(int transferId, TransferDraft draft);

  Future<void> softDeleteTransfer(int transferId);
}
