import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/logic/net_worth_calculator.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_events.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_resolver.dart';
import 'package:finanseapp/core/features/dashboard/logic/safety_cushion.dart';
import 'package:finanseapp/core/features/dashboard/logic/tax_estimate.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/domain/goal_progress.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/goals/logic/calculate_goal_progress.dart';
import 'package:finanseapp/core/features/goals/logic/goal_calculator.dart';
import 'package:finanseapp/core/features/settings/domain/display_settings_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:rational/rational.dart';
import 'package:signals/signals.dart';

/// Цель на главной с прогрессом (статус может быть вычислен, не записан).
final class DashboardGoal {
  const DashboardGoal({
    required this.goal,
    required this.progress,
    required this.displayStatus,
  });

  final FinancialGoal goal;
  final GoalProgress? progress;
  final GoalStatus displayStatus;
}

/// Главная: net worth, цели и последние операции (10.1).
class DashboardViewModel {
  DashboardViewModel({
    required this.queries,
    required this.goalRepository,
    required this.assetRepository,
    required this.transactionRepository,
    required this.cashflowRepository,
    required this.settingsRepository,
    required this.displaySettings,
    required this.currencyRepository,
    required this.rateRepository,
    required this.categoryRepository,
    required this.now,
  });

  final AnalyticsQueries queries;
  final GoalRepository goalRepository;
  final AssetRepository assetRepository;
  final AssetTransactionRepository transactionRepository;
  final CashflowRepository cashflowRepository;
  final SettingsRepository settingsRepository;
  final DisplaySettingsRepository displaySettings;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final CategoryRepository categoryRepository;
  final LocalDate Function() now;

  static const recentLimit = 5;

  /// Категория доходов, проценты по вкладам (D21.6/X1).
  static const depositInterestCategoryName = 'Проценты по вкладу';

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<NetWorthSummary?> netWorth = signal(null);
  final Signal<DomainErrorCode?> netWorthError = signal(null);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<List<DashboardGoal>> goals = signal(const []);
  final Signal<List<AssetTransaction>> recentOperations = signal(const []);
  final Signal<Map<int, String>> assetNames = signal(const {});
  final Signal<CashflowSummary?> cashflowSummary = signal(null);
  final Signal<List<CashflowPeriodPoint>> cashflowPoints = signal(const []);
  final Signal<DomainErrorCode?> cashflowError = signal(null);
  final Signal<LocalDate> today = signal(
    LocalDate.fromDateTime(DateTime.now()),
  );

  /// Неархивные счета с истёкшим сроком окончания (today > endDate).
  final Signal<List<AccountAsset>> overdueAccounts = signal(const []);

  /// Подушка безопасности; null — нет расходов/счетов/курса.
  final Signal<SafetyCushion?> safetyCushion = signal(null);

  /// Неустранимая ошибка курса в подушке (D21.5/S5); блок остаётся видимым
  /// с inline-состоянием («Курс недоступен» + повторить) вместо исчезновения.
  final Signal<DomainErrorCode?> safetyCushionError = signal(null);

  /// Предполагаемый налог с процентов по вкладам за год (D21.6);
  /// null — нет счетов/расчёта или ошибка (см. [taxError]).
  final Signal<TaxEstimate?> taxEstimate = signal(null);

  /// Ставка налога, % (D21.6/X2); начальное значение — из настройки.
  final Signal<int> taxRatePercent = signal(defaultTaxRatePercent);

  /// Причина, по которой [taxEstimate] не посчитан (D21.6/X5).
  final Signal<DomainErrorCode?> taxError = signal(null);

  /// Самая свежая дата резервного курса, использованного на Главной
  /// (BR-C-9/C4); null — все курсы актуальны, плашка скрыта.
  final Signal<LocalDate?> staleRateDate = signal(null);

  /// Есть ли у неархивных инвестиций отметки заблокированных сумм.
  final Signal<bool> hasLockedAssets = signal(false);

