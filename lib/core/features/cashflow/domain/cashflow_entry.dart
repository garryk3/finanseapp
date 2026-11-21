import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Запись денежного потока (domain_model §6).
final class CashflowEntry {
  const CashflowEntry({
    required this.id,
    required this.kind,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRub,
    required this.affectsBalance,
    required this.revisionNo,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
    this.propertyId,
    this.accountId,
    this.assetTransactionId,
    this.recurringRuleId,
    this.deletedAt,
  });

  final int id;
  final CashflowKind kind;
  final int categoryId;
  final Money amount;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final Money amountRub;
  final bool affectsBalance;
  final int revisionNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comment;
  final int? propertyId;
  final int? accountId;
  final int? assetTransactionId;
  final int? recurringRuleId;
  final DateTime? deletedAt;
}

/// Draft записи денежного потока.
final class CashflowEntryDraft {
  const CashflowEntryDraft({
    required this.kind,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    required this.affectsBalance,
    this.comment,
    this.propertyId,
    this.accountId,
  });

  final CashflowKind kind;
  final int categoryId;
  final Money amount;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final bool affectsBalance;
  final String? comment;
  final int? propertyId;
  final int? accountId;
}
