import 'package:signals/signals.dart';

/// In-process invalidation after a rate was stored (manual or CBR).
///
/// Signals-runtime avoids a global stream and lets screens recompute only when
/// a rate actually changed; subscribers must cancel in `dispose()`.
///
/// Current subscriber: `DashboardViewModel`. A new long-lived screen
/// (StatefulShellRoute) that shows converted amounts must subscribe itself.
final Signal<int> exchangeRateRevision = signal(0);

void markExchangeRateChanged() => exchangeRateRevision.value++;
