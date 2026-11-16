# FinanseApp

Мобильное приложение для учёта личных финансов.
Offline-first, Android 12+ (minSdk 31), Material 3 (светлая и тёмная темы),
локализация — русский.

> Репозиторий содержит правила разработки для агентов (`AGENTS.md`, `.agents/`)
> и каркас процессов (PLAN/TASKS/TEST_PLAN, CI). Flutter-приложение находится в
> корне репозитория; сгенерированный каркас появится на Этапе 1 (см. `PLAN.md`).

## Быстрый старт (после появления каркаса)

```bash
flutter pub get                 # установка зависимостей
flutter gen-l10n                # генерация локализации (app_localizations*.dart)
dart run build_runner build     # генерация кода drift (app_database.g.dart)
flutter run                     # запуск приложения
flutter test                    # тесты
flutter build apk --debug       # сборка Android APK
```

Генерируемые файлы (drift, локализация) коммитятся: при обычном запуске и
сборке они создаются автоматически (`generate: true`). Команды генерации нужны
только после изменения схемы БД или `app_ru.arb`.

## Стек

- Flutter / Dart (stable, без пина — в ногу со стейблом)
- State management: `signals` + `signals_flutter` (native-first; без Riverpod/Bloc/GetX)
- SQLite через `drift` (типобезопасный ORM)
- `go_router` (навигация), `fl_chart` (графики), `flutter_localizations` + `intl` (RU)
- Архитектура: MVVM, manual DI, слои UI → logic → data, `lib/uikit/` — базовые компоненты
- CI: GitHub Actions (format, analyze + analyzer-плагин `restrict_raw_flutter`,
  tests, debug APK); сборка релизов по тегу `v*` с публикацией APK в GitHub Releases

Подробности — `docs/PROJECT.md`. Правила для агентов — `AGENTS.md`.

## Проектные контракты

Перед реализацией читать `docs/architecture/README.md`: там связаны продуктовые правила,
доменные сигнатуры, Drift-схема, маршруты, безопасный backup/restore и обновления.
Контракты UI — `lib/uikit/design/README.md`, визуальные правила — `DESIGN.md`.
Пошаговые TDD-задачи с точными файлами и проверками — `PLAN.md`.

## Структура проекта

```
lib/
  main.dart
  app/                # app.dart, router.dart, theme/
  core/
    database/         # drift: app_database.dart, tables/, converters/
    di/               # service_locator.dart
    domain/           # domain-модели фич, валидаторы
    features/         # <feature>/data/ + <feature>/ui/
  uikit/              # единый источник базовых UI-компонентов (AppCard, ...)
  l10n/               # app_ru.arb, gen_l10n
test/                 # зеркалит lib/
integration_test/
vendor/restrict_raw_flutter/  # analyzer-плагин: запрет сырых Material-виджетов вне uikit
.agents/              # правила, субагенты и скиллы для агентов (versioned)
docs/PROJECT.md       # стабильный технический контекст
PLAN.md / PLAN_ARCHIVE.md     # живой план и архив этапов
TASKS.md              # входной ящик пользователя
TEST_PLAN.md          # накопительный ручной тест-план
DESIGN.md             # дизайн-система (черновик)
```

## Проверки

```bash
flutter analyze --fatal-infos
dart analyze lib --fatal-infos    # гейт restrict_raw_flutter (analyzer-плагин)
dart format --output=none --set-exit-if-changed lib test tool integration_test
flutter test
flutter build apk --debug
```

## Git-процесс

Каждая задача из `PLAN.md` выполняется в отдельной ветке `task/<NN>-<slug>`,
открывается Pull Request в `main`. Проверки выполняет GitHub Actions
(`.github/workflows/ci.yml`) на каждом PR и пуше в `main`. Перед коммитом/PR —
ревью агентом `task-reviewer` (и `design-reviewer` при UI-изменениях);
перед релизом — `plan-review`. Полный процесс — `AGENTS.md`.
