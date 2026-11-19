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

/// Агрегаты итогов: dated-курсы и исторические стоимости (9.1).
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
    final rows = await _db.assetsDao.allRows();
    final included = [
      for (final row in rows)
        if (AnalyticsMappers.isIncluded(row, onDate)) row,
    ];
    final baseCurrency = await _settingsRepository.getBaseCurrency();
    if (included.isEmpty) {
      return NetWorthCalculator.calculate(
        assets: const [],
        ratesToRub: const {},
        baseCurrency: baseCurrency,
      );
    }

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

    final rates = <String, Decimal>{};
    Future<void> requireRate(String code) async {
      if (code == Currency.rubCode || rates.containsKey(code)) return;
      final rate = await _rateRepository.find(code, onDate);
      if (rate == null) {
        throw DomainException(
          DomainErrorCode.rateUnavailable,
          fieldErrors: {'currencyCode': code, 'date': onDate.toIsoString()},
        );
      }
      rates[code] = rate.rateToRub;
    }

    final values = <NetWorthAssetValue>[];
    for (final asset in included) {
      final currency = currencies[asset.currencyCode];
      if (currency == null) {
        throw AnalyticsMappers.currencyNotFound(asset.currencyCode);
      }
      if (asset.currencyCode != baseCurrency.code) {
        await requireRate(asset.currencyCode);
        await requireRate(baseCurrency.code);
      }
      values.add(
        NetWorthAssetValue(
          kind: asset.kind,
          value: Money(
            minorUnits: AnalyticsMappers.valueMinor(
              asset: asset,
              transactions: transactionsByAsset[asset.id] ?? const [],
              valuations: valuationsByAsset[asset.id] ?? const [],
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
      baseCurrency: baseCurrency,
    );
  }

  @override
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
  }) => throw UnimplementedError('9.2');

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
