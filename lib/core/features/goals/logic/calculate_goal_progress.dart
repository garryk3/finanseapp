import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/currency_converter.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_progress.dart';
import 'package:finanseapp/core/features/goals/logic/goal_calculator.dart';

/// Конвертация стоимостей связанных активов в валюту цели и расчёт прогресса.
///
/// Если курса не хватает, прогресс не считается целиком: частичная сумма
/// выглядела бы как реальный прогресс и могла бы ложно закрыть цель.
final class CalculateGoalProgress {
  const CalculateGoalProgress();

  /// Загружает недостающие курсы к RUB (RUB и совпадение с валютой цели не
  /// требуют сети) и считает прогресс. [rateCache] разделяется между целями.
  Future<GoalProgress?> load({
    required FinancialGoal goal,
    required Map<int, Money> assetValues,
    required Map<String, Currency> currencies,
    required ExchangeRateRepository rateRepository,
    required LocalDate today,
    Map<String, Decimal>? rateCache,
  }) async {
    final targetCode = goal.targetAmount.currencyCode;
    final needsConversion = assetValues.values.any(
      (value) => value.currencyCode != targetCode,
    );
    final codes = <String>{
      for (final value in assetValues.values)
        if (value.currencyCode != targetCode) value.currencyCode,
      if (needsConversion && targetCode != Currency.rubCode) targetCode,
    }..remove(Currency.rubCode);

    final rates = <String, Decimal>{};
    for (final code in codes) {
      final cached = rateCache?[code];
      if (cached != null) {
        rates[code] = cached;
        continue;
      }
      try {
        final rate = await rateRepository.find(code, today);
        if (rate == null) return null;
        rates[code] = rate.rateToRub;
        rateCache?[code] = rate.rateToRub;
      } on Exception {
        return null;
      }
    }

    return calculate(
      goal: goal,
      assetValues: assetValues,
      currencies: currencies,
      ratesToRub: rates,
      today: today,
    );
  }

  /// Чистая конверсия по уже загруженным курсам (для тестов и переиспользования).
  GoalProgress? calculate({
    required FinancialGoal goal,
    required Map<int, Money> assetValues,
    required Map<String, Currency> currencies,
    required Map<String, Decimal> ratesToRub,
    required LocalDate today,
  }) {
    final target = currencies[goal.targetAmount.currencyCode];
    if (target == null) return null;
    final converted = <int, Money>{};
    for (final entry in assetValues.entries) {
      final value = entry.value;
      if (value.currencyCode == target.code) {
        converted[entry.key] = value;
        continue;
      }
      final source = currencies[value.currencyCode];
      if (source == null) return null;
      final sourceRate = source.isRub ? Decimal.one : ratesToRub[source.code];
      final targetRate = target.isRub ? null : ratesToRub[target.code];
      if (sourceRate == null || (!target.isRub && targetRate == null)) {
        return null;
      }
      try {
        converted[entry.key] = CurrencyConverter.convertWithRates(
          value: value,
          source: source,
          target: target,
          sourceRateToRub: sourceRate,
          targetRateToRub: targetRate,
        );
      } on DomainException {
        return null;
      }
    }
    return GoalCalculator.calculate(
      goal: goal,
      assetValues: converted,
      currency: target,
      today: today,
    );
  }
}
