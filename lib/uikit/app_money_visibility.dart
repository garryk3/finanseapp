// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Скоуп видимости денежных значений (D21.4).
///
/// `hidden == true` — все денежные значения под этим узлом прячутся за
/// блюром (`AppAmountBlur`/`AppMoneyText`). Провайдерится на Главной;
/// вне него значения показываются как обычно.
///
/// Экраны: Dashboard (переключатель «скрыть суммы»).
class AppMoneyVisibility extends InheritedWidget {
  const AppMoneyVisibility({
    super.key,
    required this.hidden,
    required super.child,
  });

  /// Скрыты ли денежные значения в этом поддереве.
  final bool hidden;

  /// Текущее состояние; без провайдера — `false` (значения видимы).
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AppMoneyVisibility>()
          ?.hidden ??
      false;

  @override
  bool updateShouldNotify(AppMoneyVisibility oldWidget) =>
      oldWidget.hidden != hidden;
}
