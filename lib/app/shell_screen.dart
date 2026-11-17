import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_navigation_bar.dart';
import 'package:finanseapp/uikit/app_navigation_rail.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Адаптивный shell пяти primary-разделов: bar <600dp, rail >=600dp.
class ShellScreen extends StatelessWidget {
  const ShellScreen({
    super.key,
    required this.navigationShell,
    required this.destinations,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppNavigationDestination> destinations;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      // Повторный tap по текущему разделу возвращает на его root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppSpacing.twoColumnBreakpoint) {
          return AppScaffold(
            body: navigationShell,
            bottomNavigationBar: AppNavigationBar(
              destinations: destinations,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _select,
            ),
          );
        }
        return AppScaffold(
          body: Row(
            children: [
              AppNavigationRail(
                destinations: destinations,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _select,
              ),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}
