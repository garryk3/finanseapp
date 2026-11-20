import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/features/analytics/ui/asset_comparison_screen.dart';
import 'package:finanseapp/core/features/analytics/ui/asset_comparison_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_chart_legend.dart';
import 'package:finanseapp/uikit/app_line_chart.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
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

AssetSnapshot _account(int id, String name, {bool archived = false}) =>
    AssetSnapshot(
      asset: AccountAsset(
        id: id,
        name: name,
        currencyCode: 'RUB',
        openingValue: _rubles(1000),
        createdAt: DateTime.utc(2026, 1, 1),
        archivedAt: archived ? DateTime.utc(2026, 2, 1) : null,
        bankId: 1,
        annualRate: Decimal.zero,
        startDate: LocalDate(2026, 1, 1),
      ),
      currentValue: _rubles(1000),
    );

final class _Queries implements AnalyticsQueries {
  _Queries(this.pointsByAsset);

  final Map<int, List<NetWorthPoint>> pointsByAsset;
  int? lastAssetId;

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
    int? assetId,
  }) async {
    lastAssetId = assetId;
    return pointsByAsset[assetId] ?? const [];
  }

  @override
  Future<NetWorthSummary> netWorth(LocalDate onDate) =>
      throw UnimplementedError();

  @override
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind}) async => null;

  @override
  Future<bool> hasAnyCashflow() async => false;

  @override
  Future<CashflowSummary> cashflow(CashflowFilter filter) =>
      throw UnimplementedError();

  @override
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter) =>
      throw UnimplementedError();

  @override
  Future<List<CashflowPeriodPoint>> cashflowSeries(CashflowFilter filter) =>
      throw UnimplementedError();
}

final class _Assets implements AssetRepository {
  _Assets(this.snapshots);

  final List<AssetSnapshot> snapshots;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value(snapshots);

  @override
  Stream<AssetSnapshot?> watchById(int id) => throw UnimplementedError();

  @override
  Future<AssetSnapshot> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(AssetDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(int id, AssetDraft draft) => throw UnimplementedError();

  @override
  Future<void> deleteIfUnused(int id) => throw UnimplementedError();

  @override
  Future<void> archive(int id) => throw UnimplementedError();

  @override
  Future<void> recordValuation(AssetValuationDraft draft) =>
      throw UnimplementedError();

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) =>
      throw UnimplementedError();

  @override
  Future<List<AssetValuation>> valuations(int id) => throw UnimplementedError();
}

final class _Settings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async => _rub;

  @override
  Future<void> setBaseCurrency(String code) async {}
}

NetWorthPoint _point(int day, int value) =>
    NetWorthPoint(date: LocalDate(2026, 11, day), value: _rubles(value));

