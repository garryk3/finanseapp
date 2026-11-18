import 'package:finanseapp/core/database/daos/assets_dao.dart';
import 'package:finanseapp/core/database/daos/audit_dao.dart';
import 'package:finanseapp/core/features/audit/data/revision_decoder.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry_revision.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';

/// Ревизии из append-only таблиц с декодированием snapshot (6.3).
final class AuditRepositoryImpl implements AuditRepository {
  const AuditRepositoryImpl(this._auditDao, this._assetsDao);

  final AuditDao _auditDao;
  final AssetsDao _assetsDao;

  @override
  Stream<List<AssetTransactionRevision>> watchAssetTransactionRevisions(
    int id,
  ) => _auditDao.watchAssetTransactionRevisions(id).asyncMap((rows) async {
    final revisions = <AssetTransactionRevision>[];
    for (final row in rows) {
      final asset = await _assetsDao.getById(
        assetIdFromSnapshot(row.snapshotJson),
      );
      revisions.add(
        AssetTransactionRevision(
          id: row.id,
          transactionId: row.transactionId,
          revisionNo: row.revisionNo,
          action: row.action,
          snapshot: decodeAssetTransactionSnapshot(
            row.snapshotJson,
            asset.currencyCode,
          ),
          changedAt: row.changedAt,
        ),
      );
    }
    return revisions;
  });

  @override
  Stream<List<CashflowEntryRevision>> watchCashflowRevisions(int id) =>
      _auditDao
          .watchCashflowRevisions(id)
          .map(
            (rows) => [
              for (final row in rows)
                CashflowEntryRevision(
                  id: row.id,
                  entryId: row.entryId,
                  revisionNo: row.revisionNo,
                  action: row.action,
                  snapshot: decodeCashflowSnapshot(row.snapshotJson),
                  changedAt: row.changedAt,
                ),
            ],
          );
}
