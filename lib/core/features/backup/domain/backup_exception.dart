/// Причина отказа импорта выбранного файла (BR-BU-3).
enum BackupValidationError {
  notADatabase,
  corrupted,
  schemaNewer,
  notFinanseApp,
  invalidReferences,
}

final class BackupValidationException implements Exception {
  const BackupValidationException(
    this.reason, {
    this.schemaVersion,
    this.installedVersion,
  });

  final BackupValidationError reason;
  final int? schemaVersion;
  final int? installedVersion;
}

/// Шаг хранилища, на котором произошёл сбой импорта/экспорта.
enum BackupStorageOperation { export, stage, replace, rollback, reopen }

final class BackupStorageException implements Exception {
  const BackupStorageException(this.operation);

  final BackupStorageOperation operation;
}