void main() {
  test('absolute/normalized и лимит 2–5 активов', () async {
    final queries = _Queries({
      1: [_point(1, 1000), _point(10, 1100)],
      2: [_point(1, 500), _point(10, 400)],
      3: [_point(1, 0), _point(10, 200)],
    });
    final vm = AssetComparisonViewModel(
      queries: queries,
      assetRepository: _Assets([
        _account(1, 'Первый'),
        _account(2, 'Второй'),
        _account(3, 'Третий'),
        _account(4, 'Четвёртый'),
        _account(5, 'Пятый'),
        _account(6, 'Шестой'),
      ]),
      settingsRepository: _Settings(),
      now: () => LocalDate(2026, 11, 20),
    );
    addTearDown(vm.dispose);

    await vm.init();
    expect(vm.selected.value, {1, 2});
    expect(vm.series.value, hasLength(2));
    expect(vm.series.value.first.values, [1000, 1100]);

    vm.setMode(AssetComparisonMode.normalized);
    await vm.reload();
    expect(vm.series.value.first.values[0], 100);
    expect(vm.series.value.first.values[1], closeTo(110, 1e-9));
    expect(vm.series.value[1].values[0], 100);
    expect(vm.series.value[1].values[1], closeTo(80, 1e-9));

    vm.setPeriod(AnalyticsPeriod.year);
    await vm.reload();
    expect(queries.lastAssetId, isNotNull);

    vm.toggleAsset(3);
    expect(vm.selected.value, {1, 2, 3});
    vm.toggleAsset(4);
    vm.toggleAsset(5);
    vm.toggleAsset(6);
    expect(vm.selected.value, hasLength(5));
  });

  test('нормировка от первого ненулевого значения', () async {
    final vm = AssetComparisonViewModel(
      queries: _Queries({
        1: [_point(1, 0), _point(10, 300)],
        2: [_point(1, 0), _point(10, 0)],
      }),
      assetRepository: _Assets([_account(1, 'Первый'), _account(2, 'Второй')]),
      settingsRepository: _Settings(),
      now: () => LocalDate(2026, 11, 20),
    );
    addTearDown(vm.dispose);
    await vm.init();
    vm.setMode(AssetComparisonMode.normalized);
    await vm.reload();

    expect(vm.series.value.first.values[0], 0);
    expect(vm.series.value.first.values[1], 100);
    expect(vm.series.value[1].values, [0.0, 0.0]);
  });

  test('серии выравниваются по union дат, архивные не предлагаются', () async {
    final vm = AssetComparisonViewModel(
      queries: _Queries({
        1: [_point(1, 1000), _point(10, 1100)],
        2: [_point(5, 500), _point(15, 600)],
      }),
      assetRepository: _Assets([
        _account(1, 'Первый'),
        _account(2, 'Второй'),
        _account(3, 'Архив', archived: true),
      ]),
      settingsRepository: _Settings(),
      now: () => LocalDate(2026, 11, 20),
    );
    addTearDown(vm.dispose);

    await vm.init();
    expect(vm.assets.value.map((asset) => asset.id), [1, 2]);
    final first = vm.series.value.first;
    final second = vm.series.value[1];
    expect(first.points.map((point) => point.date.day), [1, 5, 10, 15]);
    expect(first.points.map((point) => point.value.minorUnits), [
      100000,
      100000,
      110000,
      110000,
    ]);
    expect(second.points.map((point) => point.value.minorUnits), [
      0,
      50000,
      50000,
      60000,
    ]);
  });

  test('пустая серия выравнивается нулями', () async {
    final vm = AssetComparisonViewModel(
      queries: _Queries({
        1: [_point(1, 1000), _point(10, 1100)],
        2: const [],
      }),
      assetRepository: _Assets([_account(1, 'Первый'), _account(2, 'Второй')]),
      settingsRepository: _Settings(),
      now: () => LocalDate(2026, 11, 20),
    );
    addTearDown(vm.dispose);

    await vm.init();
    expect(vm.series.value, hasLength(2));
    expect(vm.series.value[1].points, hasLength(2));
    expect(vm.series.value[1].values, [0, 0]);
  });

  testWidgets('экран сравнения показывает график, легенду и таблицу', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final vm = AssetComparisonViewModel(
      queries: _Queries({
        1: [_point(1, 1000), _point(10, 1100)],
        2: [_point(1, 500), _point(10, 400)],
      }),
      assetRepository: _Assets([_account(1, 'Первый'), _account(2, 'Второй')]),
      settingsRepository: _Settings(),
      now: () => LocalDate(2026, 11, 20),
    );
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: AssetComparisonScreen(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.comparisonChartTitle), findsOneWidget);
    expect(find.byType(AppLineChart), findsOneWidget);
    expect(find.text('Первый'), findsWidgets);
    expect(find.text('Второй'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byType(AppChartLegend),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(AppChartLegend), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('01.11.26').last,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('01.11.26'), findsWidgets);
    expect(find.textContaining('1\u00A0000'), findsWidgets);
  });
}
