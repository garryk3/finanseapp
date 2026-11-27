import 'dart:io';

import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../generated_migrations/schema_v3.dart' as v3;

/// Миграция v3→текущая на файловой БД с реальными данными (18.3).
///
/// v3 создаётся сгенерированной моделью `DatabaseAtV3`; затем файл открывается
/// как [AppDatabase], и drift выполняет onUpgrade. Проверяются новая таблица
/// `investment_locked_amounts` (PK, CHECK, FK), ослабленный CHECK
/// `goals.category` (`mixed`), `user_version = 5`, целостность старых строк и
/// работа отметки через репозиторий.
void main() {
  test('v3→текущая: таблица отметок и CHECK goals, user_version=5', () async {
    final directory = await Directory.systemTemp.createTemp(
      'finanseapp_migration_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'v3.sqlite');

    final old = v3.DatabaseAtV3(NativeDatabase(File(path)));
    await _insertV3Fixtures(old);
    await old.close();

    final db = AppDatabase(executor: NativeDatabase(File(path)));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 5);

    final goalsSql = await db
        .customSelect(
          'SELECT sql FROM sqlite_master '
          "WHERE type = 'table' AND name = 'goals'",
        )
        .getSingle();
    expect(goalsSql.read<String>('sql'), contains("'mixed'"));

    final columns = await db
        .customSelect("PRAGMA table_info('investment_locked_amounts')")
        .get();
    final byName = {for (final row in columns) row.read<String>('name'): row};
    expect(
      byName.keys,
      unorderedEquals([
        'asset_id',
        'currency_code',
        'amount_minor',
        'created_at',
        'updated_at',
      ]),
    );
    expect(byName['asset_id']!.read<int>('pk'), 1);
    expect(byName['currency_code']!.read<int>('pk'), 2);
    expect(byName['asset_id']!.read<int>('notnull'), 1);
    expect(byName['currency_code']!.read<int>('notnull'), 1);
    expect(byName['amount_minor']!.read<int>('notnull'), 1);

    final foreignKeys = await db
        .customSelect("PRAGMA foreign_key_list('investment_locked_amounts')")
        .get();
    final targets = {
      for (final row in foreignKeys)
        row.read<String>('table'): row.read<String>('on_delete'),
    };
    expect(targets, {'assets': 'RESTRICT', 'currencies': 'RESTRICT'});

    final assets = await db.select(db.assets).get();
    expect(assets, hasLength(2));
    final valuations = await db.select(db.assetValuations).get();
    expect(valuations.single.assetId, 2);
    expect(valuations.single.valueMinor, 12000);
    expect(valuations.single.currencyCode, 'USD');

    final repository = AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
      db.currenciesDao,
    );
    await repository.setLockedAmount(
      2,
      'USD',
      const Money(minorUnits: 9900, currencyCode: 'USD'),
    );
    final snapshot = await repository.getById(2);
    expect(snapshot.locked, const [
      Money(minorUnits: 9900, currencyCode: 'USD'),
    ]);
    expect(snapshot.currentValue.minorUnits, 50000);

    await expectLater(
      db.customStatement(
        'INSERT INTO investment_locked_amounts '
        '(asset_id, currency_code, amount_minor, created_at, updated_at) '
        "VALUES (2, 'EUR', 0, '2026-01-01T00:00:00.000000Z', "
        "'2026-01-01T00:00:00.000000Z')",
      ),
      throwsA(isA<SqliteException>()),
    );

    final integrity = await db
        .customSelect('PRAGMA integrity_check')
        .getSingle();
    expect(integrity.read<String>('integrity_check'), 'ok');
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}

Future<void> _insertV3Fixtures(v3.DatabaseAtV3 db) async {
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
    'INSERT INTO asset_valuations '
    '(id, asset_id, effective_on, value_minor, currency_code, rate_to_rub, '
    'value_rub_minor, created_at) '
    "VALUES (1, 2, '2026-01-05', 12000, 'USD', '90', 1080000, '$timestamp')",
  );
}
