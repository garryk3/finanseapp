import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:finanseapp/app/app_restart.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/backup/data/local_database_backup_service.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../test/app/test_app_locator.dart';
import '../test/core/database/database_fixtures.dart';
import 'helpers/test_app.dart';

final class _FakeBackupGateway implements BackupFileGateway {
  String? pickPath;
  BackupFile? saved;

  @override
  Future<String?> pickDatabase() async => pickPath;

  @override
  Future<BackupShareOutcome> share(BackupFile file) async =>
      BackupShareOutcome.shared;

  @override
  Future<bool> save(BackupFile file, {required String dialogTitle}) async {
    saved = file;
    return true;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('export → изменение → import → restart, invalid не разрушает', (
    tester,
  ) async {
    configureTestView(tester);
    final l10n = await loadL10n();
    final l10nContext = l10n;
    final temp = await Directory.systemTemp.createTemp('finanseapp_e2e_');
    addTearDown(() => temp.delete(recursive: true));
    final path = p.join(temp.path, 'finanseapp.sqlite');
    final gateway = _FakeBackupGateway();
    var db = AppDatabase(executor: NativeDatabase(File(path)));
    await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
    await createAccount(db, name: 'До', openingValueMinor: 100000);

    var first = true;
    await tester.pumpWidget(
      AppRestartHost(
        build: () async {
          if (!first) {
            db = AppDatabase(executor: NativeDatabase(File(path)));
          }
          first = false;
          return buildTestLocator(
            database: db,
            backupFileGateway: gateway,
            backupServiceFactory: () => LocalDatabaseBackupService(
              databaseProvider: () => db,
              databasePath: () async => path,
              closeDatabase: () async => db.close(),
              installedSchemaVersion: db.schemaVersion,
              tempDirectory: () async => temp,
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    await _openSettings(tester, l10nContext);
    await tester.scrollUntilVisible(
      find.text(l10nContext.backupSave),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text(l10nContext.backupSave));
    await tester.pumpAndSettle();
    expect(gateway.saved, isNotNull);
    expect(find.text(l10nContext.backupExportSaved), findsOneWidget);

    // Меняем данные после экспорта.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await openAssets(tester, l10nContext);
    await createAccountThroughUi(
      tester,
      l10nContext,
      name: 'После',
      opening: '200',
    );
    expect(find.text('После'), findsWidgets);

    // Импортируем сохранённую копию и перезапускаем приложение.
    await _openSettings(tester, l10nContext);
    await tester.scrollUntilVisible(
      find.text(l10nContext.backupImport),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    gateway.pickPath = gateway.saved!.path;
    await tester.tap(find.text(l10nContext.backupImport));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nContext.backupImportConfirm));
    await tester.pumpAndSettle();
    expect(find.text(l10nContext.backupRestartTitle), findsOneWidget);
    await tester.tap(find.text(l10nContext.backupRestartOk));
    await tester.pumpAndSettle();

    await openAssets(tester, l10nContext);
    expect(find.text('До'), findsOneWidget);
    expect(find.text('После'), findsNothing);

    // Битый файл не должен менять данные.
    final broken = File(p.join(temp.path, 'broken.sqlite'));
    await broken.writeAsString('this is definitely not a sqlite database');
    await _openSettings(tester, l10nContext);
    await tester.scrollUntilVisible(
      find.text(l10nContext.backupImport),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    gateway.pickPath = broken.path;
    await tester.tap(find.text(l10nContext.backupImport));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nContext.backupImportConfirm));
    await tester.pumpAndSettle();
    expect(find.text(l10nContext.backupValidationNotDatabase), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await openAssets(tester, l10nContext);
    expect(find.text('До'), findsOneWidget);
    expect(find.text('После'), findsNothing);

    await shutdownApp(tester);
  });
}

Future<void> _openSettings(WidgetTester tester, AppLocalizations l10n) async {
  await openMore(tester, l10n);
  await tester.tap(find.text(l10n.settingsTitle));
  await tester.pumpAndSettle();
}
