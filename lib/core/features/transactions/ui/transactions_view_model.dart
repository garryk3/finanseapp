import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Журнал операций по активам: фильтры и реактивный поток (6.3).
class TransactionsViewModel {
  TransactionsViewModel({
    required this.repository,
    required this.assetRepository,
    required this.today,
  });

  final AssetTransactionRepository repository;
  final AssetRepository assetRepository;
  final LocalDate today;

  static const pageSize = 200;

  final Signal<ViewState<List<AssetTransaction>>> state = signal(
    const ViewLoading(),
  );
  final Signal<String> query = signal('');
  final Signal<AssetTransactionKind?> kind = signal(null);
  final Signal<bool> monthOnly = signal(false);
  final Signal<bool> hasMore = signal(false);
  final Signal<bool> loadingMore = signal(false);

  final Map<int, Asset> _assets = {};
  StreamSubscription<List<AssetTransaction>>? _subscription;
  StreamSubscription<List<AssetSnapshot>>? _assetSubscription;
  bool _disposed = false;
  int _limit = pageSize;

  void init() {
    _limit = pageSize;
    hasMore.value = false;
    loadingMore.value = false;
    state.value = const ViewLoading();
    _assetSubscription?.cancel();
    _assetSubscription = assetRepository.watchAll(includeArchived: true).listen(
      (snapshots) {
        _assets
          ..clear()
          ..addEntries(
            snapshots.map(
              (snapshot) => MapEntry(snapshot.asset.id, snapshot.asset),
            ),
          );
      },
      onError: (Object _) {},
    );
    _subscribe();
  }

  /// Обновление после возврата: без мигания skeleton и без новых asset-watch.
  void reload() => _subscribe();

  void _subscribe() {
    _subscription?.cancel();
    _subscription = repository
        .watch(
          TransactionFilter(
            period: monthOnly.value ? _currentMonth() : null,
            kind: kind.value,
            query: query.value,
            limit: _limit + 1,
          ),
        )
        .listen(
          (transactions) {
            if (_disposed) return;
            hasMore.value = transactions.length > _limit;
            loadingMore.value = false;
            state.value = ViewData(transactions.take(_limit).toList());
          },
          onError: (Object _) {
            if (_disposed) return;
            loadingMore.value = false;
            state.value = const ViewError(DomainErrorCode.storageFailure);
          },
        );
  }

  DateRange _currentMonth() {
    final lastDay = DateTime(today.year, today.month + 1, 0).day;
    return DateRange(
      start: LocalDate(today.year, today.month, 1),
      end: LocalDate(today.year, today.month, lastDay),
    );
  }

  void setQuery(String value) {
    query.value = value;
    _limit = pageSize;
    hasMore.value = false;
    _subscribe();
  }

  void setKind(AssetTransactionKind? value) {
    kind.value = value;
    _limit = pageSize;
    hasMore.value = false;
    _subscribe();
  }

  void setMonthOnly(bool value) {
    monthOnly.value = value;
    _limit = pageSize;
    hasMore.value = false;
    _subscribe();
  }

  void loadMore() {
    if (!hasMore.value || loadingMore.value) return;
    loadingMore.value = true;
    _limit += pageSize;
    _subscribe();
  }

  bool get filtersActive =>
      query.value.trim().isNotEmpty || kind.value != null || monthOnly.value;

  void resetFilters() {
    query.value = '';
    kind.value = null;
    monthOnly.value = false;
    _limit = pageSize;
    hasMore.value = false;
    _subscribe();
  }

  Asset? assetOf(AssetTransaction transaction) => _assets[transaction.assetId];

  String assetName(AssetTransaction transaction) =>
      assetOf(transaction)?.name ?? '—';

  String formatAmount(AssetTransaction transaction) {
    return const MoneyFormatter().format(
      transaction.amount,
      Currency(
        code: transaction.amount.currencyCode,
        name: transaction.amount.currencyCode,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      ),
    );
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _assetSubscription?.cancel();
  }
}
