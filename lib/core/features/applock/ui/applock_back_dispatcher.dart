import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:flutter/widgets.dart';

/// Перехват системного BACK для go_router (BR-Sec-6): лок-скрин — overlay,
/// а не route, поэтому без диспетчера back снимал бы маршрут под защитой.
/// Это точка входа системного back у Router (`handlePopRoute` → observer'ы
/// в прямом порядке → RootBackButtonDispatcher первым).
class ApplockBackDispatcher extends RootBackButtonDispatcher {
  ApplockBackDispatcher(this._controller);

  final ApplockController _controller;

  @override
  Future<bool> didPopRoute() async {
    if (_controller.locked.value) return true;
    return super.didPopRoute();
  }
}
