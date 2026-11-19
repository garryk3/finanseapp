import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry_revision.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Аудит дохода/расхода: append-only ревизии, доступные после удаления (7.3).
class AuditCashflowViewModel {
  AuditCashflowViewModel({
    required this.auditRepository,
    required this.entryId,
  });

  final AuditRepository auditRepository;
  final int entryId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<CashflowEntryRevision>> revisions = signal(const []);

  Future<void> load() async {
    try {
      revisions.value = await auditRepository
          .watchCashflowRevisions(entryId)
          .first;
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  void dispose() {}
}
