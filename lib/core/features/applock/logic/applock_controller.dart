import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:signals/signals.dart';

/// Глобальное состояние гейта защиты (BR-Sec-6): лок на cold start и при
/// возврате из фона по политике auto-lock. Живёт выше маршрутизации —
/// блокирует любой экран.
class ApplockController {
  ApplockController({required this._service, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final ApplockService _service;
  final DateTime Function() _clock;

  final Signal<bool> locked = signal(false);
  DateTime? _pausedAt;

  bool get enabled => _service.isEnabled;

  Future<void> init() async {
    await _service.init();
    if (_service.isEnabled) locked.value = true;
  }

  void onAppPaused() => _pausedAt = _clock();

  void onAppResumed() {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null || !_service.isEnabled) return;
    if (_service.shouldLockAfterBackground(_clock().difference(pausedAt))) {
      locked.value = true;
    }
  }

  void unlock() => locked.value = false;
}
