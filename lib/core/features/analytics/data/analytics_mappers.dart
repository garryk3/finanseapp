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
  ) {
    final latest = _latestValuation(valuations, onDate);
    var value = latest?.valueMinor ?? asset.openingValueMinor;
    final from = latest?.effectiveOn;
    for (final transaction in transactions) {
      if (transaction.deletedAt != null) continue;
      if (transaction.occurredOn.compareTo(onDate) > 0) continue;
      if (from != null && transaction.occurredOn.compareTo(from) < 0) continue;
      value += switch (transaction.kind) {
        AssetTransactionKind.deposit ||
        AssetTransactionKind.transferIn => transaction.amountMinor,
        AssetTransactionKind.withdrawal ||
        AssetTransactionKind.transferOut => -transaction.amountMinor,
      };
    }
    return value;
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
