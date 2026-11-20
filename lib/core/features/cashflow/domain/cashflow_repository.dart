import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';

/// Repository доходов и расходов (domain_model §9).
abstract interface class CashflowRepository {
  Stream<List<CashflowEntry>> watch(CashflowFilter filter);

  Future<CashflowEntry> getById(int id);

  Future<int> create(CashflowEntryDraft draft);

  Future<int> createLinked(
    CashflowEntryDraft draft, {
    required int assetTransactionId,
  });

  Future<void> revise(int id, CashflowEntryDraft draft);

  Future<void> softDelete(int id);

  Future<void> restore(int id);
}
