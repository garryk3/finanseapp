import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel целей; прогресс подключается в 8.1.
class GoalsViewModel {
  final Signal<ViewState<void>> state = signal(const ViewData(null));

  void dispose() {}
}
