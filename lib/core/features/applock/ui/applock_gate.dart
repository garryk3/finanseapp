import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Гейт защиты (BR-Sec-6): слушает lifecycle, при локе перекрывает приложение
/// экраном блокировки независимо от текущего маршрута. Живёт в `builder` у
/// `MaterialApp.router`, поэтому лок-скрин имеет тему и локализацию.
class AppLockGate extends StatefulWidget {
  const AppLockGate({
    super.key,
    required this.controller,
    required this.lockViewModel,
    required this.child,
  });

  final ApplockController controller;
  final ApplockViewModel lockViewModel;
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  ApplockController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Только `paused`: `inactive` срабатывает при системном диалоге биометрии
  /// и не должен дёргать лок до завершения аутентификации.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      controller.onAppResumed();
    }
  }

  /// Системный BACK перехватывается в [ApplockBackDispatcher] — точке входа
  /// go_router: под локом pop маршрута под оверлеем запрещён (BR-Sec-6).
  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) => Stack(
        children: <Widget>[
          widget.child,
          if (controller.locked.value)
            ApplockScreen(viewModel: widget.lockViewModel),
        ],
      ),
    );
  }
}
