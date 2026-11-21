import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';

/// Единая команда сохранения/удаления правила регулярного платежа (BR-RC-7).
///
/// После сохранения сразу запускает catch-up, чтобы первый платёж появился
/// без перезапуска приложения. Пользователь создаёт только `fixed`.
final class RecurringCommands {
  RecurringCommands({
    required this.repository,
    required this.catchup,
    required this.today,
  });

  final RecurringRepository repository;
  final Future<void> Function() catchup;
  final LocalDate today;

  Future<Result<int>> save({
    int? id,
    required CashflowKind kind,
    required int categoryId,
    required Money amount,
    required String currencyCode,
    int? accountId,
    int? propertyId,
    required bool affectsBalance,
    required LocalDate startDate,
    LocalDate? endDate,
    String? comment,
  }) async {
    if (amount.minorUnits <= 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'amount': 'validationAmountPositive'},
        ),
      );
    }
    if (endDate != null && endDate.compareTo(startDate) < 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'endDate': 'validationRecurringDates'},
        ),
      );
    }
    final normalizedComment = (comment?.trim().isEmpty ?? true)
        ? null
        : comment!.trim();
    final draft = RecurringRuleDraft(
      strategy: RecurringStrategy.fixed,
      kind: kind,
      categoryId: categoryId,
      amount: amount,
      currencyCode: currencyCode,
      accountId: accountId,
      propertyId: propertyId,
      affectsBalance: affectsBalance,
      startDate: startDate,
      endDate: endDate,
      comment: normalizedComment,
    );
    try {
      int ruleId;
      if (id == null) {
        ruleId = await repository.create(draft);
      } else {
        await repository.revise(id, draft);
        ruleId = id;
      }
      await catchup();
      return Success(ruleId);
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
}
