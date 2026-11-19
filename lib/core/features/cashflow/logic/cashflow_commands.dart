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

/// Единая команда сохранения/удаления дохода или расхода (7.1).
class CashflowCommands {
  CashflowCommands({
    required this.repository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.today,
  });

  final CashflowRepository repository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;

  Future<Result<int>> save({
    int? id,
    required CashflowKind kind,
    required int categoryId,
    required Money amount,
    required LocalDate occurredOn,
    Decimal? manualRate,
    String? comment,
    int? propertyId,
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
    try {
      final rate = await ResolveExchangeRate.call(
        rateRepository,
        amount.currencyCode,
        occurredOn,
        manualRate: manualRate,
      );
      final draft = CashflowEntryDraft(
        kind: kind,
        categoryId: categoryId,
        amount: amount,
        occurredOn: occurredOn,
        rateToRub: rate.rateToRub,
        affectsBalance: false,
        propertyId: propertyId,
        comment: (comment?.trim().isEmpty ?? true) ? null : comment!.trim(),
      );
      if (id == null) return Success(await repository.create(draft));
      await repository.revise(id, draft);
      return const Success(0);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    }
  }

  Future<Result<void>> delete(int id) async {
    try {
      await repository.softDelete(id);
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
