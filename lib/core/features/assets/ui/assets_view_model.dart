import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel активов; watchAll подключается в 5.1.
class AssetsViewModel {
  final Signal<ViewState<void>> state = signal(const ViewData(null));

  void dispose() {}
}
