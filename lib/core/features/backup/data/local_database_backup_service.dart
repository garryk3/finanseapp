import 'dart:io';

import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/features/backup/domain/backup_exception.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

typedef BackupDatabaseProvider = AppDatabase Function();
typedef BackupDatabasePathProvider = Future<String> Function();
typedef BackupFailInjector = bool Function(BackupStorageOperation operation);

/// Полный SQLite snapshot: экспорт, валидация candidate и безопасная замена
/// с rollback (backup_and_updates §5–6).
final class LocalDatabaseBackupService implements BackupService {
  LocalDatabaseBackupService({
    required this.databaseProvider,
    required this.databasePath,
    required this.closeDatabase,
    this.installedSchemaVersion = appDatabaseSchemaVersion,
    this.failOn,
    this.tempDirectory,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final BackupDatabaseProvider databaseProvider;
  final BackupDatabasePathProvider databasePath;
  final Future<void> Function() closeDatabase;
  final int installedSchemaVersion;
  final BackupFailInjector? failOn;
  final Future<Directory> Function()? tempDirectory;
  final DateTime Function() _clock;

  static const _magic = 'SQLite format 3\u0000';

  @override
  Future<BackupFile> exportDatabase() async {
    final temp = await (tempDirectory?.call() ?? getTemporaryDirectory());
    final now = _clock().toUtc();
    final stamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final fileName =
        'finanseapp_backup_${stamp}_${now.microsecondsSinceEpoch % 100000}.sqlite';
    final target = File(p.join(temp.path, fileName));
    if (await target.exists()) {
      throw const BackupStorageException(BackupStorageOperation.export);
    }
    try {
      final db = databaseProvider();
      await db.customStatement(
        "VACUUM INTO '${target.path.replaceAll("'", "''")}'",
      );
      return BackupFile(path: target.path, fileName: fileName);
    } on BackupStorageException {
      rethrow;
    } on Exception {
      throw const BackupStorageException(BackupStorageOperation.export);
    }
  }

  @override
  Future<void> importDatabase(String sourcePath) async {
    final dbPath = await databasePath();
    final dir = Directory(p.dirname(dbPath));
    final nonce = _clock().microsecondsSinceEpoch;
    final staging = File(p.join(dir.path, 'finanseapp.staging.$nonce.sqlite'));
    final candidate = File(
      p.join(dir.path, 'finanseapp.candidate.$nonce.sqlite'),
    );
    final rollback = File(
      p.join(dir.path, 'finanseapp.rollback.$nonce.sqlite'),
    );
    final preImport = File('$dbPath.pre-import');

    try {
      await File(sourcePath).copy(staging.path);
      await _validate(staging);
      await staging.copy(candidate.path);
      await _migrateCandidate(candidate.path);
    } on BackupValidationException {
      await _cleanup([staging, candidate]);
      rethrow;
    } on Exception {
      await _cleanup([staging, candidate]);
      throw const BackupValidationException(BackupValidationError.notADatabase);
    }

    try {
      await databaseProvider().customStatement(
        "VACUUM INTO '${rollback.path.replaceAll("'", "''")}'",
      );
    } on Exception {
      await _cleanup([staging, candidate, rollback]);
      throw const BackupStorageException(BackupStorageOperation.export);
    }
    if (failOn?.call(BackupStorageOperation.stage) ?? false) {
      await _cleanup([staging, candidate, rollback]);
      throw const BackupStorageException(BackupStorageOperation.stage);
    }

    try {
      await closeDatabase();
      if (failOn?.call(BackupStorageOperation.replace) ?? false) {
        throw const BackupStorageException(BackupStorageOperation.replace);
      }
      if (await File(dbPath).exists()) {
        await File(dbPath).rename(preImport.path);
      }
      await candidate.rename(dbPath);
      if (failOn?.call(BackupStorageOperation.reopen) ?? false) {
        throw const BackupStorageException(BackupStorageOperation.reopen);
      }
      await _cleanup([staging, candidate, preImport, rollback]);
    } on Exception {
      // Любой сбой после закрытия: возвращаем прежнюю БД и пересобираем DI.
      try {
        if (await preImport.exists()) {
          if (await File(dbPath).exists()) await File(dbPath).delete();
          await preImport.rename(dbPath);
        } else if (await rollback.exists()) {
          await rollback.copy(dbPath);
        }
        if (failOn?.call(BackupStorageOperation.rollback) ?? false) {
          throw const BackupStorageException(BackupStorageOperation.rollback);
        }
      } on Exception {
        throw const BackupStorageException(BackupStorageOperation.rollback);
      }
      await _cleanup([staging, candidate, preImport, rollback]);
      throw const BackupStorageException(BackupStorageOperation.reopen);
    }
  }

  Future<void> _validate(File file) async {
    if (!await file.exists() || await file.length() < 16) {
      throw const BackupValidationException(BackupValidationError.notADatabase);
    }
    final header = await file
        .openRead(0, 16)
        .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk));
    if (String.fromCharCodes(header) != _magic) {
      throw const BackupValidationException(BackupValidationError.notADatabase);
    }
    Database? probe;
    try {
      probe = sqlite3.open(file.path, mode: OpenMode.readOnly);
      final integrity = probe.select('PRAGMA integrity_check');
      if (integrity.isEmpty || integrity.first.values.first != 'ok') {
        throw const BackupValidationException(BackupValidationError.corrupted);
      }
      final appId = probe.select('PRAGMA application_id').first.values.first;
      if (appId != appDatabaseApplicationId) {
        throw const BackupValidationException(
          BackupValidationError.notFinanseApp,
        );
      }
      final version = probe.select('PRAGMA user_version').first.values.first;
      final schemaVersion = version is int ? version : -1;
      if (schemaVersion < 1) {
        throw const BackupValidationException(
          BackupValidationError.notFinanseApp,
        );
      }
      if (schemaVersion > installedSchemaVersion) {
        throw BackupValidationException(
          BackupValidationError.schemaNewer,
          schemaVersion: schemaVersion,
          installedVersion: installedSchemaVersion,
        );
      }
      if (probe.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw const BackupValidationException(
          BackupValidationError.invalidReferences,
        );
      }
    } on BackupValidationException {
      rethrow;
    } on SqliteException {
      throw const BackupValidationException(BackupValidationError.corrupted);
    } finally {
      probe?.close();
    }
  }

  Future<void> _migrateCandidate(String path) async {
    final candidate = AppDatabase(executor: NativeDatabase(File(path)));
    try {
      await candidate.customSelect('SELECT 1').get();
    } on Exception {
      throw const BackupValidationException(BackupValidationError.corrupted);
    } finally {
      await candidate.close();
    }
  }

  Future<void> _cleanup(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) await file.delete();
      } on Exception {
        // cleanup best-effort
      }
    }
  }
}
