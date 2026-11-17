// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_dialog.dart';

/// Подтверждение действия: конкретный title, последствие и named actions.
/// [destructive] окрашивает confirm в error-роли (только delete/replace
/// данных и импорт заменой). [pending] блокирует оба действия и закрытие
/// по barrier там, где отмена невозможна. Диалог не выполняет async-команду
/// сам — View владеет mounted check и последовательностью (patterns.md §1).
///
/// Экраны: все delete/archive подтверждения (Операции, Активы, Цели,
/// Справочники), импорт backup и replace данных Настроек, unsaved-changes
/// при системном Back в формах.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
    this.destructive = false,
    this.pending = false,
  });

  final String title, message, confirmLabel, cancelLabel;
  final VoidCallback onConfirm, onCancel;
  final bool destructive, pending;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final callback = pending ? null : onConfirm;
    return PopScope(
      canPop: !pending,
      child: AppDialog(
        title: Text(title, style: textTheme.titleLarge),
        content: Text(message, style: textTheme.bodyMedium),
        actions: <Widget>[
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.text,
            onPressed: pending ? null : onCancel,
          ),
          AppButton(
            label: confirmLabel,
            variant: destructive
                ? AppButtonVariant.destructive
                : AppButtonVariant.filled,
            pending: pending,
            onPressed: callback,
          ),
        ],
      ),
    );
  }
}
