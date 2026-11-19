import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry_revision.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Детали дохода/расхода: ревизии и удаление (7.1).
class CashflowDetailsViewModel {
  CashflowDetailsViewModel({
    required this.repository,
    required this.categoryRepository,
    required this.auditRepository,
    required this.currencyRepository,
    required this.commands,
    required this.entryId,
  });

  final CashflowRepository repository;
  final CategoryRepository categoryRepository;
  final AuditRepository auditRepository;
  final CurrencyRepository currencyRepository;
  final CashflowCommands commands;
  final int entryId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<CashflowEntry?> entry = signal(null);
  final Signal<CashflowCategory?> category = signal(null);
  final Signal<List<CashflowEntryRevision>> revisions = signal(const []);
  final Signal<bool> busy = signal(false);
  final Signal<String?> deleteError = signal(null);
  final Signal<Currency?> currency = signal(null);

  Future<void> load() async {
    try {
      final current = await repository.getById(entryId);
      if (current.deletedAt != null) {
        state.value = const ViewError(DomainErrorCode.notFound);
        return;
      }
      entry.value = current;
      final currencies = await currencyRepository.watchAll().first;
      currency.value = currencies.firstWhere(
        (item) => item.code == current.amount.currencyCode,
        orElse: () => Currency(
          code: current.amount.currencyCode,
          name: current.amount.currencyCode,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        ),
      );
      final all = [
        ...await categoryRepository
            .watchByKind(CashflowKind.income, includeArchived: true)
            .first,
        ...await categoryRepository
            .watchByKind(CashflowKind.expense, includeArchived: true)
            .first,
      ];
      category.value = all
          .where((item) => item.id == current.categoryId)
          .firstOrNull;
      revisions.value = await auditRepository
          .watchCashflowRevisions(entryId)
          .first;
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<Result<void>> delete() async {
    busy.value = true;
    deleteError.value = null;
    try {
      final result = await commands.delete(entryId);
      if (result is Failure<void>) {
        deleteError.value = result.error.code.name;
      }
      return result;
    } finally {
      busy.value = false;
    }
  }

  void dispose() {}
}
