// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_money_visibility.dart';

/// Прячет денежное значение за блюром, когда активно [AppMoneyVisibility]
/// (D21.4). При `hidden` дополнительно исключает узел из семантики, чтобы
/// TalkBack не прочитал скрытую сумму.
///
/// Используется для значений, которые не идут через `AppMoneyText`
/// (например, денежные части составных текстов и график).
///
/// Экраны: Dashboard (карточки целей, подушка безопасности, график).
class AppAmountBlur extends StatelessWidget {
  const AppAmountBlur({super.key, required this.child, this.blurSigma = 4});

  final Widget child;

  /// Радиус размытия (симметричный по осям), по умолчанию 4.
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    if (!AppMoneyVisibility.of(context)) return child;
    // `container: true` обязателен: без собственного узла флаг `hidden`
    // поглощается ближайшим родительским узлом с подписью (например,
    // `Semantics` в `AppCard`) и теряется — сумма снова попадает в label
    // карточки и читается TalkBack'ом.
    return Semantics(
      container: true,
      hidden: true,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: child,
      ),
    );
  }
}
