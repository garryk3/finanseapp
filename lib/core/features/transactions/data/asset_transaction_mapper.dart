import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Единый маппер операции по активу (6.1): суммы в валюте актива.
AssetTransaction mapAssetTransaction(
  AssetTransactionRow row,
  String currencyCode, {
  int? cashflowEntryId,
}) => AssetTransaction(
  id: row.id,
  assetId: row.assetId,
  kind: row.kind,
  amount: Money(minorUnits: row.amountMinor, currencyCode: currencyCode),
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
