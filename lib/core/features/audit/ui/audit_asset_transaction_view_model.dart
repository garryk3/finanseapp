import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Аудит операции: append-only ревизии доступны и для удалённой записи (6.3).
class AuditAssetTransactionViewModel {
  AuditAssetTransactionViewModel({
    required this.auditRepository,
    required this.assetRepository,
    required this.transactionRepository,
    required this.transactionId,
  });

  final AuditRepository auditRepository;
  final AssetRepository assetRepository;
  final AssetTransactionRepository transactionRepository;
  final int transactionId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<AssetTransactionRevision>> revisions = signal(const []);
  final Signal<Asset?> asset = signal(null);
  final Signal<bool> restoreBusy = signal(false);
  final Signal<bool> restoreFailed = signal(false);

  bool get canRestore =>
      revisions.value.isNotEmpty &&
      revisions.value.last.action == RevisionAction.delete;

  Future<void> restore() async {
    if (!canRestore || restoreBusy.value) return;
    restoreBusy.value = true;
    restoreFailed.value = false;
    try {
      await transactionRepository.restore(transactionId);
      await load();
    } on Exception {
      restoreFailed.value = true;
    } finally {
      restoreBusy.value = false;
    }
  }

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
