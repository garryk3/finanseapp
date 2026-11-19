import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/ui/net_worth_chart_section.dart';
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

NetWorthPoint _point(int day, int minor) => NetWorthPoint(
  date: LocalDate(2026, 11, day),
  value: Money(minorUnits: minor, currencyCode: 'RUB'),
);

String _format(Money money) => '${money.minorUnits ~/ 100} ₽';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('график показывает текстовую альтернативу каждой точки', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1800);
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
          child: NetWorthChartSection(
            points: [_point(1, 100000), _point(12, 150000)],
            baseCurrency: _rub,
            periodLabel: l10n.analyticsPeriodMonth,
            l10n: l10n,
            formatMoney: _format,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.analyticsNetWorthTitle), findsWidgets);
    expect(find.text(l10n.analyticsPointsTitle), findsOneWidget);
    expect(find.text('01.11.2026'), findsWidgets);
    expect(find.text('12.11.2026'), findsWidgets);
    expect(find.text('1000 ₽'), findsWidgets);
    expect(find.text('1500 ₽'), findsWidgets);
    expect(find.text(l10n.analyticsMinLabel), findsOneWidget);
    expect(find.text(l10n.analyticsMaxLabel), findsOneWidget);
  });

  testWidgets('одна точка — состояние «нет изменений» без графика', (
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
          child: NetWorthChartSection(
            points: [_point(1, 100000)],
            baseCurrency: _rub,
            periodLabel: l10n.analyticsPeriodMonth,
            l10n: l10n,
            formatMoney: _format,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.analyticsNoChangesTitle), findsOneWidget);
    expect(find.text(l10n.analyticsPointsTitle), findsNothing);
  });

  testWidgets('320dp, font 1.3, тёмная тема — без overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
          child: NetWorthChartSection(
            points: [_point(1, 100000), _point(12, 150000)],
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
    expect(find.text(l10n.analyticsNetWorthTitle), findsWidgets);
    expect(find.text(l10n.analyticsMinLabel), findsOneWidget);
  });
}
