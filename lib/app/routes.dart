/// Статические пути маршрутов. Полная карта — в
/// `docs/architecture/navigation_and_screens.md` §2.
abstract final class AppRoutes {
  /// Управление защитой приложения (PIN-код, биометрия, auto-lock).
  /// Переедет в настройки (10.3) вместе с точкой входа.
  static const applockManage = '/applock';
}
