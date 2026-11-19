import 'dart:async';
import 'dart:developer' as developer;

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
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
    required this.assetRepository,
    required this.today,
  });

  final CashflowRepository repository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;
  final AssetRepository assetRepository;
  final LocalDate today;

  final Signal<ViewState<List<CashflowEntry>>> state = signal(
    const ViewLoading(),
  );
  final Signal<Map<int, String>> categoryNames = signal(const {});
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<List<CashflowCategory>> categories = signal(const []);
  final Signal<List<AccountAsset>> accounts = signal(const []);
  final Signal<List<PropertyAsset>> properties = signal(const []);
  final Signal<String> query = signal('');
  final Signal<CashflowKind?> kind = signal(null);
  final Signal<CashflowJournalPeriod> period = signal(
    CashflowJournalPeriod.all,
  );
  final Signal<int?> categoryId = signal(null);
  final Signal<int?> accountId = signal(null);
  final Signal<String?> currencyCode = signal(null);
  final Signal<int?> propertyId = signal(null);

  StreamSubscription<List<CashflowEntry>>? _subscription;
  bool _disposed = false;

  void init() {
    state.value = const ViewLoading();
    _loadReferences();
    _subscribe();
  }

  void reload() => _subscribe();

  bool get filtersActive =>
      query.value.trim().isNotEmpty ||
      kind.value != null ||
      period.value != CashflowJournalPeriod.all ||
      categoryId.value != null ||
      accountId.value != null ||
      currencyCode.value != null ||
      propertyId.value != null;

  void setQuery(String value) {
    query.value = value;
    _subscribe();
  }

  void setKind(CashflowKind? value) {
    kind.value = value;
    _subscribe();
  }

  void setPeriod(CashflowJournalPeriod value) {
    period.value = value;
    _subscribe();
  }

  void setCategory(int? value) {
    categoryId.value = value;
    _subscribe();
  }

  void setAccount(int? value) {
    accountId.value = value;
    _subscribe();
  }

  void setCurrency(String? value) {
    currencyCode.value = value;
    _subscribe();
  }

  void setProperty(int? value) {
    propertyId.value = value;
    _subscribe();
  }

  void resetFilters() {
    query.value = '';
    kind.value = null;
    period.value = CashflowJournalPeriod.all;
    categoryId.value = null;
    accountId.value = null;
    currencyCode.value = null;
    propertyId.value = null;
    _subscribe();
  }

  DateRange? get _range => switch (period.value) {
    CashflowJournalPeriod.month => DateRange(
      start: LocalDate(today.year, today.month, 1),
      end: LocalDate(
        today.year,
        today.month,
        DateTime(today.year, today.month + 1, 0).day,
      ),
    ),
    CashflowJournalPeriod.year => DateRange(
      start: LocalDate(today.year, 1, 1),
      end: LocalDate(today.year, 12, 31),
    ),
    CashflowJournalPeriod.all => null,
  };

  void _subscribe() {
    _subscription?.cancel();
    _subscription = repository
        .watch(
          CashflowFilter(
            period: _range,
            kind: kind.value,
            categoryId: categoryId.value,
            accountId: accountId.value,
            currencyCode: currencyCode.value,
            propertyId: propertyId.value,
            query: query.value,
          ),
        )
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
      final all = [...income, ...expense];
      categories.value = all;
      categoryNames.value = {
        for (final category in all) category.id: category.name,
      };
      final list = await currencyRepository.watchAll().first;
      currencies.value = {for (final currency in list) currency.code: currency};
      final snapshots = await assetRepository.watchAll().first;
      accounts.value = [
        for (final snapshot in snapshots)
          if (snapshot.asset is AccountAsset &&
              snapshot.asset.archivedAt == null)
            snapshot.asset as AccountAsset,
      ];
      properties.value = [
        for (final snapshot in snapshots)
          if (snapshot.asset is PropertyAsset &&
              snapshot.asset.archivedAt == null)
            snapshot.asset as PropertyAsset,
      ];
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

/// Период журнала денежного потока.
enum CashflowJournalPeriod { month, year, all }

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
    this.propertyId,
  });

  final CashflowRepository repository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;
  final CashflowCommands commands;
  final AssetRepository assetRepository;
  final int? editingId;
  final CashflowKind initialKind;
  final int? propertyId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<CashflowCategory>> categories = signal(const []);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<List<AccountAsset>> accounts = signal(const []);
  final Signal<PropertyAsset?> property = signal(null);
  final Signal<CashflowEntry?> entry = signal(null);
  final Signal<bool> busy = signal(false);

  bool get isEditing => editingId != null;

  LocalDate get today => commands.today;

  Future<void> load({CashflowKind? kind}) async {
    try {
      if (propertyId != null) {
        final snapshot = await assetRepository.getById(propertyId!);
        if (snapshot.asset is! PropertyAsset) {
          state.value = const ViewError(DomainErrorCode.notFound);
          return;
        }
        property.value = snapshot.asset as PropertyAsset;
      }
      final list = await currencyRepository.watchAll().first;
      currencies.value = {for (final currency in list) currency.code: currency};
      if (editingId != null) {
        final current = await repository.getById(editingId!);
        entry.value = current;
        if (propertyId == null && current.propertyId != null) {
          try {
            final snapshot = await assetRepository.getById(current.propertyId!);
            if (snapshot.asset is PropertyAsset) {
              property.value = snapshot.asset as PropertyAsset;
            }
          } on DomainException {
            // Нет доступа к квартире — контекст просто не показываем.
          } catch (error, stackTrace) {
            developer.log(
              'Не удалось загрузить контекст квартиры',
              name: 'cashflow.form',
              error: error,
              stackTrace: stackTrace,
            );
          }
        }
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
    propertyId: propertyId ?? entry.value?.propertyId ?? this.propertyId,
    accountId: accountId,
    affectsBalance: affectsBalance,
  );

  void dispose() {}
}
