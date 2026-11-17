import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel операций по активам; поток подключается в 6.1.
class TransactionsViewModel {
  final Signal<ViewState<void>> state = signal(const ViewData(null));

  void dispose() {}
}
