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

AssetValuation _valuation(
  int id,
  LocalDate date,
  int value, {
  String currency = 'RUB',
}) => AssetValuation(
  id: id,
  assetId: 1,
  effectiveOn: date,
  value: Money(minorUnits: value, currencyCode: currency),
  rateToRub: Decimal.one,
  valueRub: Money(minorUnits: value, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
);

AssetTransaction _tx(
  int amount,
  LocalDate date,
  AssetTransactionKind kind, {
  int id = 1,
  String currency = 'RUB',
  DateTime? deletedAt,
}) => AssetTransaction(
  id: id,
  assetId: 1,
  kind: kind,
  amount: Money(minorUnits: amount, currencyCode: currency),
  occurredOn: date,
  rateToRub: Decimal.one,
  amountRub: Money(minorUnits: amount, currencyCode: 'RUB'),
  revisionNo: 1,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  deletedAt: deletedAt,
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

  group('investmentBalances (M3/M4)', () {
    test('CALC-045: opening RUB + deposit USD → позиции основной и USD', () {
      final balances = AssetValueCalculator.investmentBalances(
        _asset(100000),
        const [],
        [
          _tx(
            10000,
            LocalDate(2026, 1, 1),
            AssetTransactionKind.deposit,
            currency: 'USD',
          ),
        ],
      );

      expect(balances, [
        const Money(minorUnits: 100000, currencyCode: 'RUB'),
        const Money(minorUnits: 10000, currencyCode: 'USD'),
      ]);
    });

    test('оценка в USD меняет только USD-позицию', () {
      final balances = AssetValueCalculator.investmentBalances(
        _asset(100000),
        [_valuation(1, LocalDate(2026, 1, 5), 12000, currency: 'USD')],
        [
          _tx(
            10000,
            LocalDate(2026, 1, 1),
            AssetTransactionKind.deposit,
            currency: 'USD',
          ),
        ],
      );

      expect(balances, [
        const Money(minorUnits: 100000, currencyCode: 'RUB'),
        const Money(minorUnits: 12000, currencyCode: 'USD'),
      ]);
    });

    test('операция той же даты, что оценка, применяется после неё', () {
      final balances = AssetValueCalculator.investmentBalances(
        _asset(0),
        [_valuation(1, LocalDate(2026, 1, 5), 12000, currency: 'USD')],
        [
          _tx(
            500,
            LocalDate(2026, 1, 5),
            AssetTransactionKind.deposit,
            currency: 'USD',
          ),
        ],
      );

      expect(balances, [
        const Money(minorUnits: 0, currencyCode: 'RUB'),
        const Money(minorUnits: 12500, currencyCode: 'USD'),
      ]);
    });

    test('withdrawal обнуляет USD — позиция исчезает, RUB остаётся первой', () {
      final balances = AssetValueCalculator.investmentBalances(
        _asset(100000),
        const [],
        [
          _tx(
            10000,
            LocalDate(2026, 1, 1),
            AssetTransactionKind.deposit,
            id: 1,
            currency: 'USD',
          ),
          _tx(
            10000,
            LocalDate(2026, 1, 2),
            AssetTransactionKind.withdrawal,
            id: 2,
            currency: 'USD',
          ),
        ],
      );

      expect(balances, [const Money(minorUnits: 100000, currencyCode: 'RUB')]);
    });

    test('удалённые операции не учитываются', () {
      final balances = AssetValueCalculator.investmentBalances(
        _asset(100000),
        const [],
        [
          _tx(
            10000,
            LocalDate(2026, 1, 1),
            AssetTransactionKind.deposit,
            currency: 'USD',
            deletedAt: DateTime.utc(2026, 2),
          ),
        ],
      );

      expect(balances, [const Money(minorUnits: 100000, currencyCode: 'RUB')]);
    });

    test(
      'основная валюта присутствует даже с нулём; остальные по алфавиту',
      () {
        final balances = AssetValueCalculator.investmentBalances(
          _asset(0),
          const [],
          [
            _tx(
              10000,
              LocalDate(2026, 1, 1),
              AssetTransactionKind.deposit,
              id: 1,
              currency: 'USD',
            ),
            _tx(
              20000,
              LocalDate(2026, 1, 2),
              AssetTransactionKind.deposit,
              id: 2,
              currency: 'EUR',
            ),
          ],
        );

        expect(balances, [
          const Money(minorUnits: 0, currencyCode: 'RUB'),
          const Money(minorUnits: 20000, currencyCode: 'EUR'),
          const Money(minorUnits: 10000, currencyCode: 'USD'),
        ]);
      },
    );
  });
}
