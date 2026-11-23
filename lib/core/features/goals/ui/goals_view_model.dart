import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_progress.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/goals/logic/calculate_goal_progress.dart';
import 'package:finanseapp/core/features/goals/logic/goal_calculator.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Цель с рассчитанным прогрессом; `progress == null` — не хватает курса.
final class GoalView {
  const GoalView({required this.goal, this.progress});

  final FinancialGoal goal;
  final GoalProgress? progress;

  bool get hasProgress => progress != null;
}

/// Список финансовых целей с автоматическим прогрессом (8.2).
class GoalsViewModel {
  GoalsViewModel({
    required this.repository,
    required this.currencyRepository,
    required this.assetRepository,
    required this.rateRepository,
    required this.now,
  });

  final GoalRepository repository;
  final CurrencyRepository currencyRepository;
  final AssetRepository assetRepository;
  final ExchangeRateRepository rateRepository;

  /// Провайдер текущей даты; [today] пересчитывается при [init]/[reload],
  /// потому что вкладка целей живёт в shell дольше суток.
  final LocalDate Function() now;
  late LocalDate _today = now();

  LocalDate get today => _today;

  final Signal<ViewState<List<GoalView>>> state = signal(const ViewLoading());
  final Signal<Map<String, Currency>> currencies = signal(const {});

  final CalculateGoalProgress _calculator = const CalculateGoalProgress();
  final Map<String, Decimal> _rateCache = {};
  final Set<int> _statusWrites = {};
  List<FinancialGoal> _goals = const [];
  Map<int, AssetSnapshot> _snapshots = const {};

  StreamSubscription<List<FinancialGoal>>? _goalsSubscription;
  StreamSubscription<List<AssetSnapshot>>? _assetsSubscription;
  bool _referencesReady = false;
  bool _assetsReady = false;
  bool _assetsFailed = false;
  bool _disposed = false;
  int _emitToken = 0;

  void init() {
    state.value = const ViewLoading();
    _emitToken++;
    _today = now();
    _referencesReady = false;
    _assetsReady = false;
    _assetsFailed = false;
    _loadReferences();
    _subscribeGoals();
    _assetsSubscription?.cancel();
    _assetsSubscription = assetRepository
        .watchAll(includeArchived: true)
        .listen(
          (snapshots) {
            _snapshots = {
              for (final snapshot in snapshots) snapshot.asset.id: snapshot,
            };
            _assetsReady = true;
            _assetsFailed = false;
            _emit();
          },
          onError: (Object _) {
            // Список целей остаётся доступным, но без прогресса: нулевая сумма
            // не должна приниматься за реальный прогресс.
            _assetsFailed = true;
            _assetsReady = true;
            _emit();
          },
        );
  }

  void reload() {
    _today = now();
    _subscribeGoals();
  }

  void _subscribeGoals() {
    _goalsSubscription?.cancel();
    _goalsSubscription = repository.watchAll().listen(
      (goals) {
        _goals = goals;
        _emit();
      },
      onError: (Object _) {
        if (_disposed) return;
        state.value = const ViewError(DomainErrorCode.storageFailure);
      },
    );
  }

  Future<void> _loadReferences() async {
    try {
      final list = await currencyRepository.watchAll().first;
      currencies.value = {for (final currency in list) currency.code: currency};
    } on Exception {
      // Валюты не блокируют список: прогресс покажется без суммы.
    } finally {
      _referencesReady = true;
      _emit();
    }
  }

