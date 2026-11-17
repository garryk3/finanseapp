import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/asset_transaction_revisions.dart';
import 'package:finanseapp/core/database/tables/cashflow_entry_revisions.dart';

part 'audit_dao.g.dart';

/// Журналы ревизий: только чтение, записи идут из DAO транзакций.
@DriftAccessor(tables: [AssetTransactionRevisions, CashflowEntryRevisions])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  Stream<List<AssetTransactionRevisionRow>> watchAssetTransactionRevisions(
    int transactionId,
  ) {
    final query = select(assetTransactionRevisions)
      ..where((r) => r.transactionId.equals(transactionId))
      ..orderBy([(r) => OrderingTerm.asc(r.revisionNo)]);
    return query.watch();
  }

  Stream<List<CashflowEntryRevisionRow>> watchCashflowRevisions(int entryId) {
    final query = select(cashflowEntryRevisions)
      ..where((r) => r.entryId.equals(entryId))
      ..orderBy([(r) => OrderingTerm.asc(r.revisionNo)]);
    return query.watch();
  }
}
