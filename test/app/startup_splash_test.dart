import 'package:finanseapp/app/startup_splash.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget splashBuilder(BuildContext context) => const AppText('splash');
  Widget app() => const MaterialApp(home: AppText('app'));

  testWidgets('splash держится до 2.5 с, затем loading и приложение', (
    tester,
  ) async {
    await tester.pumpWidget(
      StartupSplash(splashBuilder: splashBuilder, child: null),
    );

    expect(find.text('splash'), findsOneWidget);
    expect(find.text('app'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2400));
    expect(find.text('splash'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('splash'), findsNothing);
    expect(find.byType(AppSpinner), findsOneWidget);

    await tester.pumpWidget(
      StartupSplash(splashBuilder: splashBuilder, child: app()),
    );
    await tester.pump();

    expect(find.text('app'), findsOneWidget);
    expect(find.text('splash'), findsNothing);
  });

  testWidgets('готовый child не отменяет 2.5-секундную заставку', (
    tester,
  ) async {
    await tester.pumpWidget(
      StartupSplash(splashBuilder: splashBuilder, child: app()),
    );

    expect(find.text('splash'), findsOneWidget);
    expect(find.text('app'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2200));
    expect(find.text('app'), findsNothing);

    // Последние 200 мс приложение проявляется поверх заставки.
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('splash'), findsOneWidget);
    expect(find.text('app'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(of: find.text('app'), matching: find.byType(FadeTransition))
          .last,
    );
    expect(fade.opacity.value, greaterThan(0));
    expect(fade.opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('splash'), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('reduce-motion: смена без кросс-фейда ровно в 2.5 с', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      StartupSplash(splashBuilder: splashBuilder, child: app()),
    );

    await tester.pump(const Duration(milliseconds: 2400));
    expect(find.text('splash'), findsOneWidget);
    expect(find.text('app'), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('splash'), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('disabled: приложение сразу, без splash', (tester) async {
    await tester.pumpWidget(
      StartupSplash(enabled: false, splashBuilder: splashBuilder, child: app()),
    );

    expect(find.text('app'), findsOneWidget);
    expect(find.text('splash'), findsNothing);
  });

  testWidgets('disabled без child: пустой виджет, без splash', (tester) async {
    await tester.pumpWidget(
      StartupSplash(enabled: false, splashBuilder: splashBuilder, child: null),
    );

    expect(find.text('splash'), findsNothing);
    expect(find.byType(AppSpinner), findsNothing);
  });

  testWidgets('после завершения новый child не перезапускает splash', (
    tester,
  ) async {
    await tester.pumpWidget(
      StartupSplash(splashBuilder: splashBuilder, child: app()),
    );
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.text('app'), findsOneWidget);

    await tester.pumpWidget(
      StartupSplash(splashBuilder: splashBuilder, child: app()),
    );
    await tester.pump();

    expect(find.text('splash'), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('таймер отменяется при dispose', (tester) async {
    await tester.pumpWidget(
      StartupSplash(splashBuilder: splashBuilder, child: null),
    );
    expect(find.text('splash'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));

    expect(tester.takeException(), isNull);
  });
}
