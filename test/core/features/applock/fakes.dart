import 'dart:async';

import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/features/applock/data/biometric_gateway.dart';
import 'package:finanseapp/core/features/applock/domain/applock_service.dart';
import 'package:finanseapp/core/features/applock/domain/applock_snapshot.dart';
import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:finanseapp/core/features/applock/domain/pin_hasher.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// In-memory хранилище для unit-тестов applock.
class FakeApplockStorage implements ApplockStorage {
  ApplockSnapshot snapshot = const ApplockSnapshot();
  int saveCount = 0;

  @override
  Future<ApplockSnapshot> load() async => snapshot;

  @override
  Future<void> save(ApplockSnapshot value) async {
    snapshot = value;
    saveCount++;
  }
}

/// Ручной fake биометрии (BR-Sec-4: за интерфейсом, Linux/CI не падает).
class FakeBiometricGateway implements BiometricGateway {
  bool available = false;
  bool authenticateResult = false;
  String? lastReason;
  int authenticateCount = 0;

  /// Если задан — `authenticate` ждёт его завершения (проверка состояния
  /// «идёт биометрия»); иначе сразу отдаёт [authenticateResult].
  Completer<bool>? pending;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String reason}) async {
    lastReason = reason;
    authenticateCount++;
    final pending = this.pending;
    if (pending != null) return pending.future;
    return authenticateResult;
  }
}

/// Сервис с фейковым хранилищем и управляемыми часами.
class TestApplockHarness {
  TestApplockHarness({DateTime? start})
    : now = start ?? DateTime(2026, 11, 17, 12) {
    storage = FakeApplockStorage();
    service = ApplockService(
      storage: storage,
      hasher: const PinHasher(useIsolate: false),
      clock: () => now,
    );
  }

  late DateTime now;
  late FakeApplockStorage storage;
  late ApplockService service;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await service.init();
  }

  Future<void> enable(String digits) async {
    await init();
    await service.enable(PinCode.parse(digits));
  }
}

/// Widget-host для экранов applock: тема, русская локаль, bounded размеры.
Widget applockTestHost(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      AppLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ru')],
    home: SizedBox(width: 400, height: 800, child: child),
  );
}

/// A11y-матрица (patterns.md §3): 320dp, font scale 1.3 — без overflow.
Widget applockA11yHost(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      AppLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ru')],
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(320, 640),
        textScaler: TextScaler.linear(1.3),
      ),
      child: child,
    ),
  );
}
