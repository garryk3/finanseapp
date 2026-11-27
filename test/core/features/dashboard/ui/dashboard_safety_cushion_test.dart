import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/dashboard/logic/safety_cushion.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_safety_cushion.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

SafetyCushion _cushion({
  required int months,
  int? monthsToTarget,
  int cashMinor = -1,
}) => SafetyCushion(
  cash: Money(
    minorUnits: cashMinor >= 0 ? cashMinor : months * 100,
    currencyCode: 'RUB',
  ),
  avgExpenses: const Money(minorUnits: 100, currencyCode: 'RUB'),
  avgIncome: const Money(minorUnits: 120, currencyCode: 'RUB'),
  monthlyProfit: const Money(minorUnits: 20, currencyCode: 'RUB'),
  months: months,
  target: const Money(minorUnits: 600, currencyCode: 'RUB'),
  monthsToTarget: monthsToTarget,
);

String _formatMoney(Money value) => '${value.minorUnits} ₽';

Widget _app(
  AppLocalizations l10n,
  SafetyCushion cushion, {
  double textScale = 1.3,
  bool dark = false,
}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: SizedBox(
      width: 288,
      child: DashboardSafetyCushion(
        cushion: cushion,
        l10n: l10n,
        formatMoney: _formatMoney,
      ),
    ),
  ),
);

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('13 мес показываются как 13 мес и 1 год 1 мес', (tester) async {
    await tester.pumpWidget(
      _app(l10n, _cushion(months: 13, monthsToTarget: 5)),
    );
    await tester.pump();

    expect(find.text(l10n.dashboardSafetyMonths(13)), findsOneWidget);
    expect(
      find.text(
        l10n.dashboardSafetyYearsMonths(l10n.dashboardSafetyYears(1), 1),
      ),
      findsOneWidget,
    );
    final value = tester.renderObject<RenderParagraph>(
      find.text(l10n.dashboardSafetyMonths(13)),
    );
    expect(value.didExceedMaxLines, isFalse);
  });

  testWidgets('ровно 2 года — без «0 мес»', (tester) async {
    await tester.pumpWidget(_app(l10n, _cushion(months: 24)));
    await tester.pump();

    expect(find.text(l10n.dashboardSafetyYears(2)), findsOneWidget);
    expect(
      find.text(
        l10n.dashboardSafetyYearsMonths(l10n.dashboardSafetyYears(2), 0),
      ),
      findsNothing,
    );
  });

  testWidgets('нулевой запас — «Запаса нет»', (tester) async {
    await tester.pumpWidget(_app(l10n, _cushion(months: 0, monthsToTarget: 3)));
    await tester.pump();

    expect(find.text(l10n.dashboardSafetyNoReserve), findsOneWidget);
  });

  testWidgets('деньги есть, но меньше месяца — «Меньше чем на месяц»', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(l10n, _cushion(months: 0, monthsToTarget: 3, cashMinor: 50000)),
    );
    await tester.pump();

    expect(find.text(l10n.dashboardSafetyLessThanMonth), findsOneWidget);
    expect(find.text(l10n.dashboardSafetyNoReserve), findsNothing);
  });

  testWidgets('1500 мес при 320dp/2.0 — «100+ лет» без overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(l10n, _cushion(months: 1500, monthsToTarget: 200), textScale: 2.0),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.dashboardSafetyMoreThan100Years), findsOneWidget);
    final value = tester.renderObject<RenderParagraph>(
      find.text(l10n.dashboardSafetyMoreThan100Years),
    );
    expect(value.didExceedMaxLines, isFalse);
  });

  testWidgets('достигнутая цель — success-тон и иконка', (tester) async {
    await tester.pumpWidget(_app(l10n, _cushion(months: 8, monthsToTarget: 0)));
    await tester.pump();

    expect(find.text(l10n.dashboardSafetyReached), findsOneWidget);
    expect(find.byType(AppIcon), findsOneWidget);
    final text = tester.widget<Text>(find.text(l10n.dashboardSafetyReached));
    final colors = AppTheme.light().extension<AppSemanticColors>()!;
    expect(text.style?.color, colors.success);
  });

  testWidgets('семантика карточки — одна строка', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(l10n, _cushion(months: 13, monthsToTarget: 5)),
    );
    await tester.pump();

    expect(
      find.bySemanticsLabel(
        RegExp(
          '${l10n.dashboardSafetyRunway}.*${l10n.dashboardSafetyPeriod}.*'
          '${l10n.dashboardSafetyEta(5, _formatMoney(const Money(minorUnits: 20, currencyCode: 'RUB')))}',
        ),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('семантика нулевого запаса начинается с «Запаса нет»', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(l10n, _cushion(months: 0, monthsToTarget: 3)));
    await tester.pump();

    expect(
      find.bySemanticsLabel(RegExp('^${l10n.dashboardSafetyNoReserve}')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('семантика 100+ лет не склеивает «хватит на»', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(l10n, _cushion(months: 1500, monthsToTarget: 200)),
    );
    await tester.pump();

    expect(
      find.bySemanticsLabel(
        RegExp('^${RegExp.escape(l10n.dashboardSafetyMoreThan100Years)}'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('хватит на 100\\+ лет')), findsNothing);
    semantics.dispose();
  });

  testWidgets('ошибка курса — inline «Курс недоступен» и повтор (S5)', (
    tester,
  ) async {
    var retried = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SizedBox(
          width: 288,
          child: DashboardSafetyCushion(
            error: DomainErrorCode.rateUnavailable,
            l10n: l10n,
            formatMoney: _formatMoney,
            onRetry: () => retried++,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(l10n.dashboardSafetyTitle), findsOneWidget);
    expect(find.text(l10n.assetBaseUnavailable), findsOneWidget);
    await tester.tap(find.text(l10n.retry));
    await tester.pump();
    expect(retried, 1);
  });

  testWidgets('ошибка хранилища — без повтора', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SizedBox(
          width: 288,
          child: DashboardSafetyCushion(
            error: DomainErrorCode.storageFailure,
            l10n: l10n,
            formatMoney: _formatMoney,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(l10n.dashboardSafetyTitle), findsOneWidget);
    expect(find.text(l10n.retry), findsNothing);
  });
}
