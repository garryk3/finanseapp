import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_screen.dart';
import 'package:finanseapp/uikit/app_asset_list_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('создание счёта и просмотр деталей', (tester) async {
    final l10n = await loadL10n();
    final db = openE2eDatabase();
    await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
    final locator = await pumpApp(tester, database: db);

    await openAssets(tester, l10n);
    expect(find.text(l10n.assetsEmptyTitle), findsOneWidget);

    await createAccountThroughUi(
      tester,
      l10n,
      name: 'Наличные',
      opening: '1000',
    );

    expect(find.text('Наличные'), findsWidgets);
    expect(find.byType(AppAssetListTile), findsOneWidget);
    await tester.tap(find.byType(AppAssetListTile));
    await tester.pumpAndSettle();

    expect(find.byType(AccountDetailsScreen), findsOneWidget);
    expect(find.text(l10n.accountBalanceLabel), findsOneWidget);
    expect(find.textContaining('1\u00A0000'), findsWidgets);

    await shutdownApp(tester, locator);
  });
}
