import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';

/// Repository активов и их оценок (domain_model §9).
/// Сколько записей ссылается на актив (BR-A-5): для диалога удаления.
final class AssetReferenceCounts {
  const AssetReferenceCounts({
    required this.transactions,
    required this.valuations,
    required this.goals,
    required this.cashflow,
    this.recurringRules = 0,
  });

  final int transactions;
  final int valuations;
  final int goals;
  final int cashflow;
  final int recurringRules;

  int get total =>
      transactions + valuations + goals + cashflow + recurringRules;

  bool get isUsed => total > 0;
}

abstract interface class AssetRepository {
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false});

  Stream<AssetSnapshot?> watchById(int id);

  Future<AssetSnapshot> getById(int id);

  Future<int> create(AssetDraft draft);

  Future<void> update(int id, AssetDraft draft);

  Future<void> deleteIfUnused(int id);

  Future<void> archive(int id);

  Future<void> recordValuation(AssetValuationDraft draft);

  /// Разбивка ссылок для диалога удаления/архивации (BR-A-5).
  Future<AssetReferenceCounts> referenceCounts(int id);

  /// История абсолютных оценок по `(effectiveOn, id)`.
  Future<List<AssetValuation>> valuations(int id);

  /// Устанавливает/снимает отметку заблокированной суммы по валюте (L2).
  ///
  /// Нулевая [amount] удаляет отметку. Сумма больше баланса позиции или
  /// позиции нет — `DomainException(validationLockedExceedsBalance)`.
  Future<void> setLockedAmount(int assetId, String currencyCode, Money amount);

  /// Отметки заблокированных сумм инвестиции по валютам.
  Future<List<Money>> lockedAmounts(int assetId);
}
