import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_progress.dart';
import 'package:rational/rational.dart';

/// Чистый расчёт прогресса цели (calculations §7, CALC-026…029).
abstract final class GoalCalculator {
  /// Считает прогресс по стоимостям активов **в валюте цели**.
  ///
  /// Конверсия — ответственность `CalculateGoalProgress`; сюда попадают только
  /// суммы одной валюты, поэтому смешивание курсов не может просочиться сюда.
  static GoalProgress calculate({
    required FinancialGoal goal,
    required Map<int, Money> assetValues,
    required Currency currency,
    required LocalDate today,
  }) {
    if (currency.code != goal.targetAmount.currencyCode) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
      );
    }
    if (goal.targetAmount.minorUnits <= 0) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'targetAmount': 'validationAmountPositive'},
      );
    }

    var progress = Money(minorUnits: 0, currencyCode: currency.code);
    for (final value in assetValues.values) {
      progress = MoneyMath.add(progress, value);
    }

    final rawDeficit = MoneyMath.subtract(goal.targetAmount, progress);
    final deficit = rawDeficit.isNegative
        ? Money(minorUnits: 0, currencyCode: currency.code)
        : rawDeficit;
    final surplus = rawDeficit.isNegative
        ? Money(minorUnits: -rawDeficit.minorUnits, currencyCode: currency.code)
        : Money(minorUnits: 0, currencyCode: currency.code);

    return GoalProgress(
      goal: goal,
      progress: progress,
      deficit: deficit,
      surplus: surplus,
      completionRatio: _ratio(progress, goal.targetAmount),
      monthlyContribution: _monthlyContribution(
        goal: goal,
        deficit: deficit,
        currency: currency,
        today: today,
      ),
    );
  }

  /// Автоматический статус: achieved по прогрессу; снижение возвращает active.
  /// `closed` — ручной статус и автоматически не меняется (BR-G-2).
  static GoalStatus resolveStatus({
    required GoalStatus current,
    required GoalProgress progress,
  }) {
    if (current == GoalStatus.closed) return current;
    return progress.progress.minorUnits >= progress.goal.targetAmount.minorUnits
        ? GoalStatus.achieved
        : GoalStatus.active;
  }

  static Decimal _ratio(Money progress, Money target) =>
      (Decimal.fromBigInt(BigInt.from(progress.minorUnits)).toRational() /
              Decimal.fromBigInt(BigInt.from(target.minorUnits)).toRational())
          .toDecimal(scaleOnInfinitePrecision: 10);

  /// Дефицит / календарные месяцы до даты цели включительно.
  ///
  /// `null` без даты, при нулевом дефиците и при уже истёкшем сроке — без
  /// деления на ноль и без «бесконечных» взносов (CALC-028, CALC-029).
  static Money? _monthlyContribution({
    required FinancialGoal goal,
    required Money deficit,
    required Currency currency,
    required LocalDate today,
  }) {
    final targetDate = goal.targetDate;
    if (targetDate == null || deficit.isZero) return null;
    if (targetDate.compareTo(today) < 0) return null;
    final months =
        (targetDate.year - today.year) * 12 +
        targetDate.month -
        today.month +
        1;
    if (months <= 0) return null;
    final monthly =
        MoneyMath.toDecimal(deficit, currency).toRational() /
        Rational.fromInt(months);
    return MoneyMath.fromRational(monthly, currency);
  }
}
