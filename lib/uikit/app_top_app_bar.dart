// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Top app bar экрана. [large] — развёрнутый заголовок (headline) для
/// ключевых summary-экранов.
///
/// Экраны: все экраны с заголовком; `large` — Dashboard (net worth в шапке),
/// Аналитика.
class AppTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.large = false,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final bool large;

  @override
  Size get preferredSize => Size.fromHeight(large ? 128 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    if (large) {
      // M3 large top bar: компактный toolbar + headlineSmall заголовок
      // в bottom-секции (foundations.md §3) — без пустой полосы.
      return AppBar(
        leading: leading,
        actions: actions,
        title: const SizedBox.shrink(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: AppText(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ),
        ),
      );
    }
    return AppBar(
      leading: leading,
      actions: actions,
      title: AppText(
        title,
        style: textTheme.titleLarge,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: false,
    );
  }
}
