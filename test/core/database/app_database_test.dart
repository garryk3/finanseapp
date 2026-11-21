import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/recurring_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import 'database_fixtures.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('структура схемы', () {
    test('integrity_check = ok и foreign_key_check пуст', () async {
      final integrity = await db
          .customSelect('PRAGMA integrity_check')
          .getSingle();
      expect(integrity.read<String>('integrity_check'), 'ok');
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    });

    test('application_id = FNAP, schemaVersion = 2', () async {
      final appId = await db.customSelect('PRAGMA application_id').getSingle();
      expect(appId.read<int>('application_id'), appDatabaseApplicationId);
      expect(appDatabaseApplicationId, 0x464E4150);
      expect(db.schemaVersion, 2);
    });

    test('UTC timestamp хранится фиксированной ширины', () {
      const converter = UtcTimestampConverter();

      expect(
        converter.toSql(DateTime.utc(2026, 1, 1)),
        '2026-01-01T00:00:00.000000Z',
      );
      expect(
        converter.toSql(DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 500)),
        '2026-01-01T00:00:00.000500Z',
      );
      expect(
        DateTime.parse(converter.toSql(DateTime.utc(2026, 1, 1, 10, 30))),
        DateTime.utc(2026, 1, 1, 10, 30),
      );
    });

    test('все таблицы v1 созданы', () async {
      final tables = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      final names = tables.map((row) => row.read<String>('name')).toSet();

      expect(
        names,
        containsAll([
          'assets',
          'account_details',
          'investment_details',
          'property_details',
          'asset_valuations',
          'asset_transfers',
          'asset_transactions',
          'asset_transaction_revisions',
          'cashflow_entries',
          'cashflow_entry_revisions',
          'subgroups',
          'currencies',
          'exchange_rates',
          'categories',
          'goals',
          'goal_assets',
          'app_settings',
          'recurring_cashflow_rules',
        ]),
      );
    });

    test('индекс последней оценки включает id', () async {
      final rows = await db
          .customSelect("PRAGMA index_info('asset_valuations_asset_effective')")
          .get();

      expect(rows.map((row) => row.read<String>('name')), [
        'asset_id',
        'effective_on',
        'id',
      ]);
    });

    test('индексы и триггеры созданы', () async {
      final indexes = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      final triggers = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'trigger'")
          .get();
      final indexNames = indexes.map((row) => row.read<String>('name')).toSet();
      final triggerNames = triggers
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(
        indexNames,
        containsAll([
          'asset_transactions_active_transfer_leg',
          'cashflow_active_asset_link',
          'categories_active_name',
          'assets_currency',
          'cashflow_occurred',
          'recurring_active_deposit_interest',
          'cashflow_recurring_period',
        ]),
      );
      expect(
        triggerNames,
        containsAll([
          'asset_transaction_revisions_no_update',
          'asset_transaction_revisions_no_delete',
          'cashflow_entry_revisions_no_update',
          'cashflow_entry_revisions_no_delete',
          'currencies_rub_no_disable',
          'currencies_rub_no_delete',
          'account_details_dates_on_insert',
          'account_details_dates_on_update',
        ]),
      );
    });
  });

  group('ограничения', () {
    test('FK RESTRICT запрещает удалить используемую валюту', () async {
      await createAccount(db, currencyCode: 'USD');

      await expectLater(
        (db.delete(db.currencies)..where((c) => c.code.equals('USD'))).go(),
        throwsA(isA<Exception>()),
      );
    });

    test('unique (currencyCode, date) для курса', () async {
      Future<void> insertRate() => db
          .into(db.exchangeRates)
          .insert(
            ExchangeRatesCompanion.insert(
              currencyCode: 'USD',
              date: LocalDate(2026, 1, 5),
              rateToRub: Decimal.parse('90.25'),
              source: ExchangeRateSource.manual,
              fetchedAt: testNow(),
            ),
          );

      await insertRate();
      await expectLater(insertRate(), throwsA(isA<Exception>()));
    });

    test('CHECK суммы и fractionDigits', () async {
      final accountId = await createAccount(db);

      await expectLater(
        db
            .into(db.assetTransactions)
            .insert(
              AssetTransactionsCompanion.insert(
                assetId: accountId,
                kind: AssetTransactionKind.deposit,
                amountMinor: 0,
                occurredOn: LocalDate(2026, 1, 5),
                rateToRub: Decimal.one,
                amountRubMinor: 100,
                revisionNo: 1,
                createdAt: testNow(),
                updatedAt: testNow(),
              ),
            ),
        throwsA(isA<Exception>()),
      );

      await expectLater(
        db
            .into(db.currencies)
            .insert(
              CurrenciesCompanion.insert(
                code: 'BAD',
                name: 'Плохая',
                normalizedName: 'плохая',
                fractionDigits: 9,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('CHECK property/account взаимоисключающие и affectsBalance', () async {
      final propertyId = await createProperty(db);
      final accountId = await createAccount(db);
      final category = await categoryId(db, CashflowKind.expense);

      await expectLater(
        db
            .into(db.cashflowEntries)
            .insert(
              CashflowEntriesCompanion.insert(
                kind: CashflowKind.expense,
                categoryId: category,
                amountMinor: 100,
                currencyCode: 'RUB',
                occurredOn: LocalDate(2026, 1, 5),
                rateToRub: Decimal.one,
                amountRubMinor: 100,
                affectsBalance: false,
                propertyId: Value(propertyId),
                accountId: Value(accountId),
                revisionNo: 1,
                createdAt: testNow(),
                updatedAt: testNow(),
              ),
            ),
        throwsA(isA<Exception>()),
      );

      await expectLater(
        db
            .into(db.cashflowEntries)
            .insert(
              CashflowEntriesCompanion.insert(
                kind: CashflowKind.expense,
                categoryId: category,
                amountMinor: 100,
                currencyCode: 'RUB',
                occurredOn: LocalDate(2026, 1, 5),
                rateToRub: Decimal.one,
                amountRubMinor: 100,
                affectsBalance: true,
                revisionNo: 1,
                createdAt: testNow(),
                updatedAt: testNow(),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'будущие даты дохода/расхода и оценки отклоняются (BR-VAL-5)',
      () async {
        final future = LocalDate(2030, 1, 1);
        final accountId = await createAccount(db);
        final toAccountId = await createAccount(db, name: 'B');
        final investmentId = await createInvestment(db);
        final category = await categoryId(db, CashflowKind.expense);

        await expectLater(
          db.cashflowDao.create(
            CashflowEntryInput(
              kind: CashflowKind.expense,
              categoryId: category,
              amountMinor: 100,
              currencyCode: 'RUB',
              occurredOn: future,
              rateToRub: Decimal.one,
              amountRubMinor: 100,
              affectsBalance: false,
            ),
          ),
          throwsA(
            isA<DomainException>()
                .having(
                  (error) => error.code,
                  'code',
                  DomainErrorCode.validation,
                )
                .having(
                  (error) => error.fieldErrors,
                  'fieldErrors',
                  containsPair('occurredOn', 'validationDateInFuture'),
                ),
          ),
        );

        await expectLater(
          db.valuationsDao.create(
            assetId: investmentId,
            effectiveOn: future,
            valueMinor: 100,
            rateToRub: Decimal.one,
            valueRubMinor: 100,
          ),
          throwsA(
            isA<DomainException>()
                .having(
                  (error) => error.code,
                  'code',
                  DomainErrorCode.validation,
                )
                .having(
                  (error) => error.fieldErrors,
                  'fieldErrors',
                  containsPair('effectiveOn', 'validationDateInFuture'),
                ),
          ),
        );

        // Перевод с будущей датой не должен создавать группу.
        await expectLater(
          db.transactionsDao.createTransfer(
            TransferInput(
              fromAccountId: accountId,
              toAccountId: toAccountId,
              fromAmountMinor: 100,
              toAmountMinor: 100,
              occurredOn: future,
              fromRateToRub: Decimal.one,
              toRateToRub: Decimal.one,
              fromAmountRubMinor: 100,
              toAmountRubMinor: 100,
            ),
          ),
          throwsA(
            isA<DomainException>().having(
              (error) => error.code,
              'code',
              DomainErrorCode.validation,
            ),
          ),
        );
        expect(await db.select(db.assetTransfers).get(), isEmpty);
      },
    );

    test('оценка допустима только для инвестиции и квартиры', () async {
      final accountId = await createAccount(db);

      await expectLater(
        db.valuationsDao.create(
          assetId: accountId,
          effectiveOn: LocalDate(2026, 1, 1),
          valueMinor: 100,
          rateToRub: Decimal.one,
          valueRubMinor: 100,
        ),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.validation,
          ),
        ),
      );

      final investmentId = await createInvestment(db);
      await expectLater(
        db.valuationsDao.create(
          assetId: investmentId,
          effectiveOn: LocalDate(2026, 1, 1),
          valueMinor: 100,
          rateToRub: Decimal.one,
          valueRubMinor: 100,
        ),
        completes,
      );
    });

    test('базовая валюта считается использованием (BR-C-4)', () async {
      await db.settingsDao.setBaseCurrency('USD');

      await expectLater(
        db.currenciesDao.setEnabled('USD', false),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.conflict,
          ),
        ),
      );
      await expectLater(
        db.currenciesDao.deleteIfUnused('USD'),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.conflict,
          ),
        ),
      );

      await db.settingsDao.setBaseCurrency('RUB');
      await expectLater(db.currenciesDao.setEnabled('USD', false), completes);
    });

    test('RUB нельзя отключить или удалить', () async {
      await expectLater(
        db.customStatement(
          "UPDATE currencies SET is_enabled = 0 WHERE code = 'RUB'",
        ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db.customStatement("DELETE FROM currencies WHERE code = 'RUB'"),
        throwsA(isA<Exception>()),
      );
    });

    test('дата окончания счёта не раньше даты начала', () async {
      final accountId = await createAccount(db);

      await expectLater(
        db.customStatement(
          'UPDATE account_details SET start_date = ?, end_date = ? '
          'WHERE asset_id = ?',
          ['2026-02-01', '2026-01-01', accountId],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('ревизии append-only: UPDATE/DELETE запрещены', () async {
      final accountId = await createAccount(db);
      final txId = await db
          .into(db.assetTransactions)
          .insert(
            AssetTransactionsCompanion.insert(
              assetId: accountId,
              kind: AssetTransactionKind.deposit,
              amountMinor: 100,
              occurredOn: LocalDate(2026, 1, 5),
              rateToRub: Decimal.one,
              amountRubMinor: 100,
              revisionNo: 1,
              createdAt: testNow(),
              updatedAt: testNow(),
            ),
          );
      await db
          .into(db.assetTransactionRevisions)
          .insert(
            AssetTransactionRevisionsCompanion.insert(
              transactionId: txId,
              revisionNo: 1,
              action: RevisionAction.create,
              snapshotJson: '{}',
              changedAt: testNow(),
            ),
          );

      await expectLater(
        db.customStatement(
          "UPDATE asset_transaction_revisions SET snapshot_json = 'x'",
        ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db.customStatement('DELETE FROM asset_transaction_revisions'),
        throwsA(isA<Exception>()),
      );
    });

    test('частичный уникальный индекс активной ноги перевода', () async {
      final from = await createAccount(db, name: 'A');
      final to = await createAccount(db, name: 'B');
      final transferId = await db
          .into(db.assetTransfers)
          .insert(
            AssetTransfersCompanion.insert(
              createdAt: testNow(),
              updatedAt: testNow(),
            ),
          );

      Future<int> insertLeg(int assetId) => db
          .into(db.assetTransactions)
          .insert(
            AssetTransactionsCompanion.insert(
              assetId: assetId,
              kind: AssetTransactionKind.transferOut,
              amountMinor: 100,
              occurredOn: LocalDate(2026, 1, 5),
              rateToRub: Decimal.one,
              amountRubMinor: 100,
              transferId: Value(transferId),
              revisionNo: 1,
              createdAt: testNow(),
              updatedAt: testNow(),
            ),
          );

      await insertLeg(from);
      await expectLater(insertLeg(to), throwsA(isA<Exception>()));
    });

    test('частичный уникальный индекс активной связи cashflow', () async {
      final accountId = await createAccount(db);
      final category = await categoryId(db, CashflowKind.expense);
      final txId = await db
          .into(db.assetTransactions)
          .insert(
            AssetTransactionsCompanion.insert(
              assetId: accountId,
              kind: AssetTransactionKind.withdrawal,
              amountMinor: 100,
              occurredOn: LocalDate(2026, 1, 5),
              rateToRub: Decimal.one,
              amountRubMinor: 100,
              revisionNo: 1,
              createdAt: testNow(),
              updatedAt: testNow(),
            ),
          );

      Future<int> insertEntry() => db
          .into(db.cashflowEntries)
          .insert(
            CashflowEntriesCompanion.insert(
              kind: CashflowKind.expense,
              categoryId: category,
              amountMinor: 100,
              currencyCode: 'RUB',
              occurredOn: LocalDate(2026, 1, 5),
              rateToRub: Decimal.one,
              amountRubMinor: 100,
              affectsBalance: true,
              accountId: Value(accountId),
              assetTransactionId: Value(txId),
              revisionNo: 1,
              createdAt: testNow(),
              updatedAt: testNow(),
            ),
          );

      await insertEntry();
      await expectLater(insertEntry(), throwsA(isA<Exception>()));
    });

    test('актив с активным правилом нельзя удалить (BR-RC-13)', () async {
      final propertyId = await createProperty(db);
      final category = await categoryId(db, CashflowKind.expense);
      final ruleId = await db.recurringDao.create(
        RecurringRuleInput(
          strategy: RecurringStrategy.fixed,
          kind: CashflowKind.expense,
          categoryId: category,
          amountMinor: 100000,
          currencyCode: 'RUB',
          propertyId: propertyId,
          affectsBalance: false,
          startDate: LocalDate(2026, 1, 15),
        ),
      );

      expect((await db.assetsDao.referenceCounts(propertyId)).recurring, 1);
      await expectLater(
        db.assetsDao.deleteIfUnused(propertyId),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.conflict,
          ),
        ),
      );

      await db.recurringDao.softDelete(ruleId);
      expect((await db.assetsDao.referenceCounts(propertyId)).recurring, 0);
      await expectLater(db.assetsDao.deleteIfUnused(propertyId), completes);
    });

    test(
      'soft-deleted правило с автооперацией не мешает удалить актив',
      () async {
        final propertyId = await createProperty(db, name: 'Старая');
        final otherProperty = await createProperty(db, name: 'Новая');
        final category = await categoryId(db, CashflowKind.expense);
        final ruleId = await db.recurringDao.create(
          RecurringRuleInput(
            strategy: RecurringStrategy.fixed,
            kind: CashflowKind.expense,
            categoryId: category,
            amountMinor: 100000,
            currencyCode: 'RUB',
            propertyId: propertyId,
            affectsBalance: false,
            startDate: LocalDate(2026, 1, 15),
          ),
        );
        // Операция правила перевешена на другой объект, но осталась связанной.
        final entryId = await db.cashflowDao.create(
          CashflowEntryInput(
            kind: CashflowKind.expense,
            categoryId: category,
            amountMinor: 100000,
            currencyCode: 'RUB',
            occurredOn: LocalDate(2026, 1, 15),
            rateToRub: Decimal.one,
            amountRubMinor: 100000,
            affectsBalance: false,
            propertyId: otherProperty,
            recurringRuleId: ruleId,
          ),
        );
        await db.recurringDao.softDelete(ruleId);

        expect((await db.assetsDao.referenceCounts(propertyId)).recurring, 0);
        await expectLater(db.assetsDao.deleteIfUnused(propertyId), completes);

        await expectLater(
          db.recurringDao.getById(ruleId),
          throwsA(isA<DomainException>()),
        );
        expect((await db.cashflowDao.getById(entryId)).recurringRuleId, null);
      },
    );

    test(
      'soft-deleted правило affectsBalance не мешает удалить счёт',
      () async {
        final accountId = await createAccount(db, name: 'Старый счёт');
        final category = await categoryId(db, CashflowKind.income);
        final ruleId = await db.recurringDao.create(
          RecurringRuleInput(
            strategy: RecurringStrategy.fixed,
            kind: CashflowKind.income,
            categoryId: category,
            amountMinor: 100000,
            currencyCode: 'RUB',
            accountId: accountId,
            affectsBalance: true,
            startDate: LocalDate(2026, 1, 15),
          ),
        );
        // Автооперация перевешена без счёта, но сохраняет ссылку на правило.
        final entryId = await db.cashflowDao.create(
          CashflowEntryInput(
            kind: CashflowKind.income,
            categoryId: category,
            amountMinor: 100000,
            currencyCode: 'RUB',
            occurredOn: LocalDate(2026, 1, 15),
            rateToRub: Decimal.one,
            amountRubMinor: 100000,
            affectsBalance: false,
            recurringRuleId: ruleId,
          ),
        );
        await db.recurringDao.softDelete(ruleId);

        await expectLater(db.assetsDao.deleteIfUnused(accountId), completes);

        await expectLater(
          db.recurringDao.getById(ruleId),
          throwsA(isA<DomainException>()),
        );
        expect((await db.cashflowDao.getById(entryId)).recurringRuleId, null);
      },
    );
  });
}
