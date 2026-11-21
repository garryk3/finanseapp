import 'dart:async';

import 'dart:developer' as developer;

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_schedule.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Список ежемесячных платежей: правила, следующий платёж и ожидание курса.
class RecurringRulesViewModel {
  RecurringRulesViewModel({
    required this.repository,
    required this.categoryRepository,
    required this.currencyRepository,
    required this.assetRepository,
    required this.rateRepository,
    required this.today,
  });

  final RecurringRepository repository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;
  final AssetRepository assetRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;

  final Signal<ViewState<List<RecurringRule>>> state = signal(
    const ViewLoading(),
  );
  final Signal<Map<int, String>> categoryNames = signal(const {});
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<Map<int, Asset>> assets = signal(const {});
  final Signal<Set<int>> ratePending = signal(const {});

  StreamSubscription<List<RecurringRule>>? _subscription;
  bool _disposed = false;
  int _pendingGeneration = 0;

  void init() {
    state.value = const ViewLoading();
    _loadReferences();
    _subscribe();
  }

  void reload() => _subscribe();

  void _subscribe() {
    _subscription?.cancel();
    _subscription = repository.watchActive().listen(
      (rules) {
        if (_disposed) return;
        final sorted = [...rules]..sort(_compareByNextPayment);
        state.value = ViewData(sorted);
        _computePending(sorted);
      },
      onError: (Object _) {
        if (_disposed) return;
        state.value = const ViewError(DomainErrorCode.storageFailure);
      },
    );
  }

  int _compareByNextPayment(RecurringRule left, RecurringRule right) {
    final leftNext = nextPayment(left);
    final rightNext = nextPayment(right);
    if (leftNext == null && rightNext == null) {
      return left.id.compareTo(right.id);
    }
    if (leftNext == null) return 1;
    if (rightNext == null) return -1;
    final byDate = leftNext.compareTo(rightNext);
    return byDate != 0 ? byDate : left.id.compareTo(right.id);
  }

  /// Ближайший невыполненный платёж правила (включая просроченный).
  LocalDate? nextPayment(RecurringRule rule) => RecurringSchedule.nextPayment(
    startDate: rule.startDate,
    endDate: rule.endDate,
    lastGeneratedPeriod: rule.lastGeneratedPeriod,
    firstPeriodOffset: rule.strategy == RecurringStrategy.fixed ? 0 : 1,
  );

  bool isAuto(RecurringRule rule) =>
      rule.strategy == RecurringStrategy.depositInterest;

  String categoryName(int id) => categoryNames.value[id] ?? '—';

  String assetName(RecurringRule rule) {
    final targetId = rule.accountId ?? rule.propertyId;
    if (targetId == null) return '';
    return assets.value[targetId]?.name ?? '';
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

  String formatAmount(RecurringRule rule) {
    final amount = rule.amount;
    if (amount == null) return '—';
    return const MoneyFormatter().format(
      amount,
      currencyOf(amount.currencyCode),
    );
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
  }

  Future<void> _loadReferences() async {
    try {
      final income = await categoryRepository
          .watchByKind(CashflowKind.income, includeArchived: true)
          .first;
      final expense = await categoryRepository
          .watchByKind(CashflowKind.expense, includeArchived: true)
          .first;
      final all = [...income, ...expense];
      if (_disposed) return;
      categoryNames.value = {
        for (final category in all) category.id: category.name,
      };
      final list = await currencyRepository.watchAll().first;
      if (_disposed) return;
      currencies.value = {for (final currency in list) currency.code: currency};
      final snapshots = await assetRepository
          .watchAll(includeArchived: true)
          .first;
      if (_disposed) return;
      assets.value = {
        for (final snapshot in snapshots) snapshot.asset.id: snapshot.asset,
      };
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Не удалось загрузить справочники регулярных платежей',
        name: 'recurring.rules',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _computePending(List<RecurringRule> rules) async {
    final generation = ++_pendingGeneration;
    final pending = <int>{};
    for (final rule in rules) {
      if (rule.currencyCode == 'RUB') continue;
      final next = nextPayment(rule);
      if (next == null || next.compareTo(today) > 0) continue;
      final rate = await rateRepository.find(rule.currencyCode, next);
      if (rate == null) pending.add(rule.id);
    }
    if (_disposed || generation != _pendingGeneration) return;
    ratePending.value = pending;
  }
}
