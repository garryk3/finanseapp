import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';

/// Общие поля draft'а актива без id/createdAt/archivedAt.
sealed class AssetDraft {
  const AssetDraft({
    required this.name,
    required this.currencyCode,
    required this.openingValue,
  });

  final String name;
  final String currencyCode;
  final Money openingValue;
}

/// Draft счёта (domain_model §4).
final class AccountDraft extends AssetDraft {
  const AccountDraft({
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required this.bankId,
    required this.annualRate,
    required this.startDate,
    this.endDate,
  });

  final int bankId;
  final Decimal annualRate;
  final LocalDate startDate;
  final LocalDate? endDate;
}

/// Draft инвестиции.
final class InvestmentDraft extends AssetDraft {
  const InvestmentDraft({
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required this.brokerId,
  });

  final int brokerId;
}

/// Draft квартиры.
final class PropertyDraft extends AssetDraft {
  const PropertyDraft({
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    this.address,
    this.purchasePrice,
  });

  final String? address;
  final Money? purchasePrice;
}
