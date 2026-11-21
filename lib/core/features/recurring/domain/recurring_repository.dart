import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';

/// Repository правил регулярных платежей (domain_model §6a).
abstract interface class RecurringRepository {
  Stream<List<RecurringRule>> watchActive({RecurringStrategy? strategy});

  Stream<List<RecurringRule>> watchByAccount(int accountId);

  Stream<List<RecurringRule>> watchByProperty(int propertyId);

  Future<RecurringRule> getById(int id);

  Future<int> create(RecurringRuleDraft draft);

  Future<void> revise(int id, RecurringRuleDraft draft);

  Future<void> softDelete(int id);

  /// Последнее начисление правила (сумма и дата) для карточки в деталях счёта.
  Future<({Money amount, LocalDate date})?> lastGenerated(int ruleId);
}
