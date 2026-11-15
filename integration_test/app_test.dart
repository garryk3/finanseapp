import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/home/ui/home_screen.dart';
import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke: приложение стартует, домашний экран виден', (
    tester,
  ) async {
    final ServiceLocator locator = ServiceLocator()
      ..register<HomeViewModel>(HomeViewModel());

    await tester.pumpWidget(FinanseApp(locator: locator));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
