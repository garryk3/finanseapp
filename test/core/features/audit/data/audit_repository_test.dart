import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/audit/data/audit_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/core/features/transactions/logic/revision_diff.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AssetTransactionRepositoryImpl transactions;
  late AuditRepositoryImpl audit;
  late int assetId;

  setUp(() async {
    db = openTestDatabase();
    transactions = AssetTransactionRepositoryImpl(db);
    audit = AuditRepositoryImpl(db.auditDao, db.assetsDao);
    assetId = await createAccount(db, currencyCode: 'RUB');
  });

  tearDown(() async {
    await db.close();
  });

  AssetTransactionDraft draft({int amount = 10000, String? comment}) =>
      AssetTransactionDraft(
        assetId: assetId,
        kind: AssetTransactionKind.deposit,
        amount: Money(minorUnits: amount, currencyCode: 'RUB'),
        occurredOn: LocalDate(2026, 1, 2),
        rateToRub: Decimal.one,
        comment: comment,
      );

  test('ревизии append-only: create → edit → delete и diff', () async {
    final id = await transactions.create(draft());
    await transactions.revise(id, draft(amount: 20000, comment: 'правка'));
    await transactions.softDelete(id);

    final revisions = await audit.watchAssetTransactionRevisions(id).first;
    expect(revisions, hasLength(3));
    expect(revisions[0].action, RevisionAction.create);
    expect(revisions[0].snapshot.amount.minorUnits, 10000);
    expect(revisions[1].action, RevisionAction.edit);
    expect(revisions[1].snapshot.amount.minorUnits, 20000);
    expect(revisions[1].snapshot.revisionNo, 2);
    expect(revisions[2].action, RevisionAction.delete);
    expect(revisions[2].snapshot.deletedAt, isNotNull);

    final diff = diffAssetTransactions(
      revisions[0].snapshot,
      revisions[1].snapshot,
    );
    expect(
      diff.map((change) => change.field),
      containsAll(['amount', 'comment']),
    );
    final amount = diff.firstWhere((change) => change.field == 'amount');
    expect(amount.oldValue, contains('100'));
    expect(amount.newValue, contains('200'));
    expect(revisions[0].snapshot.amount.minorUnits, 10000);
  });

  test('фильтры журнала комбинируются', () async {
    final usdId = await createAccount(db, name: 'USD', currencyCode: 'USD');
    await transactions.create(draft(comment: 'Аренда'));
    await transactions.create(
      AssetTransactionDraft(
        assetId: usdId,
        kind: AssetTransactionKind.deposit,
        amount: const Money(minorUnits: 100, currencyCode: 'USD'),
        occurredOn: LocalDate(2026, 2, 2),
        rateToRub: Decimal.fromInt(90),
        comment: 'Продукты',
      ),
    );

    final byFilters = await transactions
        .watch(
          TransactionFilter(
            period: DateRange(
              start: LocalDate(2026, 1, 1),
              end: LocalDate(2026, 1, 31),
            ),
            assetId: assetId,
            kind: AssetTransactionKind.deposit,
            currencyCode: 'RUB',
            query: 'арен',
          ),
        )
        .first;
    expect(byFilters, hasLength(1));
    expect(byFilters.single.assetId, assetId);

    final byCurrency = await transactions
        .watch(const TransactionFilter(currencyCode: 'USD'))
        .first;
    expect(byCurrency, hasLength(1));
    expect(byCurrency.single.assetId, usdId);
  });

  test('удалённая операция остаётся доступной для аудита', () async {
    final id = await transactions.create(draft());
    await transactions.softDelete(id);

    final current = await transactions.getById(id);
    expect(current.deletedAt, isNotNull);
    expect(await audit.watchAssetTransactionRevisions(id).first, hasLength(2));
    final filter = TransactionFilter(assetId: assetId);
    expect(await transactions.watch(filter).first, isEmpty);
  });
}
