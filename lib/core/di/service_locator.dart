/// Ручной DI-контейнер (manual DI, см. .agents/rules/FLUTTER.md):
/// зависимости явно регистрируются при старте и запрашиваются по типу.
class ServiceLocator {
  final Map<Type, Object> _services = {};

  void register<T extends Object>(T instance) {
    final Object? existing = _services[T];
    assert(existing == null, 'Сервис $T уже зарегистрирован');
    _services[T] = instance;
  }

  T get<T extends Object>() {
    final Object? instance = _services[T];
    assert(instance != null, 'Сервис $T не зарегистрирован');
    return instance! as T;
  }
}
