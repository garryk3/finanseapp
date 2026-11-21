import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_commands.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Форма создания и правки ежемесячного платежа (15.2).
class RecurringRuleFormViewModel {
  RecurringRuleFormViewModel({
    required this.repository,
    required this.categoryRepository,
    required this.currencyRepository,
    required this.assetRepository,
    required this.commands,
    this.editingId,
    this.initialKind = CashflowKind.expense,
    this.presetPropertyId,
    this.presetAccountId,
  });

  final RecurringRepository repository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;
  final AssetRepository assetRepository;
  final RecurringCommands commands;
  final int? editingId;
  final CashflowKind initialKind;
  final int? presetPropertyId;
  final int? presetAccountId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<CashflowCategory>> categories = signal(const []);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<List<AccountAsset>> accounts = signal(const []);
  final Signal<List<PropertyAsset>> properties = signal(const []);
  final Signal<RecurringRule?> rule = signal(null);
  final Signal<String?> presetTargetName = signal(null);
  final Signal<bool> busy = signal(false);

  bool get isEditing => editingId != null;

  bool get isAuto => rule.value?.strategy == RecurringStrategy.depositInterest;

  bool get isDeleted => rule.value?.deletedAt != null;

  LocalDate get today => commands.today;

  Future<void> load({CashflowKind? kind}) async {
    try {
      final current = editingId == null
          ? null
          : await repository.getById(editingId!);
      rule.value = current;
      if (current?.deletedAt != null) {
        // Ссылка из истории автооперации после удаления правила: показываем
        // спокойное состояние, а не редактируемую форму с ошибками.
        state.value = const ViewData(null);
        return;
      }
      final list = await currencyRepository.watchAll().first;
      currencies.value = {for (final currency in list) currency.code: currency};
      final snapshots = await assetRepository
          .watchAll(includeArchived: true)
          .first;
      final targetIds = <int>{
        ?current?.accountId,
        ?current?.propertyId,
        ?presetAccountId,
        ?presetPropertyId,
      };
      accounts.value = [
        for (final snapshot in snapshots)
          if (snapshot.asset is AccountAsset &&
              (snapshot.asset.archivedAt == null ||
                  targetIds.contains(snapshot.asset.id)))
            snapshot.asset as AccountAsset,
      ];
      properties.value = [
        for (final snapshot in snapshots)
          if (snapshot.asset is PropertyAsset &&
              (snapshot.asset.archivedAt == null ||
                  targetIds.contains(snapshot.asset.id)))
            snapshot.asset as PropertyAsset,
      ];
      final presetId = presetPropertyId ?? presetAccountId;
      if (presetId != null) {
        presetTargetName.value = snapshots
            .where((snapshot) => snapshot.asset.id == presetId)
            .firstOrNull
            ?.asset
            .name;
      }
      await loadCategories(current?.kind ?? kind ?? initialKind);
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<void> loadCategories(CashflowKind kind) async {
    categories.value = await categoryRepository
        .watchByKind(kind, includeArchived: true)
        .first;
  }

  Currency currencyOf(String code) =>
      currencies.value[code] ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  Future<Result<int>> save({
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
  }) => commands.save(
    id: editingId,
    kind: kind,
    categoryId: categoryId,
    amount: amount,
    currencyCode: currencyCode,
    accountId: accountId,
    propertyId: propertyId,
    affectsBalance: affectsBalance,
    startDate: startDate,
    endDate: endDate,
    comment: comment,
  );

  Future<Result<void>> delete() async {
    final id = editingId;
    if (id == null) {
      return const Failure(DomainException(DomainErrorCode.validation));
    }
    busy.value = true;
    try {
      return await commands.delete(id);
    } finally {
      busy.value = false;
    }
  }

  void dispose() {}
}
