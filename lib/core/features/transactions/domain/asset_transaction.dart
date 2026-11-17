import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';

/// Вид операции по активу (domain_model §5); стабильное TEXT-значение в БД.
enum AssetTransactionKind { deposit, withdrawal, transferOut, transferIn }

/// Операция по активу; `amount` всегда > 0, `amountRub` — абсолютный RUB.
final class AssetTransaction {
  const AssetTransaction({
    required this.id,
    required this.assetId,
    required this.kind,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRub,
    required this.revisionNo,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
    this.transferId,
    this.cashflowEntryId,
    this.deletedAt,
  });

  final int id;
  final int assetId;
  final AssetTransactionKind kind;
  final Money amount;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final Money amountRub;
  final int revisionNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comment;
  final int? transferId;

  /// Производное значение из join по `cashflow_entries.assetTransactionId`.
  final int? cashflowEntryId;
  final DateTime? deletedAt;
}

/// Draft операции по активу.
final class AssetTransactionDraft {
  const AssetTransactionDraft({
    required this.assetId,
    required this.kind,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    this.comment,
  });

  final int assetId;
  final AssetTransactionKind kind;
  final Money amount;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final String? comment;
}

/// Draft перевода: суммы каждой ноги в валюте своего счёта.
final class TransferDraft {
  const TransferDraft({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.destinationAmount,
    required this.occurredOn,
    required this.fromRateToRub,
    required this.toRateToRub,
    this.comment,
  });

  final int fromAccountId;
  final int toAccountId;

  /// Валюта исходного счёта.
  final Money amount;

  /// Валюта счёта зачисления.
  final Money destinationAmount;
  final LocalDate occurredOn;
  final Decimal fromRateToRub;
  final Decimal toRateToRub;
  final String? comment;
}
