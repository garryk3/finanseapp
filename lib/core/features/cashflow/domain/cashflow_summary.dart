import 'package:finanseapp/core/domain/common/money.dart';

/// Итоги денежного потока в одной валюте (domain_model §8).
final class CashflowSummary {
  const CashflowSummary({
    required this.income,
    required this.expense,
    required this.net,
    required this.currencyCode,
  });

  final Money income;
  final Money expense;
  final Money net;
  final String currencyCode;
}

/// Итог по категории для разреза аналитики.
final class CategoryTotal {
  const CategoryTotal({required this.categoryId, required this.total});

  final int categoryId;
  final Money total;
}
