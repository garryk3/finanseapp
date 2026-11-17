// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_navigation_bar.dart';

/// Боковая навигация для средних/широких экранов (>=600dp, fold/планшет).
///
/// Экраны: адаптивный shell — те же пять root-разделов, что у
/// [AppNavigationBar]; подключается в задаче 3.5.
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
  }) : assert(selectedIndex >= 0);

  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    assert(selectedIndex < destinations.length);
    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      destinations: <NavigationRailDestination>[
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon ?? destination.icon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
