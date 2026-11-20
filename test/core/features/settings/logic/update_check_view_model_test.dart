import 'package:finanseapp/core/features/settings/domain/update_service.dart';
import 'package:finanseapp/core/features/settings/logic/update_check_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Service implements UpdateService {
  _Service(this.release, {this.error});

  final ReleaseInfo? release;
  final Object? error;
  int calls = 0;

  @override
  Future<ReleaseInfo?> fetchLatestRelease() async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return release;
  }
}

void main() {
  test('update available / upToDate / no releases / invalid version', () async {
    final available = UpdateCheckViewModel(
      service: _Service(const ReleaseInfo(tagName: 'v1.2.0')),
      installedVersionProvider: () async => '1.1.0',
    );
    await available.check();
    expect(available.status.value, UpdateStatus.updateAvailable);
    expect(available.release.value?.tagName, 'v1.2.0');

    final current = UpdateCheckViewModel(
      service: _Service(const ReleaseInfo(tagName: '1.1.0')),
      installedVersionProvider: () async => '1.1.0',
    );
    await current.check();
    expect(current.status.value, UpdateStatus.upToDate);

    final none = UpdateCheckViewModel(
      service: _Service(null),
      installedVersionProvider: () async => '1.1.0',
    );
    await none.check();
    expect(none.errorKind.value, UpdateErrorKind.noReleases);

    final invalid = UpdateCheckViewModel(
      service: _Service(const ReleaseInfo(tagName: 'not-a-version')),
      installedVersionProvider: () async => '1.1.0',
    );
    await invalid.check();
    expect(invalid.errorKind.value, UpdateErrorKind.invalid);
  });

  test('double check даёт один вызов', () async {
    final service = _Service(const ReleaseInfo(tagName: '1.2.0'));
    final vm = UpdateCheckViewModel(
      service: service,
      installedVersionProvider: () async => '1.1.0',
    );
    await Future.wait([vm.check(), vm.check()]);
    expect(service.calls, 1);
  });

  test('network error маппится', () async {
    final vm = UpdateCheckViewModel(
      service: _Service(
        null,
        error: const UpdateException(UpdateErrorKind.network),
      ),
      installedVersionProvider: () async => '1.1.0',
    );
    await vm.check();
    expect(vm.status.value, UpdateStatus.error);
    expect(vm.errorKind.value, UpdateErrorKind.network);
  });

  test('openUpdate: APK fail → page, обе fail → openFailed', () async {
    final opened = <String>[];
    final fallback = UpdateCheckViewModel(
      service: _Service(const ReleaseInfo(tagName: '1.2.0')),
      installedVersionProvider: () async => '1.1.0',
      opener: (url) async {
        opened.add(url);
        return url.contains('page');
      },
    );
    fallback.release.value = const ReleaseInfo(
      tagName: '1.2.0',
      apkUrl: 'https://apk',
      htmlUrl: 'https://page',
    );
    await fallback.openUpdate();
    expect(opened, ['https://apk', 'https://page']);

    final failed = UpdateCheckViewModel(
      service: _Service(const ReleaseInfo(tagName: '1.2.0')),
      installedVersionProvider: () async => '1.1.0',
      opener: (_) async => false,
    );
    failed.release.value = const ReleaseInfo(
      tagName: '1.2.0',
      apkUrl: 'https://apk',
      htmlUrl: 'https://page',
    );
    await failed.openUpdate();
    expect(failed.status.value, UpdateStatus.openFailed);
  });
}
