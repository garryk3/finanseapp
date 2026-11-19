import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/app/test_app_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('аналитика открывается из «Ещё» и переключает период', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final locator = await buildTestLocator();

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.navMore));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.analyticsTitle));
    await tester.pumpAndSettle();

    expect(find.text(l10n.analyticsTitle), findsWidgets);
    expect(find.text(l10n.analyticsNoAssetsTitle), findsOneWidget);

    await tester.tap(find.text(l10n.analyticsPeriodYear));
    await tester.pumpAndSettle();

    expect(find.text(l10n.analyticsNoAssetsTitle), findsOneWidget);

    // Гасим drift-стримы экрана до проверки инвариантов.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
