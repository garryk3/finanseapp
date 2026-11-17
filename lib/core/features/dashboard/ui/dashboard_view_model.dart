import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel главной: до 10.1 показывает реальные итоги из AnalyticsQueries.
class DashboardViewModel {
  final Signal<ViewState<void>> state = signal(const ViewData(null));

  /// Освобождает подписки, когда появятся stream'ы (10.1).
  void dispose() {}
}
