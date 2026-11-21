import 'dart:async';
import 'dart:developer' as developer;

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Аудит удалённых записей: вход в восстановление (13.1).
class AuditViewModel {
  AuditViewModel({
    required this.transactionRepository,
    required this.cashflowRepository,
    required this.currencyRepository,
    required this.assetRepository,
    required this.categoryRepository,
  });

  final AssetTransactionRepository transactionRepository;
  final CashflowRepository cashflowRepository;
  final CurrencyRepository currencyRepository;
  final AssetRepository assetRepository;
  final CategoryRepository categoryRepository;

  final Signal<List<AssetTransaction>> transactions = signal(const []);
  final Signal<List<CashflowEntry>> entries = signal(const []);
  final Signal<ViewState<void>> state = signal(const ViewLoading());

  StreamSubscription<List<AssetTransaction>>? _transactionSubscription;
  StreamSubscription<List<CashflowEntry>>? _entrySubscription;
  Map<String, Currency> _currencies = const {};
  Map<int, String> _assetNames = const {};
  Map<int, String> _categoryNames = const {};
  bool _transactionsLoaded = false;
  bool _entriesLoaded = false;
  bool _failed = false;
  bool _disposed = false;

  Future<void> load() async {
    state.value = const ViewLoading();
    _failed = false;
    await _loadCurrencies();
    await _loadNames();
    if (_disposed) return;
    _transactionSubscription?.cancel();
    _entrySubscription?.cancel();
    _transactionsLoaded = false;
    _entriesLoaded = false;
    _transactionSubscription = transactionRepository.watchDeleted().listen((
      items,
    ) {
      if (_disposed || _failed) return;
      transactions.value = items;
      _transactionsLoaded = true;
      _markLoaded();
    }, onError: (Object _) => _fail());
    _entrySubscription = cashflowRepository.watchDeleted().listen((items) {
      if (_disposed || _failed) return;
      entries.value = items;
      _entriesLoaded = true;
      _markLoaded();
    }, onError: (Object _) => _fail());
  }

  Future<void> _loadCurrencies() async {
    try {
      final list = await currencyRepository.watchAll().first;
      if (_disposed) return;
      _currencies = {for (final currency in list) currency.code: currency};
    } on Exception catch (error, stackTrace) {
      _log('Не удалось загрузить валюты аудита', error, stackTrace);
      _currencies = const {};
    }
  }

  Future<void> _loadNames() async {
    try {
      final assets = await assetRepository
          .watchAll(includeArchived: true)
          .first;
      if (_disposed) return;
      _assetNames = {for (final item in assets) item.asset.id: item.asset.name};
    } on Exception catch (error, stackTrace) {
      _log('Не удалось загрузить активы аудита', error, stackTrace);
      _assetNames = const {};
    }
    try {
      final categories = [
        ...await categoryRepository
            .watchByKind(CashflowKind.income, includeArchived: true)
            .first,
        ...await categoryRepository
            .watchByKind(CashflowKind.expense, includeArchived: true)
            .first,
      ];
      if (_disposed) return;
      _categoryNames = {for (final item in categories) item.id: item.name};
    } on Exception catch (error, stackTrace) {
      _log('Не удалось загрузить категории аудита', error, stackTrace);
      _categoryNames = const {};
    }
  }

  void _log(String message, Object error, StackTrace stackTrace) => developer
      .log(message, name: 'audit', error: error, stackTrace: stackTrace);

  /// Удалённые записи, которые действительно можно восстановить: запись,
  /// удалённая отвязкой от активной операции, восстановлению не подлежит и
  /// в аудите не показывается.
  List<CashflowEntry> get restorableEntries {
    final deletedTransactions = {
      for (final item in transactions.value) item.id,
    };
    return [
      for (final entry in entries.value)
        if (entry.assetTransactionId == null ||
            deletedTransactions.contains(entry.assetTransactionId))
          entry,
    ];
  }

  int get restorableEntryCount => restorableEntries.length;

  String assetName(int id) => _assetNames[id] ?? '';

  String categoryName(int id) => _categoryNames[id] ?? '';

  void _markLoaded() {
    if (_failed || _disposed) return;
    if (_transactionsLoaded && _entriesLoaded) {
      state.value = const ViewData(null);
    }
  }

  void _fail() {
    if (_disposed) return;
    // Ошибка «залипает»: следующее событие второго потока её не затирает.
    _failed = true;
    state.value = const ViewError(DomainErrorCode.storageFailure);
  }

  String formatAmount(Money amount) =>
      const MoneyFormatter().format(amount, currencyOf(amount.currencyCode));

  Currency currencyOf(String code) =>
      _currencies[code] ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  void dispose() {
    _disposed = true;
    _transactionSubscription?.cancel();
    _entrySubscription?.cancel();
  }
}
