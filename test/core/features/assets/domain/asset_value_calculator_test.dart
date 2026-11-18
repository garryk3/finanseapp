import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_value_calculator.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

AccountAsset _account(int openingMinor) => AccountAsset(
  id: 1,
  name: 'Счёт',
  currencyCode: 'RUB',
  openingValue: Money(minorUnits: openingMinor, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  bankId: 1,
  annualRate: Decimal.zero,
  startDate: LocalDate(2026, 1, 1),
);

AssetTransaction _tx(
  int amount,
  AssetTransactionKind kind, {
  DateTime? deleted,
}) => AssetTransaction(
  id: 1,
  assetId: 1,
  kind: kind,
  amount: Money(minorUnits: amount, currencyCode: 'RUB'),
  occurredOn: LocalDate(2026, 1, 10),
  rateToRub: Decimal.one,
  amountRub: Money(minorUnits: amount, currencyCode: 'RUB'),
  revisionNo: 1,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  deletedAt: deleted,
);

void main() {
  test('opening 100000 + deposit 2500 − withdrawal 1000 = 101500', () {
    final value = AssetValueCalculator.account(_account(10000000), [
      _tx(250000, AssetTransactionKind.deposit),
      _tx(100000, AssetTransactionKind.withdrawal),
    ]);

    expect(value.minorUnits, 10150000);
  });

  test('удалённые операции не влияют на баланс', () {
    final value = AssetValueCalculator.account(_account(10000000), [
      _tx(250000, AssetTransactionKind.deposit, deleted: DateTime.utc(2026)),
    ]);

    expect(value.minorUnits, 10000000);
  });
}
