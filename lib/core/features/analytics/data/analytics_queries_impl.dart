import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/data/analytics_mappers.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/domain/cashflow_period_point.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/analytics/logic/cashflow_analytics.dart';
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
  Future<bool> hasAnyCashflow() async =>
      (await _db.cashflowDao.watchAll().first).isNotEmpty;

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
    int? assetId,
  }) async {
    final data = await _load();
    final selected = [
      for (final asset in data.assets)
        if ((assetKind == null || asset.kind == assetKind) &&
            (assetId == null || asset.id == assetId))
          asset,
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
        assetId: assetId,
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
    int? assetId,
  }) async {
    final rates = <String, Decimal>{};
    final values = <NetWorthAssetValue>[];
    for (final asset in data.assets) {
      if (assetKind != null && asset.kind != assetKind) continue;
      if (assetId != null && asset.id != assetId) continue;
      if (!AnalyticsMappers.isIncluded(asset, onDate)) continue;
      final transactions = data.transactionsByAsset[asset.id] ?? const [];
      final valuations = data.valuationsByAsset[asset.id] ?? const [];
      final positions = asset.kind == AssetKind.investment
          ? AnalyticsMappers.investmentValuesByCurrency(
              asset,
              valuations,
              transactions,
              onDate,
            )
          : {
              asset.currencyCode: AnalyticsMappers.valueMinor(
                asset: asset,
                transactions: transactions,
                valuations: valuations,
                onDate: onDate,
              ),
            };
      for (final position in positions.entries) {
        final code = position.key;
        final currency = data.currencies[code];
        if (currency == null) throw AnalyticsMappers.currencyNotFound(code);
        if (code != data.baseCurrency.code) {
          rates[code] = await _rateFor(code, onDate, rateCache);
          rates[data.baseCurrency.code] = await _rateFor(
            data.baseCurrency.code,
            onDate,
            rateCache,
          );
        }
        values.add(
          NetWorthAssetValue(
            kind: asset.kind,
            value: Money(minorUnits: position.value, currencyCode: code),
            currency: currency,
          ),
        );
      }
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
  Future<CashflowSummary> cashflow(CashflowFilter filter) async {
    final data = await _cashflowValues(filter);
    return CashflowAnalytics.summarize(data.values, data.baseCurrency);
  }

  @override
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter) async {
    final data = await _cashflowValues(filter);
    return CashflowAnalytics.byCategory(data.values, data.baseCurrency);
  }

  @override
  Future<List<CashflowPeriodPoint>> cashflowSeries(
    CashflowFilter filter,
  ) async {
    final data = await _cashflowValues(filter);
    final period = filter.period ?? _periodOf(data.values);
    if (period == null) return const [];
    return CashflowAnalytics.series(
      values: data.values,
      period: period,
      baseCurrency: data.baseCurrency,
    );
  }

  Future<({List<CashflowAmount> values, Currency baseCurrency})>
  _cashflowValues(CashflowFilter filter) async {
    final baseCurrency = await _settingsRepository.getBaseCurrency();
    final currencies = {
      for (final currency in await _currencyRepository.watchAll().first)
        currency.code: currency,
    };
    final search = filter.query.trim().toLowerCase();
    final rows = await _db.cashflowDao
        .watchFiltered(
          CashflowFilter(
            period: filter.period,
            kind: filter.kind,
            categoryId: filter.categoryId,
            currencyCode: filter.currencyCode,
            propertyId: filter.propertyId,
            accountId: filter.accountId,
          ),
        )
        .first;
    final values = <CashflowAmount>[];
    final rateCache = <String, Decimal>{};
    for (final row in rows) {
      if (search.isNotEmpty &&
          !(row.comment ?? '').toLowerCase().contains(search)) {
        continue;
      }
      final source = currencies[row.currencyCode];
      if (source == null) {
        throw AnalyticsMappers.currencyNotFound(row.currencyCode);
      }
      final amount = MoneyMath.toDecimal(
        Money(minorUnits: row.amountMinor, currencyCode: row.currencyCode),
        source,
      ).toRational();
      final converted = row.currencyCode == baseCurrency.code
          ? amount
          : amount *
                (await _rateFor(
                  row.currencyCode,
                  row.occurredOn,
                  rateCache,
                )).toRational() /
                (await _rateFor(
                  baseCurrency.code,
                  row.occurredOn,
                  rateCache,
                )).toRational();
      values.add(
        CashflowAmount(
          kind: row.kind,
          categoryId: row.categoryId,
          occurredOn: row.occurredOn,
          amount: converted,
        ),
      );
    }
    return (values: values, baseCurrency: baseCurrency);
  }

  static DateRange? _periodOf(List<CashflowAmount> values) {
    if (values.isEmpty) return null;
    var start = values.first.occurredOn;
    var end = values.first.occurredOn;
    for (final value in values.skip(1)) {
      if (value.occurredOn.compareTo(start) < 0) start = value.occurredOn;
      if (value.occurredOn.compareTo(end) > 0) end = value.occurredOn;
    }
    return DateRange(start: start, end: end);
  }
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
