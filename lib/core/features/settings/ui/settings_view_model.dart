import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:signals/signals.dart';

/// Настройки: выбранная базовая валюта и переходы (10.3).
class SettingsViewModel {
  SettingsViewModel({required this.repository});

  final SettingsRepository repository;

  final Signal<Currency?> baseCurrency = signal(null);
  StreamSubscription<Currency>? _subscription;
  bool _disposed = false;

  void init() {
    _subscription?.cancel();
    _subscription = repository.watchBaseCurrency().listen((currency) {
      if (_disposed) return;
      baseCurrency.value = currency;
    }, onError: (Object _) {});
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
  }
}
