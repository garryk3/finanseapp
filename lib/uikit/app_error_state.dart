// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Ошибка: icon + title + конкретное сообщение (не только красный, не raw
/// exception). Retry опционален: без него feature предлагает другое
/// реальное действие. [compact] — inline-вариант поверх локальных данных
/// (offline network-only, patterns.md §2).
///
/// Экраны: все экраны с error-состоянием — любой журнал/детали (Retry),
/// курсы ЦБ и проверка обновлений (compact + «Ввести вручную»/Retry),
/// Настройки (backup).
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.compact = false,
    this.errorLabel = 'Ошибка',
  });

  final String title, message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final bool compact;

  /// Семантический ярлык иконки ошибки — переопределяется feature (l10n).
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AppIcon(
          Icons.error_outline,
          size: compact ? 24 : 48,
          color: scheme.error,
          semanticLabel: errorLabel,
        ),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.md),
        AppText(
          title,
          style: compact ? textTheme.titleSmall : textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          message,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null && retryLabel != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: retryLabel!,
            variant: AppButtonVariant.tonal,
            onPressed: onRetry,
          ),
        ],
      ],
    );
    if (compact) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: body,
          ),
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: body,
        ),
      ),
    );
  }
}
