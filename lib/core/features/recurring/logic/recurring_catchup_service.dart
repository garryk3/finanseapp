import 'dart:developer' as developer;

import 'package:finanseapp/core/features/recurring/logic/recurring_generator.dart';

/// Триггер догоняющей генерации с коалесцированием вызовов (BR-RC-11, D8).
///
/// Пока прогон идёт, повторные вызовы ставят флаг и запускают ещё один прогон
/// после текущего — без параллельных генераций. Ошибки логируются и не
/// пробрасываются: catch-up не должен ломать старт приложения.
final class RecurringCatchupService {
  RecurringCatchupService({required this.generator});

  final RecurringGenerator generator;

  bool _running = false;
  bool _queued = false;

  Future<void> catchUp() async {
    if (_running) {
      _queued = true;
      return;
    }
    _running = true;
    try {
      do {
        _queued = false;
        final report = await generator.run();
        if (report.generated > 0 || report.pending.isNotEmpty) {
          developer.log(
            'Recurring catch-up: generated ${report.generated}, '
            'pending ${report.pending.length}',
            name: 'recurring.catchup',
          );
        }
      } while (_queued);
    } catch (error, stackTrace) {
      developer.log(
        'Recurring catch-up failed',
        name: 'recurring.catchup',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _running = false;
    }
  }
}
