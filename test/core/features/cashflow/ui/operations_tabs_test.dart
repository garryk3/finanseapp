import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/features/cashflow/ui/operations_tabs.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('320dp/1.3: полные подписи скроллятся и подводят выбранную', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: AppScaffold(
          body: OperationsTabs(
            current: 'recurring',
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.operationsCashflowTab), findsOneWidget);
    expect(find.text(l10n.operationsTransactionsTab), findsOneWidget);
    expect(find.text(l10n.operationsRecurringTab), findsOneWidget);

    final tabsRect = tester.getRect(find.byType(OperationsTabs));
    final selectedRect = tester.getRect(find.text(l10n.operationsRecurringTab));
    expect(
      selectedRect.left >= tabsRect.left &&
          selectedRect.right <= tabsRect.right,
      isTrue,
      reason: 'выбранная вкладка должна быть подведена в видимую область',
    );

    await tester.ensureVisible(find.text(l10n.operationsCashflowTab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.operationsCashflowTab));
    await tester.pumpAndSettle();

    expect(selected, 'cashflow');
    expect(tester.takeException(), isNull);

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
    expect(scrollbar.thumbVisibility, isTrue);
    expect(scrollbar.trackVisibility, isTrue);
  });

  testWidgets('авто-скролл не двигает родительский вертикальный список', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vertical = ScrollController();
    addTearDown(vertical.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: AppScaffold(
          body: SingleChildScrollView(
            controller: vertical,
            child: Column(
              children: [
                const SizedBox(height: 1200),
                OperationsTabs(current: 'recurring', onChanged: (_) {}),
                const SizedBox(height: 600),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(vertical.offset, 0);
  });
}
