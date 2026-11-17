import 'dart:async';

/// Освобождение ресурса при `ServiceLocator.reset`.
typedef ServiceDisposer<T> = FutureOr<void> Function(T instance);

/// Ручной DI-контейнер (см. `.agents/rules/FLUTTER.md`).
///
/// Регистрация дубликата и запрос незарегистрированного типа — программные
/// ошибки, поэтому бросается `StateError` (в release `assert` исчезает).
/// `reset` освобождает disposable-сервисы и очищает реестр.
final class ServiceLocator {
  final Map<Type, Object> _instances = {};
  final Map<Type, FutureOr<void> Function(Object instance)> _disposers = {};
  final Map<Type, Object Function()> _factories = {};

  /// Регистрирует singleton; [dispose] вызывается один раз в [reset].
  void register<T extends Object>(T instance, {ServiceDisposer<T>? dispose}) {
    _requireTypeFree<T>();
    _instances[T] = instance;
    if (dispose != null) {
      _disposers[T] = (Object value) => dispose(value as T);
    }
  }

  /// Регистрирует factory: каждый [get] создаёт новый экземпляр (для ViewModel).
  void registerFactory<T extends Object>(T Function() factory) {
    _requireTypeFree<T>();
    _factories[T] = factory;
  }

  T get<T extends Object>() {
    final instance = _instances[T];
    if (instance != null) return instance as T;
    final factory = _factories[T];
    if (factory != null) return factory() as T;
    throw StateError('Сервис $T не зарегистрирован в ServiceLocator');
  }

  bool isRegistered<T extends Object>() =>
      _instances.containsKey(T) || _factories.containsKey(T);

  /// Освобождает ресурсы (БД, stream-контроллеры) и очищает реестр.
  ///
  /// Сначала реестр очищается, чтобы во время `dispose` нельзя было получить
  /// «полуживой» singleton, затем disposer'ы выполняются последовательно.
  Future<void> reset() async {
    final instances = Map<Type, Object>.of(_instances);
    final disposers = Map<Type, FutureOr<void> Function(Object)>.of(_disposers);
    _instances.clear();
    _disposers.clear();
    _factories.clear();

    for (final entry in disposers.entries) {
      final instance = instances[entry.key];
      if (instance != null) await entry.value(instance);
    }
  }

  void _requireTypeFree<T extends Object>() {
    if (isRegistered<T>()) {
      throw StateError('Сервис $T уже зарегистрирован в ServiceLocator');
    }
  }
}
