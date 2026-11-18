import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Аудит операции: append-only ревизии доступны и для удалённой записи (6.3).
class AuditAssetTransactionViewModel {
  AuditAssetTransactionViewModel({
    required this.auditRepository,
    required this.transactionRepository,
    required this.assetRepository,
    required this.transactionId,
  });

  final AuditRepository auditRepository;
  final AssetTransactionRepository transactionRepository;
  final AssetRepository assetRepository;
  final int transactionId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<AssetTransactionRevision>> revisions = signal(const []);
  final Signal<Asset?> asset = signal(null);

  Future<void> load() async {
    try {
      final revisionsList = await auditRepository
          .watchAssetTransactionRevisions(transactionId)
          .first;
      revisions.value = revisionsList;
      if (revisionsList.isNotEmpty) {
        asset.value = (await assetRepository.getById(
          revisionsList.last.snapshot.assetId,
        )).asset;
      }
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  void dispose() {}
}
