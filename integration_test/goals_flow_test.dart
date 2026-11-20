import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/core/database/database_fixtures.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('цель учитывает привязанный счёт', (tester) async {
    final l10n = await loadL10n();
    final db = openE2eDatabase();
    await db.referencesDao.createSubgroup(SubgroupKind.bank, 'Банк');
    await createAccount(db, name: 'Вклад', openingValueMinor: 60000);
    final locator = await pumpApp(tester, database: db);
    await openGoals(tester, l10n);

    await tester.tap(find.text(l10n.goalsAdd).first);
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Отпуск');
    await tester.enterText(fields.at(1), '1000');
    await tester.tap(find.text('Вклад'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    await openGoals(tester, l10n);
    expect(find.text('Отпуск'), findsOneWidget);
    expect(find.textContaining('600'), findsWidgets);
    expect(find.textContaining('1\u00A0000'), findsWidgets);

    await shutdownApp(tester, locator);
  });
}
