/// Готовый файл резервной копии во временном каталоге.
final class BackupFile {
  const BackupFile({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

typedef BackupServiceFactory = BackupService Function();

abstract interface class BackupService {
  Future<BackupFile> exportDatabase();
  Future<void> importDatabase(String sourcePath);
}

/// Результат системного share sheet.
enum BackupShareOutcome { shared, cancelled, unavailable }

abstract interface class BackupFileGateway {
  Future<String?> pickDatabase();

  Future<BackupShareOutcome> share(BackupFile file);

  Future<bool> save(BackupFile file, {required String dialogTitle});
}
