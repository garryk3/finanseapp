import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('настройки: валюта, версия, проверка обновлений, About', (
    tester,
  ) async {
    final l10n = await loadL10n();
    final locator = await pumpApp(tester);
    await openMore(tester, l10n);

    await tester.tap(find.text(l10n.settingsTitle));
    await tester.pumpAndSettle();
    expect(find.text(l10n.baseCurrencyTitle), findsOneWidget);
    expect(find.textContaining('RUB'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l10n.updateCheck),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text(l10n.settingsUpdateVersion('0.1.0')), findsOneWidget);

    await tester.tap(find.text(l10n.updateCheck));
    await tester.pumpAndSettle();
    expect(find.text(l10n.updateNoReleases), findsOneWidget);

    await tester.tap(find.text(l10n.settingsAboutDetails));
    await tester.pumpAndSettle();
    expect(find.text(l10n.aboutTitle), findsWidgets);
    expect(find.text(l10n.aboutDescription), findsOneWidget);

    await shutdownApp(tester, locator);
  });
}
