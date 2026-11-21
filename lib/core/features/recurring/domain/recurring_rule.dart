import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Вид правила регулярного платежа (BR-RC-1).
enum RecurringStrategy {
  /// Пользовательское правило с фиксированной суммой.
  fixed,

  /// Автоправило вклада: проценты от фактического баланса (BR-RC-9).
  depositInterest,
}

/// Правило ежемесячного дохода/расхода (domain_model §6a, BR-RC-1).
final class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.strategy,
    required this.kind,
    required this.categoryId,
    required this.currencyCode,
    required this.affectsBalance,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.amount,
    this.accountId,
    this.propertyId,
    this.endDate,
    this.comment,
    this.lastGeneratedPeriod,
    this.deletedAt,
  });

  final int id;
  final RecurringStrategy strategy;
  final CashflowKind kind;
  final int categoryId;

  /// Сумма фиксированного правила; null только у `depositInterest`.
  final Money? amount;
  final String currencyCode;
  final int? accountId;
  final int? propertyId;
  final bool affectsBalance;
  final LocalDate startDate;
  final LocalDate? endDate;
  final String? comment;

  /// Последний сгенерированный период 'YYYY-MM' (BR-RC-11).
  final String? lastGeneratedPeriod;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

/// Draft правила: стратегию задаёт вызывающий (пользователь — только `fixed`).
final class RecurringRuleDraft {
  const RecurringRuleDraft({
    required this.strategy,
    required this.kind,
    required this.categoryId,
    required this.currencyCode,
    required this.affectsBalance,
    required this.startDate,
    this.amount,
    this.accountId,
    this.propertyId,
    this.endDate,
    this.comment,
  });

  final RecurringStrategy strategy;
  final CashflowKind kind;
  final int categoryId;
  final Money? amount;
  final String currencyCode;
  final int? accountId;
  final int? propertyId;
  final bool affectsBalance;
  final LocalDate startDate;
  final LocalDate? endDate;
  final String? comment;
}
