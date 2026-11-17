import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Версия формата JSON-снимка ревизии (data_schema §1).
const snapshotSchemaVersion = 1;

/// Каноническая запись Decimal в JSON берётся из конвертера колонок, чтобы
/// хранимая колонка и immutable snapshot не расходились по формату.
String canonicalDecimal(Decimal value) => DecimalConverter.toCanonical(value);

/// Стабильное TEXT-значение вида операции для snapshot.
String assetTransactionKindValue(AssetTransactionKind kind) =>
    const AssetTransactionKindConverter().toSql(kind);

/// Стабильное TEXT-значение типа денежного потока для snapshot.
String cashflowKindValue(CashflowKind kind) =>
    const CashflowKindConverter().toSql(kind);

/// Стабильное TEXT-значение действия ревизии.
String revisionActionValue(RevisionAction action) =>
    const RevisionActionConverter().toSql(action);

/// Снимок current projection после действия, с версией формата.
///
/// Ключи — английские, minor units — JSON integer, Decimal/date/time — String.
String encodeRevisionSnapshot(Map<String, Object?> fields) =>
    jsonEncode({'snapshotSchemaVersion': snapshotSchemaVersion, ...fields});

/// Поля операции по активу для журнала.
Map<String, Object?> assetTransactionSnapshotFields({
  required int id,
  required int assetId,
  required AssetTransactionKind kind,
  required int amountMinor,
  required LocalDate occurredOn,
  required Decimal rateToRub,
  required int amountRubMinor,
  required String? comment,
  required int? transferId,
  required int revisionNo,
  required DateTime createdAt,
  required DateTime updatedAt,
  required DateTime? deletedAt,
}) => {
  'id': id,
  'assetId': assetId,
  'kind': assetTransactionKindValue(kind),
  'amountMinor': amountMinor,
  'occurredOn': occurredOn.toIsoString(),
  'rateToRub': canonicalDecimal(rateToRub),
  'amountRubMinor': amountRubMinor,
  'comment': comment,
  'transferId': transferId,
  'revisionNo': revisionNo,
  'createdAt': _snapshotTimestamp(createdAt),
  'updatedAt': _snapshotTimestamp(updatedAt),
  'deletedAt': deletedAt == null ? null : _snapshotTimestamp(deletedAt),
};

/// Поля записи денежного потока для журнала.
Map<String, Object?> cashflowSnapshotFields({
  required int id,
  required CashflowKind kind,
  required int categoryId,
  required int amountMinor,
  required String currencyCode,
  required LocalDate occurredOn,
  required Decimal rateToRub,
  required int amountRubMinor,
  required bool affectsBalance,
  required String? comment,
  required int? propertyId,
  required int? accountId,
  required int? assetTransactionId,
  required int revisionNo,
  required DateTime createdAt,
  required DateTime updatedAt,
  required DateTime? deletedAt,
}) => {
  'id': id,
  'kind': cashflowKindValue(kind),
  'categoryId': categoryId,
  'amountMinor': amountMinor,
  'currencyCode': currencyCode,
  'occurredOn': occurredOn.toIsoString(),
  'rateToRub': canonicalDecimal(rateToRub),
  'amountRubMinor': amountRubMinor,
  'affectsBalance': affectsBalance,
  'comment': comment,
  'propertyId': propertyId,
  'accountId': accountId,
  'assetTransactionId': assetTransactionId,
  'revisionNo': revisionNo,
  'createdAt': _snapshotTimestamp(createdAt),
  'updatedAt': _snapshotTimestamp(updatedAt),
  'deletedAt': deletedAt == null ? null : _snapshotTimestamp(deletedAt),
};

/// Тот же формат, что у колонок: ISO TEXT фиксированной ширины (микросекунды).
String _snapshotTimestamp(DateTime value) =>
    const UtcTimestampConverter().toSql(value);
