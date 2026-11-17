import 'package:finanseapp/uikit/app_box.dart';
import 'package:material_ui/material_ui.dart';

/// Индикатор ввода PIN: [length] точек, [filled] заполнено.
/// Состояние ошибки дублируется цветом (не только цветом — рядом текст).
/// [semanticsLabel] — готовая строка из feature View (l10n).
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    required this.semanticsLabel,
    this.hasError = false,
  });

  final int length;
  final int filled;
  final String semanticsLabel;
  final bool hasError;

  static const _dotSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filledColor = hasError ? scheme.error : scheme.primary;
    return Semantics(
      label: semanticsLabel,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < length; i++)
            AppBox(
              width: _dotSize,
              height: _dotSize,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              borderRadius: BorderRadius.circular(_dotSize / 2),
              color: i < filled ? filledColor : scheme.outline,
            ),
        ],
      ),
    );
  }
}
