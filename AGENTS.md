# AGENTS.md — ядро правил FinanseApp

Краткие правила, нужные каждой сессии. Детали по ссылкам:
- `docs/AGENTS_DETAILS.md` — окружение (JDK/эмулятор/NDK), generated-код, протокол `TASKS.md`, запуск `android-tester`/`design-reviewer`, симлинки opencode.
- `docs/REPO_CONTEXT.md` — контекст репозитория для субагентов (читают целиком при старте).
- `docs/PROJECT.md` — стек и принятые решения. `DESIGN.md` — дизайн-система.

## Repo layout

- **Git root = Flutter package root** (`pubspec.yaml`, `lib/`, `test/`, `integration_test/`). Все `flutter`/`dart` команды — из корня.
- Трекеры: `PLAN.md` (живой план), `PLAN_ARCHIVE.md` (архив этапов), `TASKS.md` (ящик пользователя), `TEST_PLAN.md` (накопительный тест-план, ведёт `android-tester`).
- `lib/uikit/` — единый источник базовых UI-компонентов.
- `.agents/`: `rules/FLUTTER.md` (стиль/state), `skills/` (скиллы), `agents/` (субагенты). `rules/FLUTTER.md` соблюдать: native-first state (signals, `ChangeNotifier`, `ValueNotifier`), **без Riverpod/Bloc/GetX**, MVVM, manual DI.

## Как читать PLAN.md

**Не читать целиком** — найди секцию задачи (`grep -n -E '^### NN\.' PLAN.md`) и прочитай только её диапазон (`sed -n 'A,Bp' PLAN.md`). Статус задачи (`[x]` + дата) обновляется при завершении, **до открытия PR**. Рабочий план задачи записывается в `PLAN.md` **до начала кода**.

## Commands (CI in `.github/workflows/ci.yml` is the source of truth)

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool integration_test
flutter analyze --fatal-infos
dart analyze lib --fatal-infos   # гейт restrict_raw_flutter; таргет `lib` ОБЯЗАТЕЛЕН (Dart 3.14: плагин-диагностики отдаются только при каталоге-таргете, dart-lang/sdk#64208)
flutter test
flutter build apk --debug
```

- Single test: `flutter test test/<path>_test.dart`. e2e (`integration_test/`) в CI не прогоняются — локально `flutter test integration_test -d linux` (долго на холодном прогоне; подробности — детали).
- Stack: Flutter/Dart stable (без пина), `drift`, `signals`/`signals_flutter`, `go_router`, `fl_chart`, `flutter_localizations`, виджеты из `package:material_ui`. Окружение и подводные камни — `docs/AGENTS_DETAILS.md`.

## Workflow & conventions

- Язык репо — русский: `PLAN.md`, commit messages (`task/NN.NN: <описание> (#PR)`), UI-строки — только через `lib/l10n/app_ru.arb`.
- Задача = ветка `task/<NN>-<slug>` из `main` → PR → зелёный CI → squash merge, в порядке зависимостей. Перед коммитом/PR ветка синхронизируется с `origin/main` через **`git merge origin/main` (никогда не `rebase`)**; реальный diff — только фактически изменённые файлы (`git diff --name-status origin/main..HEAD`).
- **Состояние задачи в `PLAN.md` — до открытия PR, а не после.**
- **Перед PR спросите пользователя, запускать ли e2e** (`flutter test integration_test -d linux`). Молча не запускать и не пропускать вопрос нельзя.
- **Перед публикацией релизного тега спросите владельца, нужен ли полный QA-прогон android-tester** (~час; иначе релиз на unit-тестах и CI). Отказ не блокирует релиз; молчать нельзя.
- **Гейты ревью (субагенты, `.agents/agents/`):**
  - После реализации, **перед коммитом/PR — `task-reviewer`** (вердикт `DO NOT SHIP` блокирует). Исключение: задачи без изменений кода (чистка `TASKS.md`, планы).
  - Задача с UI-изменениями в `lib/` — также **`design-reviewer`** (только diff-файлы; вердикт `REDESIGN REQUIRED` блокирует).
  - **Перед релизом — `plan-review`** (задачи с `[x]`+датой и рабочими планами в `PLAN.md`).
  - **После релиза `release-manager` сжимает `PLAN.md`** (завершённые этапы → `PLAN_ARCHIVE.md`, индекс и нумерация сохраняются).
  - После задачи с новым функционалом — **`android-tester` коротким прогоном** дополняет `TEST_PLAN.md` (только append сценариев). Полный QA — по требованию или перед релизом.
- **UI — только через `lib/uikit/`**: заголовки секций — `AppSectionHeader`/`AppSection`, primary CTA — `AppGradientButton`/`AppButton`, карточки/списки — `AppCard`/`AppTile`. Полный каталог и правила запрета сырых Material-виджетов (`restrict_raw_flutter`: `Text`→`AppText`, `Scaffold`→`AppScaffold`, `FilledButton`→`AppButton`, `Colors.*`/`Color(...)` вне theme — запрещены и т.д.) — в `analysis_options.yaml` и CI-гейтах; зоны исключения — `lib/uikit/**`, `lib/app/theme/**`, `test/**`, `integration_test/**`.
- Generated-код коммитится (drift, l10n) — команды и тонкости: `docs/AGENTS_DETAILS.md`.
