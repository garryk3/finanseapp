import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/ui/cashflow_chart_section.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

String _format(Money money) => '${money.minorUnits ~/ 100} ₽';

CashflowPeriodPoint _point(LocalDate date, int income, int expense) =>
    CashflowPeriodPoint(
      periodStart: date,
      summary: CashflowSummary(
        income: _rubles(income),
        expense: _rubles(expense),
        net: _rubles(income - expense),
        currencyCode: 'RUB',
      ),
    );

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('summary, график и легенда без списка периодов', (tester) async {
    tester.view.physicalSize = const Size(1000, 2000);
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
        home: SingleChildScrollView(
          child: CashflowChartSection(
            summary: CashflowSummary(
              income: _rubles(1000),
              expense: _rubles(250),
              net: _rubles(750),
              currencyCode: 'RUB',
            ),
            points: [
              _point(LocalDate(2026, 11, 1), 700, 100),
              _point(LocalDate(2026, 11, 2), 300, 150),
            ],
            baseCurrency: _rub,
            periodLabel: l10n.analyticsPeriodMonth,
            l10n: l10n,
            formatMoney: _format,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.analyticsCashflowTitle), findsOneWidget);
    expect(find.text('1000 ₽'), findsOneWidget);
    expect(find.text('250 ₽'), findsOneWidget);
    expect(find.text('750 ₽'), findsOneWidget);
    expect(find.text('01.11.2026'), findsNothing);
    expect(find.text('02.11.2026'), findsNothing);
    expect(find.textContaining('Показать все'), findsNothing);
    expect(find.text(l10n.cashflowIncome), findsWidgets);
    expect(find.text(l10n.cashflowExpense), findsWidgets);
    expect(find.text(l10n.cashflowTotalsNet), findsWidgets);
  });

  testWidgets('пустая серия не рисует секцию', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: SingleChildScrollView(
          child: CashflowChartSection(
            summary: CashflowSummary(
              income: _rubles(0),
              expense: _rubles(0),
              net: _rubles(0),
              currencyCode: 'RUB',
            ),
            points: const [],
            baseCurrency: _rub,
            periodLabel: l10n.analyticsPeriodMonth,
            l10n: l10n,
            formatMoney: _format,
          ),
        ),
      ),
    );

    expect(find.text(l10n.analyticsCashflowTitle), findsNothing);
  });

  testWidgets('все нули — «Нет операций за период» вместо пустой сетки', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: SingleChildScrollView(
          child: CashflowChartSection(
            summary: CashflowSummary(
              income: _rubles(0),
              expense: _rubles(0),
              net: _rubles(0),
              currencyCode: 'RUB',
            ),
            points: [
              _point(LocalDate(2026, 11, 1), 0, 0),
              _point(LocalDate(2026, 11, 2), 0, 0),
            ],
            baseCurrency: _rub,
            periodLabel: l10n.analyticsPeriodMonth,
            l10n: l10n,
            formatMoney: _format,
          ),
        ),
      ),
    );

    expect(find.text(l10n.analyticsCashflowEmptyTitle), findsOneWidget);
    expect(find.text(l10n.analyticsCashflowTitle), findsNothing);
  });

  testWidgets('31 дневная группа на 320dp/1.3/dark — без overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final points = [
      for (var day = 1; day <= 30; day++)
        _point(LocalDate(2026, 11, day), 100, 10),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: SingleChildScrollView(
          child: CashflowChartSection(
            summary: CashflowSummary(
              income: _rubles(3000),
              expense: _rubles(300),
              net: _rubles(2700),
              currencyCode: 'RUB',
            ),
            points: points,
            baseCurrency: _rub,
            periodLabel: l10n.analyticsPeriodMonth,
            l10n: l10n,
            formatMoney: _format,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    final horizontal = tester
        .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .where((scroll) => scroll.scrollDirection == Axis.horizontal);
    expect(horizontal, isNotEmpty);
  });
}
