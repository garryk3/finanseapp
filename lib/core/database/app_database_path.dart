import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:finanseapp/core/database/app_database.dart';

/// Production-путь БД: `<applicationDocuments>/finanseapp.sqlite`.
QueryExecutor appDatabaseExecutor() => driftDatabase(name: 'finanseapp');

/// Открывает БД приложения с production-путём.
AppDatabase openAppDatabase({DateTime Function()? now}) =>
    AppDatabase(executor: appDatabaseExecutor(), now: now);
