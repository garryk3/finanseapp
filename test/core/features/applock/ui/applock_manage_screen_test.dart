import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_manage_screen.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes.dart';

void main() {
  late TestApplockHarness harness;
  late FakeBiometricGateway bio;
  late ApplockSettingsViewModel viewModel;
  late AppLocalizations l10n;

  setUp(() async {
    harness = TestApplockHarness();
    bio = FakeBiometricGateway();
    viewModel = ApplockSettingsViewModel(
      service: harness.service,
      biometrics: bio,
    );
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('защита выключена: статус и кнопка включения', (tester) async {
    await tester.pumpWidget(
      applockTestHost(ApplockManageScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.appLockStatusOff), findsOneWidget);
    expect(find.text(l10n.appLockEnable), findsOneWidget);
  });

  testWidgets('включение: двойной ввод через экран (BR-Sec-3)', (tester) async {
    await tester.pumpWidget(
      applockTestHost(ApplockManageScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.appLockEnable));
    await tester.pumpAndSettle();
    expect(find.text(l10n.appLockEnterNew), findsOneWidget);

    for (final digit in '1234'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await tester.tap(find.text(l10n.appLockContinue));
    await tester.pumpAndSettle();
    expect(find.text(l10n.appLockConfirmNew), findsOneWidget);

    for (final digit in '1234'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await tester.tap(find.text(l10n.appLockContinue));
    await tester.pumpAndSettle();

    expect(find.text(l10n.appLockStatusOn), findsOneWidget);
    expect(harness.service.isEnabled, isTrue);
  });

  testWidgets('защита включена: смена, отключение, auto-lock', (tester) async {
    await harness.enable('1234');
    await tester.pumpWidget(
      applockTestHost(ApplockManageScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.appLockStatusOn), findsOneWidget);
    expect(find.text(l10n.appLockChange), findsOneWidget);
    expect(find.text(l10n.appLockDisable), findsOneWidget);
    expect(find.text(l10n.appLockAutoLock), findsOneWidget);
    expect(find.text(l10n.appLockAutoLockImmediate), findsOneWidget);

    // Auto-lock: выбор «Через 5 мин».
    await tester.tap(find.text(l10n.appLockAutoLockAfterMinutes(5)));
    await tester.pumpAndSettle();
    expect(harness.service.autoLockMinutes, 5);
  });

  testWidgets('a11y-матрица: 320dp и font scale 1.3 — без overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      applockA11yHost(ApplockManageScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
