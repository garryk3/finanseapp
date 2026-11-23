import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/analytics/ui/category_totals_section.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

String _format(Money money) => '${money.minorUnits ~/ 100} ₽';

CashflowCategory _category(
  int id,
  CashflowKind kind,
  String name, {
  DateTime? archivedAt,
}) => CashflowCategory(
  id: id,
  kind: kind,
  name: name,
  isPreset: false,
  archivedAt: archivedAt,
);

Map<int, CashflowCategory> _map(List<CashflowCategory> categories) => {
  for (final category in categories) category.id: category,
};

double Function(CategoryTotal) _shareByKind(
  Map<int, CashflowCategory> categories,
  int incomeTotal,
  int expenseTotal,
) => (total) {
  final kind = categories[total.categoryId]?.kind;
  final denominator = kind == CashflowKind.income ? incomeTotal : expenseTotal;
  if (denominator == 0) return 0;
  return (total.total.minorUnits / denominator).clamp(0, 1).toDouble();
};

Widget _app({
  required AppLocalizations l10n,
  required List<CategoryTotal> totals,
  required List<CashflowCategory> categories,
  CashflowKind? cashflowKind,
  CashflowKind? selectedKind,
  ValueChanged<CashflowKind>? onKindChanged,
  bool showShare = true,
}) {
  final map = _map(categories);
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      AppLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ru')],
    home: Material(
      child: SingleChildScrollView(
        child: CategoryTotalsSection(
          totals: totals,
          categories: map,
          cashflowKind: cashflowKind,
          selectedKind: selectedKind,
          onKindChanged: onKindChanged,
          l10n: l10n,
          formatMoney: _format,
          shareOf: _shareByKind(map, 10000000, 10000000),
          showShare: showShare,
        ),
      ),
    ),
  );
}

