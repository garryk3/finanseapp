import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// О приложении: версия будет подключена в 10.5.
class AboutViewModel {
  final Signal<ViewState<void>> state = signal(const ViewData(null));

  void dispose() {}
}
