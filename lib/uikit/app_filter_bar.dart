// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_button.dart';

/// Горизонтальный ряд фильтров с кнопкой сброса. Reset показывается только
/// при `activeCount > 0` и сбрасывает одним callback (inputs.md §4).
///
/// Экраны: Операции (тип/категория/период), Активы (kind/архив/query),
/// Аналитика (период/kind/категории), Аудит (тип/query).
class AppFilterBar extends StatelessWidget {
  const AppFilterBar({
    super.key,
    required this.children,
    this.onReset,
    this.resetLabel,
    this.activeCount = 0,
  });

  final List<Widget> children;
  final VoidCallback? onReset;
  final String? resetLabel;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final showReset = onReset != null && activeCount > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            children: <Widget>[
              for (final child in children) ...<Widget>[
                child,
                const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ),
        if (showReset)
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: resetLabel ?? 'Сбросить фильтры',
              variant: AppButtonVariant.text,
              onPressed: onReset,
            ),
          ),
      ],
    );
  }
}
