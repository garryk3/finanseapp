import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/logic/calculate_goal_progress.dart';
import 'package:finanseapp/core/features/goals/logic/goal_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _usd = Currency(
  code: 'USD',
  name: 'Доллар',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _eur = Currency(
  code: 'EUR',
  name: 'Евро',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _jpy = Currency(
  code: 'JPY',
  name: 'Иена',
  fractionDigits: 0,
  isPreset: false,
  isEnabled: true,
);

final _today = LocalDate(2026, 11, 19);

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

FinancialGoal _goal({
  int target = 100000,
  String currency = 'RUB',
  LocalDate? targetDate,
  GoalStatus status = GoalStatus.active,
  Set<int> assetIds = const {1},
}) => FinancialGoal(
  id: 1,
  name: 'Цель',
  category: GoalCategory.accounts,
  targetAmount: Money(minorUnits: target * 100, currencyCode: currency),
  status: status,
  assetIds: assetIds,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
  targetDate: targetDate,
);

void main() {
  group('GoalCalculator', () {
    test('CALC-026: 50 000 из 100 000 — deficit 50 000, ratio 0,5', () {
      final progress = GoalCalculator.calculate(
        goal: _goal(),
        assetValues: {1: _rubles(30000), 2: _rubles(20000)},
        currency: _rub,
        today: _today,
      );

      expect(progress.progress, _rubles(50000));
      expect(progress.deficit, _rubles(50000));
      expect(progress.surplus, Money(minorUnits: 0, currencyCode: 'RUB'));
      expect(progress.completionRatio, Decimal.parse('0.5'));
      expect(progress.monthlyContribution, isNull);
    });

    test('CALC-027: 120 000 — surplus 20 000 и ratio 1,2 (не clamp)', () {
      final progress = GoalCalculator.calculate(
        goal: _goal(),
        assetValues: {1: _rubles(120000)},
        currency: _rub,
        today: _today,
      );

      expect(progress.deficit, Money(minorUnits: 0, currencyCode: 'RUB'));
      expect(progress.surplus, _rubles(20000));
      expect(progress.completionRatio, Decimal.parse('1.2'));
      expect(
        GoalCalculator.resolveStatus(
          current: GoalStatus.active,
          progress: progress,
        ),
        GoalStatus.achieved,
      );
    });

    test('CALC-028: 12 000 / 6 месяцев → 2 000; 9 500 / 5 → 1 900', () {
      final first = GoalCalculator.calculate(
        goal: _goal(targetDate: LocalDate(2027, 4, 19)),
        assetValues: {1: _rubles(88000)},
        currency: _rub,
        today: _today,
      );
      final second = GoalCalculator.calculate(
        goal: _goal(target: 12000, targetDate: LocalDate(2027, 3, 19)),
        assetValues: {1: _rubles(2500)},
        currency: _rub,
        today: _today,
      );

      expect(first.deficit, _rubles(12000));
      expect(first.monthlyContribution, _rubles(2000));
      expect(second.deficit, _rubles(9500));
      expect(second.monthlyContribution, _rubles(1900));
    });

    test('CALC-029: просроченная дата при дефиците — monthly null', () {
      final progress = GoalCalculator.calculate(
        goal: _goal(targetDate: LocalDate(2026, 11, 18)),
        assetValues: {1: _rubles(10000)},
        currency: _rub,
        today: _today,
      );

      expect(progress.deficit, _rubles(90000));
      expect(progress.monthlyContribution, isNull);
    });

    test('дата сегодня — один месяц; нулевой дефицит — monthly null', () {
      final today = GoalCalculator.calculate(
        goal: _goal(targetDate: _today),
        assetValues: {1: _rubles(90000)},
        currency: _rub,
        today: _today,
      );
      final noDeficit = GoalCalculator.calculate(
        goal: _goal(targetDate: LocalDate(2027, 4, 19)),
        assetValues: {1: _rubles(100000)},
        currency: _rub,
        today: _today,
      );

      expect(today.monthlyContribution, _rubles(10000));
      expect(noDeficit.monthlyContribution, isNull);
    });

    test('closed остаётся closed, achieved снижается до active', () {
      final achieved = GoalCalculator.calculate(
        goal: _goal(target: 100, status: GoalStatus.closed),
        assetValues: {1: _rubles(200)},
        currency: _rub,
        today: _today,
      );
      final dropped = GoalCalculator.calculate(
        goal: _goal(status: GoalStatus.achieved),
        assetValues: {1: _rubles(50000)},
        currency: _rub,
        today: _today,
      );

      expect(
        GoalCalculator.resolveStatus(
          current: GoalStatus.closed,
          progress: achieved,
        ),
        GoalStatus.closed,
      );
      expect(
        GoalCalculator.resolveStatus(
          current: GoalStatus.achieved,
          progress: dropped,
        ),
        GoalStatus.active,
      );
    });

    test('валюта значений и нулевая цель отклоняются', () {
      expect(
        () => GoalCalculator.calculate(
          goal: _goal(),
          assetValues: {1: const Money(minorUnits: 100, currencyCode: 'USD')},
          currency: _rub,
          today: _today,
        ),
        throwsA(isA<DomainException>()),
      );
      expect(
        () => GoalCalculator.calculate(
          goal: _goal(target: 0),
          assetValues: const {},
          currency: _rub,
          today: _today,
        ),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('CalculateGoalProgress', () {
    const calculator = CalculateGoalProgress();
    final currencies = {'RUB': _rub, 'USD': _usd, 'EUR': _eur, 'JPY': _jpy};

    test('USD + RUB конвертируются в валюту цели', () {
      final progress = calculator.calculate(
        goal: _goal(), // RUB
        assetValues: {
          1: const Money(minorUnits: 2000, currencyCode: 'USD'),
          2: _rubles(1000),
        },
        currencies: currencies,
        ratesToRub: {'USD': Decimal.fromInt(90)},
        today: _today,
      );

      expect(progress, isNotNull);
      expect(progress!.progress, _rubles(2800));
    });

    test('цель в USD: RUB и USD складываются после конверсии', () {
      final progress = calculator.calculate(
        goal: _goal(currency: 'USD'),
        assetValues: {
          1: _rubles(9000),
          2: const Money(minorUnits: 5000, currencyCode: 'USD'),
        },
        currencies: currencies,
        ratesToRub: {'USD': Decimal.fromInt(90)},
        today: _today,
      );

      expect(
        progress!.progress,
        const Money(minorUnits: 15000, currencyCode: 'USD'),
      );
    });

    test('цель в EUR, активы в RUB и USD', () {
      final progress = calculator.calculate(
        goal: _goal(currency: 'EUR'),
        assetValues: {
          1: _rubles(900),
          2: const Money(minorUnits: 4500, currencyCode: 'USD'),
        },
        currencies: currencies,
        ratesToRub: {'USD': Decimal.fromInt(90), 'EUR': Decimal.fromInt(100)},
        today: _today,
      );

      expect(
        progress!.progress,
        const Money(minorUnits: 4950, currencyCode: 'EUR'),
      );
    });

    test('нет курса — прогресс не считается (не частичная сумма)', () {
      final progress = calculator.calculate(
        goal: _goal(),
        assetValues: {1: const Money(minorUnits: 2000, currencyCode: 'USD')},
        currencies: currencies,
        ratesToRub: const {},
        today: _today,
      );

      expect(progress, isNull);
    });

    test('валюта цели отсутствует в справочнике — null', () {
      final progress = calculator.calculate(
        goal: _goal(currency: 'CHF'),
        assetValues: const {},
        currencies: currencies,
        ratesToRub: const {},
        today: _today,
      );

      expect(progress, isNull);
    });

    test('одна валюта с целью не требует курсов', () {
      final progress = calculator.calculate(
        goal: _goal(currency: 'JPY'),
        assetValues: {1: const Money(minorUnits: 1000, currencyCode: 'JPY')},
        currencies: currencies,
        ratesToRub: const {},
        today: _today,
      );

      expect(
        progress!.progress,
        const Money(minorUnits: 1000, currencyCode: 'JPY'),
      );
    });
  });
}
