# PLAN.md — FinanseApp

Живой трекер разработки: «Индекс этапов» + текущий (незавершённый) этап.

## Как читать этот файл

- **Не читайте файл целиком** — найдите секцию задачи (`grep -n -E '^### NN\.' PLAN.md`) и прочитайте только её диапазон (`sed -n 'A,Bp' PLAN.md`).
- Завершённые этапы (полные планы и блоки «Реализовано») переносятся в `PLAN_ARCHIVE.md` агентом `release-manager` после релиза.
- Стабильный технический контекст (решения, стек, структура, схема БД) — в `docs/PROJECT.md`.
- Статус задачи обновляется (`[x]` + дата) по завершении, **до открытия PR** (см. `AGENTS.md`, «Workflow & conventions»).
- Входной «ящик» пользователя — `TASKS.md` (см. `AGENTS.md`, «Работа с TASKS.md»).

## Индекс этапов

| Этап | Название | Задачи | Статус | Дата |
|------|----------|--------|--------|------|
| 1 | Базовый каркас приложения | 1.1–1.3 | ✅ 2026-11-15 | 2026-11-15 |

## Этап 1 — Базовый каркас приложения

Каркас Flutter-приложения FinanseApp (личные финансы, offline-first, Android 12+,
Material 3, RU) на перенесённом стеке, с проверкой запуска на Linux desktop.

### 1.1 Flutter-проект в корне репозитория — [x] 2026-11-15

- `flutter create --org com.example --project-name finanseapp --platforms android,linux .`
  (пакет приложения — `com.example.finanseapp`).
- `pubspec.yaml`: стек из `docs/PROJECT.md` — `signals`/`signals_flutter`, `go_router`,
  `drift` + `drift_flutter`, `fl_chart`, `intl`, `material_ui`, `flutter_localizations`;
  dev: `flutter_lints`, `drift_dev`, `build_runner`, `integration_test`.
  `generate: true` (l10n). Версия `0.1.0+1`.
- `analysis_options.yaml` по образцу референса: `flutter_lints`, exclude
  (`**/*.g.dart`, `**/l10n/*.dart`, `vendor/**` и платформенные каталоги),
  плагин `restrict_raw_flutter` (вендорный форк) со всеми ban-правилами — сразу,
  каркас строится сразу на обёртках uikit.
- Linux desktop: `flutter config --enable-linux-desktop` (если выключен).

### 1.2 Структура lib/ и базовый UI — [x] 2026-11-15

- `lib/main.dart` — вход, инициализация DI-локатора, запуск App.
- `lib/app/`: `app.dart` (`MaterialApp.router`, локализация ru, темы),
  `router.dart` (go_router: `/` → home), `theme/app_theme.dart`
  (`ColorScheme.fromSeed`, светлая+тёмная; seed — черновик из `DESIGN.md`).
- `lib/core/di/service_locator.dart` — ручной DI (простейший контейнер-заглушка).
- `lib/core/features/home/ui/` — домашний экран-заглушка: `AppScaffold` +
  `AppText` + демо-счётчик на `signals` (демонстрация стека state management,
  MVVM: `HomeViewModel` с `Signal<int>`, manual DI через конструктор).
- `lib/uikit/`: минимальный набор обёрток (`AppScaffold`, `AppText`, `AppButton`,
  `AppSection`/`AppSectionHeader`) — внутри сырые Material-виджеты разрешены
  (`// ignore_for_file: type=lint`), весь остальной `lib/` — только обёртки.
- `lib/l10n/app_ru.arb` + `l10n.yaml` — все видимые строки через l10n.

### 1.3 Тесты и проверка запуска — [x] 2026-11-15

- `test/app_test.dart` — widget-тест: приложение поднимается, домашний экран
  показывает заголовок (проверка по русской строке l10n), счётчик реагирует на тап.
- `integration_test/app_test.dart` — smoke-тест на Linux desktop
  (`flutter test integration_test -d linux`) — прошёл, бандл собран.
- Проверки: `dart format --set-exit-if-changed` — чисто; `flutter analyze --fatal-infos` —
  чисто; `dart analyze lib --fatal-infos` (гейт плагина) — чисто; `flutter test` — 2/2.
  Windowed-запуск `build/linux/x64/debug/bundle/finanseapp` — успешен.

### Реализовано (2026-11-15)

- Каркас создан по плану 1.1–1.3; отклонений от плана нет, кроме одного
  перенесённого из референса обязательного изменения: Flutter 3.50 депрекейтил
  `package:flutter/material.dart` → весь виджетный слой (включая uikit и тесты)
  переведён на `package:material_ui/material_ui.dart`, делегаты локализации —
  `GlobalMaterialLocalizations.delegates` из material_ui; `watch(context)` в
  signals_flutter заменён на `SignalBuilder`. Зафиксировано в `docs/PROJECT.md`.
- Демо-счётчик на домашнем экране — временный, уйдёт с реальным контентом.
- Не выполнялось (не входило в объём): drift-таблицы и generated-код БД
  (зависимости объявлены; подключение БД — отдельная задача этапа 2),
  CI-прогон на GitHub (репо ещё не запушен), android-tester (нет нового
  функционала для сценариев; каркас — заглушка).

### Тесты

- Unit/widget: `test/app_test.dart` (заголовок домашнего экрана через AppLocalizations).
- Integration (linux desktop): smoke — приложение стартует, home виден.

