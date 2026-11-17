// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Показывает SnackBar как дополнительное подтверждение действия — не
/// единственный канал ошибки (DESIGN.md §5).
///
/// Экраны: все экраны CRUD — подтверждение create/update/delete/archive,
/// backup-действия Настроек. `isError` — критические сбои с icon-стилизацией.
Future<void> showAppSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  bool isError = false,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final scheme = Theme.of(context).colorScheme;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: <Widget>[
          if (isError) ...<Widget>[
            Icon(Icons.error_outline, size: 20, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              // При errorContainer дефолтный onInverseSurface даёт ~1.2:1 —
              // явный onErrorContainer (WCAG AA).
              style: isError ? TextStyle(color: scheme.onErrorContainer) : null,
            ),
          ),
        ],
      ),
      backgroundColor: isError ? scheme.errorContainer : null,
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: isError ? scheme.onErrorContainer : null,
              onPressed: onAction ?? () {},
            ),
    ),
  );
}
