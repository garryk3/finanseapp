import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';

/// Абсолютная оценка инвестиции или квартиры (domain_model §4).
final class AssetValuation {
  const AssetValuation({
    required this.id,
    required this.assetId,
    required this.effectiveOn,
    required this.value,
    required this.rateToRub,
    required this.valueRub,
    required this.createdAt,
  });

  final int id;
  final int assetId;
  final LocalDate effectiveOn;
  final Money value;
  final Decimal rateToRub;
  final Money valueRub;
  final DateTime createdAt;
}

/// Draft оценки: `valueRub` вычисляет repository перед записью.
final class AssetValuationDraft {
  const AssetValuationDraft({
    required this.assetId,
    required this.effectiveOn,
    required this.value,
    required this.rateToRub,
  });

  final int assetId;
  final LocalDate effectiveOn;
  final Money value;
  final Decimal rateToRub;
}
