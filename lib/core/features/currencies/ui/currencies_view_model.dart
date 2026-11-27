import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/rate_refresh_service.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel списка валют: watchAll, enable/disable, rename, delete,
/// ручное обновление курсов (D21.3/R3).
class CurrenciesViewModel {
  CurrenciesViewModel({
    required this.repository,
    required this.settingsRepository,
    required this.rateRefreshService,
  });

  final CurrencyRepository repository;
  final SettingsRepository settingsRepository;
  final RateRefreshService rateRefreshService;

  final Signal<ViewState<List<Currency>>> state = signal(const ViewLoading());
  final Signal<bool> busy = signal(false);
  final Signal<bool> refreshing = signal(false);
  final Signal<String?> baseCode = signal(null);

  StreamSubscription<List<Currency>>? _subscription;
  StreamSubscription<Currency>? _baseSubscription;
  bool _disposed = false;

  void init() {
    _baseSubscription = settingsRepository.watchBaseCurrency().listen(
      (base) => baseCode.value = base.code,
      onError: (Object _) {},
    );
    state.value = const ViewLoading();
    _subscription = repository.watchAll().listen(
      (currencies) {
        if (_disposed) return;
        state.value = ViewData(currencies);
      },
      onError: (Object _) {
        if (_disposed) return;
        state.value = const ViewError(DomainErrorCode.storageFailure);
      },
    );
  }

  void retry() {
    _subscription?.cancel();
    _baseSubscription?.cancel();
    init();
  }

  Future<int> countReferences(String code) => repository.countReferences(code);

  /// Ручное обновление курсов на сегодня (R3): всегда `force`, чтобы кнопка
  /// работала даже после автоматического прогона в тот же день.
  Future<RateRefreshReport> refreshRates() async {
    if (refreshing.value) return const RateRefreshReport.noOp();
    refreshing.value = true;
    try {
      return await rateRefreshService.refreshToday(force: true);
    } finally {
      refreshing.value = false;
    }
  }

  Future<Result<void>> setEnabled(String code, bool value) =>
      _run(() => repository.setEnabled(code, value));

  Future<Result<void>> rename(String code, String name) =>
      _run(() => repository.rename(code, name));

  Future<Result<void>> deleteIfUnused(String code) =>
      _run(() => repository.deleteIfUnused(code));

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
    await _baseSubscription?.cancel();
  }

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    busy.value = true;
    try {
      return Success(await action());
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }
}
