import 'dart:async';

import 'package:finanseapp/app/router.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/applock/logic/applock_controller.dart';
import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_back_dispatcher.dart';
import 'package:finanseapp/core/features/applock/ui/applock_gate.dart';
import 'package:finanseapp/core/features/onboarding/domain/onboarding_repository.dart';
import 'package:finanseapp/core/features/onboarding/ui/onboarding_gate.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_catchup_service.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_events.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals/signals.dart';

/// Корневой виджет приложения: темы, локализация (ru), маршрутизация.
class FinanseApp extends StatefulWidget {
  const FinanseApp({super.key, required this.locator});

  final ServiceLocator locator;

  @override
  State<FinanseApp> createState() => _FinanseAppState();
}

class _FinanseAppState extends State<FinanseApp> with WidgetsBindingObserver {
  late final GoRouter _router = buildRouter(locator: widget.locator);
  late final RecurringCatchupService _catchup = widget.locator
      .get<RecurringCatchupService>();
  EffectCleanup? _rateCleanup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // После ручного курса/ответа ЦБ догоняем отложенные периоды (D5, D8).
    _rateCleanup = exchangeRateRevision.subscribe((_) {
      unawaited(_catchup.catchUp());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_catchup.catchUp());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rateCleanup?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ServiceLocator locator = widget.locator;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      // BACK под локом поглощается до pop маршрута (BR-Sec-6).
      backButtonDispatcher: ApplockBackDispatcher(
        locator.get<ApplockController>(),
      ),
      // Гейт защиты поверх навигатора: лок-скрин перекрывает любой маршрут
      // и при этом имеет тему и локализацию (BR-Sec-6).
      builder: (context, child) => AppLockGate(
        controller: locator.get<ApplockController>(),
        lockViewModel: locator.get<ApplockViewModel>(),
        child: OnboardingGate(
          repository: locator.get<OnboardingRepository>(),
          settingsRepository: locator.get<SettingsRepository>(),
          currencyRepository: locator.get<CurrencyRepository>(),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
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
