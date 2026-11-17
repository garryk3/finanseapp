import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_ink_well.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Цифровая клавиатура PIN: 0–9 и стирание. Feature-виджет applock.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.backspaceLabel,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final String backspaceLabel;

  static const _keySize = 64.0;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall;

    Widget key(String digit) => AppInkWell(
      onTap: () => onDigit(digit),
      semanticLabel: digit,
      borderRadius: BorderRadius.circular(_keySize / 2),
      child: ExcludeSemantics(
        child: SizedBox(
          width: _keySize,
          height: _keySize,
          child: Center(child: AppText(digit, style: textStyle)),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[for (final d in row) key(d)],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SizedBox(width: _keySize, height: _keySize),
              key('0'),
              AppInkWell(
                onTap: onBackspace,
                semanticLabel: backspaceLabel,
                borderRadius: BorderRadius.circular(_keySize / 2),
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: _keySize,
                    height: _keySize,
                    child: const Center(
                      child: AppIcon(Icons.backspace_outlined, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
