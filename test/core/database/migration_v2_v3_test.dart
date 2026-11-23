import 'dart:io';

import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/transactions/data/asset_transaction_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../generated_migrations/schema_v2.dart' as v2;

/// Миграция v2→v3 на файловой БД с реальными данными (18.1).
///
/// v2 создаётся сгенерированной моделью `DatabaseAtV2`; затем файл открывается
/// как [AppDatabase], и drift выполняет onUpgrade. Runtime-DDL в v3 нет, поэтому
/// проверяется отсутствие новых объектов, наличие nullable-колонок и целостность
/// старых строк.
void main() {
  test('v2→v3: user_version=3, currency_code и данные целы', () async {
    final directory = await Directory.systemTemp.createTemp(
      'finanseapp_migration_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'v2.sqlite');

    final old = v2.DatabaseAtV2(NativeDatabase(File(path)));
    await _insertV2Fixtures(old);
    await old.close();

    final db = AppDatabase(executor: NativeDatabase(File(path)));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 3);

    for (final table in ['asset_transactions', 'asset_valuations']) {
      final columns = await db
          .customSelect("PRAGMA table_info('$table')")
          .get();
      final byName = {for (final row in columns) row.read<String>('name'): row};
      expect(byName, contains('currency_code'), reason: table);
      expect(byName['currency_code']!.read<int>('notnull'), 0, reason: table);
    }

    final transactions = await db.select(db.assetTransactions).get();
    expect(transactions, hasLength(2));
    final accountTransaction = transactions.firstWhere(
      (row) => row.assetId == 1,
    );
    expect(accountTransaction.amountMinor, 25050);
    expect(accountTransaction.currencyCode, isNull);
    expect(
      mapAssetTransaction(accountTransaction, 'RUB').amount,
      const Money(minorUnits: 25050, currencyCode: 'RUB'),
    );

    final valuations = await db.select(db.assetValuations).get();
    expect(valuations.single.assetId, 2);
    expect(valuations.single.valueMinor, 60000);
    expect(valuations.single.currencyCode, isNull);

    final repository = AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
    );
    final snapshot = await repository.getById(2);
    expect(snapshot.currentValue.minorUnits, 70000);

    final integrity = await db
        .customSelect('PRAGMA integrity_check')
        .getSingle();
    expect(integrity.read<String>('integrity_check'), 'ok');
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}

Future<void> _insertV2Fixtures(v2.DatabaseAtV2 db) async {
  const timestamp = '2026-01-01T00:00:00.000000Z';
  await db.customStatement(
    'INSERT INTO currencies (code, name, normalized_name, fraction_digits) '
    "VALUES ('RUB', 'Рубль', 'рубль', 2)",
  );
  await db.customStatement(
    'INSERT INTO currencies (code, name, normalized_name, fraction_digits) '
    "VALUES ('USD', 'Доллар', 'доллар', 2)",
  );
  await db.customStatement(
    'INSERT INTO subgroups (id, kind, name, normalized_name, created_at) '
    "VALUES (1, 'bank', 'Банк', 'банк', '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO subgroups (id, kind, name, normalized_name, created_at) '
    "VALUES (2, 'broker', 'Брокер', 'брокер', '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO assets '
    '(id, name, kind, currency_code, opening_value_minor, created_at) '
    "VALUES (1, 'Вклад', 'account', 'RUB', 100000, '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO assets '
    '(id, name, kind, currency_code, opening_value_minor, created_at) '
    "VALUES (2, 'Инвестиция', 'investment', 'RUB', 50000, '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO account_details '
    '(asset_id, bank_id, annual_rate, start_date) '
    "VALUES (1, 1, '0', '2026-01-01')",
  );
  await db.customStatement(
    'INSERT INTO investment_details (asset_id, broker_id) VALUES (2, 2)',
  );
  await db.customStatement(
    'INSERT INTO asset_transactions '
    '(id, asset_id, kind, amount_minor, occurred_on, rate_to_rub, '
    'amount_rub_minor, revision_no, created_at, updated_at) '
    "VALUES (1, 1, 'deposit', 25050, '2026-01-10', '1', 25050, 1, "
    "'$timestamp', '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO asset_transactions '
    '(id, asset_id, kind, amount_minor, occurred_on, rate_to_rub, '
    'amount_rub_minor, revision_no, created_at, updated_at) '
    "VALUES (2, 2, 'deposit', 10000, '2026-01-10', '1', 10000, 1, "
    "'$timestamp', '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO asset_valuations '
    '(id, asset_id, effective_on, value_minor, rate_to_rub, value_rub_minor, '
    'created_at) '
    "VALUES (1, 2, '2026-01-05', 60000, '1', 60000, '$timestamp')",
  );
}
