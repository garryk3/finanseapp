import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/audit/data/audit_repository_impl.dart';
import 'package:finanseapp/core/features/cashflow/data/cashflow_repository_impl.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_calculator.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late CashflowRepositoryImpl repository;
  late AuditRepositoryImpl audit;
  late int expenseCategoryId;
  late int accountId;

  setUp(() async {
    db = openTestDatabase();
    repository = CashflowRepositoryImpl(db.cashflowDao, db.currenciesDao);
    audit = AuditRepositoryImpl(db.auditDao, db.assetsDao);
    expenseCategoryId = (await db.select(db.categories).get())
        .firstWhere((row) => row.kind == CashflowKind.expense)
        .id;
    accountId = await createAccount(db, openingValueMinor: 100000);
  });

  tearDown(() async {
    await db.close();
  });

  CashflowEntryDraft draft({
    int amount = 10000,
    int? account,
    LocalDate? date,
  }) => CashflowEntryDraft(
    kind: CashflowKind.expense,
    categoryId: expenseCategoryId,
    amount: Money(minorUnits: amount, currencyCode: 'RUB'),
    occurredOn: date ?? LocalDate(2026, 1, 2),
    rateToRub: Decimal.one,
    affectsBalance: account != null,
    accountId: account,
    comment: 'Продукты',
  );

  test('audit хранит create/edit/delete ревизии cashflow', () async {
    final id = await repository.create(draft());
    await repository.revise(id, draft(amount: 20000));
    await repository.softDelete(id);

    final revisions = await audit.watchCashflowRevisions(id).first;
    expect(revisions, hasLength(3));
    expect(revisions.first.action, RevisionAction.create);
    expect(revisions[1].action, RevisionAction.edit);
    expect(revisions[1].snapshot.amount.minorUnits, 20000);
    expect(revisions.last.action, RevisionAction.delete);
  });

  test('account filter показывает только связанные записи', () async {
    await repository.create(draft());
    await repository.create(draft(account: accountId));

    final linked = await repository
        .watch(CashflowFilter(accountId: accountId))
        .first;
    expect(linked, hasLength(1));
    expect(linked.single.accountId, accountId);
    expect(linked.single.affectsBalance, isTrue);
  });

  test('удалённая запись скрыта, summary уменьшается', () async {
    final first = await repository.create(draft(amount: 10000));
    await repository.create(draft(amount: 5000));

    final before = await repository.watch(const CashflowFilter()).first;
    expect(CashflowCalculator.totals(before).expense.minorUnits, 15000);

    await repository.softDelete(first);
    final after = await repository.watch(const CashflowFilter()).first;
    expect(after, hasLength(1));
    expect(CashflowCalculator.totals(after).expense.minorUnits, 5000);
  });

  test('конец периода включителен', () async {
    await repository.create(draft(date: LocalDate(2026, 1, 31)));
    final entries = await repository
        .watch(
          CashflowFilter(
            period: DateRange(
              start: LocalDate(2026, 1, 1),
              end: LocalDate(2026, 1, 31),
            ),
          ),
        )
        .first;
    expect(entries, hasLength(1));
  });
}
