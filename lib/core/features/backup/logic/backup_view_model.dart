import 'package:finanseapp/core/features/backup/domain/backup_exception.dart';
import 'package:finanseapp/core/features/backup/domain/backup_service.dart';
import 'package:signals/signals.dart';

enum BackupAction { share, save, import }

enum BackupStatusKind {
  exportShared,
  exportSaved,
  shareCancelled,
  shareResultUnknown,
  saveCancelled,
  importDone,
  exportFailed,
  importFailed,
  restoreFailed,
}

final class BackupState {
  const BackupState({
    this.isBusy = false,
    this.status,
    this.validationError,
    this.storageError,
    this.busyAction,
  });

  final bool isBusy;
  final BackupStatusKind? status;
  final BackupValidationException? validationError;
  final BackupStorageException? storageError;
  final BackupAction? busyAction;

  bool get blocking => status == BackupStatusKind.restoreFailed;

  bool get requiresRestart =>
      blocking ||
      (status == BackupStatusKind.importFailed &&
          storageError?.operation == BackupStorageOperation.reopen);

  BackupState copyWith({
    bool? isBusy,
    BackupStatusKind? status,
    BackupValidationException? validationError,
    BackupStorageException? storageError,
    BackupAction? busyAction,
    bool clearStatus = false,
  }) => BackupState(
    isBusy: isBusy ?? this.isBusy,
    status: clearStatus ? null : status ?? this.status,
    validationError: validationError ?? this.validationError,
    storageError: storageError ?? this.storageError,
    busyAction: busyAction,
  );
}

/// Backup actions с typed-статусами и блокировкой после restoreFailed.
final class BackupViewModel {
  BackupViewModel(this._serviceFactory, this._files);

  final BackupService Function() _serviceFactory;
  final BackupFileGateway _files;

  final Signal<BackupState> state = signal(const BackupState());
  bool _disposed = false;

  Future<bool> exportShared() async {
    if (!_begin(BackupAction.share)) return false;
    try {
      final file = await _serviceFactory().exportDatabase();
      final outcome = await _files.share(file);
      _set(switch (outcome) {
        BackupShareOutcome.shared => const BackupState(
          status: BackupStatusKind.exportShared,
        ),
        BackupShareOutcome.cancelled => const BackupState(
          status: BackupStatusKind.shareCancelled,
        ),
        BackupShareOutcome.unavailable => const BackupState(
          status: BackupStatusKind.shareResultUnknown,
        ),
      });
      return true;
    } on Exception {
      _set(const BackupState(status: BackupStatusKind.exportFailed));
      return false;
    } on UnimplementedError {
      _set(const BackupState(status: BackupStatusKind.exportFailed));
      return false;
    } finally {
      _endBusy();
    }
  }

  Future<bool> exportSaved({required String dialogTitle}) async {
    if (!_begin(BackupAction.save)) return false;
    try {
      final file = await _serviceFactory().exportDatabase();
      final saved = await _files.save(file, dialogTitle: dialogTitle);
      _set(
        BackupState(
          status: saved
              ? BackupStatusKind.exportSaved
              : BackupStatusKind.saveCancelled,
        ),
      );
      return true;
    } on Exception {
      _set(const BackupState(status: BackupStatusKind.exportFailed));
      return false;
    } on UnimplementedError {
      _set(const BackupState(status: BackupStatusKind.exportFailed));
      return false;
    } finally {
      _endBusy();
    }
  }

  Future<bool> importSelected() async {
    if (!_begin(BackupAction.import)) return false;
    try {
      final source = await _files.pickDatabase();
      if (source == null) {
        _endBusy();
        return false;
      }
      await _serviceFactory().importDatabase(source);
      _set(const BackupState(status: BackupStatusKind.importDone));
      return true;
    } on BackupValidationException catch (error) {
      _set(BackupState(validationError: error));
      return false;
    } on BackupStorageException catch (error) {
      _set(
        BackupState(
          status: error.operation == BackupStorageOperation.rollback
              ? BackupStatusKind.restoreFailed
              : BackupStatusKind.importFailed,
          storageError: error,
        ),
      );
      return false;
    } on Exception {
      _set(const BackupState(status: BackupStatusKind.importFailed));
      return false;
    } finally {
      _endBusy();
    }
  }

  void clearStatus() {
    if (state.value.blocking) return;
    _set(const BackupState());
  }

  bool _begin(BackupAction action) {
    if (_disposed || state.value.isBusy || state.value.requiresRestart) {
      return false;
    }
    state.value = BackupState(isBusy: true, busyAction: action);
    return true;
  }

  void _set(BackupState value) {
    if (_disposed) return;
    state.value = value.copyWith(isBusy: state.value.isBusy);
  }

  void _endBusy() {
    if (_disposed) return;
    final current = state.value;
    state.value = current.copyWith(isBusy: false, busyAction: null);
  }

  void dispose() {
    _disposed = true;
  }
}
