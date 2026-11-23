import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/logic/net_worth_calculator.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Список активов: реактивные снапшоты, поиск/вид/архив, base equivalent.
class AssetsViewModel {
  AssetsViewModel({
    required this.repository,
    required this.currencyRepository,
    required this.settingsRepository,
    required this.rateRepository,
    required this.today,
  });

  final AssetRepository repository;
  final CurrencyRepository currencyRepository;
  final SettingsRepository settingsRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;

  final Signal<ViewState<List<AssetSnapshot>>> state = signal(
    const ViewLoading(),
  );
  final Signal<String> query = signal('');
  final Signal<AssetKind?> kind = signal(null);
  final Signal<bool> showArchived = signal(false);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<int> total = signal(0);
  final Signal<Map<AssetKind, int>> kindCounts = signal(const {});

  final Map<String, Decimal> _rateCache = {};
  List<AssetSnapshot> _all = const [];
  StreamSubscription<List<AssetSnapshot>>? _subscription;
  StreamSubscription<Currency>? _baseSubscription;
  StreamSubscription<List<Currency>>? _currencySubscription;
  bool _disposed = false;
  bool _referencesReady = false;
  bool _hasData = false;

  bool get filtersActive =>
      query.value.trim().isNotEmpty || kind.value != null || showArchived.value;

  void init() {
    _cancelSubscriptions();
    state.value = const ViewLoading();
    _loadReferences();
    _baseSubscription = settingsRepository.watchBaseCurrency().listen((base) {
      baseCurrency.value = base;
      _ensureRates().then((_) => _emit());
    }, onError: (Object _) {});
    _currencySubscription = currencyRepository.watchAll().listen((list) {
      currencies.value = {for (final currency in list) currency.code: currency};
      _emit();
    }, onError: (Object _) {});
    _subscription = repository
        .watchAll(includeArchived: true)
        .listen(
          _onData,
          onError: (Object _) {
            if (_disposed) return;
            state.value = const ViewError(DomainErrorCode.storageFailure);
          },
        );
  }

  Future<void> _loadReferences() async {
    try {
      final list = await currencyRepository.getEnabled();
      currencies.value = {for (final currency in list) currency.code: currency};
      baseCurrency.value = await settingsRepository.getBaseCurrency();
      _referencesReady = true;
      await _ensureRates();
      _emit();
    } on Exception {
      // Справочники не блокируют список: суммы показываются по коду валюты.
      _referencesReady = true;
      _emit();
    }
  }

  Future<void> _onData(List<AssetSnapshot> snapshots) async {
    if (_disposed) return;
    _all = snapshots;
    total.value = snapshots.length;
    _hasData = true;
    await _ensureRates();
    _emit();
  }

  Future<void> _ensureRates() async {
    final codes = {
      for (final snapshot in _all)
        for (final money in snapshot.breakdown) money.currencyCode,
      if (baseCurrency.value != null) baseCurrency.value!.code,
    };
    final missing = [
      for (final code in codes)
        if (code != 'RUB' && !_rateCache.containsKey(code)) code,
    ];
    if (missing.isEmpty) return;
    for (final code in missing) {
      try {
        final rate = await rateRepository.find(code, today);
        if (rate != null) _rateCache[code] = rate.rateToRub;
      } on Exception {
        // Нет кэша курса — base equivalent не показывается.
      }
    }
  }

  void _emit() {
    if (_disposed || !_referencesReady || !_hasData) return;
    final search = query.value.trim().toLowerCase();
    final selectedKind = kind.value;
    final archived = showArchived.value;
    final counts = <AssetKind, int>{
      for (final value in AssetKind.values) value: 0,
    };
    for (final snapshot in _all) {
      if (!archived && snapshot.asset.archivedAt != null) continue;
      counts[snapshot.asset.kind] = counts[snapshot.asset.kind]! + 1;
    }
    kindCounts.value = counts;
    state.value = ViewData([
      for (final snapshot in _all)
        if ((archived || snapshot.asset.archivedAt == null) &&
            (selectedKind == null || snapshot.asset.kind == selectedKind) &&
            (search.isEmpty ||
                snapshot.asset.name.toLowerCase().contains(search)))
          snapshot,
    ]);
  }

  void setQuery(String value) {
    query.value = value;
    _emit();
  }

  void setKind(AssetKind? value) {
    kind.value = value;
    _emit();
  }

  void setShowArchived(bool value) {
    showArchived.value = value;
    _emit();
  }

  void resetFilters() {
    query.value = '';
    kind.value = null;
    showArchived.value = false;
    _emit();
  }

  /// Форматирование суммы валютой актива (fractionDigits из справочника).
  String formatAmount(Money money) =>
      const MoneyFormatter().format(money, currencyOf(money.currencyCode));

  /// Эквивалент в базовой валюте: текст, «нет курса» или совпадение валют.
  ///
  /// Мультивалютная инвестиция суммируется по `breakdown` через
  /// [NetWorthCalculator] и показывается даже при совпадении базовой валюты с
  /// основной валютой актива.
  ({String? text, bool unavailable}) baseEquivalent(AssetSnapshot snapshot) {
    final base = baseCurrency.value;
    if (base == null) return (text: null, unavailable: false);
    final breakdown = snapshot.breakdown;
    if (breakdown.length == 1 && base.code == breakdown.single.currencyCode) {
      return (text: null, unavailable: false);
    }
    final needsConversion = breakdown.any(
      (money) => money.currencyCode != base.code,
    );
    final rates = <String, Decimal>{};
    if (needsConversion) {
      for (final money in breakdown) {
        if (money.currencyCode == base.code) continue;
        final rate = money.currencyCode == 'RUB'
            ? Decimal.one
            : _rateCache[money.currencyCode];
        if (rate == null) return (text: null, unavailable: true);
        rates[money.currencyCode] = rate;
      }
      if (base.code != 'RUB') {
        final baseRate = _rateCache[base.code];
        if (baseRate == null) return (text: null, unavailable: true);
        rates[base.code] = baseRate;
      }
    }
    try {
      final summary = NetWorthCalculator.calculate(
        assets: [
          for (final money in breakdown)
            NetWorthAssetValue(
              kind: snapshot.asset.kind,
              value: money,
              currency: currencyOf(money.currencyCode),
            ),
        ],
        ratesToRub: rates,
        baseCurrency: base,
      );
      return (
        text: const MoneyFormatter().format(summary.total, base),
        unavailable: false,
      );
    } on DomainException {
      return (text: null, unavailable: true);
    }
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

  void retry() => init();

  Future<void> _cancelSubscriptions() {
    final pending = <Future<void>>[
      if (_subscription != null) _subscription!.cancel(),
      if (_baseSubscription != null) _baseSubscription!.cancel(),
      if (_currencySubscription != null) _currencySubscription!.cancel(),
    ];
    _subscription = null;
    _baseSubscription = null;
    _currencySubscription = null;
    return Future.wait(pending);
  }

  Future<void> dispose() async {
    _disposed = true;
    await _cancelSubscriptions();
  }
}
