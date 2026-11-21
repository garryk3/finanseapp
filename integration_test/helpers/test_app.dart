import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/backup/data/platform_backup_file_gateway.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/app/test_app_locator.dart';

/// In-memory БД с реальными часами: формы e2e используют DateTime.now().
AppDatabase openE2eDatabase() => AppDatabase(executor: NativeDatabase.memory());

/// Общие помощники e2e: локализация, запуск приложения и навигация.
Future<AppLocalizations> loadL10n() =>
    AppLocalizations.delegate.load(const Locale('ru'));

/// Высокий desktop-вьюпорт, чтобы формы e2e были видны без ручного скролла.
void configureTestView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<ServiceLocator> pumpApp(
  WidgetTester tester, {
  AppDatabase? database,
  BackupServiceFactory? backupServiceFactory,
  BackupFileGateway backupFileGateway = const PlatformBackupFileGateway(),
}) async {
  configureTestView(tester);
  final locator = await buildTestLocator(
    database: database,
    backupServiceFactory: backupServiceFactory,
    backupFileGateway: backupFileGateway,
  );
  await tester.pumpWidget(FinanseApp(locator: locator));
  await tester.pumpAndSettle();
  return locator;
}

/// Гасит drift-стримы экрана и закрывает БД после проверок.
Future<void> shutdownApp(WidgetTester tester, [ServiceLocator? locator]) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 20));
  await locator?.reset();
}

Future<void> tapTab(WidgetTester tester, String label) async {
  final finder = find.text(label);
  for (var attempt = 0; attempt < 100 && finder.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(
    finder,
    findsWidgets,
    reason: 'вкладка «$label» не появилась: DI ещё собирается',
  );
  await tester.tap(finder.last);
  await tester.pumpAndSettle();
}

Future<void> openAssets(WidgetTester tester, AppLocalizations l10n) =>
    tapTab(tester, l10n.navAssets);

Future<void> openOperations(WidgetTester tester, AppLocalizations l10n) =>
    tapTab(tester, l10n.navOperations);

Future<void> openGoals(WidgetTester tester, AppLocalizations l10n) =>
    tapTab(tester, l10n.navGoals);

Future<void> openMore(WidgetTester tester, AppLocalizations l10n) =>
    tapTab(tester, l10n.navMore);

/// Создаёт счёт через каталог активов и возвращает его название.
Future<void> createAccountThroughUi(
  WidgetTester tester,
  AppLocalizations l10n, {
  required String name,
  required String opening,
}) async {
  await tester.tap(find.byTooltip(l10n.assetsAddAsset).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.assetsAddAccount));
  await tester.pumpAndSettle();

  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), opening);
  await tester.ensureVisible(find.text(l10n.commonSave));
  await tester.tap(find.text(l10n.commonSave));
  await tester.pumpAndSettle();
}
