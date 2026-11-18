import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
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
}
