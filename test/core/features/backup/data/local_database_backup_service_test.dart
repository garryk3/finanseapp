import 'dart:io';

import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/features/backup/data/local_database_backup_service.dart';
import 'package:finanseapp/core/features/backup/domain/backup_exception.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../generated_migrations/schema_v1.dart' as v1;

void main() {
  late Directory dir;
  late String path;

  AppDatabase open() => AppDatabase(executor: NativeDatabase(File(path)));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('finanseapp_backup_test_');
    path = '${dir.path}/finanseapp.sqlite';
  });

  tearDown(() async {
    try {
      await dir.delete(recursive: true);
    } on FileSystemException {
      // best effort
    }
  });

  LocalDatabaseBackupService service(
    AppDatabase Function() database, {
    BackupFailInjector? failOn,
  }) => LocalDatabaseBackupService(
    databaseProvider: database,
    databasePath: () async => path,
    closeDatabase: () async => database().close(),
    failOn: failOn,
    tempDirectory: () async => dir,
  );

  test('valid export and import заменяют базу', () async {
    final db = open();
    await db.settingsDao.setBaseCurrency('USD');
    final backup = await service(() => db).exportDatabase();
    expect(await File(backup.path).length(), greaterThan(0));
    await db.close();

    final db2 = open();
    await db2.settingsDao.setBaseCurrency('EUR');
    await service(() => db2).importDatabase(backup.path);

    final check = open();
    expect((await check.settingsDao.getBaseCurrency()).code, 'USD');
    await check.close();
  });

  test('v1-копия импортируется и мигрирует до текущей версии', () async {
    final v1Path = '${dir.path}/v1.sqlite';
    final old = v1.DatabaseAtV1(NativeDatabase(File(v1Path)));
    await old.customStatement(
      'PRAGMA application_id = $appDatabaseApplicationId',
    );
    await old.customStatement(
      'INSERT INTO currencies (code, name, normalized_name, fraction_digits) '
      "VALUES ('USD', 'Доллар США', 'доллар сша', 2)",
    );
    await old.customStatement(
      'INSERT INTO app_settings (key, value, updated_at) '
      "VALUES ('baseCurrencyCode', 'USD', '2026-01-01T00:00:00.000000Z')",
    );
    await old.close();

    final db = open();
    await db.customSelect('SELECT 1').get();
    await service(() => db).importDatabase(v1Path);

    final check = open();
    final version = await check.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), appDatabaseSchemaVersion);
    expect((await check.settingsDao.getBaseCurrency()).code, 'USD');
    await check.close();
  });

  test('wrong magic → notADatabase, рабочая БД не тронута', () async {
    final db = open();
    await db.settingsDao.setBaseCurrency('USD');
    final bad = File('${dir.path}/bad.sqlite');
    await bad.writeAsString('not sqlite');

    await expectLater(
      service(() => db).importDatabase(bad.path),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.reason,
          'reason',
          BackupValidationError.notADatabase,
        ),
      ),
    );
    expect((await db.settingsDao.getBaseCurrency()).code, 'USD');
    await db.close();
  });

  test(
    'сбой replace → importFailed-совместимый storage, база восстановлена',
    () async {
      final db = open();
      await db.settingsDao.setBaseCurrency('USD');
      final backup = await service(() => db).exportDatabase();
      await db.close();

      final current = open();
      await current.settingsDao.setBaseCurrency('EUR');
      await expectLater(
        service(
          () => current,
          failOn: (operation) => operation == BackupStorageOperation.replace,
        ).importDatabase(backup.path),
        throwsA(isA<BackupStorageException>()),
      );
      await current.close();

      final restored = open();
      expect((await restored.settingsDao.getBaseCurrency()).code, 'EUR');
      await restored.close();
    },
  );

  test('сбой reopen → storage reopen, база восстановлена', () async {
    final db = open();
    await db.settingsDao.setBaseCurrency('USD');
    final backup = await service(() => db).exportDatabase();
    await db.close();

    final current = open();
    await current.settingsDao.setBaseCurrency('EUR');
    await expectLater(
      service(
        () => current,
        failOn: (operation) => operation == BackupStorageOperation.reopen,
      ).importDatabase(backup.path),
      throwsA(
        isA<BackupStorageException>().having(
          (error) => error.operation,
          'operation',
          BackupStorageOperation.reopen,
        ),
      ),
    );
    await current.close();

    final restored = open();
    expect((await restored.settingsDao.getBaseCurrency()).code, 'EUR');
    await restored.close();
  });

  test('чужой application_id и новая schema отклоняются', () async {
    final db = open();
    final foreign = '${dir.path}/foreign.sqlite';
    var raw = sqlite3.open(foreign);
    raw.execute('PRAGMA application_id = 1');
    raw.execute('PRAGMA user_version = 1');
    raw.execute('CREATE TABLE marker (id INTEGER)');
    raw.close();
    await expectLater(
      service(() => db).importDatabase(foreign),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.reason,
          'reason',
          BackupValidationError.notFinanseApp,
        ),
      ),
    );

    final newer = '${dir.path}/newer.sqlite';
    raw = sqlite3.open(newer);
    raw.execute('PRAGMA application_id = $appDatabaseApplicationId');
    raw.execute('PRAGMA user_version = 99');
    raw.execute('CREATE TABLE marker (id INTEGER)');
    raw.close();
    await expectLater(
      service(() => db).importDatabase(newer),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.reason,
          'reason',
          BackupValidationError.schemaNewer,
        ),
      ),
    );
    await db.close();
  });

  test(
    'сбой rollback после replace → restoreFailed (rollback-файл сохранён)',
    () async {
      final db = open();
      await db.settingsDao.setBaseCurrency('USD');
      final backup = await service(() => db).exportDatabase();
      await db.close();

      final current = open();
      await current.settingsDao.setBaseCurrency('EUR');
      await expectLater(
        service(
          () => current,
          failOn: (operation) =>
              operation == BackupStorageOperation.replace ||
              operation == BackupStorageOperation.rollback,
        ).importDatabase(backup.path),
        throwsA(
          isA<BackupStorageException>().having(
            (error) => error.operation,
            'operation',
            BackupStorageOperation.rollback,
          ),
        ),
      );
      await current.close();
    },
  );
}
