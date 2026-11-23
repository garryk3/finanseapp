import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Текущая стоимость актива по current-истории (calculations §3).
///
/// Удалённые операции не учитываются; порядок не важен для суммы.
abstract final class AssetValueCalculator {
  static Money account(
    AccountAsset asset,
    List<AssetTransaction> transactions,
  ) {
    var balance = asset.openingValue;
    for (final transaction in transactions) {
      if (transaction.deletedAt != null) continue;
      balance = switch (transaction.kind) {
        AssetTransactionKind.deposit || AssetTransactionKind.transferIn =>
          MoneyMath.add(balance, transaction.amount),
        AssetTransactionKind.withdrawal || AssetTransactionKind.transferOut =>
          MoneyMath.subtract(balance, transaction.amount),
      };
    }
    return balance;
  }

  /// Инвестиция: баланс основной валюты актива (M4).
  ///
  /// Оставлено обёрткой над [investmentBalances] для одного валютного
  /// измерения; мультивалютный расчёт — там же.
  static Money investment(
    InvestmentAsset asset,
    List<AssetValuation> valuations,
    List<AssetTransaction> transactions,
  ) => investmentBalances(asset, valuations, transactions).first;

  /// Инвестиция по каждой валюте (M3/M4).
  ///
  /// Для валюты C: последняя оценка в C (`effectiveOn`, затем `id`) и
  /// активные операции в C с `occurredOn >=` даты оценки (операция той же
  /// даты — после оценки). Старт: валюта актива — `openingValue`, остальные —
  /// 0. Основная валюта всегда первая (даже с нулём), остальные — по алфавиту
  /// кода и только с ненулевым балансом.
  static List<Money> investmentBalances(
    InvestmentAsset asset,
    List<AssetValuation> valuations,
    List<AssetTransaction> transactions,
  ) {
    final codes = <String>{
      asset.currencyCode,
      for (final valuation in valuations) valuation.value.currencyCode,
      for (final transaction in transactions) transaction.amount.currencyCode,
    };
    final balances = <String, Money>{};
    for (final code in codes) {
      final latest = _latestValuationIn(valuations, code);
      var value =
          latest?.value ??
          (code == asset.currencyCode
              ? asset.openingValue
              : Money(minorUnits: 0, currencyCode: code));
      final from = latest?.effectiveOn;
      for (final transaction in transactions) {
        if (transaction.deletedAt != null) continue;
        if (transaction.amount.currencyCode != code) continue;
        if (from != null && transaction.occurredOn.compareTo(from) < 0) {
          continue;
        }
        value = switch (transaction.kind) {
          AssetTransactionKind.deposit || AssetTransactionKind.transferIn =>
            MoneyMath.add(value, transaction.amount),
          AssetTransactionKind.withdrawal || AssetTransactionKind.transferOut =>
            MoneyMath.subtract(value, transaction.amount),
        };
      }
      balances[code] = value;
    }
    final others = [
      for (final entry in balances.entries)
        if (entry.key != asset.currencyCode && !entry.value.isZero) entry.value,
    ]..sort((left, right) => left.currencyCode.compareTo(right.currencyCode));
    return [balances[asset.currencyCode]!, ...others];
  }

  static AssetValuation? _latestValuationIn(
    List<AssetValuation> valuations,
    String currencyCode,
  ) {
    AssetValuation? latest;
    for (final valuation in valuations) {
      if (valuation.value.currencyCode != currencyCode) continue;
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

  /// Квартира: последняя оценка или opening; денежный поток не входит (5.4).
  static Money property(PropertyAsset asset, List<AssetValuation> valuations) {
    if (valuations.isEmpty) return asset.openingValue;
    final sorted = [...valuations]
      ..sort((left, right) {
        final byDate = left.effectiveOn.compareTo(right.effectiveOn);
        return byDate != 0 ? byDate : left.id.compareTo(right.id);
      });
    return sorted.last.value;
  }
}
