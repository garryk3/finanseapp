import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';

/// Итоги денежного потока в одной валюте (domain_model §8).
final class CashflowSummary {
  const CashflowSummary({
    required this.income,
    required this.expense,
    required this.net,
    required this.currencyCode,
    this.staleRateDate,
  });

  final Money income;
  final Money expense;
  final Money net;
  final String currencyCode;

  /// Самая свежая дата резервного курса, использованного при конвертации
  /// (BR-C-9); null — все курсы были точными.
  final LocalDate? staleRateDate;
}

/// Итог по категории для разреза аналитики.
final class CategoryTotal {
  const CategoryTotal({required this.categoryId, required this.total});

  final int categoryId;
  final Money total;
}
