# FinanseApp

Мобильное приложение для учёта личных финансов.
Offline-first, Android 12+ (minSdk 31), Material 3 (светлая и тёмная темы),
локализация — русский.

> Репозиторий содержит готовое Flutter-приложение v1 и правила разработки для агентов
> (`AGENTS.md`, `.agents/`). Трекеры: `PLAN.md`, `PLAN_ARCHIVE.md`, `TASKS.md`, `TEST_PLAN.md`.

## Возможности v1

- Счета, инвестиции и квартиры; пополнения/снятия, переводы, оценки и история стоимости.
- Доходы/расходы и связанные с ними операции по счетам; журналы с фильтрами и итогами.
- Цели с привязкой активов, прогрессом и рекомендацией взноса.
- Аналитика: net worth, денежный поток по периодам, итоги по категориям, ручной курс.
- Резервная копия SQLite: экспорт/SAF/импорт с валидацией, rollback и перезапуском.
- Ручная проверка обновлений через GitHub Releases; защита приложения PIN/биометрией.
- Offline-first: сеть нужна только для курсов ЦБ и проверки обновлений.

## Быстрый старт

```bash
flutter pub get                 # установка зависимостей
flutter gen-l10n                # генерация локализации (app_localizations*.dart)
dart run build_runner build     # генерация кода drift (app_database.g.dart)
flutter run                     # запуск приложения
flutter test                    # тесты
flutter build apk --release     # подписанный release APK (TEMP_KEY)
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
  tests, **release** APK); релизы по тегу `v*` с публикацией APK в GitHub Releases.
- Локальный e2e: `flutter test integration_test -d linux` (перед PR — спросить владельца).
- Android-подпись: временный `TEMP_KEY` из `android/key.properties`; перед Google Play
  ключ заменяется (см. PLAN §10.6).

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
    features/         # <feature>/{domain,data,logic,ui}/
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
DESIGN.md             # нормативная дизайн-система
```

## Проверки

```bash
flutter analyze --fatal-infos
dart analyze lib --fatal-infos    # гейт restrict_raw_flutter (analyzer-плагин)
dart format --output=none --set-exit-if-changed lib test tool integration_test
flutter test
flutter build apk --release
```

## Релиз

1. Убедиться, что `main` зелёный и `plan-review` пройден.
2. Спросить владельца, нужен ли полный QA-прогон `android-tester` перед тегом.
3. Поднять patch-версию и поставить тег `vX.Y.Z` (release workflow соберёт APK из тега,
   прогонит гейты и опубликует GitHub Release с `app-release.apk`).
4. Проверить ассет `app-release.apk` и заметки релиза; обновления в приложении читают
   последний GitHub Release.

Ключ `TEMP_KEY` — временный, для внутренних сборок; публикация в Google Play требует
замены keystore. Backup-файл не зашифрован и содержит финансовые данные. `applicationId`
пока `com.example.finanseapp`: смена после публикации сломает путь обновления и данные
пользователя, поэтому выполняется до первого публичного релиза.

## Git-процесс

Каждая задача из `PLAN.md` выполняется в отдельной ветке `task/<NN>-<slug>`,
открывается Pull Request в `main`. Проверки выполняет GitHub Actions
(`.github/workflows/ci.yml`) на каждом PR и пуше в `main`. Перед коммитом/PR —
ревью агентом `task-reviewer` (и `design-reviewer` при UI-изменениях);
перед релизом — `plan-review`. Полный процесс — `AGENTS.md`.