  /// Сумма заблокированных активов в базовой валюте; null — нет расчёта.
  final Signal<Money?> lockedTotal = signal(null);

  /// Доля заблокированных от инвестиций (0..1, scale 4); null — нет данных.
  final Signal<Decimal?> lockedShare = signal(null);

  /// Причина, по которой [lockedTotal] не посчитан.
  final Signal<DomainErrorCode?> lockedError = signal(null);

  /// Скрыты ли денежные суммы на Главной (D21.4).
  ///
  /// Начальное значение берётся из настройки «скрывать суммы при входе»;
  /// иконка на Главной переключает только текущую сессию (не персистится).
  final Signal<bool> amountsHidden = signal(false);

  final CalculateGoalProgress _goalCalculator = const CalculateGoalProgress();
  final Map<String, Decimal> _rateCache = {};
  final Map<String, LocalDate> _rateStaleDates = {};

  List<FinancialGoal> _goals = const [];
  Map<int, AssetSnapshot> _snapshots = const {};
  Map<String, Currency> _currencies = const {};
  int _goalToken = 0;
  int _netWorthToken = 0;
  int _cashflowToken = 0;
  int _lockedToken = 0;
  bool _assetsReady = false;
  bool _fatal = false;
  bool _netWorthReady = false;
  bool _cashflowReady = false;
  bool _goalsReady = false;
  bool _transactionsReady = false;
  bool _disposed = false;

  StreamSubscription<List<AssetSnapshot>>? _assetsSubscription;
  StreamSubscription<List<FinancialGoal>>? _goalsSubscription;
  StreamSubscription<List<AssetTransaction>>? _transactionsSubscription;
  StreamSubscription<Currency>? _baseSubscription;
  StreamSubscription<List<CashflowEntry>>? _cashflowSubscription;
  StreamSubscription<List<CashflowEntry>>? _safetySubscription;
  StreamSubscription<List<CashflowEntry>>? _taxSubscription;
  StreamSubscription<List<Currency>>? _currenciesSubscription;
  EffectCleanup? _rateCleanup;

  CashflowSummary? _safetySummary;
  Money? _safetyCash;
  DomainErrorCode? _safetyCashError;
  DomainErrorCode? _safetyFlowError;
  int _safetyToken = 0;
  bool _safetyReady = false;

  Money? _taxBase;
  int _taxToken = 0;
  bool _taxReady = false;

  LocalDate? _staleNetWorth;
  LocalDate? _staleLocked;
  LocalDate? _staleCashflow;
  LocalDate? _staleSafety;
  LocalDate? _staleTax;

