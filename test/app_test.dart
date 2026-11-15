import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Приложение поднимается, домашний экран показывает заголовок', (
    tester,
  ) async {
    final ServiceLocator locator = ServiceLocator()
      ..register<HomeViewModel>(HomeViewModel());
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('ru'),
    );

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.text(l10n.homeDemoSection), findsOneWidget);
    expect(find.text(l10n.increment), findsOneWidget);
  });

  testWidgets('Демо-счётчик увеличивается по нажатию', (tester) async {
    final ServiceLocator locator = ServiceLocator()
      ..register<HomeViewModel>(HomeViewModel());
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('ru'),
    );

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.text('${l10n.counterLabel}: 0'), findsOneWidget);
    await tester.tap(find.text(l10n.increment));
    await tester.pumpAndSettle();
    expect(find.text('${l10n.counterLabel}: 1'), findsOneWidget);
  });
}
