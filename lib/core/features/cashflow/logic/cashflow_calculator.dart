import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Итоги денежного потока за период в RUB (BR-IE-12).
final class CashflowTotals {
  const CashflowTotals({
    required this.income,
    required this.expense,
    required this.net,
  });

  final Money income;
  final Money expense;
  final Money net;
}

abstract final class CashflowCalculator {
  static CashflowTotals totals(List<CashflowEntry> entries) {
    Money sum(CashflowKind kind) {
      var total = const Money(minorUnits: 0, currencyCode: 'RUB');
      for (final entry in entries) {
        if (entry.kind != kind) continue;
        total = MoneyMath.add(total, entry.amountRub);
      }
      return total;
    }

    final income = sum(CashflowKind.income);
    final expense = sum(CashflowKind.expense);
    return CashflowTotals(
      income: income,
      expense: expense,
      net: MoneyMath.subtract(income, expense),
    );
  }
}
