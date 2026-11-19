import 'dart:async';

import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:material_ui/material_ui.dart';

/// Тик полного пересоздания приложения после импорта БД (BR-BU-6).
final ValueNotifier<int> appRestartTick = ValueNotifier<int>(0);

final List<Completer<void>> _restartWaiters = <Completer<void>>[];

/// Запрашивает полный restart; future завершается после сборки нового DI.
Future<void> restartApp() {
  final completer = Completer<void>();
  _restartWaiters.add(completer);
  appRestartTick.value++;
  return completer.future;
}

void completeAppRestart() {
  final waiters = [..._restartWaiters];
  _restartWaiters.clear();
  for (final waiter in waiters) {
    if (!waiter.isCompleted) waiter.complete();
  }
}

/// Владелец ServiceLocator: пересоздаёт его по [appRestartTick].
class AppRestartHost extends StatefulWidget {
  const AppRestartHost({super.key, required this.build});

  final Future<ServiceLocator> Function() build;

  @override
  State<AppRestartHost> createState() => _AppRestartHostState();
}

class _AppRestartHostState extends State<AppRestartHost> {
  ServiceLocator? _locator;
  int _generation = 0;
  bool _restarting = false;

  @override
  void initState() {
    super.initState();
    appRestartTick.addListener(_restart);
    _load();
  }

  Future<void> _load() async {
    final locator = await widget.build();
    if (!mounted) return;
    setState(() {
      _locator = locator;
      _generation++;
    });
    completeAppRestart();
  }

  Future<void> _restart() async {
    if (_restarting) return;
    _restarting = true;
    final old = _locator;
    setState(() => _locator = null);
    await old?.reset();
    await _load();
    _restarting = false;
  }

  @override
  void dispose() {
    appRestartTick.removeListener(_restart);
    _locator?.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locator = _locator;
    if (locator == null) return const SizedBox.shrink();
    return FinanseApp(key: ValueKey(_generation), locator: locator);
  }
}
