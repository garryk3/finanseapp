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

  /// Инвестиция: последняя абсолютная оценка и операции после неё
  /// (операция той же даты считается после оценки).
  static Money investment(
    InvestmentAsset asset,
    List<AssetValuation> valuations,
    List<AssetTransaction> transactions,
  ) {
    final sorted = [...valuations]
      ..sort((left, right) {
        final byDate = left.effectiveOn.compareTo(right.effectiveOn);
        return byDate != 0 ? byDate : left.id.compareTo(right.id);
      });
    final latest = sorted.isEmpty ? null : sorted.last;
    var value = latest?.value ?? asset.openingValue;
    final from = latest?.effectiveOn;

    for (final transaction in transactions) {
      if (transaction.deletedAt != null) continue;
      if (from != null && transaction.occurredOn.compareTo(from) < 0) continue;
      value = switch (transaction.kind) {
        AssetTransactionKind.deposit || AssetTransactionKind.transferIn =>
          MoneyMath.add(value, transaction.amount),
        AssetTransactionKind.withdrawal || AssetTransactionKind.transferOut =>
          MoneyMath.subtract(value, transaction.amount),
      };
    }
    return value;
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
