import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';

/// Подушка безопасности по решениям владельца D19.1–D19.3:
/// runway = деньги на счетах / средние расходы; цель = 6 месяцев расходов;
/// срок достижения цели — при положительной средней прибыли.
///
/// Средние считаются за 3 полных месяца (суммарные / 3), все суммы — в базовой
/// валюте. Расчёт целочисленный в minor units, без double.
final class SafetyCushion {
  const SafetyCushion({
    required this.cash,
    required this.avgExpenses,
    required this.avgIncome,
    required this.monthlyProfit,
    required this.months,
    required this.target,
    required this.monthsToTarget,
  });

  final Money cash;
  final Money avgExpenses;
  final Money avgIncome;
  final Money monthlyProfit;
  final Money target;

  /// Целые месяцы, на которые хватает денег (floor).
  final int months;

  /// Месяцы до цели; 0 — цель достигнута, null — прибыль не покрывает расходы.
  final int? monthsToTarget;

  static const int targetMonths = 6;

  static SafetyCushion? calculate({
    required Money cash,
    required CashflowSummary lastThreeMonths,
  }) {
    if (cash.currencyCode != lastThreeMonths.currencyCode) return null;
    final expense = lastThreeMonths.expense.minorUnits;
    if (expense <= 0) return null;
    final income = lastThreeMonths.income.minorUnits;
    final cashMinor = cash.minorUnits < 0 ? 0 : cash.minorUnits;
    final cashMoney = Money(
      minorUnits: cashMinor,
      currencyCode: cash.currencyCode,
    );
    final months = cashMinor == 0 ? 0 : (cashMinor * 3) ~/ expense;
    final target = Money(
      minorUnits: expense * targetMonths ~/ 3,
      currencyCode: cash.currencyCode,
    );
    final profit = income - expense;
    int? monthsToTarget;
    if (cashMinor >= target.minorUnits) {
      monthsToTarget = 0;
    } else if (profit > 0) {
      final remaining = target.minorUnits - cashMinor;
      monthsToTarget = (remaining * 3 + profit - 1) ~/ profit;
    }
    return SafetyCushion(
      cash: cashMoney,
      avgExpenses: Money(
        minorUnits: expense ~/ 3,
        currencyCode: cash.currencyCode,
      ),
      avgIncome: Money(
        minorUnits: income ~/ 3,
        currencyCode: cash.currencyCode,
      ),
      monthlyProfit: Money(
        minorUnits: profit ~/ 3,
        currencyCode: cash.currencyCode,
      ),
      months: months,
      target: target,
      monthsToTarget: monthsToTarget,
    );
  }
}