  void init() {
    today.value = now();
    amountsHidden.value = false;
    unawaited(_loadAmountsHidden());
    _rateCache.clear();
    _rateStaleDates.clear();
    staleRateDate.value = null;
    _staleNetWorth = null;
    _staleLocked = null;
    _staleCashflow = null;
    _staleSafety = null;
    _staleTax = null;
    _assetsReady = false;
    _fatal = false;
    _netWorthReady = false;
    _cashflowReady = false;
    _goalsReady = false;
    _transactionsReady = false;
    state.value = const ViewLoading();
    netWorthError.value = null;
    lockedError.value = null;
    hasLockedAssets.value = false;
    lockedTotal.value = null;
    lockedShare.value = null;
    _lockedToken++;
    _subscribeCurrencies();
    _subscribeBaseCurrency();
    cashflowError.value = null;
    _rateCleanup?.call();
    var seenRateRevision = exchangeRateRevision.value;
    _rateCleanup = exchangeRateRevision.subscribe((revision) {
      if (_disposed || revision == seenRateRevision) return;
      seenRateRevision = revision;
      _rateCache.clear();
      _rateStaleDates.clear();
      unawaited(_reloadNetWorth());
      unawaited(_reloadLocked());
      unawaited(_reloadCashflow());
      unawaited(_reloadSafety());
      unawaited(_reloadTax());
      unawaited(_recomputeGoals());
    });
    _cashflowSubscription?.cancel();
    _cashflowSubscription = cashflowRepository
        .watch(CashflowFilter(period: _monthRange))
        .listen(
          (_) => unawaited(_reloadCashflow()),
          onError: _failLocalCashflow,
        );
    _safetySummary = null;
    _safetyCash = null;
    _safetyCashError = null;
    _safetyFlowError = null;
    _safetyReady = false;
    safetyCushion.value = null;
    safetyCushionError.value = null;
    _safetySubscription?.cancel();
    _safetySubscription = cashflowRepository
        .watch(CashflowFilter(period: _safetyRange))
        .listen((_) => unawaited(_reloadSafety()), onError: _failLocalSafety);
    unawaited(_reloadSafety());
    _taxBase = null;
    _taxReady = false;
    taxEstimate.value = null;
    taxError.value = null;
    _taxSubscription?.cancel();
    _taxSubscription = cashflowRepository
        .watch(CashflowFilter(period: _taxRange))
        .listen(
          (_) => unawaited(_reloadTax()),
          onError: (_) => _failLocalTax(),
        );
    unawaited(_loadTaxRate());
    unawaited(_reloadTax());
    _assetsSubscription?.cancel();
    _assetsSubscription = assetRepository
        .watchAll(includeArchived: true)
        .listen((snapshots) {
          _assetsReady = true;
          _snapshots = {
            for (final snapshot in snapshots) snapshot.asset.id: snapshot,
          };
          _updateOverdueAccounts(snapshots);
          unawaited(_reloadSafety());
          unawaited(_reloadTax());
          assetNames.value = {
            for (final snapshot in snapshots)
              snapshot.asset.id: snapshot.asset.name,
          };
          unawaited(_recomputeGoals());
          unawaited(_reloadNetWorth());
          unawaited(_reloadLocked());
        }, onError: _fail);
    _goalsSubscription?.cancel();
    _goalsSubscription = goalRepository.watchAll().listen((goals) {
      _goals = goals;
      _goalsReady = true;
      unawaited(_recomputeGoals());
    }, onError: _fail);
    _transactionsSubscription?.cancel();
    _transactionsSubscription = transactionRepository
        .watch(const TransactionFilter())
        .listen((operations) {
          recentOperations.value = operations.take(recentLimit).toList();
          _transactionsReady = true;
          _emit();
        }, onError: _fail);
  }

  /// Начальное состояние блюра — из настройки (D21.4/H5).
  Future<void> _loadAmountsHidden() async {
    try {
      final hidden = await displaySettings.getAmountsHidden();
      if (_disposed) return;
      amountsHidden.value = hidden;
    } on Object {
      // Настройка недоступна — оставляем суммы видимыми.
    }
  }

  /// Переключить блюр сумм на текущую сессию (не персистится).
  void toggleAmountsHidden() => amountsHidden.value = !amountsHidden.value;

