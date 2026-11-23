import 'dart:convert';

import 'package:finanseapp/core/features/audit/data/revision_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _snapshot({Object? currencyCode = _absent}) => {
  'snapshotSchemaVersion': 1,
  'id': 1,
  'assetId': 2,
  'kind': 'deposit',
  'amountMinor': 10000,
  if (!identical(currencyCode, _absent)) 'currencyCode': currencyCode,
  'occurredOn': '2026-01-10',
  'rateToRub': '90',
  'amountRubMinor': 900000,
  'comment': null,
  'transferId': null,
  'revisionNo': 1,
  'createdAt': '2026-01-01T00:00:00.000000Z',
  'updatedAt': '2026-01-01T00:00:00.000000Z',
  'deletedAt': null,
};

const _absent = Object();

void main() {
  test('декодер аудита читает валюту операции из snapshot (M7)', () {
    final transaction = decodeAssetTransactionSnapshot(
      jsonEncode(_snapshot(currencyCode: 'USD')),
      'RUB',
    );

    expect(transaction.amount.currencyCode, 'USD');
    expect(transaction.amount.minorUnits, 10000);
  });

  test('старый snapshot без ключа использует валюту актива', () {
    final transaction = decodeAssetTransactionSnapshot(
      jsonEncode(_snapshot()),
      'RUB',
    );

    expect(transaction.amount.currencyCode, 'RUB');
  });

  test('snapshot с null использует валюту актива', () {
    final transaction = decodeAssetTransactionSnapshot(
      jsonEncode(_snapshot(currencyCode: null)),
      'EUR',
    );

    expect(transaction.amount.currencyCode, 'EUR');
  });
}
