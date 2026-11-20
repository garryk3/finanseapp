import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

enum AssetComparisonMode { absolute, normalized }

/// Сравнение 2–5 активов: absolute Money или normalized (100 на старте).
final class AssetComparisonSeries {
  const AssetComparisonSeries({
    required this.asset,
    required this.points,
    required this.values,
  });

  final Asset asset;
  final List<NetWorthPoint> points;
  final List<double> values;
}

final class AssetComparisonViewModel {
  AssetComparisonViewModel({
    required this.queries,
    required this.assetRepository,
    required this.settingsRepository,
    required this.now,
  });

  final AnalyticsQueries queries;
  final AssetRepository assetRepository;
  final SettingsRepository settingsRepository;
  final LocalDate Function() now;

  static const minAssets = 2;
  static const maxAssets = 5;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<Asset>> assets = signal(const []);
  final Signal<Set<int>> selected = signal(const {});
  final Signal<AnalyticsPeriod> period = signal(AnalyticsPeriod.month);
  final Signal<AssetComparisonMode> mode = signal(AssetComparisonMode.absolute);
  final Signal<List<AssetComparisonSeries>> series = signal(const []);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<String?> error = signal(null);
  final Signal<bool> busy = signal(false);
  Map<int, List<NetWorthPoint>> _raw = const {};
  int _requestId = 0;
  bool _disposed = false;

  bool get canSelectMore => selected.value.length < maxAssets;
  bool get ready => selected.value.length >= minAssets;

  Future<void> init() async {
    state.value = const ViewLoading();
    try {
      baseCurrency.value = await settingsRepository.getBaseCurrency();
      final list = await assetRepository.watchAll(includeArchived: true).first;
      assets.value = [
        for (final snapshot in list)
          if (snapshot.asset.archivedAt == null) snapshot.asset,
      ];
      if (selected.value.isEmpty) {
        selected.value = {
          for (final asset in assets.value.take(minAssets)) asset.id,
        };
      }
      await reload();
    } on DomainException catch (exception) {
      error.value = exception.code.name;
      state.value = const ViewError(DomainErrorCode.storageFailure);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  void toggleAsset(int id) {
    final current = {...selected.value};
    if (current.contains(id)) {
      if (current.length <= minAssets) return;
      current.remove(id);
    } else {
      if (current.length >= maxAssets) return;
      current.add(id);
    }
    selected.value = current;
    reload();
  }

  void setPeriod(AnalyticsPeriod value) {
    period.value = value;
    reload();
  }

  void setMode(AssetComparisonMode value) {
    mode.value = value;
    _emit();
  }

  Future<void> reload() async {
    error.value = null;
    final ids = selected.value;
    if (ids.length < minAssets) {
      _raw = const {};
      series.value = const [];
      state.value = const ViewData(null);
      return;
    }
    final request = ++_requestId;
    busy.value = true;
    try {
      if (baseCurrency.value == null) {
        baseCurrency.value = await settingsRepository.getBaseCurrency();
      }
      final selectedAssets = [
        for (final asset in assets.value)
          if (ids.contains(asset.id)) asset,
      ];
      final earliest = period.value == AnalyticsPeriod.all
          ? selectedAssets
                .map(
                  (asset) => LocalDate.fromDateTime(asset.createdAt.toLocal()),
                )
                .reduce(
                  (left, right) => left.compareTo(right) <= 0 ? left : right,
                )
          : null;
      final range = analyticsRange(
        period: period.value,
        today: now(),
        earliest: earliest,
      );
      final raw = <int, List<NetWorthPoint>>{};
      for (final asset in assets.value) {
        if (!ids.contains(asset.id)) continue;
        final points = await queries.netWorthSeries(
          period: range,
          assetId: asset.id,
        );
        if (_disposed || request != _requestId) return;
        raw[asset.id] = points;
      }
      if (_disposed || request != _requestId) return;
      _raw = raw;
      _emit();
      state.value = const ViewData(null);
    } on DomainException catch (exception) {
      error.value = exception.code.name;
      state.value = ViewError(exception.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    } finally {
      busy.value = false;
    }
  }

  /// Выравнивает серии по union дат: стоимость между событиями не меняется,
  /// до создания актива — ноль, поэтому точки сопоставимы по датам.
  void _emit() {
    final base = baseCurrency.value;
    if (base == null || _raw.isEmpty) {
      series.value = const [];
      return;
    }
    final dates = <LocalDate>{
      for (final points in _raw.values)
        for (final point in points) point.date,
    }.toList()..sort();
    final aligned = <AssetComparisonSeries>[];
    for (final asset in assets.value) {
      final raw = _raw[asset.id];
      if (raw == null) continue;
      final points = <NetWorthPoint>[];
      var cursor = -1;
      for (final date in dates) {
        while (cursor + 1 < raw.length &&
            raw[cursor + 1].date.compareTo(date) <= 0) {
          cursor++;
        }
        points.add(
          NetWorthPoint(
            date: date,
            value: cursor < 0
                ? Money(minorUnits: 0, currencyCode: base.code)
                : raw[cursor].value,
          ),
        );
      }
      aligned.add(
        AssetComparisonSeries(
          asset: asset,
          points: points,
          values: _values(points, base),
        ),
      );
    }
    series.value = aligned;
  }

  List<double> _values(List<NetWorthPoint> points, Currency base) {
    if (mode.value == AssetComparisonMode.absolute) {
      return [
        for (final point in points)
          MoneyMath.toDecimal(point.value, base).toDouble(),
      ];
    }
    final first = points
        .map((point) => point.value.minorUnits)
        .where((value) => value != 0)
        .firstOrNull;
    if (first == null) return [for (final _ in points) 0.0];
    return [
      for (final point in points)
        (point.value.minorUnits / first * 100).toDouble(),
    ];
  }

  String valueText(AssetComparisonSeries item, int index) {
    if (mode.value == AssetComparisonMode.normalized) {
      return '${item.values[index].round()}%';
    }
    return const MoneyFormatter().format(
      item.points[index].value,
      _currency(item.points[index].value.currencyCode),
    );
  }

  String lastValueText(AssetComparisonSeries item) {
    if (item.points.isEmpty) return '—';
    return valueText(item, item.points.length - 1);
  }

  Currency _currency(String code) => baseCurrency.value?.code == code
      ? baseCurrency.value!
      : Currency(
          code: code,
          name: code,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        );

  void dispose() {
    _disposed = true;
    _requestId++;
  }
}
