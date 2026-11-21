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
}
