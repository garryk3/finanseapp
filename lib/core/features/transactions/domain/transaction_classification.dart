import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Классификация операции счёта как дохода/расхода (BR-IE-6, BR-IE-9).
///
/// Создаёт связанную запись денежного потока в той же DB-транзакции.
final class TransactionClassification {
  const TransactionClassification({
    required this.kind,
    required this.categoryId,
  });

  final CashflowKind kind;
  final int categoryId;
}
