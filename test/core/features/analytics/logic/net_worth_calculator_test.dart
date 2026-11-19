import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/logic/net_worth_calculator.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _eur = Currency(
  code: 'EUR',
  name: 'Евро',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);
const _usd = Currency(
  code: 'USD',
  name: 'Доллар',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

NetWorthAssetValue _value(AssetKind kind, int minor, Currency currency) =>
    NetWorthAssetValue(
      kind: kind,
      value: Money(minorUnits: minor, currencyCode: currency.code),
      currency: currency,
    );

void main() {
  test('одна валюта: суммы и категории', () {
    final summary = NetWorthCalculator.calculate(
      assets: [
        _value(AssetKind.account, 100000, _rub),
        _value(AssetKind.investment, 150000, _rub),
      ],
      ratesToRub: const {},
      baseCurrency: _rub,
    );

    expect(summary.total, const Money(minorUnits: 250000, currencyCode: 'RUB'));
    expect(
      summary.byAssetKind[AssetKind.account],
      const Money(minorUnits: 100000, currencyCode: 'RUB'),
    );
    expect(
      summary.byAssetKind[AssetKind.investment],
      const Money(minorUnits: 150000, currencyCode: 'RUB'),
    );
    expect(
      summary.byAssetKind[AssetKind.property],
      const Money(minorUnits: 0, currencyCode: 'RUB'),
    );
  });

  test('A→RUB→base без промежуточного округления', () {
    final summary = NetWorthCalculator.calculate(
      assets: [
        _value(AssetKind.account, 100000, _rub),
        _value(AssetKind.investment, 1000, _usd),
      ],
      ratesToRub: {'USD': Decimal.fromInt(90), 'EUR': Decimal.fromInt(100)},
      baseCurrency: _eur,
    );

    // 1000 RUB = 10 EUR; 10 USD × 90 = 900 RUB = 9 EUR.
    expect(summary.total, const Money(minorUnits: 1900, currencyCode: 'EUR'));
    expect(
      summary.byAssetKind[AssetKind.account],
      const Money(minorUnits: 1000, currencyCode: 'EUR'),
    );
    expect(
      summary.byAssetKind[AssetKind.investment],
      const Money(minorUnits: 900, currencyCode: 'EUR'),
    );
  });

  test('нет курса — rateUnavailable, не ноль', () {
    expect(
      () => NetWorthCalculator.calculate(
        assets: [_value(AssetKind.account, 100000, _usd)],
        ratesToRub: const {},
        baseCurrency: _rub,
      ),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.rateUnavailable,
        ),
      ),
    );
  });

  test('остаток округления уходит в категорию, сумма категорий = итог', () {
    // 0,01 USD × 0,4 = 0,004 RUB: каждая категория округляется в 0,
    // а общий итог 0,008 RUB — в 0,01 RUB.
    final summary = NetWorthCalculator.calculate(
      assets: [
        _value(AssetKind.account, 1, _usd),
        _value(AssetKind.investment, 1, _usd),
      ],
      ratesToRub: {'USD': Decimal.parse('0.4')},
      baseCurrency: _rub,
    );
    final kinds = [
      for (final kind in AssetKind.values) summary.byAssetKind[kind]!,
    ];

    expect(summary.total, const Money(minorUnits: 1, currencyCode: 'RUB'));
    expect(
      kinds.fold<int>(0, (sum, value) => sum + value.minorUnits),
      summary.total.minorUnits,
    );
  });
}
