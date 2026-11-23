import 'dart:convert';

import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Декодирование immutable snapshot JSON ревизии (6.3).
AssetTransaction decodeAssetTransactionSnapshot(
  String json,
  String currencyCode,
) {
  final data = jsonDecode(json) as Map<String, dynamic>;
  return AssetTransaction(
    id: data['id'] as int,
    assetId: data['assetId'] as int,
    kind: const AssetTransactionKindConverter().fromSql(data['kind'] as String),
    amount: Money(
      minorUnits: data['amountMinor'] as int,
      // M7: старые snapshot без ключа читаются в валюте актива.
      currencyCode: data['currencyCode'] as String? ?? currencyCode,
    ),
    occurredOn: LocalDate.parse(data['occurredOn'] as String),
    rateToRub: const DecimalConverter().fromSql(data['rateToRub'] as String),
    amountRub: Money(
      minorUnits: data['amountRubMinor'] as int,
      currencyCode: 'RUB',
    ),
    revisionNo: data['revisionNo'] as int,
    createdAt: _timestamp(data['createdAt'] as String),
    updatedAt: _timestamp(data['updatedAt'] as String),
    comment: data['comment'] as String?,
    transferId: data['transferId'] as int?,
    deletedAt: data['deletedAt'] == null
        ? null
        : _timestamp(data['deletedAt'] as String),
  );
}

/// ID актива из snapshot — для валюты и имени.
int assetIdFromSnapshot(String json) =>
    (jsonDecode(json) as Map<String, dynamic>)['assetId'] as int;

CashflowEntry decodeCashflowSnapshot(String json) {
  final data = jsonDecode(json) as Map<String, dynamic>;
  return CashflowEntry(
    id: data['id'] as int,
    kind: const CashflowKindConverter().fromSql(data['kind'] as String),
    categoryId: data['categoryId'] as int,
    amount: Money(
      minorUnits: data['amountMinor'] as int,
      currencyCode: data['currencyCode'] as String,
    ),
    occurredOn: LocalDate.parse(data['occurredOn'] as String),
    rateToRub: const DecimalConverter().fromSql(data['rateToRub'] as String),
    amountRub: Money(
      minorUnits: data['amountRubMinor'] as int,
      currencyCode: 'RUB',
    ),
    affectsBalance: data['affectsBalance'] as bool,
    revisionNo: data['revisionNo'] as int,
    createdAt: _timestamp(data['createdAt'] as String),
    updatedAt: _timestamp(data['updatedAt'] as String),
    comment: data['comment'] as String?,
    propertyId: data['propertyId'] as int?,
    accountId: data['accountId'] as int?,
    assetTransactionId: data['assetTransactionId'] as int?,
    recurringRuleId: data['recurringRuleId'] as int?,
    deletedAt: data['deletedAt'] == null
        ? null
        : _timestamp(data['deletedAt'] as String),
  );
}

DateTime _timestamp(String value) =>
    const UtcTimestampConverter().fromSql(value);
