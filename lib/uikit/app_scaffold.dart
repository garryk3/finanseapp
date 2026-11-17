// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_top_app_bar.dart';

/// Базовый каркас экрана: Scaffold + SafeArea.
///
/// Передаётся либо [title] (соберётся [AppTopAppBar]), либо готовый [appBar].
///
/// Экраны: все экраны приложения — корневой каркас каждого route.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? (title == null ? null : AppTopAppBar(title: title!)),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
