# docs/REPO_CONTEXT.md — контекст репозитория для субагентов

Прочитайте этот файл в начале прогона. Пути не угадывать.

## Каркас и пути

- Git-корень = Flutter-пакет (`pubspec.yaml`, `lib/`, `test/`, `integration_test/`). Все `flutter`/`dart` команды — из корня репозитория.
- `lib/main.dart` → `lib/app/` (`MaterialApp.router`, темы, ru-локаль), `lib/app/router.dart` (go_router), `lib/app/theme/` (дизайн-токены).
- `lib/core/`: `di/service_locator.dart` (manual DI), `features/<feature>/{data,ui}/` — контекстные виджеты в `ui/`.
- `lib/uikit/` — единый источник базовых компонентов (`AppScaffold`, `AppText`, `AppButton`, `AppSection`/`AppSectionHeader`, `AppCard`, `AppListTile`, `AppDialog`, `AppSpinner` и др. — полный список в `AGENTS.md`). Новый UI собирается только из них.
- Импорты виджетного слоя — `package:material_ui/material_ui.dart` (Flutter 3.50; `flutter/material` deprecated, ловится `--fatal-infos`). Делегаты локализации — `GlobalMaterialLocalizations.delegates` из material_ui + `AppLocalizations.delegate`.
- Видимые строки — только через `lib/l10n/app_ru.arb` (ключи, не «голые» строки). Тесты проверяют русские строки `AppLocalizations`.

## Трекеры

- `PLAN.md` (корень): «Индекс этапов» + текущий этап. **Читать только секцию задачи**: `grep -n -E '^### NN\.' PLAN.md` → `sed -n 'A,Bp'`, не весь файл. Завершённые этапы — `PLAN_ARCHIVE.md` (только при необходимости). Стабильный техконтекст — `docs/PROJECT.md`.
- Статус задачи обновляется (`[x]` + дата) **до** открытия PR.
- `TEST_PLAN.md` (корень): накопительный ручной тест-план, ведёт `android-tester`. Протокол: `TC-<NNN>` (монотонно), статусы `PASS`/`FAIL`/`SKIP`/`BLOCKED`, даты `YYYY-MM-DD`, прошлые записи не трогать.
- `TASKS.md` — входной ящик пользователя (протокол — `AGENTS.md`).

## Правила стиля и архитектуры

Детали — `.agents/rules/FLUTTER.md`. Ключевое:

- State: `signals`/`signals_flutter`, `ChangeNotifier`, `ValueNotifier`. **Запрещены Riverpod/Bloc/GetX.** MVVM, manual DI (зависимости — через конструктор, не создаются внутри).
- Сырые Material-виджеты запрещены вне `lib/uikit/` (analyzer-плагин `restrict_raw_flutter`, гейт `dart analyze lib --fatal-infos`; список банов — `analysis_options.yaml`). Подавление `// ignore_for_file: type=lint` разрешено только в `lib/uikit/**`, `lib/app/theme/**`, `test/**`, `integration_test/**`.
- Generated-код коммитится, CI не перегенерирует: drift `*.g.dart` + дамп `drift_schemas/`, l10n `app_localizations*.dart`.
- Тесты зеркалят `lib/` под `test/`; DB-тесты — `AppDatabase(executor: NativeDatabase.memory())`.

## Субагенты (`.agents/agents/`)

- `task-reviewer` — ревью реализации задачи перед коммитом/PR (вердикт SHIP / SHIP WITH FIXES / DO NOT SHIP).
- `design-reviewer` — ревью UI по `DESIGN.md` (вердикт APPROVE / APPROVE WITH FIXES / REDESIGN REQUIRED).
- `plan-review` — проверка `PLAN.md` перед релизом.
- `release-manager` — публикация релизов (теги `v*`), сжатие `PLAN.md` после релиза.
- `android-tester` — ручной QA в Android-эмуляторе, ведёт `TEST_PLAN.md`.

Полные протоколы запуска — `AGENTS.md` и `docs/AGENTS_DETAILS.md`.
