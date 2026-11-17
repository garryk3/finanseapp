import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel экрана «Ещё»; навигация — через View (named routes).
class MoreViewModel {
  final Signal<ViewState<void>> state = signal(const ViewData(null));

  void dispose() {}
}
