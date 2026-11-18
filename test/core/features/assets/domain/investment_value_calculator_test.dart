import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_value_calculator.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

InvestmentAsset _asset(int opening) => InvestmentAsset(
  id: 1,
  name: 'Инвестиция',
  currencyCode: 'RUB',
  openingValue: Money(minorUnits: opening, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  brokerId: 1,
);

AssetValuation _valuation(int id, LocalDate date, int value) => AssetValuation(
  id: id,
  assetId: 1,
  effectiveOn: date,
  value: Money(minorUnits: value, currencyCode: 'RUB'),
  rateToRub: Decimal.one,
  valueRub: Money(minorUnits: value, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
);

AssetTransaction _tx(int amount, LocalDate date, AssetTransactionKind kind) =>
    AssetTransaction(
      id: 1,
      assetId: 1,
      kind: kind,
      amount: Money(minorUnits: amount, currencyCode: 'RUB'),
      occurredOn: date,
      rateToRub: Decimal.one,
      amountRub: Money(minorUnits: amount, currencyCode: 'RUB'),
      revisionNo: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

void main() {
  test('CALC-014: оценка 1500 и последующая tx +50 = 1550', () {
    final value = AssetValueCalculator.investment(
      _asset(100000),
      [_valuation(1, LocalDate(2026, 1, 2), 150000)],
      [
        _tx(10000, LocalDate(2026, 1, 1), AssetTransactionKind.deposit),
        _tx(5000, LocalDate(2026, 1, 3), AssetTransactionKind.deposit),
      ],
    );

    expect(value.minorUnits, 155000);
  });

  test('поздняя оценка заменяет базу; транзакции до неё не считаются', () {
    final value = AssetValueCalculator.investment(
      _asset(100000),
      [
        _valuation(1, LocalDate(2026, 1, 2), 150000),
        _valuation(2, LocalDate(2026, 1, 4), 140000),
      ],
      [
        _tx(10000, LocalDate(2026, 1, 1), AssetTransactionKind.deposit),
        _tx(5000, LocalDate(2026, 1, 5), AssetTransactionKind.deposit),
      ],
    );

    expect(value.minorUnits, 145000);
  });

  test('две оценки одной даты: последняя по id', () {
    final value = AssetValueCalculator.investment(_asset(100000), [
      _valuation(1, LocalDate(2026, 1, 2), 150000),
      _valuation(2, LocalDate(2026, 1, 2), 160000),
    ], []);

    expect(value.minorUnits, 160000);
  });

  test('операция той же даты считается после оценки', () {
    final value = AssetValueCalculator.investment(
      _asset(100000),
      [_valuation(1, LocalDate(2026, 1, 2), 150000)],
      [_tx(10000, LocalDate(2026, 1, 2), AssetTransactionKind.deposit)],
    );

    expect(value.minorUnits, 160000);
  });

  test('без оценок учитываются все операции от opening', () {
    final value = AssetValueCalculator.investment(_asset(100000), [], [
      _tx(10000, LocalDate(2026, 1, 1), AssetTransactionKind.deposit),
    ]);

    expect(value.minorUnits, 110000);
  });
}
