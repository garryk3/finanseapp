import 'dart:async';
import 'dart:developer' as developer;

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_schedule.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Итог одного прогона генерации (BR-RC-11).
final class RecurringGenerationReport {
  const RecurringGenerationReport({
    required this.generated,
    required this.pending,
  });

  const RecurringGenerationReport.empty() : generated = 0, pending = const [];

  final int generated;
  final List<RecurringPending> pending;
}

/// Период, который правило не смогло сгенерировать.
final class RecurringPending {
  const RecurringPending({
    required this.ruleId,
    required this.date,
    required this.reason,
  });

  final int ruleId;
  final LocalDate date;
  final RecurringPendingReason reason;
}

/// Причина отложенного периода; UI показывает её без сети (D5).
enum RecurringPendingReason {
  rateUnavailable,
  negativeBalance,
  categoryUnavailable,
  assetArchived,
  validation,
}

/// Генератор операций по активным правилам (BR-RC-3…6, BR-RC-11).
///
/// Никогда не ходит в сеть: курс берётся только из кэша на точную дату;
/// без курса период откладывается. Ошибка одного правила не мешает остальным,
/// [run] не бросает исключения.
final class RecurringGenerator {
  RecurringGenerator({
    required this.db,
    required this.rateRepository,
    required this.currencyRepository,
  });

  final AppDatabase db;
  final ExchangeRateRepository rateRepository;
  final CurrencyRepository currencyRepository;

