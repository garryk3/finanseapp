import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Журнал доходов и расходов (7.1).
class CashflowViewModel {
  CashflowViewModel({
    required this.repository,
    required this.categoryRepository,
    required this.currencyRepository,
  });

  final CashflowRepository repository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;

  final Signal<ViewState<List<CashflowEntry>>> state = signal(
    const ViewLoading(),
  );
  final Signal<Map<int, String>> categoryNames = signal(const {});
  final Signal<Map<String, Currency>> currencies = signal(const {});

  StreamSubscription<List<CashflowEntry>>? _subscription;
  bool _disposed = false;

  void init() {
    state.value = const ViewLoading();
    _loadReferences();
    _subscribe();
  }

  void reload() => _subscribe();

  void _subscribe() {
    _subscription?.cancel();
    _subscription = repository
        .watch(const CashflowFilter())
        .listen(
          (entries) {
            if (_disposed) return;
            state.value = ViewData(entries);
          },
          onError: (Object _) {
            if (_disposed) return;
            state.value = const ViewError(DomainErrorCode.storageFailure);
          },
        );
  }

  Future<void> _loadReferences() async {
    try {
      final income = await categoryRepository
          .watchByKind(CashflowKind.income, includeArchived: true)
          .first;
      final expense = await categoryRepository
          .watchByKind(CashflowKind.expense, includeArchived: true)
          .first;
      categoryNames.value = {
        for (final category in [...income, ...expense])
          category.id: category.name,
      };
      final list = await currencyRepository.watchAll().first;
      currencies.value = {for (final currency in list) currency.code: currency};
    } on Exception {
      // Справочники не блокируют журнал.
    }
  }

  String categoryName(int id) => categoryNames.value[id] ?? '—';

  Currency currencyOf(String code) =>
      currencies.value[code] ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  String formatAmount(CashflowEntry entry) => const MoneyFormatter().format(
    entry.amount,
    currencyOf(entry.amount.currencyCode),
  );

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
  }
}

/// ViewModel формы дохода/расхода (7.1).
class CashflowFormViewModel {
  CashflowFormViewModel({
    required this.repository,
    required this.categoryRepository,
    required this.currencyRepository,
    required this.commands,
    required this.assetRepository,
    this.editingId,
    this.initialKind = CashflowKind.expense,
  });

  final CashflowRepository repository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;
  final CashflowCommands commands;
  final AssetRepository assetRepository;
  final int? editingId;
  final CashflowKind initialKind;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<CashflowCategory>> categories = signal(const []);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<List<AccountAsset>> accounts = signal(const []);
  final Signal<CashflowEntry?> entry = signal(null);
  final Signal<bool> busy = signal(false);

  bool get isEditing => editingId != null;

  LocalDate get today => commands.today;

  Future<void> load({CashflowKind? kind}) async {
    try {
      final list = await currencyRepository.watchAll().first;
      currencies.value = {for (final currency in list) currency.code: currency};
      if (editingId != null) {
        final current = await repository.getById(editingId!);
        entry.value = current;
        await loadCategories(current.kind);
      } else if (kind != null) {
        await loadCategories(kind);
      }
      final snapshots = await assetRepository.watchAll().first;
      accounts.value = [
        for (final snapshot in snapshots)
          if (snapshot.asset is AccountAsset &&
              (snapshot.asset.archivedAt == null ||
                  snapshot.asset.id == entry.value?.accountId))
            snapshot.asset as AccountAsset,
      ];
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
    required LocalDate occurredOn,
    Decimal? manualRate,
    String? comment,
    int? propertyId,
    int? accountId,
    bool affectsBalance = false,
  }) => commands.save(
    id: editingId,
    kind: kind,
    categoryId: categoryId,
    amount: amount,
    occurredOn: occurredOn,
    manualRate: manualRate,
    comment: comment,
    propertyId: propertyId ?? entry.value?.propertyId,
    accountId: accountId ?? entry.value?.accountId,
    affectsBalance: affectsBalance,
  );

  void dispose() {}
}
