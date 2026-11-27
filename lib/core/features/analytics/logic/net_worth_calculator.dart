import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/analytics/domain/net_worth_summary.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:rational/rational.dart';

/// Стоимость актива на дату в его валюте.
final class NetWorthAssetValue {
  const NetWorthAssetValue({
    required this.kind,
    required this.value,
    required this.currency,
  });

  final AssetKind kind;
  final Money value;
  final Currency currency;
}

/// Чистый капитал: exact A→RUB→base, одно округление на итог (calculations §5).
abstract final class NetWorthCalculator {
  static NetWorthSummary calculate({
    required List<NetWorthAssetValue> assets,
    required Map<String, Decimal> ratesToRub,
    required Currency baseCurrency,
    LocalDate? staleRateDate,
  }) {
    final byKind = <AssetKind, Rational>{
      for (final kind in AssetKind.values) kind: Rational.zero,
    };
    var total = Rational.zero;

    for (final asset in assets) {
      if (asset.value.currencyCode != asset.currency.code) {
        throw const DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'currencyCode': 'validationCurrencyMismatch'},
        );
      }
      final amount = _convert(
        asset: asset,
        ratesToRub: ratesToRub,
        baseCurrency: baseCurrency,
      );
      total += amount;
      byKind[asset.kind] = byKind[asset.kind]! + amount;
    }

    final totalMoney = MoneyMath.fromRational(total, baseCurrency);
    final kindMoney = <AssetKind, Money>{
      for (final kind in AssetKind.values)
        kind: MoneyMath.fromRational(byKind[kind]!, baseCurrency),
    };
    // Категории выводятся из тех же значений; расхождение на 1 minor unit
    // из-за независимого округления уходит в крупнейшую категорию.
    final remainder =
        totalMoney.minorUnits -
        kindMoney.values.fold<int>(0, (sum, value) => sum + value.minorUnits);
    if (remainder != 0) {
      final target = _largestKind(byKind);
      kindMoney[target] = Money(
        minorUnits: kindMoney[target]!.minorUnits + remainder,
        currencyCode: baseCurrency.code,
      );
    }

    return NetWorthSummary(
      total: totalMoney,
      byAssetKind: kindMoney,
      staleRateDate: staleRateDate,
    );
  }

  static Rational _convert({
    required NetWorthAssetValue asset,
    required Map<String, Decimal> ratesToRub,
    required Currency baseCurrency,
  }) {
    final amount = MoneyMath.toDecimal(
      asset.value,
      asset.currency,
    ).toRational();
    if (asset.currency.code == baseCurrency.code) return amount;
    final sourceRate = asset.currency.isRub
        ? Rational.one
        : _rate(asset.currency.code, ratesToRub);
    final baseRate = baseCurrency.isRub
        ? Rational.one
        : _rate(baseCurrency.code, ratesToRub);
    return amount * sourceRate / baseRate;
  }

  static Rational _rate(String code, Map<String, Decimal> ratesToRub) {
    final rate = ratesToRub[code];
    if (rate == null || rate <= Decimal.zero) {
      throw DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'currencyCode': code},
      );
    }
    return rate.toRational();
  }

  static AssetKind _largestKind(Map<AssetKind, Rational> byKind) {
    var target = AssetKind.account;
    var largest = _abs(byKind[target]!);
    for (final kind in AssetKind.values.skip(1)) {
      final value = _abs(byKind[kind]!);
      if (value > largest) {
        largest = value;
        target = kind;
      }
    }
    return target;
  }

  static Rational _abs(Rational value) =>
      value < Rational.zero ? -value : value;
}
