import 'dart:io';

import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../generated_migrations/schema_v4.dart' as v4;

/// Миграция v4→v5 на файловой БД с реальными данными (21.1).
///
/// v4 создаётся сгенерированной моделью `DatabaseAtV4`; затем файл открывается
/// как [AppDatabase], и drift выполняет onUpgrade. Проверяются ослабленный CHECK
/// `goals.category` (`mixed`), `user_version = 5`, сохранность старых строк и
/// связей, а также запись смешанной цели через DAO после апгрейда.
void main() {
  test('v4→v5: CHECK goals ослаблен, user_version=5, данные целы', () async {
    final directory = await Directory.systemTemp.createTemp(
      'finanseapp_migration_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'v4.sqlite');

    final old = v4.DatabaseAtV4(NativeDatabase(File(path)));
    await _insertV4Fixtures(old);
    await old.close();

    final db = AppDatabase(executor: NativeDatabase(File(path)));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 5);

    final goalsSql = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'goals'",
        )
        .getSingle();
    expect(goalsSql.read<String>('sql'), contains("'mixed'"));

    final indexNames = {
      for (final row
          in await db
              .customSelect(
                'SELECT name FROM sqlite_master '
                "WHERE type = 'index' AND tbl_name = 'goals'",
              )
              .get())
        row.read<String>('name'),
    };
    expect(
      indexNames,
      containsAll([
        'goals_status_deleted',
        'goals_target_date',
        'goals_currency',
      ]),
    );

    final goal = await db.select(db.goals).getSingle();
    expect(goal.name, 'Цель');
    expect(goal.category, GoalCategory.accounts);
    expect(goal.targetAmountMinor, 200000);

    final links = await db.select(db.goalAssets).get();
    expect(links.single.goalId, goal.id);
    expect(links.single.assetId, 1);

    // Смешанная цель пишется и читается как mixed (BR-G-1).
    final mixedId = await db.goalsDao.create(
      name: 'Смешанная',
      targetAmountMinor: 300000,
      currencyCode: 'RUB',
      assetIds: {1, 2},
    );
    expect((await db.goalsDao.getById(mixedId)).category, GoalCategory.mixed);

    await expectLater(
      db.customStatement(
        'INSERT INTO goals '
        '(name, category, target_amount_minor, currency_code, status, '
        "created_at, updated_at) VALUES ('Плохая', 'bogus', 100, 'RUB', "
        "'active', '2026-01-01T00:00:00.000000Z', "
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

Future<void> _insertV4Fixtures(v4.DatabaseAtV4 db) async {
  const timestamp = '2026-01-01T00:00:00.000000Z';
  await db.customStatement(
    'INSERT INTO currencies (code, name, normalized_name, fraction_digits) '
    "VALUES ('RUB', 'Рубль', 'рубль', 2)",
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
    'INSERT INTO goals '
    '(id, name, category, target_amount_minor, currency_code, status, '
    "created_at, updated_at) VALUES (1, 'Цель', 'accounts', 200000, 'RUB', "
    "'active', '$timestamp', '$timestamp')",
  );
  await db.customStatement(
    'INSERT INTO goal_assets (goal_id, asset_id) VALUES (1, 1)',
  );
}