  Future<void> _emit() async {
    if (_disposed) return;
    // Пустой список показываем сразу; непустой — после справочников и
    // стоимостей, иначе прогресс 0 мог бы ложно сбросить achieved.
    if (_goals.isNotEmpty && (!_referencesReady || !_assetsReady)) return;
    // Перекрывающиеся эмиссии (цели/активы) завершаются не в порядке старта;
    // проигравшая не должна перезаписывать state и статус устаревшими данными.
    final token = ++_emitToken;
    final views = <GoalView>[];
    for (final goal in _goals) {
      final values = <int, List<Money>>{};
      for (final assetId in goal.assetIds) {
        final snapshot = _snapshots[assetId];
        if (snapshot != null) values[assetId] = snapshot.breakdown;
      }
      final progress = _assetsFailed
          ? null
          : await _calculator.load(
              goal: goal,
              assetValues: values,
              currencies: currencies.value,
              rateRepository: rateRepository,
              today: _today,
              rateCache: _rateCache,
            );
      if (_disposed || token != _emitToken) return;
      views.add(GoalView(goal: goal, progress: progress));
      if (progress != null) {
        final resolved = GoalCalculator.resolveStatus(
          current: goal.status,
          progress: progress,
        );
        if (resolved != goal.status) {
          unawaited(_syncStatus(goal.id, resolved));
        }
      }
    }
    if (_disposed || token != _emitToken) return;
    views.sort(_compare);
    state.value = ViewData(views);
  }

  /// Автоматический статус пишется один раз на цель; эмиссия после записи
  /// увидит согласованный статус и не зациклится.
  Future<void> _syncStatus(int id, GoalStatus status) async {
    if (_statusWrites.contains(id)) return;
    _statusWrites.add(id);
    try {
      await repository.setStatus(id, status);
    } on DomainException {
      // Оставляем прежний статус; следующий поток данных повторит попытку.
    } finally {
      _statusWrites.remove(id);
    }
  }

  static int _statusRank(GoalStatus status) => switch (status) {
    GoalStatus.active => 0,
    GoalStatus.achieved => 1,
    GoalStatus.closed => 2,
  };

  static int _compare(GoalView left, GoalView right) {
    final byStatus = _statusRank(left.goal.status)
        .compareTo(_statusRank(right.goal.status));
    return byStatus != 0 ? byStatus : left.goal.name.compareTo(right.goal.name);
  }

  Currency currencyOf(String code) =>
      currencies.value[code] ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  String formatMoney(Money money) =>
      const MoneyFormatter().format(money, currencyOf(money.currencyCode));

  String formatTarget(FinancialGoal goal) => formatMoney(goal.targetAmount);

  void dispose() {
    _disposed = true;
    _goalsSubscription?.cancel();
    _assetsSubscription?.cancel();
  }
}

/// ViewModel формы цели (8.1).
class GoalFormViewModel {
  GoalFormViewModel({
    required this.repository,
    required this.assetRepository,
    required this.currencyRepository,
    this.editingId,
  });

  final GoalRepository repository;
  final AssetRepository assetRepository;
  final CurrencyRepository currencyRepository;
  final int? editingId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<Asset>> assets = signal(const []);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<FinancialGoal?> goal = signal(null);
  final Signal<bool> busy = signal(false);

  bool get isEditing => editingId != null;

  Future<void> load() async {
    try {
      final list = await currencyRepository.getEnabled();
      currencies.value = {for (final currency in list) currency.code: currency};
      final snapshots = await assetRepository
          .watchAll(includeArchived: true)
          .first;
      assets.value = [for (final snapshot in snapshots) snapshot.asset];
      if (editingId != null) {
        goal.value = await repository.getById(editingId!);
      }
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  /// Архивные активы доступны только если уже привязаны к цели (8.1).
  List<Asset> eligibleAssets(GoalCategory category) {
    final linked = goal.value?.assetIds ?? const <int>{};
    return [
      for (final asset in assets.value)
        if (category == GoalCategory.accounts
            ? asset is AccountAsset
            : asset is InvestmentAsset)
          if (asset.archivedAt == null || linked.contains(asset.id)) asset,
    ];
  }

  Currency currencyOf(String code) =>
      currencies.value[code] ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  Future<Result<int>> save({
    required String name,
    required GoalCategory category,
    required Money targetAmount,
    required Set<int> assetIds,
    LocalDate? targetDate,
  }) async {
    busy.value = true;
    try {
      final draft = GoalDraft(
        name: name,
        category: category,
        targetAmount: targetAmount,
        assetIds: assetIds,
        targetDate: targetDate,
      );
      if (editingId == null) return Success(await repository.create(draft));
      await repository.update(editingId!, draft);
      return const Success(0);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }

  void dispose() {}
}
