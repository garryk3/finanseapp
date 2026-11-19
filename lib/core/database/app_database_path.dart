import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:finanseapp/core/database/app_database.dart';

/// Production-путь БД: `<applicationDocuments>/finanseapp.sqlite`.
QueryExecutor appDatabaseExecutor() => driftDatabase(name: 'finanseapp');

/// Абсолютный путь production-БД (для backup/import).
Future<String> appDatabaseFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return p.join(directory.path, 'finanseapp.sqlite');
}

/// Открывает БД приложения с production-путём.
AppDatabase openAppDatabase({DateTime Function()? now}) =>
    AppDatabase(executor: appDatabaseExecutor(), now: now);
