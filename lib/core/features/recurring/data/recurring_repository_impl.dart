import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/recurring_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';

/// Правила регулярных платежей поверх [RecurringDao] (8.1-подобный маппинг).
final class RecurringRepositoryImpl implements RecurringRepository {
  const RecurringRepositoryImpl(this._dao);

  final RecurringDao _dao;

  @override
  Stream<List<RecurringRule>> watchActive({RecurringStrategy? strategy}) =>
      _dao.watchActive(strategy: strategy).map(_mapList);

  @override
  Stream<List<RecurringRule>> watchByAccount(int accountId) =>
      _dao.watchByAccount(accountId).map(_mapList);

  @override
  Stream<List<RecurringRule>> watchByProperty(int propertyId) =>
      _dao.watchByProperty(propertyId).map(_mapList);

  @override
  Future<RecurringRule> getById(int id) async => _map(await _dao.getById(id));

  @override
  Future<int> create(RecurringRuleDraft draft) => _dao.create(_input(draft));

  @override
  Future<void> revise(int id, RecurringRuleDraft draft) =>
      _dao.revise(id, _input(draft));

  @override
  Future<void> softDelete(int id) => _dao.softDelete(id);

  @override
  Future<({Money amount, LocalDate date})?> lastGenerated(int ruleId) async {
    final row = await _dao.findLastGeneratedEntry(ruleId);
    if (row == null) return null;
    return (
      amount: Money(
        minorUnits: row.amountMinor,
        currencyCode: row.currencyCode,
      ),
      date: row.occurredOn,
    );
  }

  static List<RecurringRule> _mapList(List<RecurringCashflowRuleRow> rows) => [
    for (final row in rows) _map(row),
  ];

  static RecurringRule _map(RecurringCashflowRuleRow row) => RecurringRule(
    id: row.id,
    strategy: row.strategy,
    kind: row.kind,
    categoryId: row.categoryId,
    amount: row.amountMinor == null
        ? null
        : Money(minorUnits: row.amountMinor!, currencyCode: row.currencyCode),
    currencyCode: row.currencyCode,
    accountId: row.accountId,
    propertyId: row.propertyId,
    affectsBalance: row.affectsBalance,
    startDate: row.startDate,
    endDate: row.endDate,
    comment: row.comment,
    lastGeneratedPeriod: row.lastGeneratedPeriod,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );

  static RecurringRuleInput _input(RecurringRuleDraft draft) =>
      RecurringRuleInput(
        strategy: draft.strategy,
        kind: draft.kind,
        categoryId: draft.categoryId,
        amountMinor: draft.amount?.minorUnits,
        currencyCode: draft.currencyCode,
        accountId: draft.accountId,
        propertyId: draft.propertyId,
        affectsBalance: draft.affectsBalance,
        startDate: draft.startDate,
        endDate: draft.endDate,
        comment: draft.comment,
      );
}
