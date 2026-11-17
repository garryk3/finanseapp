import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Фильтр денежного потока (domain_model §8).
final class CashflowFilter {
  const CashflowFilter({
    this.period,
    this.kind,
    this.categoryId,
    this.currencyCode,
    this.propertyId,
    this.accountId,
    this.query = '',
  });

  final DateRange? period;
  final CashflowKind? kind;
  final int? categoryId;
  final String? currencyCode;
  final int? propertyId;
  final int? accountId;
  final String query;
}
