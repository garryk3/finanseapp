import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/features/settings/domain/update_service.dart';
import 'package:finanseapp/core/features/settings/logic/update_check_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/widgets/update_section.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final class _Updates implements UpdateService {
  @override
  Future<ReleaseInfo?> fetchLatestRelease() async => null;
}

UpdateCheckViewModel _viewModel() => UpdateCheckViewModel(
  service: _Updates(),
  installedVersionProvider: () async => '1.0.0',
);

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  Future<void> pump(
    WidgetTester tester,
    UpdateCheckViewModel vm, {
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
            child: UpdateSection(viewModel: vm, onOpenAbout: () {}),
          ),
        ),
      ),
    );
    await vm.init();
    await tester.pumpAndSettle();
  }

  testWidgets('версия, проверка и About', (tester) async {
    final vm = _viewModel();
    await pump(tester, vm);

    expect(find.text(l10n.settingsUpdateVersion('1.0.0')), findsOneWidget);
    expect(find.text(l10n.updateCheck), findsOneWidget);
    expect(find.text(l10n.settingsAboutDetails), findsOneWidget);
  });

  testWidgets('updateAvailable показывает открытие обновления', (tester) async {
    final vm = _viewModel()
      ..installedVersion.value = '1.0.0'
      ..release.value = const ReleaseInfo(tagName: 'v1.2.0')
      ..status.value = UpdateStatus.updateAvailable;
    await pump(tester, vm);

    expect(find.text(l10n.updateAvailable('v1.2.0')), findsOneWidget);
    expect(find.text(l10n.updateOpen), findsOneWidget);
  });

  testWidgets('openFailed сохраняет кнопку обновления', (tester) async {
    final vm = _viewModel()
      ..installedVersion.value = '1.0.0'
      ..release.value = const ReleaseInfo(tagName: 'v1.2.0')
      ..status.value = UpdateStatus.openFailed;
    await pump(tester, vm);

    expect(find.text(l10n.updateOpen), findsOneWidget);
    expect(find.text(l10n.updateOpenFailed), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('error: сеть и invalid различаются', (tester) async {
    final network = _viewModel()
      ..status.value = UpdateStatus.error
      ..errorKind.value = UpdateErrorKind.network;
    await pump(tester, network);
    expect(find.text(l10n.updateNetworkError), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    final invalid = _viewModel()
      ..status.value = UpdateStatus.error
      ..errorKind.value = UpdateErrorKind.invalid;
    await pump(tester, invalid);
    expect(find.text(l10n.updateInvalidResponse), findsOneWidget);
  });

  testWidgets('320dp/font 1.3/dark — без overflow', (tester) async {
    await pump(tester, _viewModel(), width: 320, dark: true, largeText: true);
    expect(tester.takeException(), isNull);
  });
}
