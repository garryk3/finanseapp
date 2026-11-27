import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:finanseapp/core/features/goals/data/goal_repository_impl.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/ui/goal_form_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_checkbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../database/database_fixtures.dart';

/// Форма цели (21.1): единый список счетов и инвестиций, категория выводится
/// DAO как `mixed` при сохранении.
void main() {
  late AppDatabase db;
  late AppLocalizations l10n;

  setUp(() async {
    db = openTestDatabase();
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  tearDown(() async {
    await db.close();
  });

  GoalFormViewModel viewModel({int? editingId}) => GoalFormViewModel(
    repository: GoalRepositoryImpl(db.goalsDao),
    assetRepository: AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
      db.currenciesDao,
    ),
    currencyRepository: CurrencyRepositoryImpl(db.currenciesDao),
    editingId: editingId,
  );

  Future<void> pump(WidgetTester tester, GoalFormViewModel vm) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: GoalFormScreen(viewModel: vm),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('форма показывает счёт и инвестицию с подписью вида', (
    tester,
  ) async {
    await createAccount(db, name: 'Вклад');
    await createInvestment(db, name: 'Брокер');
    await pump(tester, viewModel());

    expect(find.text('Вклад · ${l10n.assetKindAccount}'), findsOneWidget);
    expect(find.text('Брокер · ${l10n.assetKindInvestment}'), findsOneWidget);
    expect(find.text(l10n.goalCategoryLabel), findsNothing);
  });

  testWidgets('сохранение смешанной цели кладёт mixed', (tester) async {
    await createAccount(db, name: 'Вклад');
    await createInvestment(db, name: 'Брокер');
    await pump(tester, viewModel());

    await tester.enterText(find.byType(TextField).at(0), 'Отпуск');
    await tester.enterText(find.byType(TextField).at(1), '1000');
    await tester.tap(find.text('Вклад · ${l10n.assetKindAccount}'));
    await tester.tap(find.text('Брокер · ${l10n.assetKindInvestment}'));
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final goal = await db.goalsDao.getById(1);
    expect(goal.category, GoalCategory.mixed);
    expect(goal.name, 'Отпуск');
    expect(await db.goalsDao.assetIdsFor(1), {1, 2});
  });

  testWidgets('редактирование восстанавливает выбор активов', (tester) async {
    final acc = await createAccount(db, name: 'Вклад');
    final inv = await createInvestment(db, name: 'Брокер');
    final id = await db.goalsDao.create(
      name: 'Цель',
      targetAmountMinor: 100000,
      currencyCode: 'RUB',
      assetIds: {acc, inv},
    );
    await pump(tester, viewModel(editingId: id));

    final checkboxes = tester.widgetList<AppCheckbox>(find.byType(AppCheckbox));
    expect(checkboxes, hasLength(2));
    expect(checkboxes.every((box) => box.value == true), isTrue);
  });
}
