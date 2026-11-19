import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:finanseapp/core/features/backup/logic/backup_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/widgets/backup_section.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final class _Gateway implements BackupFileGateway {
  @override
  Future<String?> pickDatabase() async => null;

  @override
  Future<BackupShareOutcome> share(BackupFile file) async =>
      BackupShareOutcome.cancelled;

  @override
  Future<bool> save(BackupFile file, {required String dialogTitle}) async =>
      false;
}

BackupViewModel _viewModel() =>
    BackupViewModel(() => throw UnimplementedError(), _Gateway());

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  Future<void> pump(
    WidgetTester tester,
    BackupViewModel vm, {
    double width = 1000,
    bool dark = false,
    bool largeText = false,
  }) async {
    tester.view.physicalSize = Size(width, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        builder: largeText
            ? (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              )
            : null,
        home: AppScaffold(
          body: SingleChildScrollView(
            child: BackupSection(viewModel: vm, onRestart: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('три равноправные действия и warning видны', (tester) async {
    final vm = _viewModel();
    await pump(tester, vm);

    expect(find.text(l10n.settingsBackupSection), findsOneWidget);
    expect(find.text(l10n.settingsBackupWarning), findsOneWidget);
    expect(find.text(l10n.backupShare), findsOneWidget);
    expect(find.text(l10n.backupSave), findsOneWidget);
    expect(find.text(l10n.backupImport), findsOneWidget);
  });

  testWidgets('restoreFailed блокирует действия и даёт restart', (
    tester,
  ) async {
    final vm = _viewModel()
      ..state.value = const BackupState(status: BackupStatusKind.restoreFailed);
    await pump(tester, vm);

    expect(find.text(l10n.backupRestoreFailed), findsOneWidget);
    expect(find.text(l10n.backupRestartOk), findsOneWidget);
    final share = tester.widget<AppButton>(
      find.widgetWithText(AppButton, l10n.backupShare),
    );
    expect(share.onPressed, isNull);
  });

  testWidgets('320dp/font 1.3/dark — без overflow', (tester) async {
    await pump(tester, _viewModel(), width: 320, dark: true, largeText: true);
    expect(tester.takeException(), isNull);
  });
}
