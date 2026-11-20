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
import 'package:finanseapp/core/features/goals/ui/goal_details_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

Money _rubles(int major) => Money(minorUnits: major * 100, currencyCode: 'RUB');

FinancialGoal _goal({GoalStatus status = GoalStatus.active}) => FinancialGoal(
  id: 1,
  name: 'Отпуск',
  category: GoalCategory.accounts,
  targetAmount: _rubles(1000),
  status: status,
  assetIds: const {1},
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

AssetSnapshot _account(int value) => AssetSnapshot(
  asset: AccountAsset(
    id: 1,
    name: 'Вклад',
    currencyCode: 'RUB',
    openingValue: _rubles(value),
    createdAt: DateTime.utc(2026, 1, 1),
    bankId: 1,
    annualRate: Decimal.zero,
    startDate: LocalDate(2026, 1, 1),
  ),
  currentValue: _rubles(value),
);

final class _Goals implements GoalRepository {
  _Goals(this.current);

  FinancialGoal current;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<List<FinancialGoal>> watchAll() async* {
    yield [current];
    await for (final _ in _changes.stream) {
      yield [current];
    }
  }

  @override
  Future<FinancialGoal> getById(int id) async => current;

  @override
  Future<void> setStatus(int id, GoalStatus status) async {
    current = FinancialGoal(
      id: current.id,
      name: current.name,
      category: current.category,
      targetAmount: current.targetAmount,
      status: status,
      assetIds: current.assetIds,
      createdAt: current.createdAt,
      updatedAt: DateTime.utc(2026, 11, 19),
    );
    _changes.add(null);
  }

  @override
  Future<int> create(GoalDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(int id, GoalDraft draft) => throw UnimplementedError();

  @override
  Future<void> softDelete(int id) => throw UnimplementedError();
}

final class _Assets implements AssetRepository {
  _Assets(this.snapshot);

  AssetSnapshot snapshot;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void emit(int value) {
    snapshot = _account(value);
    _changes.add(null);
  }

  void fail() => _changes.addError(StateError('stream failure'));

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) async* {
    yield [snapshot];
    await for (final _ in _changes.stream) {
      yield [snapshot];
    }
  }

  @override
  Stream<AssetSnapshot?> watchById(int id) async* {
    yield snapshot;
    await for (final _ in _changes.stream) {
      yield snapshot;
    }
  }

  @override
  Future<AssetSnapshot> getById(int id) async => snapshot;

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

final class _Currencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub];

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(String code, String name, int digits) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class _Rates implements ExchangeRateRepository {
  @override
  Future<ExchangeRate?> find(String code, LocalDate date) async => null;

  @override
  Future<ExchangeRate> fetchFromCbr(String code, LocalDate date) =>
      throw UnimplementedError();

  @override
  Future<ExchangeRate> saveManual(String code, LocalDate date, Decimal rate) =>
      throw UnimplementedError();
}

void main() {
  test('изменение связанного актива обновляет прогресс и статус', () async {
    final goals = _Goals(_goal());
    final assets = _Assets(_account(500));
    final vm = GoalDetailsViewModel(
      repository: goals,
      assetRepository: assets,
      goalId: 1,
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
      today: LocalDate(2026, 11, 19),
    );
    addTearDown(vm.dispose);

    await vm.load();
    expect(vm.progress.value?.completionRatio, Decimal.parse('0.5'));
    expect(vm.goal.value?.status, GoalStatus.active);

    assets.emit(1000);
    await pumpEventQueue();
    await pumpEventQueue();

    expect(vm.progress.value?.completionRatio, Decimal.one);
    expect(vm.goal.value?.status, GoalStatus.achieved);
  });

  test('ошибка watch-потока даёт storageFailure', () async {
    final assets = _Assets(_account(500));
    final vm = GoalDetailsViewModel(
      repository: _Goals(_goal()),
      assetRepository: assets,
      goalId: 1,
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
      today: LocalDate(2026, 11, 19),
    );
    addTearDown(vm.dispose);
    await vm.load();

    assets.fail();
    await pumpEventQueue();

    expect(vm.state.value, isA<ViewError>());
  });

  test('после dispose эмиссия не меняет состояние', () async {
    final assets = _Assets(_account(500));
    final vm = GoalDetailsViewModel(
      repository: _Goals(_goal()),
      assetRepository: assets,
      goalId: 1,
      currencyRepository: _Currencies(),
      rateRepository: _Rates(),
      today: LocalDate(2026, 11, 19),
    );
    await vm.load();
    vm.dispose();

    assets.emit(1000);
    await pumpEventQueue();

    expect(vm.progress.value?.completionRatio, Decimal.parse('0.5'));
  });
}
