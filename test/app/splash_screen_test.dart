import 'package:finanseapp/app/splash_screen.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('без доступного видео остаётся постер и семантика названия', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: const SplashScreen(assetPath: 'assets/video/missing.mp4'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel(l10n.appTitle), findsOneWidget);
    final background = tester.widget<ColoredBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == AppTheme.splashBackground,
      ),
    );
    expect(background.color, AppTheme.splashBackground);
    final poster = tester.widget<DecoratedBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).image?.image is AssetImage,
      ),
    );
    final image = (poster.decoration as BoxDecoration).image!;
    expect(
      (image.image as AssetImage).assetName,
      'assets/video/finsplash_poster.png',
    );
    semantics.dispose();
  });
}