  /// Генерирует все непогашенные периоды в хронологическом порядке.
  Future<RecurringGenerationReport> run({int chunkSize = 200}) async {
    var generated = 0;
    final pending = <RecurringPending>[];
    try {
      final rules = await db.recurringDao.activeRules();
      if (rules.isEmpty) return const RecurringGenerationReport.empty();
      final assets = await _assetsById();
      final currencies = await _currenciesByCode();
      final today = db.today();
      final tasks = <_PeriodTask>[];

      for (final rule in rules) {
        // Проценты по вкладам добавляет 15.3 (BR-RC-9).
        if (rule.strategy != RecurringStrategy.fixed) continue;
        if (rule.amountMinor == null) continue;

        final archived = _isArchived(rule, assets);
        if (archived) {
          final start = RecurringSchedule.nextPayment(
            startDate: rule.startDate,
            endDate: rule.endDate,
            lastGeneratedPeriod: rule.lastGeneratedPeriod,
            firstPeriodOffset: 0,
          );
          if (start != null) {
            pending.add(
              RecurringPending(
                ruleId: rule.id,
                date: start,
                reason: RecurringPendingReason.assetArchived,
              ),
            );
          }
          continue;
        }

        final dates = RecurringSchedule.dueDates(
          startDate: rule.startDate,
          endDate: rule.endDate,
          today: today,
          lastGeneratedPeriod: rule.lastGeneratedPeriod,
          firstPeriodOffset: 0,
        );
        for (final date in dates) {
          tasks.add(_PeriodTask(rule: rule, date: date));
        }
      }

      tasks.sort(_compareTasks);
      var processed = 0;
      final stoppedRules = <int>{};
      for (final task in tasks) {
        if (stoppedRules.contains(task.rule.id)) continue;
        processed++;
        final result = await _generatePeriod(
          task: task,
          currencies: currencies,
        );
        if (result == _PeriodResult.created) {
          generated++;
        } else if (result != _PeriodResult.skipped) {
          pending.add(
            RecurringPending(
              ruleId: task.rule.id,
              date: task.date,
              reason: _reasonFor(result),
            ),
          );
          // Остальные периоды правила ждут следующего прогона (D5).
          stoppedRules.add(task.rule.id);
        }
        if (processed % chunkSize == 0) {
          await Future<void>.delayed(Duration.zero);
        }
      }
    } catch (error, stackTrace) {
      developer.log(
        'Recurring generation stopped',
        name: 'recurring.generator',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return RecurringGenerationReport(generated: generated, pending: pending);
  }

  /// Возвращает причину отложенного периода или null, если он создан/пропущен.
  Future<_PeriodResult> _generatePeriod({
    required _PeriodTask task,
    required Map<String, Currency> currencies,
  }) async {
    final rule = task.rule;
    final date = task.date;
    try {
      final existing = await db.recurringDao.findGeneratedEntry(rule.id, date);
      if (existing != null) {
        // Пользователь мог удалить операцию: повторно не создаём (BR-RC-4).
        await db.transaction(
          () => db.recurringDao.updateLastGeneratedPeriod(
            rule.id,
            RecurringSchedule.periodKey(date),
          ),
        );
        return _PeriodResult.skipped;
      }

      final rate = await _rateFor(rule.currencyCode, date);
      if (rate == null) return _PeriodResult.rateUnavailable;

      final amount = Money(
        minorUnits: rule.amountMinor!,
        currencyCode: rule.currencyCode,
      );
      final currency = currencies[rule.currencyCode] ?? _fallbackCurrency(rule);
      final rubMinor = CashflowCommands.rubAmount(
        amount,
        currency,
        rate,
      ).minorUnits;

      await db.transaction(() async {
        int? transactionId;
        if (rule.affectsBalance && rule.accountId != null) {
          transactionId = await db.transactionsDao.create(
            AssetTransactionInput(
              assetId: rule.accountId!,
              kind: rule.kind == CashflowKind.income
                  ? AssetTransactionKind.deposit
                  : AssetTransactionKind.withdrawal,
              amountMinor: amount.minorUnits,
              occurredOn: date,
              rateToRub: rate,
              amountRubMinor: rubMinor,
              comment: rule.comment,
            ),
          );
        }
        await db.cashflowDao.create(
          CashflowEntryInput(
            kind: rule.kind,
            categoryId: rule.categoryId,
            amountMinor: amount.minorUnits,
            currencyCode: rule.currencyCode,
            occurredOn: date,
            rateToRub: rate,
            amountRubMinor: rubMinor,
            affectsBalance: rule.affectsBalance,
            comment: rule.comment,
            propertyId: rule.propertyId,
            accountId: rule.accountId,
            assetTransactionId: transactionId,
            recurringRuleId: rule.id,
          ),
        );
        await db.recurringDao.updateLastGeneratedPeriod(
          rule.id,
          RecurringSchedule.periodKey(date),
        );
      });
      return _PeriodResult.created;
    } on DomainException catch (error) {
      developer.log(
        'Recurring period rejected',
        name: 'recurring.generator',
        error: error,
      );
      return _mapError(error);
    } catch (error, stackTrace) {
      developer.log(
        'Recurring period failed',
        name: 'recurring.generator',
        error: error,
        stackTrace: stackTrace,
      );
      return _PeriodResult.validation;
    }
  }

  Future<Decimal?> _rateFor(String currencyCode, LocalDate date) async {
    if (currencyCode == 'RUB') return Decimal.one;
    final rate = await rateRepository.find(currencyCode, date);
    return rate?.rateToRub;
  }

  Future<Map<int, AssetRow>> _assetsById() async {
    final rows = await db.select(db.assets).get();
    return {for (final row in rows) row.id: row};
  }

  Future<Map<String, Currency>> _currenciesByCode() async {
    final rows = await currencyRepository.watchAll().first;
    return {for (final row in rows) row.code: row};
  }

  static bool _isArchived(
    RecurringCashflowRuleRow rule,
    Map<int, AssetRow> assets,
  ) {
    final targetId = rule.accountId ?? rule.propertyId;
    if (targetId == null) return false;
    final asset = assets[targetId];
    return asset == null || asset.archivedAt != null;
  }

  static Currency _fallbackCurrency(RecurringCashflowRuleRow rule) => Currency(
    code: rule.currencyCode,
    name: rule.currencyCode,
    fractionDigits: 2,
    isPreset: true,
    isEnabled: true,
  );

  static int _compareTasks(_PeriodTask left, _PeriodTask right) {
    final byDate = left.date.compareTo(right.date);
    if (byDate != 0) return byDate;
    final byStrategy = left.rule.strategy.index.compareTo(
      right.rule.strategy.index,
    );
    if (byStrategy != 0) return byStrategy;
    return left.rule.id.compareTo(right.rule.id);
  }

  static _PeriodResult _mapError(DomainException error) {
    if (error.code == DomainErrorCode.negativeBalance) {
      return _PeriodResult.negativeBalance;
    }
    final keys = error.fieldErrors.values;
    if (keys.any(_categoryErrorKeys.contains)) {
      return _PeriodResult.categoryUnavailable;
    }
    return _PeriodResult.validation;
  }

  static RecurringPendingReason _reasonFor(_PeriodResult result) =>
      switch (result) {
        _PeriodResult.rateUnavailable => RecurringPendingReason.rateUnavailable,
        _PeriodResult.negativeBalance => RecurringPendingReason.negativeBalance,
        _PeriodResult.categoryUnavailable =>
          RecurringPendingReason.categoryUnavailable,
        _ => RecurringPendingReason.validation,
      };

  static const _categoryErrorKeys = {
    'validationCategoryArchived',
    'validationCategoryNotFound',
    'validationCategoryKindMismatch',
  };
}

final class _PeriodTask {
  const _PeriodTask({required this.rule, required this.date});

  final RecurringCashflowRuleRow rule;
  final LocalDate date;
}

enum _PeriodResult {
  created,
  skipped,
  rateUnavailable,
  negativeBalance,
  categoryUnavailable,
  validation,
}
