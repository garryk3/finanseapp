# docs/PROJECT.md — стабильный технический контекст FinanseApp

Сюда выносится стабильный техконтекст из `PLAN.md`: решения по проекту,
окружение, стек, структура кода, схема БД, seed-данные. Обновляется по мере
принятия решений; не дублирует живой план.

## Стек (утверждён переносом подходов референсного проекта)

- Flutter / Dart (stable, без пина — в ногу со стейблом, см. `AGENTS.md`).
- State management: `signals` + `signals_flutter` (native-first;
  Riverpod/Bloc/GetX запрещены, см. `.agents/rules/FLUTTER.md`).
- SQLite через `drift` (типобезопасный ORM), generated-код коммитится.
- `go_router` (навигация), `fl_chart` (графики),
  `flutter_localizations` + `intl` (RU-локаль, `lib/l10n/app_ru.arb`).
- Архитектура: MVVM, manual DI (зависимости через конструктор), слои
  UI → logic → data, `lib/uikit/` — единый источник базовых компонентов.
- Material 3, светлая + тёмная темы, offline-first.
- CI: GitHub Actions — format, analyze (+ analyzer-плагин `restrict_raw_flutter`),
  tests, debug APK; релизы по тегу `v*` в GitHub Releases.

## Окружение

- Android 12+ (minSdk 31). Эмулятор AVD `Pixel_10_Pro` (x86_64, Android 16),
  adb `~/Android/Sdk/platform-tools/adb`, SDK `~/Android/Sdk`.
- JDK 21 (Temurin), пины см. в `AGENTS.md` («Commands»).
- Integration-тесты — на Linux desktop (`flutter test integration_test -d linux`),
  в CI не прогоняются.

## Структура кода

(Этап 1, 2026-11-15 — каркас создан.)

```
lib/
  main.dart           # вход: DI-локатор → runApp(FinanseApp)
  app/                # app.dart (MaterialApp.router, ru-локаль), router.dart (go_router), theme/app_theme.dart
  core/
    di/               # service_locator.dart (manual DI)
    features/home/ui/ # home_screen.dart + home_view_model.dart (демо-счётчик на signals)
  uikit/              # app_scaffold, app_text, app_button, app_section (+AppSectionHeader)
  l10n/               # app_ru.arb + app_localizations*.dart (генерируемые, коммитятся)
test/                 # app_test.dart (зеркалит lib/)
integration_test/     # app_test.dart (smoke, linux desktop)
```

Импорты виджетного слоя — из `package:material_ui/material_ui.dart`
(миграция Flutter 3.50; `package:flutter/material.dart` deprecated, `--fatal-infos`
его ловит). Делегаты локализации — `GlobalMaterialLocalizations.delegates` из
material_ui + `AppLocalizations.delegate`.

## Схема БД

(заполняется при проектировании drift-таблиц — Этап 1.)

## Принятые решения

(журнал ADR-подобных решений по мере работы; см. также скилл
`architecture-decision-records`.)
