import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Системные share/picker operations; domain остаётся без Flutter-зависимостей.
final class PlatformBackupFileGateway implements BackupFileGateway {
  const PlatformBackupFileGateway();

  static const _channel = MethodChannel('com.example.finanseapp/file_saver');

  @override
  Future<String?> pickDatabase() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);
      return files.isEmpty ? null : files.single.path;
    } on PlatformException {
      final files = await FilePicker.pickFiles(type: FileType.any);
      return files.isEmpty ? null : files.single.path;
    }
  }

  @override
  Future<BackupShareOutcome> share(BackupFile file) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
      return switch (result.status) {
        ShareResultStatus.success => BackupShareOutcome.shared,
        ShareResultStatus.dismissed => BackupShareOutcome.cancelled,
        ShareResultStatus.unavailable => BackupShareOutcome.unavailable,
      };
    } on Exception {
      return BackupShareOutcome.unavailable;
    }
  }

  @override
  Future<bool> save(BackupFile file, {required String dialogTitle}) async {
    if (Platform.isAndroid) {
      try {
        final saved = await _channel.invokeMethod<bool>('saveFile', {
          'sourcePath': file.path,
          'fileName': file.fileName,
        });
        return saved ?? false;
      } on PlatformException {
        return false;
      }
    }
    final destination = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: file.fileName,
      bytes: await File(file.path).readAsBytes(),
      type: FileType.any,
    );
    return destination != null;
  }
}
