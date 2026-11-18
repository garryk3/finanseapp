import 'dart:async';

import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Список активов (5.1: счета; остальные виды — 5.2/5.4).
class AssetsViewModel {
  AssetsViewModel({required this.repository});

  final AssetRepository repository;

  final Signal<ViewState<List<AssetSnapshot>>> state = signal(
    const ViewLoading(),
  );

  StreamSubscription<List<AssetSnapshot>>? _subscription;
  bool _disposed = false;

  void init() {
    state.value = const ViewLoading();
    _subscription = repository.watchAll().listen(
      (snapshots) {
        if (_disposed) return;
        state.value = ViewData(snapshots);
      },
      onError: (Object _) {
        if (_disposed) return;
        state.value = const ViewError(DomainErrorCode.storageFailure);
      },
    );
  }

  void retry() {
    _subscription?.cancel();
    init();
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
  }
}
