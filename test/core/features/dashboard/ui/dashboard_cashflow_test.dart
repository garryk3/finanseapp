import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_cashflow.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_cashflow_chart.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
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

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('30 дней сворачиваются в 5 недель с суммами и метками', (
    tester,
  ) async {
    final points = [
      for (var day = 1; day <= 30; day++)
        CashflowPeriodPoint(
          periodStart: LocalDate(2026, 11, day),
          summary: CashflowSummary(
            income: _rubles(100),
            expense: _rubles(50),
            net: _rubles(50),
            currencyCode: 'RUB',
          ),
        ),
    ];

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
            child: DashboardCashflow(
              summary: CashflowSummary(
                income: _rubles(3000),
                expense: _rubles(1500),
                net: _rubles(1500),
                currencyCode: 'RUB',
              ),
              points: points,
              baseCurrency: _rub,
              monthLabel: '01.11.2026 – 30.11.2026',
              l10n: l10n,
              formatMoney: _format,
              onOpenAnalytics: () {},
              onAddExpense: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final chart = tester.widget<AppCashflowChart>(
      find.byType(AppCashflowChart),
    );
    expect(chart.groups, hasLength(5));
    expect(chart.groups.first.label, '01–07.11');
    expect(chart.groups[1].label, '08–14.11');
    expect(chart.groups.last.label, '29–30.11');
    expect(chart.groups.first.income, 700);
    expect(chart.groups.first.expense, 350);
    expect(chart.groups.last.income, 200);
    expect(chart.groups.first.incomeText, '700 ₽');
    expect(find.text(l10n.dashboardCashflowDynamics), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
