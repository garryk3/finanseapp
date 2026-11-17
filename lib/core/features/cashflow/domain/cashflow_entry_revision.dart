import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';

/// Одна append-only ревизия записи денежного потока (domain_model §6).
final class CashflowEntryRevision {
  const CashflowEntryRevision({
    required this.id,
    required this.entryId,
    required this.revisionNo,
    required this.action,
    required this.snapshot,
    required this.changedAt,
  });

  final int id;
  final int entryId;
  final int revisionNo;
  final RevisionAction action;
  final CashflowEntry snapshot;
  final DateTime changedAt;
}
