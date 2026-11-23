import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Единый маппер операции по активу (6.1).
///
/// [currencyCode] — валюта актива, fallback для `NULL` (M1); собственная
/// валюта операции хранится в строке.
AssetTransaction mapAssetTransaction(
  AssetTransactionRow row,
  String currencyCode, {
  int? cashflowEntryId,
}) => AssetTransaction(
  id: row.id,
  assetId: row.assetId,
  kind: row.kind,
  amount: Money(
    minorUnits: row.amountMinor,
    currencyCode: row.currencyCode ?? currencyCode,
  ),
  occurredOn: row.occurredOn,
  rateToRub: row.rateToRub,
  amountRub: Money(minorUnits: row.amountRubMinor, currencyCode: 'RUB'),
  revisionNo: row.revisionNo,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
  comment: row.comment,
  transferId: row.transferId,
  cashflowEntryId: cashflowEntryId,
  deletedAt: row.deletedAt,
);
