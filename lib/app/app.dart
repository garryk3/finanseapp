import 'package:finanseapp/app/router.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Корневой виджет приложения: темы, локализация (ru), маршрутизация.
class FinanseApp extends StatelessWidget {
  const FinanseApp({super.key, required this.locator});

  final ServiceLocator locator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: buildRouter(locator: locator),
      // Локали Material/Cupertino/Widgets — из material_ui (Flutter 3.50):
      // делегаты flutter_localizations дают framework-типы, которые виджеты
      // material_ui в контексте не находят.
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru')],
    );
  }
}
