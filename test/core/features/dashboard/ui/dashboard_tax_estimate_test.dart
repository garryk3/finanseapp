import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/dashboard/logic/tax_estimate.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_tax_estimate.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

String _formatMoney(Money value) => '${value.minorUnits} ₽';

Widget _app(
  AppLocalizations l10n, {
  TaxEstimate? estimate,
  DomainErrorCode? error,
  int ratePercent = 13,
  ValueChanged<int>? onRateChanged,
  double textScale = 1.3,
  double width = 320,
}) => MaterialApp(
  theme: AppTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: SizedBox(
      width: width,
      child: DashboardTaxEstimate(
        estimate: estimate,
        ratePercent: ratePercent,
        error: error,
        l10n: l10n,
        formatMoney: _formatMoney,
        onRateChanged: onRateChanged ?? (_) {},
      ),
    ),
  ),
);

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('показывает налог и сумму процентов за год', (tester) async {
    final estimate = TaxEstimate.calculate(
      base: _rubles(10000),
      ratePercent: 13,
    );
    await tester.pumpWidget(_app(l10n, estimate: estimate));
    await tester.pump();

    expect(find.text(l10n.dashboardTaxTitle), findsOneWidget);
    expect(find.text(_formatMoney(estimate.tax)), findsOneWidget);
    expect(find.text(l10n.dashboardTaxBaseLabel), findsOneWidget);
    expect(find.text(_formatMoney(estimate.base)), findsOneWidget);
  });

  testWidgets('изменение ставки отдаёт валидное значение', (tester) async {
    int? received;
    await tester.pumpWidget(
      _app(
        l10n,
        estimate: TaxEstimate.calculate(base: _rubles(10000), ratePercent: 13),
        onRateChanged: (value) => received = value,
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '20');
    await tester.pump();

    expect(received, 20);
    expect(find.text(l10n.dashboardTaxRateInvalid), findsNothing);
  });

  testWidgets('невалидная ставка — inline-ошибка, значение не уходит', (
    tester,
  ) async {
    int? received;
    await tester.pumpWidget(
      _app(
        l10n,
        estimate: TaxEstimate.calculate(base: _rubles(10000), ratePercent: 13),
        onRateChanged: (value) => received = value,
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '150');
    await tester.pump();

    expect(find.text(l10n.dashboardTaxRateInvalid), findsOneWidget);
    expect(received, isNull);
  });

  testWidgets('инфо-диалог показывает формулу расчёта', (tester) async {
    await tester.pumpWidget(
      _app(
        l10n,
        estimate: TaxEstimate.calculate(base: _rubles(10000), ratePercent: 13),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.text(l10n.dashboardTaxInfoTitle), findsOneWidget);
    expect(find.text(l10n.dashboardTaxInfoBody), findsOneWidget);
  });

  testWidgets('неустранимая ошибка курса — inline-состояние', (tester) async {
    await tester.pumpWidget(_app(l10n, error: DomainErrorCode.rateUnavailable));
    await tester.pump();

    expect(find.text(l10n.dashboardTaxTitle), findsOneWidget);
    expect(find.text(l10n.dashboardTaxRateUnavailable), findsOneWidget);
  });

  testWidgets('320dp / 2.0 — без overflow', (tester) async {
    await tester.pumpWidget(
      _app(
        l10n,
        estimate: TaxEstimate.calculate(
          base: _rubles(12345678),
          ratePercent: 13,
        ),
        textScale: 2.0,
        width: 320,
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.dashboardTaxTitle), findsOneWidget);
  });
}
