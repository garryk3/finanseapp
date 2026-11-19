import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/resolve_exchange_rate.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Единая команда сохранения/удаления дохода или расхода (7.1).
class CashflowCommands {
  CashflowCommands({
    required this.repository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.today,
    this.db,
  });

  final CashflowRepository repository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;

  /// Для атомарных linked-пар cashflow ↔ asset transaction (7.2).
  final AppDatabase? db;

  Future<Result<int>> save({
    int? id,
    required CashflowKind kind,
    required int categoryId,
    required Money amount,
    required LocalDate occurredOn,
    Decimal? manualRate,
    String? comment,
    int? propertyId,
    int? accountId,
    bool affectsBalance = false,
  }) async {
    if (amount.minorUnits <= 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'amount': 'validationAmountPositive'},
        ),
      );
    }
    if (occurredOn.compareTo(today) > 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'occurredOn': 'validationDateInFuture'},
        ),
      );
    }
    if (affectsBalance && accountId == null) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'accountId': 'validationBalanceRequiresAccount'},
        ),
      );
    }
    try {
      final rate = await ResolveExchangeRate.call(
        rateRepository,
        amount.currencyCode,
        occurredOn,
        manualRate: manualRate,
      );
      final normalizedComment = (comment?.trim().isEmpty ?? true)
          ? null
          : comment!.trim();
      CashflowEntry? current;
      if (id != null) current = await repository.getById(id);
      if (affectsBalance && accountId != null) {
        return await _saveLinked(
          id: id,
          current: current,
          kind: kind,
          categoryId: categoryId,
          amount: amount,
          occurredOn: occurredOn,
          rateToRub: rate.rateToRub,
          comment: normalizedComment,
          accountId: accountId,
          propertyId: propertyId,
        );
      }
      final draft = CashflowEntryDraft(
        kind: kind,
        categoryId: categoryId,
        amount: amount,
        occurredOn: occurredOn,
        rateToRub: rate.rateToRub,
        affectsBalance: false,
        propertyId: propertyId,
        accountId: accountId,
        comment: normalizedComment,
      );
      if (current?.assetTransactionId != null) {
        return await _unlink(entry: current!, draft: draft);
      }
      if (id == null) return Success(await repository.create(draft));
      await repository.revise(id, draft);
      return const Success(0);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    }
  }

  Future<Result<int>> _saveLinked({
    required int? id,
    required CashflowEntry? current,
    required CashflowKind kind,
    required int categoryId,
    required Money amount,
    required LocalDate occurredOn,
    required Decimal rateToRub,
    required String? comment,
    required int accountId,
    required int? propertyId,
  }) async {
    final database = db;
    if (database == null) {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    }
    final rubMinor = await _rubMinor(amount, rateToRub);
    final txInput = AssetTransactionInput(
      assetId: accountId,
      kind: kind == CashflowKind.income
          ? AssetTransactionKind.deposit
          : AssetTransactionKind.withdrawal,
      amountMinor: amount.minorUnits,
      occurredOn: occurredOn,
      rateToRub: rateToRub,
      amountRubMinor: rubMinor,
      comment: comment,
    );
    final entryInput = CashflowEntryInput(
      kind: kind,
      categoryId: categoryId,
      amountMinor: amount.minorUnits,
      currencyCode: amount.currencyCode,
      occurredOn: occurredOn,
      rateToRub: rateToRub,
      amountRubMinor: rubMinor,
      affectsBalance: true,
      comment: comment,
      accountId: accountId,
      propertyId: propertyId,
    );
    return database.transaction(() async {
      int transactionId;
      if (current?.assetTransactionId != null) {
        transactionId = current!.assetTransactionId!;
        await database.transactionsDao.revise(transactionId, txInput);
      } else {
        transactionId = await database.transactionsDao.create(txInput);
      }
      if (id == null) {
        return Success(
          await database.cashflowDao.create(
            CashflowEntryInput(
              kind: entryInput.kind,
              categoryId: entryInput.categoryId,
              amountMinor: entryInput.amountMinor,
              currencyCode: entryInput.currencyCode,
              occurredOn: entryInput.occurredOn,
              rateToRub: entryInput.rateToRub,
              amountRubMinor: entryInput.amountRubMinor,
              affectsBalance: true,
              comment: entryInput.comment,
              accountId: entryInput.accountId,
              assetTransactionId: transactionId,
            ),
          ),
        );
      }
      await database.cashflowDao.reviseWithLink(id, entryInput, transactionId);
      return Success(id);
    });
  }

  Future<Result<int>> _unlink({
    required CashflowEntry entry,
    required CashflowEntryDraft draft,
  }) async {
    final database = db;
    final linkedId = entry.assetTransactionId;
    if (database == null || linkedId == null) {
      await repository.revise(entry.id, draft);
      return Success(entry.id);
    }
    final rubMinor = await _rubMinor(draft.amount, draft.rateToRub);
    return database.transaction(() async {
      await database.transactionsDao.softDelete(linkedId);
      await database.cashflowDao.reviseWithLink(
        entry.id,
        CashflowEntryInput(
          kind: draft.kind,
          categoryId: draft.categoryId,
          amountMinor: draft.amount.minorUnits,
          currencyCode: draft.amount.currencyCode,
          occurredOn: draft.occurredOn,
          rateToRub: draft.rateToRub,
          amountRubMinor: rubMinor,
          affectsBalance: false,
          comment: draft.comment,
          accountId: draft.accountId,
        ),
        null,
      );
      return Success(entry.id);
    });
  }

  Future<int> _rubMinor(Money amount, Decimal rateToRub) async {
    final currencies = await currencyRepository.watchAll().first;
    final currency = currencies.firstWhere(
      (item) => item.code == amount.currencyCode,
      orElse: () => Currency(
        code: amount.currencyCode,
        name: amount.currencyCode,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      ),
    );
    return rubAmount(amount, currency, rateToRub).minorUnits;
  }

  Future<Result<void>> delete(int id) async {
    try {
      final current = await repository.getById(id);
      final database = db;
      final linkedId = current.assetTransactionId;
      if (database != null && linkedId != null) {
        await database.transaction(() async {
          await database.transactionsDao.softDelete(linkedId);
          await database.cashflowDao.softDeleteFromAsset(id);
        });
      } else {
        await repository.softDelete(id);
      }
      return const Success(null);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    }
  }

  /// Точная сумма в RUB для предпросмотра формы.
  static Money rubAmount(Money amount, Currency currency, Decimal rateToRub) =>
      MoneyMath.fromDecimal(
        MoneyMath.toDecimal(amount, currency) * rateToRub,
        const Currency(
          code: 'RUB',
          name: 'Рубль',
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        ),
      );
}
