// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';

/// Pull-to-refresh поверх ленивого списка. Не заменяет первичный
/// AppSkeleton (patterns.md §2).
///
/// Экраны: журналы и списки с обновляемыми данными — Операции, Активы,
/// Цели, Аналитика, Валюты (обновление курсов ЦБ).
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}
