import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Единая запись связанной пары «операция счёта + cashflow» (BR-IE-6).
///
/// Используется и ручной командой [CashflowCommands], и автогенератором
/// регулярных платежей, чтобы поля пары не разъезжались. Вызывающий сам
/// открывает транзакцию, если нужна атомарность с другими записями.
final class LinkedCashflowWriter {
  const LinkedCashflowWriter(this.db);

  final AppDatabase db;

  Future<int> create({
    required CashflowKind kind,
    required int categoryId,
    required Money amount,
    required LocalDate occurredOn,
    required Decimal rateToRub,
    required int amountRubMinor,
    required int accountId,
    int? propertyId,
    int? recurringRuleId,
    String? comment,
  }) async {
    final transactionId = await db.transactionsDao.create(
      AssetTransactionInput(
        assetId: accountId,
        kind: kind == CashflowKind.income
            ? AssetTransactionKind.deposit
            : AssetTransactionKind.withdrawal,
        amountMinor: amount.minorUnits,
        occurredOn: occurredOn,
        rateToRub: rateToRub,
        amountRubMinor: amountRubMinor,
        comment: comment,
      ),
    );
    return db.cashflowDao.create(
      CashflowEntryInput(
        kind: kind,
        categoryId: categoryId,
        amountMinor: amount.minorUnits,
        currencyCode: amount.currencyCode,
        occurredOn: occurredOn,
        rateToRub: rateToRub,
        amountRubMinor: amountRubMinor,
        affectsBalance: true,
        comment: comment,
        propertyId: propertyId,
        accountId: accountId,
        assetTransactionId: transactionId,
        recurringRuleId: recurringRuleId,
      ),
    );
  }
}
