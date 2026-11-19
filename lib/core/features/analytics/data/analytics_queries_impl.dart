import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/data/analytics_mappers.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/net_worth_calculator.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_summary.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';

/// Агрегаты итогов: dated-курсы и исторические стоимости (9.1–9.2).
final class AnalyticsQueriesImpl implements AnalyticsQueries {
  const AnalyticsQueriesImpl(
    this._db,
    this._rateRepository,
    this._settingsRepository,
    this._currencyRepository,
  );

  final AppDatabase _db;
  final ExchangeRateRepository _rateRepository;
  final SettingsRepository _settingsRepository;
  final CurrencyRepository _currencyRepository;

  @override
  Future<NetWorthSummary> netWorth(LocalDate onDate) async {
    final data = await _load();
    return _summaryAt(
      data: data,
      onDate: onDate,
      rateCache: <String, Decimal>{},
    );
  }

  @override
  Future<LocalDate?> earliestActivityDate({AssetKind? assetKind}) async {
    final data = await _load();
    final kindById = {for (final asset in data.assets) asset.id: asset.kind};
    LocalDate? earliest;
    void consider(LocalDate date) {
      if (earliest == null || date.compareTo(earliest!) < 0) earliest = date;
    }

    for (final asset in data.assets) {
      if (assetKind != null && asset.kind != assetKind) continue;
      consider(LocalDate.fromDateTime(asset.createdAt.toLocal()));
    }
    for (final transaction in data.transactions) {
      if (transaction.deletedAt != null) continue;
      final kind = kindById[transaction.assetId];
      if (kind == null) continue;
      if (assetKind != null && kind != assetKind) continue;
      consider(transaction.occurredOn);
    }
    for (final valuation in data.valuations) {
      final kind = kindById[valuation.assetId];
      if (kind == null) continue;
      if (assetKind != null && kind != assetKind) continue;
      consider(valuation.effectiveOn);
    }
    return earliest;
  }

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
  }) async {
    final data = await _load();
    final selected = [
      for (final asset in data.assets)
        if (assetKind == null || asset.kind == assetKind) asset,
    ];
    if (selected.isEmpty) return const [];
    final assetIds = {for (final asset in selected) asset.id};

    // Точка на начало периода + даты, где состояние могло измениться:
    // создание/архивация актива, операция, оценка. Один день — одна точка.
    final dates = <LocalDate>{period.start};
    void addDate(LocalDate date) {
      if (period.contains(date)) dates.add(date);
    }

    for (final asset in selected) {
      addDate(LocalDate.fromDateTime(asset.createdAt.toLocal()));
      final archivedAt = asset.archivedAt;
      if (archivedAt != null) {
        addDate(LocalDate.fromDateTime(archivedAt.toLocal()));
      }
    }
    for (final transaction in data.transactions) {
      if (transaction.deletedAt != null) continue;
      if (!assetIds.contains(transaction.assetId)) continue;
      addDate(transaction.occurredOn);
    }
    for (final valuation in data.valuations) {
      if (!assetIds.contains(valuation.assetId)) continue;
      addDate(valuation.effectiveOn);
    }

    final ordered = dates.toList()..sort();
    final rateCache = <String, Decimal>{};
    final points = <NetWorthPoint>[];
    for (final date in ordered) {
      final summary = await _summaryAt(
        data: data,
        onDate: date,
        assetKind: assetKind,
        rateCache: rateCache,
      );
      points.add(NetWorthPoint(date: date, value: summary.total));
    }
    return points;
  }

  Future<NetWorthSummary> _summaryAt({
    required _AnalyticsDataset data,
    required LocalDate onDate,
    required Map<String, Decimal> rateCache,
    AssetKind? assetKind,
  }) async {
    final rates = <String, Decimal>{};
    final values = <NetWorthAssetValue>[];
    for (final asset in data.assets) {
      if (assetKind != null && asset.kind != assetKind) continue;
      if (!AnalyticsMappers.isIncluded(asset, onDate)) continue;
      final currency = data.currencies[asset.currencyCode];
      if (currency == null) {
        throw AnalyticsMappers.currencyNotFound(asset.currencyCode);
      }
      if (asset.currencyCode != data.baseCurrency.code) {
        rates[asset.currencyCode] = await _rateFor(
          asset.currencyCode,
          onDate,
          rateCache,
        );
        rates[data.baseCurrency.code] = await _rateFor(
          data.baseCurrency.code,
          onDate,
          rateCache,
        );
      }
      values.add(
        NetWorthAssetValue(
          kind: asset.kind,
          value: Money(
            minorUnits: AnalyticsMappers.valueMinor(
              asset: asset,
              transactions: data.transactionsByAsset[asset.id] ?? const [],
              valuations: data.valuationsByAsset[asset.id] ?? const [],
              onDate: onDate,
            ),
            currencyCode: asset.currencyCode,
          ),
          currency: currency,
        ),
      );
    }
    return NetWorthCalculator.calculate(
      assets: values,
      ratesToRub: rates,
      baseCurrency: data.baseCurrency,
    );
  }

  Future<Decimal> _rateFor(
    String code,
    LocalDate onDate,
    Map<String, Decimal> cache,
  ) async {
    if (code == Currency.rubCode) return Decimal.one;
    final key = '$code@${onDate.toIsoString()}';
    final cached = cache[key];
    if (cached != null) return cached;
    final rate = await _rateRepository.find(code, onDate);
    if (rate == null) {
      throw DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'currencyCode': code, 'date': onDate.toIsoString()},
      );
    }
    cache[key] = rate.rateToRub;
    return rate.rateToRub;
  }

  Future<_AnalyticsDataset> _load() async {
    final assets = await _db.assetsDao.allRows();
    final baseCurrency = await _settingsRepository.getBaseCurrency();
    final currencies = {
      for (final currency in await _currencyRepository.watchAll().first)
        currency.code: currency,
    };
    final transactions = await _db.transactionsDao.allRows();
    final valuations = await _db.valuationsDao.allRows();
    final transactionsByAsset = <int, List<AssetTransactionRow>>{};
    for (final transaction in transactions) {
      (transactionsByAsset[transaction.assetId] ??= []).add(transaction);
    }
    final valuationsByAsset = <int, List<AssetValuationRow>>{};
    for (final valuation in valuations) {
      (valuationsByAsset[valuation.assetId] ??= []).add(valuation);
    }
    return _AnalyticsDataset(
      assets: assets,
      currencies: currencies,
      baseCurrency: baseCurrency,
      transactions: transactions,
      valuations: valuations,
      transactionsByAsset: transactionsByAsset,
      valuationsByAsset: valuationsByAsset,
    );
  }

  @override
  Future<CashflowSummary> cashflow(CashflowFilter filter) =>
      throw UnimplementedError('9.3');

  @override
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter) =>
      throw UnimplementedError('9.3');

  @override
  Future<List<CashflowPeriodPoint>> cashflowSeries(CashflowFilter filter) =>
      throw UnimplementedError('9.3');
}

final class _AnalyticsDataset {
  const _AnalyticsDataset({
    required this.assets,
    required this.currencies,
    required this.baseCurrency,
    required this.transactions,
    required this.valuations,
    required this.transactionsByAsset,
    required this.valuationsByAsset,
  });

  final List<AssetRow> assets;
  final Map<String, Currency> currencies;
  final Currency baseCurrency;
  final List<AssetTransactionRow> transactions;
  final List<AssetValuationRow> valuations;
  final Map<int, List<AssetTransactionRow>> transactionsByAsset;
  final Map<int, List<AssetValuationRow>> valuationsByAsset;
}
