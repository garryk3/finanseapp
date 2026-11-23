import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Исторические стоимости активов на дату (calculations §3, §5).
abstract final class AnalyticsMappers {
  /// Актив входит в итог на [onDate], если уже создан и ещё не архивирован
  /// (A-6: с даты архивации скрыт из текущих итогов).
  static bool isIncluded(AssetRow asset, LocalDate onDate) {
    final created = LocalDate.fromDateTime(asset.createdAt.toLocal());
    if (created.compareTo(onDate) > 0) return false;
    final archivedAt = asset.archivedAt;
    if (archivedAt == null) return true;
    return LocalDate.fromDateTime(archivedAt.toLocal()).compareTo(onDate) > 0;
  }

  static int accountValueMinor(
    AssetRow asset,
    Iterable<AssetTransactionRow> transactions,
    LocalDate onDate,
  ) {
    var balance = asset.openingValueMinor;
    for (final transaction in transactions) {
      if (transaction.deletedAt != null) continue;
      if (transaction.occurredOn.compareTo(onDate) > 0) continue;
      balance += switch (transaction.kind) {
        AssetTransactionKind.deposit ||
        AssetTransactionKind.transferIn => transaction.amountMinor,
        AssetTransactionKind.withdrawal ||
        AssetTransactionKind.transferOut => -transaction.amountMinor,
      };
    }
    return balance;
  }

  static int investmentValueMinor(
    AssetRow asset,
    Iterable<AssetValuationRow> valuations,
    Iterable<AssetTransactionRow> transactions,
    LocalDate onDate,
  ) =>
      investmentValuesByCurrency(
        asset,
        valuations,
        transactions,
        onDate,
      )[asset.currencyCode] ??
      asset.openingValueMinor;

  /// Стоимость инвестиции по валютам на дату (M3/M4).
  ///
  /// Группировка по `currencyCode ?? asset.currencyCode`; для каждой валюты —
  /// своя последняя оценка и операции начиная с её даты. Основная валюта
  /// присутствует всегда, остальные — только с ненулевым балансом.
  static Map<String, int> investmentValuesByCurrency(
    AssetRow asset,
    Iterable<AssetValuationRow> valuations,
    Iterable<AssetTransactionRow> transactions,
    LocalDate onDate,
  ) {
    final codes = <String>{
      asset.currencyCode,
      for (final valuation in valuations)
        valuation.currencyCode ?? asset.currencyCode,
      for (final transaction in transactions)
        transaction.currencyCode ?? asset.currencyCode,
    };
    final values = <String, int>{};
    for (final code in codes) {
      final latest = _latestValuationIn(
        valuations,
        onDate,
        code,
        asset.currencyCode,
      );
      var value =
          latest?.valueMinor ??
          (code == asset.currencyCode ? asset.openingValueMinor : 0);
      final from = latest?.effectiveOn;
      for (final transaction in transactions) {
        if (transaction.deletedAt != null) continue;
        if ((transaction.currencyCode ?? asset.currencyCode) != code) continue;
        if (transaction.occurredOn.compareTo(onDate) > 0) continue;
        if (from != null && transaction.occurredOn.compareTo(from) < 0) {
          continue;
        }
        value += switch (transaction.kind) {
          AssetTransactionKind.deposit ||
          AssetTransactionKind.transferIn => transaction.amountMinor,
          AssetTransactionKind.withdrawal ||
          AssetTransactionKind.transferOut => -transaction.amountMinor,
        };
      }
      values[code] = value;
    }
    final others = [
      for (final code in values.keys)
        if (code != asset.currencyCode && values[code] != 0) code,
    ]..sort();
    return {
      asset.currencyCode: values[asset.currencyCode] ?? asset.openingValueMinor,
      for (final code in others) code: values[code]!,
    };
  }

  static AssetValuationRow? _latestValuationIn(
    Iterable<AssetValuationRow> valuations,
    LocalDate onDate,
    String currencyCode,
    String assetCurrencyCode,
  ) {
    AssetValuationRow? latest;
    for (final valuation in valuations) {
      if ((valuation.currencyCode ?? assetCurrencyCode) != currencyCode) {
        continue;
      }
      if (valuation.effectiveOn.compareTo(onDate) > 0) continue;
      if (latest == null) {
        latest = valuation;
        continue;
      }
      final byDate = valuation.effectiveOn.compareTo(latest.effectiveOn);
      if (byDate > 0 || (byDate == 0 && valuation.id > latest.id)) {
        latest = valuation;
      }
    }
    return latest;
  }

  static int propertyValueMinor(
    AssetRow asset,
    Iterable<AssetValuationRow> valuations,
    LocalDate onDate,
  ) =>
      _latestValuation(valuations, onDate)?.valueMinor ??
      asset.openingValueMinor;

  static AssetValuationRow? _latestValuation(
    Iterable<AssetValuationRow> valuations,
    LocalDate onDate,
  ) {
    AssetValuationRow? latest;
    for (final valuation in valuations) {
      if (valuation.effectiveOn.compareTo(onDate) > 0) continue;
      if (latest == null) {
        latest = valuation;
        continue;
      }
      final byDate = valuation.effectiveOn.compareTo(latest.effectiveOn);
      if (byDate > 0 || (byDate == 0 && valuation.id > latest.id)) {
        latest = valuation;
      }
    }
    return latest;
  }

  /// Стоимость актива на дату в его валюте; неизвестный вид — ошибка данных.
  static int valueMinor({
    required AssetRow asset,
    required Iterable<AssetTransactionRow> transactions,
    required Iterable<AssetValuationRow> valuations,
    required LocalDate onDate,
  }) => switch (asset.kind) {
    AssetKind.account => accountValueMinor(asset, transactions, onDate),
    AssetKind.investment => investmentValueMinor(
      asset,
      valuations,
      transactions,
      onDate,
    ),
    AssetKind.property => propertyValueMinor(asset, valuations, onDate),
  };

  static DomainException currencyNotFound(String code) => DomainException(
    DomainErrorCode.notFound,
    fieldErrors: {'currencyCode': code},
  );
}
