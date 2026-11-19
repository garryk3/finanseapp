import 'package:finanseapp/core/features/backup/domain/backup_exception.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:finanseapp/core/features/backup/logic/backup_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Service implements BackupService {
  _Service({this.onImport});

  final Future<void> Function(String path)? onImport;
  int exports = 0;
  int imports = 0;

  @override
  Future<BackupFile> exportDatabase() async {
    exports++;
    return const BackupFile(path: '/tmp/x.sqlite', fileName: 'x.sqlite');
  }

  @override
  Future<void> importDatabase(String sourcePath) async {
    imports++;
    await onImport?.call(sourcePath);
  }
}

final class _Gateway implements BackupFileGateway {
  _Gateway({this.outcome = BackupShareOutcome.shared, this.source = '/tmp/a'});

  final BackupShareOutcome outcome;
  final String? source;
  int shares = 0;

  @override
  Future<String?> pickDatabase() async => source;

  @override
  Future<BackupShareOutcome> share(BackupFile file) async {
    shares++;
    return outcome;
  }

  @override
  Future<bool> save(BackupFile file, {required String dialogTitle}) async =>
      true;
}

void main() {
  test(
    'share outcomes: shared/cancelled/unavailable — нейтральные статусы',
    () async {
      for (final entry in {
        BackupShareOutcome.shared: BackupStatusKind.exportShared,
        BackupShareOutcome.cancelled: BackupStatusKind.shareCancelled,
        BackupShareOutcome.unavailable: BackupStatusKind.shareResultUnknown,
      }.entries) {
        final vm = BackupViewModel(_Service.new, _Gateway(outcome: entry.key));
        expect(await vm.exportShared(), isTrue);
        expect(vm.state.value.status, entry.value);
        expect(vm.state.value.isBusy, isFalse);
      }
    },
  );

  test('import: success, validation и blocking restoreFailed', () async {
    final ok = BackupViewModel(_Service.new, _Gateway());
    expect(await ok.importSelected(), isTrue);
    expect(ok.state.value.status, BackupStatusKind.importDone);

    final invalid = BackupViewModel(
      () => _Service(
        onImport: (_) async => throw const BackupValidationException(
          BackupValidationError.notFinanseApp,
        ),
      ),
      _Gateway(),
    );
    expect(await invalid.importSelected(), isFalse);
    expect(
      invalid.state.value.validationError?.reason,
      BackupValidationError.notFinanseApp,
    );

    final failed = BackupViewModel(
      () => _Service(
        onImport: (_) async =>
            throw const BackupStorageException(BackupStorageOperation.reopen),
      ),
      _Gateway(),
    );
    expect(await failed.importSelected(), isFalse);
    expect(failed.state.value.status, BackupStatusKind.importFailed);

    final blocked = BackupViewModel(
      () => _Service(
        onImport: (_) async =>
            throw const BackupStorageException(BackupStorageOperation.rollback),
      ),
      _Gateway(),
    );
    expect(await blocked.importSelected(), isFalse);
    expect(blocked.state.value.status, BackupStatusKind.restoreFailed);
    expect(blocked.state.value.blocking, isTrue);
    expect(await blocked.importSelected(), isFalse);
  });

  test('busy блокирует повторный вызов и pick cancel нейтрален', () async {
    final gateway = _Gateway(source: null);
    final vm = BackupViewModel(_Service.new, gateway);
    expect(await vm.importSelected(), isFalse);
    expect(vm.state.value.status, isNull);
  });
}
