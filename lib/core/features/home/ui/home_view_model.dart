import 'package:signals/signals.dart';

/// ViewModel домашнего экрана (MVVM; зависимости — через конструктор, manual DI).
///
/// Демо-счётчик — минимальная демонстрация стека state management (`signals`);
/// уйдёт вместе с реальным содержимым домашнего экрана.
class HomeViewModel {
  final Signal<int> counter = signal(0);

  void increment() {
    counter.value++;
  }
}
