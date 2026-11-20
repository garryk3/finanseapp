import 'package:finanseapp/core/features/settings/domain/app_version.dart';
import 'package:finanseapp/core/features/settings/domain/update_service.dart';
import 'package:signals/signals.dart';

enum UpdateStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  error,
  openFailed,
}

/// Ручная проверка обновлений (UP-1…3).
final class UpdateCheckViewModel {
  UpdateCheckViewModel({
    required this.service,
    required this.installedVersionProvider,
    this.opener,
  });

  final UpdateService service;
  final Future<String> Function() installedVersionProvider;
  final Future<bool> Function(String url)? opener;

  final Signal<UpdateStatus> status = signal(UpdateStatus.idle);
  final Signal<String?> installedVersion = signal(null);
  final Signal<ReleaseInfo?> release = signal(null);
  final Signal<UpdateErrorKind?> errorKind = signal(null);

  bool _checking = false;
  bool _disposed = false;

  Future<void> init() async {
    try {
      installedVersion.value = await installedVersionProvider();
    } on Exception {
      installedVersion.value = null;
    }
  }

  Future<void> check() async {
    if (_checking || _disposed) return;
    _checking = true;
    status.value = UpdateStatus.checking;
    errorKind.value = null;
    try {
      final installed = await installedVersionProvider();
      installedVersion.value = installed;
      final latest = await service.fetchLatestRelease();
      if (_disposed) return;
      if (latest == null) {
        errorKind.value = UpdateErrorKind.noReleases;
        status.value = UpdateStatus.error;
        return;
      }
      final installedValue = AppVersion.parse(installed);
      final latestVersion = AppVersion.parse(latest.tagName);
      release.value = latest;
      status.value = latestVersion > installedValue
          ? UpdateStatus.updateAvailable
          : UpdateStatus.upToDate;
    } on FormatException {
      if (_disposed) return;
      errorKind.value = UpdateErrorKind.invalid;
      status.value = UpdateStatus.error;
    } on UpdateException catch (error) {
      if (_disposed) return;
      errorKind.value = error.kind;
      status.value = UpdateStatus.error;
    } on Exception {
      if (_disposed) return;
      errorKind.value = UpdateErrorKind.network;
      status.value = UpdateStatus.error;
    } finally {
      _checking = false;
    }
  }

  Future<void> openUpdate() async {
    final latest = release.value;
    final open = opener;
    if (latest == null || open == null) {
      status.value = UpdateStatus.openFailed;
      return;
    }
    for (final url in [latest.apkUrl, latest.htmlUrl]) {
      if (url == null) continue;
      try {
        if (await open(url)) return;
      } on Exception {
        // пробуем следующий URL
      }
    }
    status.value = UpdateStatus.openFailed;
  }

  void dispose() {
    _disposed = true;
  }
}
