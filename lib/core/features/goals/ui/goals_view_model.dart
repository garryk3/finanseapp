import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Список финансовых целей (8.1).
class GoalsViewModel {
  GoalsViewModel({required this.repository, required this.currencyRepository});

  final GoalRepository repository;
  final CurrencyRepository currencyRepository;

  final Signal<ViewState<List<FinancialGoal>>> state = signal(
    const ViewLoading(),
  );
  final Signal<Map<String, Currency>> currencies = signal(const {});

  StreamSubscription<List<FinancialGoal>>? _subscription;
  bool _disposed = false;

  void init() {
    state.value = const ViewLoading();
    _loadCurrencies();
    _subscribe();
  }

  void reload() => _subscribe();

  void _subscribe() {
    _subscription?.cancel();
    _subscription = repository.watchAll().listen(
      (goals) {
        if (_disposed) return;
        state.value = ViewData(goals);
      },
      onError: (Object _) {
        if (_disposed) return;
        state.value = const ViewError(DomainErrorCode.storageFailure);
      },
    );
  }

  Future<void> _loadCurrencies() async {
    try {
      final list = await currencyRepository.watchAll().first;
      currencies.value = {for (final currency in list) currency.code: currency};
    } on Exception {
      // Валюты не блокируют список.
    }
  }

  String formatTarget(FinancialGoal goal) => const MoneyFormatter().format(
    goal.targetAmount,
    currencies.value[goal.targetAmount.currencyCode] ??
        Currency(
          code: goal.targetAmount.currencyCode,
          name: goal.targetAmount.currencyCode,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        ),
  );

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
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

  List<Asset> eligibleAssets(GoalCategory category) => [
    for (final asset in assets.value)
      if (category == GoalCategory.accounts
          ? asset is AccountAsset
          : asset is InvestmentAsset)
        asset,
  ];

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
