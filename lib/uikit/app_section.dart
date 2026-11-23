// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_text.dart';

/// Секция с заголовком — стандартный ритм экрана: заголовок (titleMedium) +
/// контент. Секции разделяются 24dp (DESIGN.md §4).
///
/// Экраны: все экраны с группировкой контента — Dashboard, Настройки,
/// детали активов/операций, Аналитика, Ещё.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.header,
    required this.child,
    this.padded = true,
  });

  final String header;
  final Widget child;

  /// false — секция внутри контейнера, который уже даёт горизонтальный
  /// отступ (например, AppAdaptiveGrid на Главной), без двойного inset.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppSectionHeader(title: header, padded: padded),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padded ? AppSpacing.md : 0),
          child: child,
        ),
      ],
    );
  }
}

/// Заголовок секции (titleMedium из темы — не «голый» Text).
///
/// Экраны: все перечисленные для [AppSection]; также отдельные заголовки
/// внутри форм (AppFormSection).
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.padded = true});

  final String title;

  /// false — заголовок внутри контейнера с готовым горизонтальным отступом.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        padded ? AppSpacing.md : 0,
        AppSpacing.lg,
        padded ? AppSpacing.md : 0,
        AppSpacing.sm,
      ),
      child: AppText(title, style: style),
    );
  }
}
