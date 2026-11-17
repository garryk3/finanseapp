import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel Not Found: не содержит сырых route-деталей и исключений.
class NotFoundViewModel {
  final Signal<ViewState<void>> state = signal(const ViewData(null));

  void dispose() {}
}