Set<CashflowKind> _selectedKind(WidgetTester tester) => tester
    .widget<SegmentedButton<CashflowKind>>(
      find.byType(SegmentedButton<CashflowKind>),
    )
    .selected;

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  final categories = [
    _category(1, CashflowKind.expense, 'Продукты'),
    _category(2, CashflowKind.expense, 'Транспорт'),
    _category(3, CashflowKind.income, 'Зарплата'),
  ];
  const totals = [
    CategoryTotal(
      categoryId: 1,
      total: Money(minorUnits: 2500000, currencyCode: 'RUB'),
    ),
    CategoryTotal(
      categoryId: 2,
      total: Money(minorUnits: 7500000, currencyCode: 'RUB'),
    ),
    CategoryTotal(
      categoryId: 3,
      total: Money(minorUnits: 10000000, currencyCode: 'RUB'),
    ),
  ];

  testWidgets('дефолт — расходы; переключение показывает доходы без суффикса', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(l10n: l10n, totals: totals, categories: categories),
    );

    expect(find.text(l10n.analyticsCategoriesTitle), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowExpense), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowIncome), findsOneWidget);
    expect(_selectedKind(tester), {CashflowKind.expense});
    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Транспорт'), findsOneWidget);
    expect(find.text('Зарплата'), findsNothing);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('25% · Расходы'), findsNothing);
    expect(find.text('75% · Расходы'), findsNothing);
    expect(
      tester
          .widget<AppMoneyText>(find.widgetWithText(AppMoneyText, '25000 ₽'))
          .tone,
      AppMoneyTone.expense,
    );

    await tester.tap(find.text(l10n.analyticsCashflowIncome));
    await tester.pump();

    expect(_selectedKind(tester), {CashflowKind.income});
    expect(find.text('Зарплата'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Продукты'), findsNothing);
    expect(find.text('Транспорт'), findsNothing);
    expect(find.text('100% · Доходы'), findsNothing);
    expect(
      tester
          .widget<AppMoneyText>(find.widgetWithText(AppMoneyText, '100000 ₽'))
          .tone,
      AppMoneyTone.income,
    );
  });

  testWidgets('cashflowKind задаёт тип, табы скрыты при фильтре', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        l10n: l10n,
        totals: totals,
        categories: categories,
        cashflowKind: CashflowKind.income,
      ),
    );

    expect(find.byType(AppSegmentedControl<CashflowKind>), findsNothing);
    expect(find.text(l10n.analyticsCashflowIncome), findsOneWidget);
    expect(find.text('Зарплата'), findsOneWidget);
    expect(find.text('Продукты'), findsNothing);

    await tester.pumpWidget(
      _app(
        l10n: l10n,
        totals: totals,
        categories: categories,
        cashflowKind: CashflowKind.expense,
      ),
    );
    await tester.pump();

    expect(find.byType(AppSegmentedControl<CashflowKind>), findsNothing);
    expect(find.text(l10n.analyticsCashflowExpense), findsOneWidget);
    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Зарплата'), findsNothing);

    await tester.pumpWidget(
      _app(l10n: l10n, totals: totals, categories: categories),
    );
    await tester.pump();

    expect(_selectedKind(tester), {CashflowKind.expense});

    await tester.tap(find.text(l10n.analyticsCashflowIncome));
    await tester.pump();

    expect(_selectedKind(tester), {CashflowKind.income});
    expect(find.text('Зарплата'), findsOneWidget);
  });

  testWidgets('selectedKind сохраняет выбор после remount', (tester) async {
    await tester.pumpWidget(
      _app(
        l10n: l10n,
        totals: totals,
        categories: categories,
        selectedKind: CashflowKind.income,
      ),
    );
    expect(_selectedKind(tester), {CashflowKind.income});

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _app(
        l10n: l10n,
        totals: totals,
        categories: categories,
        selectedKind: CashflowKind.income,
      ),
    );
    await tester.pump();

    expect(_selectedKind(tester), {CashflowKind.income});
    expect(find.text('Зарплата'), findsOneWidget);
  });

  testWidgets('пустой таб показывает текст, пустые totals скрывают секцию', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        l10n: l10n,
        totals: const [
          CategoryTotal(
            categoryId: 1,
            total: Money(minorUnits: 2500000, currencyCode: 'RUB'),
          ),
        ],
        categories: categories,
      ),
    );

    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text(l10n.analyticsCategoriesEmptyIncome), findsNothing);

    await tester.tap(find.text(l10n.analyticsCashflowIncome));
    await tester.pump();

    expect(find.text(l10n.analyticsCategoriesEmptyIncome), findsOneWidget);
    expect(find.text('Продукты'), findsNothing);
    expect(find.text(l10n.analyticsCategoriesTitle), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowExpense), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      _app(
        l10n: l10n,
        totals: const [
          CategoryTotal(
            categoryId: 3,
            total: Money(minorUnits: 10000000, currencyCode: 'RUB'),
          ),
        ],
        categories: categories,
      ),
    );
    await tester.pump();

    expect(find.text(l10n.analyticsCategoriesEmptyExpense), findsOneWidget);
    expect(find.text('Зарплата'), findsNothing);

    await tester.pumpWidget(
      _app(l10n: l10n, totals: const [], categories: categories),
    );
    await tester.pump();

    expect(find.text(l10n.analyticsCategoriesTitle), findsNothing);
  });

  testWidgets('архивный бейдж сохраняется', (tester) async {
    final archived = _category(
      1,
      CashflowKind.expense,
      'Продукты',
      archivedAt: DateTime.utc(2026, 11, 1),
    );
    await tester.pumpWidget(
      _app(
        l10n: l10n,
        totals: const [
          CategoryTotal(
            categoryId: 1,
            total: Money(minorUnits: 2500000, currencyCode: 'RUB'),
          ),
        ],
        categories: [archived],
      ),
    );

    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text(l10n.accountArchivedBadge), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });
}
