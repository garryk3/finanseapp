import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:decimal/decimal.dart';

/// Вид актива (domain_model §4); стабильное TEXT-значение в БД.
enum AssetKind { account, investment, property }

/// Общие поля актива; вид задаёт concrete-подкласс.
sealed class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.openingValue,
    required this.createdAt,
    this.archivedAt,
  });

  final int id;
  final String name;
  final String currencyCode;
  final Money openingValue;
  final DateTime createdAt;
  final DateTime? archivedAt;

  AssetKind get kind;
}

/// Счёт: банк, ставка и срок вклада.
final class AccountAsset extends Asset {
  const AccountAsset({
    required super.id,
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required super.createdAt,
    required this.bankId,
    required this.annualRate,
    required this.startDate,
    super.archivedAt,
    this.endDate,
  });

  final int bankId;
  final Decimal annualRate;
  final LocalDate startDate;
  final LocalDate? endDate;

  @override
  AssetKind get kind => AssetKind.account;
}

/// Инвестиция: брокер.
final class InvestmentAsset extends Asset {
  const InvestmentAsset({
    required super.id,
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required super.createdAt,
    required this.brokerId,
    super.archivedAt,
  });

  final int brokerId;

  @override
  AssetKind get kind => AssetKind.investment;
}

/// Квартира: адрес и цена покупки в валюте актива.
final class PropertyAsset extends Asset {
  const PropertyAsset({
    required super.id,
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required super.createdAt,
    super.archivedAt,
    this.address,
    this.purchasePrice,
  });

  final String? address;
  final Money? purchasePrice;

  @override
  AssetKind get kind => AssetKind.property;
}

/// Актив вместе с вычисленной текущей стоимостью (domain_model §4).
///
/// [currentValue] — стоимость в основной валюте актива (первая позиция
/// [breakdown]); [currencyBalances] содержит все валютные позиции инвестиции
/// (M4). Для счёта и квартиры поле остаётся `null`.
/// [lockedBalances] — отмеченные заблокированные суммы инвестиции по валютам
/// (schema v4); `null` — отметок нет.
final class AssetSnapshot {
  const AssetSnapshot({
    required this.asset,
    required this.currentValue,
    this.currencyBalances,
    this.lockedBalances,
  });

  final Asset asset;
  final Money currentValue;

  /// Позиции мультивалютной инвестиции; `null` — стоимость в одной валюте.
  final List<Money>? currencyBalances;

  /// Заблокированные суммы инвестиции по валютам; `null` — отметок нет.
  final List<Money>? lockedBalances;

  /// Все валютные позиции; для одно-валютного актива — одна [currentValue].
  List<Money> get breakdown => currencyBalances ?? [currentValue];

  /// Отметки блокировки; для актива без отметок — пустой список.
  List<Money> get locked => lockedBalances ?? const [];
}
