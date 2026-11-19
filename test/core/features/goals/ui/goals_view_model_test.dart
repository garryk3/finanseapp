import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _usd = Currency(
  code: 'USD',
  name: 'Доллар',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final _today = LocalDate(2026, 11, 19);

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

FinancialGoal _goal({
  int id = 1,
  int target = 1000,
  String currency = 'RUB',
  GoalStatus status = GoalStatus.active,
  Set<int> assetIds = const {1},
}) => FinancialGoal(
  id: id,
  name: 'Цель $id',
  category: GoalCategory.accounts,
  targetAmount: Money(minorUnits: target * 100, currencyCode: currency),
  status: status,
  assetIds: assetIds,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

AssetSnapshot _snapshot(int id, Money value) => AssetSnapshot(
  asset: AccountAsset(
    id: id,
    name: 'Счёт $id',
    currencyCode: value.currencyCode,
    openingValue: Money(minorUnits: 0, currencyCode: value.currencyCode),
    createdAt: DateTime.utc(2026, 1, 1),
    bankId: 1,
    annualRate: Decimal.zero,
    startDate: LocalDate(2026, 1, 1),
  ),
  currentValue: value,
);

final class _FakeGoals implements GoalRepository {
  _FakeGoals(this._goals);

  final StreamController<List<FinancialGoal>> _controller =
      StreamController.broadcast();
  final List<(int, GoalStatus)> writes = [];
  List<FinancialGoal> _goals;

  void emit(List<FinancialGoal> goals) {
    _goals = goals;
    _controller.add(goals);
  }

  @override
  Stream<List<FinancialGoal>> watchAll() => _controller.stream;

  @override
  Future<FinancialGoal> getById(int id) async =>
      _goals.firstWhere((goal) => goal.id == id);

  @override
  Future<int> create(GoalDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(int id, GoalDraft draft) => throw UnimplementedError();

  @override
  Future<void> setStatus(int id, GoalStatus status) async {
    writes.add((id, status));
    emit([
      for (final goal in _goals)
        if (goal.id == id)
          FinancialGoal(
            id: goal.id,
            name: goal.name,
            category: goal.category,
            targetAmount: goal.targetAmount,
            status: status,
            assetIds: goal.assetIds,
            createdAt: goal.createdAt,
            updatedAt: DateTime.utc(2026, 11, 19),
            targetDate: goal.targetDate,
          )
        else
          goal,
    ]);
  }

  @override
  Future<void> softDelete(int id) => throw UnimplementedError();
}

final class _FakeAssets implements AssetRepository {
  final StreamController<List<AssetSnapshot>> _controller =
      StreamController.broadcast();

  void emit(List<AssetSnapshot> snapshots) => _controller.add(snapshots);

  void fail(Object error) => _controller.addError(error);

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      _controller.stream;

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

final class _FakeCurrencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub, _usd]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub, _usd];

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(
    String code,
    String name,
    int fractionDigits,
  ) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class _FakeRates implements ExchangeRateRepository {
  _FakeRates(this.rates);

  final Map<String, Decimal> rates;
  final List<String> requested = [];

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    requested.add(currencyCode);
    final rate = rates[currencyCode];
    if (rate == null) return null;
    return ExchangeRate(
      id: 1,
      currencyCode: currencyCode,
      date: date,
      rateToRub: rate,
      source: ExchangeRateSource.manual,
      fetchedAt: DateTime.utc(2026, 11, 19),
    );
  }

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw UnimplementedError();

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => throw UnimplementedError();
}

void main() {
  late _FakeGoals goals;
  late _FakeAssets assets;
  late _FakeRates rates;
  late GoalsViewModel viewModel;

  setUp(() {
    goals = _FakeGoals([_goal()]);
    assets = _FakeAssets();
    rates = _FakeRates({'USD': Decimal.fromInt(90)});
    viewModel = GoalsViewModel(
      repository: goals,
      currencyRepository: _FakeCurrencies(),
      assetRepository: assets,
      rateRepository: rates,
      now: () => _today,
    );
  });

  tearDown(() => viewModel.dispose());

  Future<void> pump() => pumpEventQueue(times: 30);

  test('прогресс считается из связанных активов', () async {
    viewModel.init();
    goals.emit([
      _goal(assetIds: const {1, 2}),
    ]);
    assets.emit([_snapshot(1, _rubles(300)), _snapshot(2, _rubles(200))]);
    await pump();

    final state = viewModel.state.value;
    expect(state, isA<ViewData<List<GoalView>>>());
    final view = (state as ViewData<List<GoalView>>).value.single;
    expect(view.progress!.progress, _rubles(500));
    expect(view.progress!.deficit, _rubles(500));
    expect(view.progress!.completionRatio, Decimal.parse('0.5'));
  });

  test('asset stream обновляет прогресс и достигнутый статус', () async {
    viewModel.init();
    goals.emit([_goal()]);
    assets.emit([_snapshot(1, _rubles(1200))]);
    await pump();

    expect(goals.writes, [(1, GoalStatus.achieved)]);
    final view =
        (viewModel.state.value as ViewData<List<GoalView>>).value.single;
    expect(view.goal.status, GoalStatus.achieved);
    expect(view.progress!.surplus, _rubles(200));
  });

  test('снижение прогресса возвращает active', () async {
    goals = _FakeGoals([_goal(status: GoalStatus.achieved)]);
    viewModel = GoalsViewModel(
      repository: goals,
      currencyRepository: _FakeCurrencies(),
      assetRepository: assets,
      rateRepository: rates,
      now: () => _today,
    )..init();
    goals.emit([_goal(status: GoalStatus.achieved)]);
    assets.emit([_snapshot(1, _rubles(500))]);
    await pump();

    expect(goals.writes, [(1, GoalStatus.active)]);
  });

  test('closed не меняется автоматически', () async {
    goals = _FakeGoals([_goal(status: GoalStatus.closed)]);
    viewModel = GoalsViewModel(
      repository: goals,
      currencyRepository: _FakeCurrencies(),
      assetRepository: assets,
      rateRepository: rates,
      now: () => _today,
    )..init();
    goals.emit([_goal(status: GoalStatus.closed)]);
    assets.emit([_snapshot(1, _rubles(2000))]);
    await pump();

    expect(goals.writes, isEmpty);
    final view =
        (viewModel.state.value as ViewData<List<GoalView>>).value.single;
    expect(view.goal.status, GoalStatus.closed);
  });

  test('без курса прогресс не считается и статус не меняется', () async {
    rates = _FakeRates({});
    viewModel = GoalsViewModel(
      repository: goals,
      currencyRepository: _FakeCurrencies(),
      assetRepository: assets,
      rateRepository: rates,
      now: () => _today,
    )..init();
    goals.emit([_goal()]);
    assets.emit([
      _snapshot(1, const Money(minorUnits: 90000, currencyCode: 'USD')),
    ]);
    await pump();

    final view =
        (viewModel.state.value as ViewData<List<GoalView>>).value.single;
    expect(view.progress, isNull);
    expect(view.hasProgress, isFalse);
    expect(goals.writes, isEmpty);
  });

  test('валюты конвертируются, курс запрашивается один раз', () async {
    viewModel.init();
    goals.emit([
      _goal(assetIds: const {1, 2}),
    ]);
    assets.emit([
      _snapshot(1, const Money(minorUnits: 2000, currencyCode: 'USD')),
      _snapshot(2, _rubles(1000)),
    ]);
    await pump();
    final first =
        (viewModel.state.value as ViewData<List<GoalView>>).value.single;
    expect(first.progress!.progress, _rubles(2800));

    assets.emit([
      _snapshot(1, const Money(minorUnits: 2000, currencyCode: 'USD')),
      _snapshot(2, _rubles(2000)),
    ]);
    await pump();

    final second =
        (viewModel.state.value as ViewData<List<GoalView>>).value.single;
    expect(second.progress!.progress, _rubles(3800));
    expect(rates.requested, ['USD']);
  });

  test('сортировка active → achieved → closed', () async {
    goals = _FakeGoals([
      _goal(id: 3, status: GoalStatus.closed),
      _goal(id: 1, status: GoalStatus.active),
      _goal(id: 2, status: GoalStatus.achieved),
    ]);
    viewModel = GoalsViewModel(
      repository: goals,
      currencyRepository: _FakeCurrencies(),
      assetRepository: assets,
      rateRepository: rates,
      now: () => _today,
    )..init();
    goals.emit([
      _goal(id: 3, status: GoalStatus.closed),
      _goal(id: 1, status: GoalStatus.active),
      _goal(id: 2, status: GoalStatus.achieved),
    ]);
    assets.emit([_snapshot(1, _rubles(500))]);
    await pump();

    final views = (viewModel.state.value as ViewData<List<GoalView>>).value;
    expect([for (final view in views) view.goal.id], [1, 2, 3]);
  });

  test('ошибка потока активов — прогресс null и статус не меняется', () async {
    viewModel.init();
    goals.emit([_goal()]);
    assets.fail(StateError('db'));
    await pump();

    final view =
        (viewModel.state.value as ViewData<List<GoalView>>).value.single;
    expect(view.progress, isNull);
    expect(goals.writes, isEmpty);
  });
}