  void _updateOverdueAccounts(List<AssetSnapshot> snapshots) {
    final today = this.today.value;
    final overdue = <AccountAsset>[];
    for (final snapshot in snapshots) {
      final asset = snapshot.asset;
      if (asset is! AccountAsset) continue;
      final endDate = asset.endDate;
      if (asset.archivedAt != null || endDate == null) continue;
      if (today.compareTo(endDate) > 0) overdue.add(asset);
    }
    overdue.sort((a, b) {
      final byDate = a.endDate!.compareTo(b.endDate!);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    overdueAccounts.value = overdue;
  }

  /// Справочник валют обновляется подпиской: кастомная валюта, добавленная
  /// после старта, должна попасть в подушку/заблокированные/прогресс целей.
  void _subscribeCurrencies() {
    _currenciesSubscription?.cancel();
    _currenciesSubscription = currencyRepository.watchAll().listen(
      (list) {
        _currencies = {for (final currency in list) currency.code: currency};
        unawaited(_recomputeGoals());
        unawaited(_reloadLocked());
        unawaited(_reloadSafety());
      },
      onError: (_) {
        // Итоги показываются без эквивалента, если справочник недоступен.
      },
    );
  }

  void _subscribeBaseCurrency() {
    _baseSubscription?.cancel();
    _baseSubscription = settingsRepository.watchBaseCurrency().listen((
      currency,
    ) {
      baseCurrency.value = currency;
      unawaited(_reloadCashflow());
      unawaited(_reloadNetWorth());
      unawaited(_reloadLocked());
      unawaited(_reloadSafety());
      unawaited(_reloadTax());
    }, onError: _fail);
  }

  DateRange get cashflowRange =>
      analyticsRange(period: AnalyticsPeriod.month, today: today.value);

  DateRange get _monthRange => cashflowRange;

  /// Три полных месяца до текущего (например, для 23.11 — август–октябрь).
  DateRange get _safetyRange {
    final firstOfMonth = DateTime(today.value.year, today.value.month);
    final end = firstOfMonth.subtract(const Duration(days: 1));
    final start = DateTime(end.year, end.month - 2, 1);
    return DateRange(
      start: LocalDate.fromDateTime(start),
      end: LocalDate.fromDateTime(end),
    );
  }

  /// С 1 января текущего года по today (D21.6/X1).
  DateRange get _taxRange {
    final today = this.today.value;
    return DateRange(start: LocalDate(today.year, 1, 1), end: today);
  }

  Future<void> _reloadCashflow() async {
    final token = ++_cashflowToken;
    final filter = CashflowFilter(period: _monthRange);
    try {
      final summary = await queries.cashflow(filter);
      final points = await queries.cashflowSeries(filter);
      if (_disposed || token != _cashflowToken) return;
      cashflowSummary.value = summary;
      cashflowPoints.value = points;
      cashflowError.value = null;
      _staleCashflow = summary.staleRateDate;
      _recomputeStaleRateDate();
      _cashflowReady = true;
      _emit();
    } on DomainException catch (error) {
      if (_disposed || token != _cashflowToken) return;
      cashflowError.value = error.code;
      _staleCashflow = null;
      _recomputeStaleRateDate();
      _cashflowReady = true;
      _emit();
    } on Exception {
      if (_disposed || token != _cashflowToken) return;
      cashflowError.value = DomainErrorCode.storageFailure;
      _staleCashflow = null;
      _recomputeStaleRateDate();
      _cashflowReady = true;
      _emit();
    }
  }

  void _failLocalCashflow(Object _) {
    if (_disposed) return;
    cashflowError.value = DomainErrorCode.storageFailure;
    _staleCashflow = null;
    _recomputeStaleRateDate();
    _cashflowReady = true;
    _emit();
  }

  Future<void> _reloadSafety() async {
    final token = ++_safetyToken;
    final base = baseCurrency.value;
    if (!_hasActiveAccounts || base == null) {
      // S3: без неархивных счетов блок законно скрыт.
      _safetyCash = null;
      _safetySummary = null;
      _safetyCashError = null;
      _safetyFlowError = null;
      _staleSafety = null;
      safetyCushion.value = null;
      safetyCushionError.value = null;
      _safetyReady = true;
      _recomputeStaleRateDate();
      _emit();
      return;
    }
    Money? cash;
    LocalDate? cashStale;
    DomainErrorCode? cashError;
    try {
      final resolved = await _cashInBase(base);
      cash = resolved.cash;
      cashStale = resolved.stale;
    } on DomainException catch (error) {
      cashError = error.code;
    } on Exception {
      cashError = DomainErrorCode.storageFailure;
    }
    if (_disposed || token != _safetyToken) return;
    CashflowSummary? summary;
    DomainErrorCode? flowError;
    try {
      summary = await queries.cashflow(CashflowFilter(period: _safetyRange));
    } on DomainException catch (error) {
      flowError = error.code;
    } on Exception {
      flowError = DomainErrorCode.storageFailure;
    }
    if (_disposed || token != _safetyToken) return;
    _safetyCash = cash;
    _safetyCashError = cashError;
    _safetySummary = summary;
    _safetyFlowError = flowError;
    _staleSafety = cashError == null && flowError == null
        ? _laterNullable(cashStale, summary?.staleRateDate)
        : null;
    _safetyReady = true;
    _recomputeStaleRateDate();
    _recomputeSafety();
    _emit();
  }

  void _failLocalSafety(Object _) {
    if (_disposed) return;
    _safetyCash = null;
    _safetySummary = null;
    _safetyCashError = null;
    _safetyFlowError = DomainErrorCode.storageFailure;
    _staleSafety = null;
    _safetyReady = true;
    _recomputeStaleRateDate();
    _recomputeSafety();
    _emit();
  }

  bool get _hasActiveAccounts => _snapshots.values.any(
    (snapshot) =>
        snapshot.asset is AccountAsset && snapshot.asset.archivedAt == null,
  );

  void _recomputeSafety() {
    final error = _safetyCashError ?? _safetyFlowError;
    if (error != null) {
      safetyCushion.value = null;
      // S5: неустранимая ошибка курса оставляет блок с inline-состоянием;
      // прочие ошибки (хранилище) блок скрывают (S3).
      safetyCushionError.value = error == DomainErrorCode.rateUnavailable
          ? error
          : null;
      return;
    }
    safetyCushionError.value = null;
    final cash = _safetyCash;
    final summary = _safetySummary;
    if (cash == null || summary == null || !_hasActiveAccounts) {
      safetyCushion.value = null;
      return;
    }
    safetyCushion.value = SafetyCushion.calculate(
      cash: cash,
      lastThreeMonths: summary,
    );
  }

  /// Ставка налога из настройки; отсутствие ключа — дефолт (D21.6/X2).
  Future<void> _loadTaxRate() async {
    try {
      final percent = await settingsRepository.getTaxRatePercent();
      if (_disposed) return;
      taxRatePercent.value = percent;
      _recomputeTax();
    } on Object {
      // Настройка недоступна — оставляем дефолт.
    }
  }

  /// Сумма процентов по вкладам за текущий год в базовой валюте (D21.6/X1).
  ///
  /// Блок скрыт без неархивных счетов (X3); ошибка курса не скрывает блок, а
  /// переводит его в inline-состояние (X5).
  Future<void> _reloadTax() async {
    final token = ++_taxToken;
    if (!_hasActiveAccounts) {
      _taxBase = null;
      _staleTax = null;
      taxEstimate.value = null;
      taxError.value = null;
      _recomputeStaleRateDate();
      _taxReady = true;
      _emit();
      return;
    }
    try {
      final categoryId = await categoryRepository.findActiveIdByName(
        depositInterestCategoryName,
        CashflowKind.income,
      );
      LocalDate? stale;
      final Money base;
      if (categoryId == null) {
        base = Money(
          minorUnits: 0,
          currencyCode: baseCurrency.value?.code ?? Currency.rubCode,
        );
      } else {
        final summary = await queries.cashflow(
          CashflowFilter(
            period: _taxRange,
            kind: CashflowKind.income,
            categoryId: categoryId,
          ),
        );
        base = summary.income;
        // BR-C-9/C4: проценты могли быть сконвертированы резервным курсом —
        // дату нужно учесть в плашке Главной.
        stale = summary.staleRateDate;
      }
      if (_disposed || token != _taxToken) return;
      _taxBase = base;
      _staleTax = stale;
      taxError.value = null;
      _recomputeStaleRateDate();
      _recomputeTax();
      _taxReady = true;
      _emit();
    } on DomainException catch (error) {
      if (_disposed || token != _taxToken) return;
      _taxBase = null;
      _staleTax = null;
      taxEstimate.value = null;
      taxError.value = error.code;
      _recomputeStaleRateDate();
      _taxReady = true;
      _emit();
    } on Exception {
      if (_disposed || token != _taxToken) return;
      _taxBase = null;
      _staleTax = null;
      taxEstimate.value = null;
      taxError.value = DomainErrorCode.storageFailure;
      _recomputeStaleRateDate();
      _taxReady = true;
      _emit();
    }
  }

  void _failLocalTax() {
    if (_disposed) return;
    _taxBase = null;
    _staleTax = null;
    taxEstimate.value = null;
    taxError.value = DomainErrorCode.storageFailure;
    _recomputeStaleRateDate();
    _taxReady = true;
    _emit();
  }

  /// Пересчитывает налог по текущей базе и ставке без повторного запроса.
  void _recomputeTax() {
    final base = _taxBase;
    if (base == null || taxError.value != null) {
      taxEstimate.value = null;
      return;
    }
    taxEstimate.value = TaxEstimate.calculate(
      base: base,
      ratePercent: taxRatePercent.value,
    );
  }

  /// Меняет ставку налога (D21.6/X2): валидация диапазона, сохранение и
  /// мгновенный пересчёт. Невалидное значение игнорируется.
  Future<void> setTaxRatePercent(int percent) async {
    if (!TaxEstimate.isValidRatePercent(percent)) return;
    if (percent == taxRatePercent.value) return;
    taxRatePercent.value = percent;
    _recomputeTax();
    try {
      await settingsRepository.setTaxRatePercent(percent);
    } on Object {
      // Настройка недоступна — расчёт в текущей сессии остаётся верным.
    }
  }

  Future<void> _reloadNetWorth() async {
    final token = ++_netWorthToken;
    final onDate = today.value;
    try {
      final summary = await queries.netWorth(onDate);
      if (_disposed || token != _netWorthToken) return;
      netWorth.value = summary;
      netWorthError.value = null;
      _staleNetWorth = summary.staleRateDate;
      _recomputeStaleRateDate();
      _netWorthReady = true;
      unawaited(_reloadLocked());
      _emit();
    } on DomainException catch (error) {
      if (_disposed || token != _netWorthToken) return;
      // Недоступный курс не должен скрывать остальные блоки главной.
      netWorthError.value = error.code;
      _staleNetWorth = null;
      _recomputeStaleRateDate();
      _netWorthReady = true;
      unawaited(_reloadLocked());
      _emit();
    } on Exception {
      if (_disposed || token != _netWorthToken) return;
      netWorthError.value = DomainErrorCode.storageFailure;
      _staleNetWorth = null;
      _recomputeStaleRateDate();
      _netWorthReady = true;
      unawaited(_reloadLocked());
      _emit();
    }
  }

  /// Сумма отметок неархивных инвестиций в базовой валюте и их доля.
  ///
  /// Отметки не уменьшают стоимость инвестиции (D4), поэтому это отдельный
  /// информационный расчёт. При нехватке курса сумма не показывается частично.
  Future<void> _reloadLocked() async {
    final token = ++_lockedToken;
    final base = baseCurrency.value;
    var hasLocked = false;
    final marks = <NetWorthAssetValue>[];
    for (final snapshot in _snapshots.values) {
      final asset = snapshot.asset;
      if (asset.archivedAt != null || asset.kind != AssetKind.investment) {
        continue;
      }
      final locked = snapshot.locked;
      if (locked.isEmpty) continue;
      hasLocked = true;
      if (base == null) continue;
      for (final value in locked) {
        final currency = _currencies[value.currencyCode];
        // Справочник ещё не загружен: дождёмся _subscribeCurrencies и пересчёта.
        if (currency == null) return;
        marks.add(
          NetWorthAssetValue(
            kind: AssetKind.investment,
            value: value,
            currency: currency,
          ),
        );
      }
    }
    if (_disposed || token != _lockedToken) return;
    hasLockedAssets.value = hasLocked;
    if (!hasLocked || base == null) {
      lockedTotal.value = null;
      lockedShare.value = null;
      lockedError.value = null;
      return;
    }
    final codes = <String>{
      for (final mark in marks)
        if (mark.currency.code != base.code && !mark.currency.isRub)
          mark.currency.code,
      if (!base.isRub && marks.any((mark) => mark.currency.code != base.code))
        base.code,
    };
    try {
      final resolved = await _resolveRates(codes);
      if (_disposed || token != _lockedToken) return;
      final total = NetWorthCalculator.calculate(
        assets: marks,
        ratesToRub: resolved.rates,
        baseCurrency: base,
      ).total;
      lockedTotal.value = total;
      lockedShare.value = _lockedShareOf(total, base);
      lockedError.value = null;
      _staleLocked = resolved.stale;
      _recomputeStaleRateDate();
    } on DomainException catch (error) {
      if (_disposed || token != _lockedToken) return;
      lockedTotal.value = null;
      lockedShare.value = null;
      lockedError.value = error.code;
      _staleLocked = null;
      _recomputeStaleRateDate();
    } on Exception {
      if (_disposed || token != _lockedToken) return;
      lockedTotal.value = null;
      lockedShare.value = null;
      lockedError.value = DomainErrorCode.storageFailure;
      _staleLocked = null;
      _recomputeStaleRateDate();
    }
  }

  /// Резолвит курсы [codes] к RUB на текущую дату с кэшем и резервным курсом
  /// чтения (BR-C-9); при отсутствии курса вовсе — `rateUnavailable`.
  Future<({Map<String, Decimal> rates, LocalDate? stale})> _resolveRates(
    Set<String> codes,
  ) async {
    final rates = <String, Decimal>{};
    LocalDate? stale;
    for (final code in codes) {
      final cached = _rateCache[code];
      if (cached != null) {
        rates[code] = cached;
        final cachedStale = _rateStaleDates[code];
        if (cachedStale != null) stale = _laterDate(stale, cachedStale);
        continue;
      }
      final resolved = await ExchangeRateResolver.resolve(
        rateRepository,
        code,
        today.value,
      );
      if (resolved == null) {
        throw DomainException(
          DomainErrorCode.rateUnavailable,
          fieldErrors: {'currencyCode': code},
        );
      }
      _rateCache[code] = resolved.rateToRub;
      if (resolved.stale) {
        _rateStaleDates[code] = resolved.effectiveDate;
        stale = _laterDate(stale, resolved.effectiveDate);
      } else {
        _rateStaleDates.remove(code);
      }
      rates[code] = resolved.rateToRub;
    }
    return (rates: rates, stale: stale);
  }

  /// Деньги неархивных счетов в базовой валюте с резервным курсом (S4/D21.5),
  /// независимо от `netWorth`/`netWorthError`.
  Future<({Money cash, LocalDate? stale})> _cashInBase(Currency base) async {
    final accounts = <NetWorthAssetValue>[
      for (final snapshot in _snapshots.values)
        if (snapshot.asset.kind == AssetKind.account &&
            snapshot.asset.archivedAt == null)
          NetWorthAssetValue(
            kind: AssetKind.account,
            value: snapshot.currentValue,
            currency: currencyOf(snapshot.asset.currencyCode),
          ),
    ];
    final codes = <String>{
      for (final account in accounts)
        if (account.currency.code != base.code && !account.currency.isRub)
          account.currency.code,
      if (!base.isRub &&
          accounts.any((account) => account.currency.code != base.code))
        base.code,
    };
    final resolved = await _resolveRates(codes);
    final total = NetWorthCalculator.calculate(
      assets: accounts,
      ratesToRub: resolved.rates,
      baseCurrency: base,
    ).total;
    return (cash: total, stale: resolved.stale);
  }

  /// Самая свежая дата резервного курса среди блоков Главной (BR-C-9/C4).
  void _recomputeStaleRateDate() {
    LocalDate? latest;
    for (final date in [
      _staleNetWorth,
      _staleLocked,
      _staleCashflow,
      _staleSafety,
      _staleTax,
    ]) {
      if (date != null) latest = _laterDate(latest, date);
    }
    staleRateDate.value = latest;
  }

  static LocalDate _laterDate(LocalDate? current, LocalDate candidate) =>
      current == null || candidate.compareTo(current) > 0 ? candidate : current;

  static LocalDate? _laterNullable(LocalDate? a, LocalDate? b) {
    if (a == null) return b;
    if (b == null) return a;
    return _laterDate(a, b);
  }

  Decimal? _lockedShareOf(Money total, Currency base) {
    final summary = netWorthError.value == null ? netWorth.value : null;
    final investment = summary?.byAssetKind[AssetKind.investment];
    if (investment == null ||
        investment.currencyCode != base.code ||
        investment.minorUnits <= 0) {
      return null;
    }
    final ratio =
        Rational.fromInt(total.minorUnits) /
        Rational.fromInt(investment.minorUnits);
    final clamped = ratio < Rational.zero
        ? Rational.zero
        : ratio > Rational.one
        ? Rational.one
        : ratio;
    return clamped.toDecimal(scaleOnInfinitePrecision: 4);
  }

  Future<void> _recomputeGoals() async {
    if (!_assetsReady || _fatal) return;
    final token = ++_goalToken;
    final views = <DashboardGoal>[];
    for (final goal in _goals) {
      final values = <int, List<Money>>{};
      for (final id in goal.assetIds) {
        final snapshot = _snapshots[id];
        if (snapshot != null) values[id] = snapshot.breakdown;
      }
      final progress = await _goalCalculator.load(
        goal: goal,
        assetValues: values,
        currencies: _currencies,
        rateRepository: rateRepository,
        today: today.value,
        rateCache: _rateCache,
      );
      if (_disposed || token != _goalToken) return;
      views.add(
        DashboardGoal(
          goal: goal,
          progress: progress,
          displayStatus: progress == null
              ? goal.status
              : GoalCalculator.resolveStatus(
                  current: goal.status,
                  progress: progress,
                ),
        ),
      );
    }
    if (_disposed || token != _goalToken) return;
    goals.value = views;
    _goalsReady = true;
    _emit();
  }

  void _emit() {
    if (_disposed || _fatal) return;
    if (!_netWorthReady ||
        !_cashflowReady ||
        !_goalsReady ||
        !_transactionsReady ||
        !_safetyReady ||
        !_taxReady) {
      return;
    }
    state.value = const ViewData(null);
  }

  void _fail(Object _) {
    if (_disposed) return;
    _fatal = true;
    state.value = const ViewError(DomainErrorCode.storageFailure);
  }

  void reload() => init();

  Currency currencyOf(String code) =>
      _currencies[code] ??
      baseCurrency.value ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  String formatMoney(Money money) =>
      const MoneyFormatter().format(money, currencyOf(money.currencyCode));

  void dispose() {
    _disposed = true;
    _goalToken++;
    _netWorthToken++;
    _lockedToken++;
    _safetyToken++;
    _taxToken++;
    _assetsSubscription?.cancel();
    _goalsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _cashflowSubscription?.cancel();
    _safetySubscription?.cancel();
    _taxSubscription?.cancel();
    _currenciesSubscription?.cancel();
    _baseSubscription?.cancel();
    _rateCleanup?.call();
    _rateCleanup = null;
  }
}
