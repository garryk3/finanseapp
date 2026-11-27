import 'dart:io';

import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../generated_migrations/schema_v1.dart' as v1;

/// Миграция v1→v2 на файловой БД с реальными данными (BR-RC-13).
///
/// v1 создаётся сгенерированной из schema dump моделью `DatabaseAtV1`;
/// затем файл открывается как [AppDatabase], и drift выполняет onUpgrade.
/// `migrateAndValidate` не используется: schema dump не содержит runtime-DDL
/// (`schemaObjectsV1/V2` — частичные индексы и триггеры), поэтому семантическое
/// сравнение дало бы ложный SchemaMismatch. Состояние v2 проверяется явно.
void main() {
  test('v1→текущая: user_version=5, объекты v2–v5 и данные целы', () async {
    final directory = await Directory.systemTemp.createTemp(
      'finanseapp_migration_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'v1.sqlite');

    final old = v1.DatabaseAtV1(NativeDatabase(File(path)));
    await _insertV1Fixtures(old);
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

    for (final table in ['asset_transactions', 'asset_valuations']) {
      final columns = await db
          .customSelect("PRAGMA table_info('$table')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('currency_code'),
        reason: table,
      );
    }

    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final tableNames = tables.map((row) => row.read<String>('name')).toList();
    expect(tableNames, contains('recurring_cashflow_rules'));
    expect(tableNames, contains('investment_locked_amounts'));

    final columns = await db
        .customSelect("PRAGMA table_info('cashflow_entries')")
        .get();
    expect(
      columns.map((row) => row.read<String>('name')),
      contains('recurring_rule_id'),
    );

    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    expect(
      indexes.map((row) => row.read<String>('name')),
      containsAll([
        'recurring_deleted',
        'recurring_account',
        'recurring_property',
        'recurring_active_deposit_interest',
        'cashflow_recurring_period',
        'goals_status_deleted',
        'goals_target_date',
        'goals_currency',
      ]),
    );

    final asset = await db.select(db.assets).getSingle();
    expect(asset.name, 'Квартира');
    expect(asset.openingValueMinor, 100000000);

    final entry = await db.select(db.cashflowEntries).getSingle();
    expect(entry.amountMinor, 50000);
    expect(entry.propertyId, asset.id);
    expect(entry.recurringRuleId, null);

    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}

Future<void> _insertV1Fixtures(v1.DatabaseAtV1 db) async {
  const timestamp = '2026-01-01T00:00:00.000000Z';
  await db.customStatement(
    'INSERT INTO currencies (code, name, normalized_name, fraction_digits) '
    "VALUES ('RUB', 'Рубль', 'рубль', 2)",
  );
  await db.customStatement(
    'INSERT INTO categories (id, kind, name, normalized_name) '
    "VALUES (1, 'expense', 'Содержание помещения', 'содержание помещения')",
  );
  await db.customStatement(
    'INSERT INTO assets '
    '(id, name, kind, currency_code, opening_value_minor, created_at) '
    "VALUES (1, 'Квартира', 'property', 'RUB', 100000000, '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO cashflow_entries '
    '(id, kind, category_id, amount_minor, currency_code, occurred_on, '
    'rate_to_rub, amount_rub_minor, affects_balance, property_id, revision_no, '
    'created_at, updated_at) '
    "VALUES (1, 'expense', 1, 50000, 'RUB', '2026-01-15', '1', 50000, 0, 1, 1, "
    "'$timestamp', '$timestamp')",
  );
}
