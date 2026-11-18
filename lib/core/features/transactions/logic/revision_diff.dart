import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';

/// Одно изменённое поле между ревизиями (6.3).
final class RevisionDiff {
  const RevisionDiff({
    required this.field,
    required this.oldValue,
    required this.newValue,
  });

  final String field;
  final String oldValue;
  final String newValue;
}

/// Поля, которые показываются в diff (RUB snapshot производный).
List<RevisionDiff> diffAssetTransactions(
  AssetTransaction previous,
  AssetTransaction next,
) {
  final formatter = const MoneyFormatter();
  Currency currency(String code) => Currency(
    code: code,
    name: code,
    fractionDigits: 2,
    isPreset: true,
    isEnabled: true,
  );
  final changes = <RevisionDiff>[];
  if (previous.kind != next.kind) {
    changes.add(
      RevisionDiff(
        field: 'kind',
        oldValue: previous.kind.name,
        newValue: next.kind.name,
      ),
    );
  }
  if (previous.amount.minorUnits != next.amount.minorUnits ||
      previous.amount.currencyCode != next.amount.currencyCode) {
    changes.add(
      RevisionDiff(
        field: 'amount',
        oldValue: formatter.format(
          previous.amount,
          currency(previous.amount.currencyCode),
        ),
        newValue: formatter.format(
          next.amount,
          currency(next.amount.currencyCode),
        ),
      ),
    );
  }
  if (previous.occurredOn != next.occurredOn) {
    changes.add(
      RevisionDiff(
        field: 'date',
        oldValue: const DateFormatter().format(previous.occurredOn),
        newValue: const DateFormatter().format(next.occurredOn),
      ),
    );
  }
  if (previous.rateToRub != next.rateToRub) {
    changes.add(
      RevisionDiff(
        field: 'rate',
        oldValue: previous.rateToRub.toString(),
        newValue: next.rateToRub.toString(),
      ),
    );
  }
  if (previous.comment != next.comment) {
    changes.add(
      RevisionDiff(
        field: 'comment',
        oldValue: previous.comment ?? '',
        newValue: next.comment ?? '',
      ),
    );
  }
  return changes;
}
