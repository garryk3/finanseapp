// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Неразрушающая inline-плашка: иконка + сообщение (+ опциональное действие).
///
/// Не использует `error`-роль: «Курс недоступен»/резервный курс, неполные
/// данные и предупреждения — не destructive (DESIGN.md §2). Для ошибок с
/// retry — [AppErrorState].
///
/// Экраны: Главная (резервный курс, BR-C-9), предупреждения поверх данных.
class AppWarningBanner extends StatelessWidget {
  const AppWarningBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel и onAction задаются вместе',
       );

  /// Текст предупреждения; переносится, не обрезается.
  final String message;

  /// Ведущая иконка; `null` — без иконки.
  final IconData? icon;

  /// Подпись опционального текстового действия (например, «Повторить»).
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Ярлык для screen reader; по умолчанию (null) читается [message].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tone = resolveStatusToneColor(context, AppStatusTone.warning);
    return Semantics(
      container: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: AppRadii.input,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                AppIcon(icon!, size: 20, color: tone),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: AppText(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: actionLabel!,
                  variant: AppButtonVariant.text,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
