import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/settings/domain/display_settings_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:signals/signals.dart';

/// Настройки: базовая валюта, отображение сумм и переходы (10.3, D21.4).
class SettingsViewModel {
  SettingsViewModel({required this.repository, required this.display});

  final SettingsRepository repository;
  final DisplaySettingsRepository display;

  final Signal<Currency?> baseCurrency = signal(null);

  /// Скрывать суммы при входе на Главную (D21.4); персистится в `app_settings`.
  final Signal<bool> amountsHidden = signal(false);

  StreamSubscription<Currency>? _subscription;
  StreamSubscription<bool>? _amountsHiddenSubscription;
  bool _disposed = false;

  void init() {
    _subscription?.cancel();
    _subscription = repository.watchBaseCurrency().listen((currency) {
      if (_disposed) return;
      baseCurrency.value = currency;
    }, onError: (Object _) {});
    _amountsHiddenSubscription?.cancel();
    _amountsHiddenSubscription = display.watchAmountsHidden().listen((hidden) {
      if (_disposed) return;
      amountsHidden.value = hidden;
    }, onError: (Object _) {});
  }

  Future<void> setAmountsHidden(bool hidden) async {
    if (_disposed) return;
    amountsHidden.value = hidden;
    try {
      await display.setAmountsHidden(hidden);
    } on Object {
      // Значение уже показано; подписка вернёт фактическое состояние.
    }
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _amountsHiddenSubscription?.cancel();
  }
}
