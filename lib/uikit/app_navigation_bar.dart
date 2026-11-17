// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Destination адаптивной навигации (label + icon, опционально selectedIcon).
class AppNavigationDestination {
  const AppNavigationDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

/// Нижняя навигация для узких экранов (<600dp, compact).
///
/// Экраны: адаптивный shell — пять root-разделов (Главная, Операции,
/// Активы, Цели, Ещё); подключается в задаче 3.5.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : assert(selectedIndex >= 0);

  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    assert(selectedIndex < destinations.length);
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
        // Высота M3-бара фиксирована: при увеличенном шрифте подпись есть
        // только у выбранного раздела, а на 320dp дополнительно ограничиваем
        // масштаб до 1.0, чтобы даже «Операции» оставались в одну строку.
        final compact = textScale > 1.15;
        final maxScale = constraints.maxWidth < 340 ? 1.0 : 1.1;
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: maxScale,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelBehavior: compact
                ? NavigationDestinationLabelBehavior.onlyShowSelected
                : NavigationDestinationLabelBehavior.alwaysShow,
            destinations: <Widget>[
              for (final destination in destinations)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(
                    destination.selectedIcon ?? destination.icon,
                  ),
                  label: destination.label,
                  tooltip: destination.label,
                ),
            ],
          ),
        );
      },
    );
  }
}
