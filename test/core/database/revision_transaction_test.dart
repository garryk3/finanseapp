import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import 'database_fixtures.dart';

Map<String, dynamic> decodeSnapshot(String json) =>
    jsonDecode(json) as Map<String, dynamic>;

Matcher throwsDomain(DomainErrorCode code) =>
    throwsA(isA<DomainException>().having((error) => error.code, 'code', code));

void main() {
  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<AssetTransactionInput> deposit(
    int assetId,
    int amountMinor, {
    LocalDate? occurredOn,
  }) => Future.value(
    AssetTransactionInput(
      assetId: assetId,
      kind: AssetTransactionKind.deposit,
      amountMinor: amountMinor,
      occurredOn: occurredOn ?? LocalDate(2026, 1, 10),
      rateToRub: Decimal.one,
      amountRubMinor: amountMinor,
      comment: 'вклад',
    ),
  );

  Future<int> balanceOf(int assetId) async {
    final asset = await (db.select(
      db.assets,
    )..where((a) => a.id.equals(assetId))).getSingle();
    final rows = await (db.select(
      db.assetTransactions,
    )..where((t) => t.assetId.equals(assetId) & t.deletedAt.isNull())).get();
    var balance = asset.openingValueMinor;
    for (final row in rows) {
      balance +=
          row.kind == AssetTransactionKind.deposit ||
              row.kind == AssetTransactionKind.transferIn
          ? row.amountMinor
          : -row.amountMinor;
    }
    return balance;
  }

  group('TX-ASSET-TX-CREATE', () {
    test('create пишет revisionNo=1 и идентичный create-snapshot', () async {
      final accountId = await createAccount(db, openingValueMinor: 100000);
      final id = await db.transactionsDao.create(
        await deposit(accountId, 25050),
      );

      final row = await db.transactionsDao.getById(id);
      final revisions = await db.transactionsDao.revisions(id);
      final snapshot = decodeSnapshot(revisions.single.snapshotJson);

      expect(row.revisionNo, 1);
      expect(revisions, hasLength(1));
      expect(revisions.single.action, RevisionAction.create);
      expect(snapshot['snapshotSchemaVersion'], 1);
      expect(snapshot['id'], id);
      expect(snapshot['assetId'], accountId);
      expect(snapshot['kind'], 'deposit');
      expect(snapshot['amountMinor'], 25050);
      expect(snapshot['occurredOn'], '2026-01-10');
      expect(snapshot['rateToRub'], '1');
      expect(snapshot['deletedAt'], isNull);
      expect(await balanceOf(accountId), 125050);
    });

    test('revise добавляет edit-ревизию, старый snapshot неизменен', () async {
      final accountId = await createAccount(db, openingValueMinor: 100000);
      final id = await db.transactionsDao.create(
        await deposit(accountId, 25050),
      );

      await db.transactionsDao.revise(
        id,
        AssetTransactionInput(
          assetId: accountId,
          kind: AssetTransactionKind.deposit,
          amountMinor: 30000,
          occurredOn: LocalDate(2026, 1, 11),
          rateToRub: Decimal.parse('1'),
          amountRubMinor: 30000,
        ),
      );

      final row = await db.transactionsDao.getById(id);
      final revisions = await db.transactionsDao.revisions(id);

      expect(row.revisionNo, 2);
      expect(row.amountMinor, 30000);
      expect(row.createdAt, row.createdAt.toUtc());
      expect(revisions, hasLength(2));
      expect(revisions.last.action, RevisionAction.edit);
      expect(revisions.first.snapshotJson, contains('"amountMinor":25050'));
      expect(revisions.last.snapshotJson, contains('"amountMinor":30000'));
      expect(revisions.last.snapshotJson, contains('"revisionNo":2'));
    });

    test('softDelete сохраняет строку и добавляет delete-ревизию', () async {
      final accountId = await createAccount(db);
      final id = await db.transactionsDao.create(
        await deposit(accountId, 1000),
      );

      await db.transactionsDao.softDelete(id);

      final row = await db.transactionsDao.getById(id);
      final revisions = await db.transactionsDao.revisions(id);
      final snapshot = decodeSnapshot(revisions.last.snapshotJson);

      expect(row.deletedAt, isNotNull);
      expect(row.revisionNo, 2);
      expect(revisions.map((r) => r.action), [
        RevisionAction.create,
        RevisionAction.delete,
      ]);
      expect(snapshot['deletedAt'], isNotNull);
      expect(await db.transactionsDao.watchByAsset(accountId).first, isEmpty);
    });

    test('сбой записи ревизии откатывает операцию', () async {
      final accountId = await createAccount(db);
      await db.customStatement(
        'CREATE TRIGGER test_boom BEFORE INSERT ON '
        'asset_transaction_revisions BEGIN '
        "SELECT RAISE(ABORT, 'boom'); END",
      );

      await expectLater(
        db.transactionsDao.create(await deposit(accountId, 1000)),
        throwsA(isA<Exception>()),
      );
      await db.customStatement('DROP TRIGGER test_boom');

      expect(await db.select(db.assetTransactions).get(), isEmpty);
    });

    test('отрицательный баланс и порядок операций по дате', () async {
      final accountId = await createAccount(db, openingValueMinor: 10000);

      await expectLater(
        db.transactionsDao.create(
          AssetTransactionInput(
            assetId: accountId,
            kind: AssetTransactionKind.withdrawal,
            amountMinor: 10001,
            occurredOn: LocalDate(2026, 1, 10),
            rateToRub: Decimal.one,
            amountRubMinor: 10001,
          ),
        ),
        throwsDomain(DomainErrorCode.negativeBalance),
      );
      expect(await db.select(db.assetTransactions).get(), isEmpty);

      // Позднее пополнение не спасает раннее снятие (CALC-010 по порядку дат).
      await db.transactionsDao.create(await deposit(accountId, 20000));
      await expectLater(
        db.transactionsDao.create(
          AssetTransactionInput(
            assetId: accountId,
            kind: AssetTransactionKind.withdrawal,
            amountMinor: 15000,
            occurredOn: LocalDate(2026, 1, 5),
            rateToRub: Decimal.one,
            amountRubMinor: 15000,
          ),
        ),
        throwsDomain(DomainErrorCode.negativeBalance),
      );
      expect(
        await db.transactionsDao.watchByAsset(accountId).first,
        hasLength(1),
      );
    });

    test('квартира не принимает операции, инвестиция — принимает', () async {
      final propertyId = await createProperty(db);
      final investmentId = await createInvestment(db);

      await expectLater(
        db.transactionsDao.create(
          AssetTransactionInput(
            assetId: propertyId,
            kind: AssetTransactionKind.deposit,
            amountMinor: 100,
            occurredOn: LocalDate(2026, 1, 10),
            rateToRub: Decimal.one,
            amountRubMinor: 100,
          ),
        ),
        throwsDomain(DomainErrorCode.validation),
      );

      await expectLater(
        db.transactionsDao.create(
          AssetTransactionInput(
            assetId: investmentId,
            kind: AssetTransactionKind.deposit,
            amountMinor: 100,
            occurredOn: LocalDate(2026, 1, 10),
            rateToRub: Decimal.one,
            amountRubMinor: 100,
          ),
        ),
        completes,
      );
    });
  });

  group('TX-TRANSFER-SAVE', () {
    late int fromId;
    late int toId;

    setUp(() async {
      fromId = await createAccount(db, name: 'A', openingValueMinor: 100000);
      toId = await createAccount(db, name: 'B');
    });

    TransferInput transferInput({
      int fromAmountMinor = 50000,
      int toAmountMinor = 50000,
      int? from,
      int? to,
    }) => TransferInput(
      fromAccountId: from ?? fromId,
      toAccountId: to ?? toId,
      fromAmountMinor: fromAmountMinor,
      toAmountMinor: toAmountMinor,
      occurredOn: LocalDate(2026, 1, 15),
      fromRateToRub: Decimal.one,
      toRateToRub: Decimal.one,
      fromAmountRubMinor: fromAmountMinor,
      toAmountRubMinor: toAmountMinor,
    );

    test('create создаёт группу, две ноги и по create-ревизии', () async {
      final transferId = await db.transactionsDao.createTransfer(
        transferInput(),
      );

      final legs = await (db.select(
        db.assetTransactions,
      )..where((t) => t.transferId.equals(transferId))).get();

      expect(legs, hasLength(2));
      expect(legs.map((leg) => leg.kind).toSet(), {
        AssetTransactionKind.transferOut,
        AssetTransactionKind.transferIn,
      });
      for (final leg in legs) {
        final revisions = await db.transactionsDao.revisions(leg.id);
        expect(revisions.single.action, RevisionAction.create);
      }
      expect(await balanceOf(fromId), 50000);
      expect(await balanceOf(toId), 50000);
    });

    test('недостаточный баланс откатывает перевод полностью', () async {
      await expectLater(
        db.transactionsDao.createTransfer(
          transferInput(fromAmountMinor: 100001, toAmountMinor: 100001),
        ),
        throwsDomain(DomainErrorCode.negativeBalance),
      );

      expect(await db.select(db.assetTransfers).get(), isEmpty);
      expect(await db.select(db.assetTransactions).get(), isEmpty);
    });

    test('один и тот же счёт и не-счёт отклоняются', () async {
      await expectLater(
        db.transactionsDao.createTransfer(
          transferInput(from: fromId, to: fromId),
        ),
        throwsDomain(DomainErrorCode.validation),
      );

      final investmentId = await createInvestment(db);
      await expectLater(
        db.transactionsDao.createTransfer(transferInput(to: investmentId)),
        throwsDomain(DomainErrorCode.validation),
      );
    });

    test(
      'reviseTransfer обновляет обе ноги и добавляет edit-ревизии',
      () async {
        final transferId = await db.transactionsDao.createTransfer(
          transferInput(),
        );

        await db.transactionsDao.reviseTransfer(
          transferId,
          transferInput(fromAmountMinor: 60000, toAmountMinor: 70000),
        );

        final legs = await (db.select(
          db.assetTransactions,
        )..where((t) => t.transferId.equals(transferId))).get();
        final outLeg = legs.firstWhere(
          (leg) => leg.kind == AssetTransactionKind.transferOut,
        );
        final inLeg = legs.firstWhere(
          (leg) => leg.kind == AssetTransactionKind.transferIn,
        );

        expect(outLeg.amountMinor, 60000);
        expect(inLeg.amountMinor, 70000);
        expect(outLeg.revisionNo, 2);
        expect(inLeg.revisionNo, 2);
        expect(await db.transactionsDao.revisions(outLeg.id), hasLength(2));
        expect(await db.transactionsDao.revisions(inLeg.id), hasLength(2));
      },
    );

    test('softDeleteTransfer удаляет обе ноги, группа остаётся', () async {
      final transferId = await db.transactionsDao.createTransfer(
        transferInput(),
      );

      await db.transactionsDao.softDeleteTransfer(transferId);

      final legs = await (db.select(
        db.assetTransactions,
      )..where((t) => t.transferId.equals(transferId))).get();
      expect(legs.every((leg) => leg.deletedAt != null), isTrue);
      expect(
        await (db.select(
          db.assetTransfers,
        )..where((t) => t.id.equals(transferId))).get(),
        hasLength(1),
      );
      for (final leg in legs) {
        final revisions = await db.transactionsDao.revisions(leg.id);
        expect(revisions.map((r) => r.action), [
          RevisionAction.create,
          RevisionAction.delete,
        ]);
      }
    });

    test('сбой ревизии откатывает reviseTransfer обеих ног', () async {
      final transferId = await db.transactionsDao.createTransfer(
        transferInput(),
      );
      await db.customStatement(
        'CREATE TRIGGER test_boom BEFORE INSERT ON '
        'asset_transaction_revisions BEGIN '
        "SELECT RAISE(ABORT, 'boom'); END",
      );

      await expectLater(
        db.transactionsDao.reviseTransfer(
          transferId,
          transferInput(fromAmountMinor: 60000, toAmountMinor: 70000),
        ),
        throwsA(isA<Exception>()),
      );
      await db.customStatement('DROP TRIGGER test_boom');

      final legs = await (db.select(
        db.assetTransactions,
      )..where((t) => t.transferId.equals(transferId))).get();
      expect(legs.every((leg) => leg.amountMinor == 50000), isTrue);
      expect(legs.every((leg) => leg.revisionNo == 1), isTrue);
    });

    test('сбой ревизии откатывает softDeleteTransfer обеих ног', () async {
      final transferId = await db.transactionsDao.createTransfer(
        transferInput(),
      );
      await db.customStatement(
        'CREATE TRIGGER test_boom BEFORE INSERT ON '
        'asset_transaction_revisions BEGIN '
        "SELECT RAISE(ABORT, 'boom'); END",
      );

      await expectLater(
        db.transactionsDao.softDeleteTransfer(transferId),
        throwsA(isA<Exception>()),
      );
      await db.customStatement('DROP TRIGGER test_boom');

      final legs = await (db.select(
        db.assetTransactions,
      )..where((t) => t.transferId.equals(transferId))).get();
      expect(legs.every((leg) => leg.deletedAt == null), isTrue);
      expect(legs.every((leg) => leg.revisionNo == 1), isTrue);
    });

    test(
      'revise учитывает id при равной дате (excludeTransactionId)',
      () async {
        final accountId = await createAccount(db, openingValueMinor: 10000);
        final firstId = await db.transactionsDao.create(
          AssetTransactionInput(
            assetId: accountId,
            kind: AssetTransactionKind.withdrawal,
            amountMinor: 4000,
            occurredOn: LocalDate(2026, 1, 10),
            rateToRub: Decimal.one,
            amountRubMinor: 4000,
          ),
        );
        await db.transactionsDao.create(
          AssetTransactionInput(
            assetId: accountId,
            kind: AssetTransactionKind.withdrawal,
            amountMinor: 3000,
            occurredOn: LocalDate(2026, 1, 10),
            rateToRub: Decimal.one,
            amountRubMinor: 3000,
          ),
        );

        // При равной дате вторая запись имеет больший id: 100 − 90 = 10, затем
        // −30 даёт отрицательный промежуточный баланс.
        await expectLater(
          db.transactionsDao.revise(
            firstId,
            AssetTransactionInput(
              assetId: accountId,
              kind: AssetTransactionKind.withdrawal,
              amountMinor: 9000,
              occurredOn: LocalDate(2026, 1, 10),
              rateToRub: Decimal.one,
              amountRubMinor: 9000,
            ),
          ),
          throwsDomain(DomainErrorCode.negativeBalance),
        );

        // 100 − 60 = 40, затем −30 = 10 — баланс остаётся неотрицательным.
        await expectLater(
          db.transactionsDao.revise(
            firstId,
            AssetTransactionInput(
              assetId: accountId,
              kind: AssetTransactionKind.withdrawal,
              amountMinor: 6000,
              occurredOn: LocalDate(2026, 1, 10),
              rateToRub: Decimal.one,
              amountRubMinor: 6000,
            ),
          ),
          completes,
        );
      },
    );

    test('прямые revise/softDelete ноги перевода отклоняются', () async {
      final transferId = await db.transactionsDao.createTransfer(
        transferInput(),
      );
      final leg = (await (db.select(
        db.assetTransactions,
      )..where((t) => t.transferId.equals(transferId))).get()).first;

      await expectLater(
        db.transactionsDao.softDelete(leg.id),
        throwsDomain(DomainErrorCode.conflict),
      );
      await expectLater(
        db.transactionsDao.revise(
          leg.id,
          AssetTransactionInput(
            assetId: leg.assetId,
            kind: AssetTransactionKind.deposit,
            amountMinor: 100,
            occurredOn: LocalDate(2026, 1, 15),
            rateToRub: Decimal.one,
            amountRubMinor: 100,
          ),
        ),
        throwsDomain(DomainErrorCode.conflict),
      );
    });
  });
}
