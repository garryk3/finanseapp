// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Диалог с доступным title, контентом и действиями. При узком экране
/// действия переносятся без overflow.
///
/// Экраны: выбор периода Аналитики, информационные диалоги О приложении,
/// все подтверждения через [AppConfirmDialog].
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const <Widget>[],
    this.scrollable = false,
  });

  final Widget? title, content;
  final List<Widget> actions;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      scrollable: scrollable,
      actions: actions.isEmpty
          ? null
          : <Widget>[
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: actions,
              ),
            ],
    );
  }
}

/// Показывает [AppDialog]; [barrierDismissible] = false только для
/// blocking-сценариев (import/restart).
///
/// Экраны: см. [AppDialog], [AppConfirmDialog], Настройки (import).
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}
