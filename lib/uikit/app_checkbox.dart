// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Checkbox с кликабельной подписью — одна target ≥48dp. Disabled сохраняет
/// читаемый label. [tristate] включает промежуточное состояние.
///
/// Экраны: GoalForm (multi-select активов цели), фильтры Аудита/Операций,
/// подтверждения в формах.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.tristate = false,
  });

  final bool? value;
  final String label;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      checked: value ?? false,
      enabled: onChanged != null,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(value != true),
        borderRadius: AppRadii.input,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Checkbox(value: value, onChanged: onChanged, tristate: tristate),
              Expanded(
                child: AppText(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
