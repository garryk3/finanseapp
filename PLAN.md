# PLAN.md — FinanseApp

Живой трекер разработки. Завершённые этапы архивирует `release-manager` после релиза;
нумерация задач и ссылки на бизнес-правила сохраняются.

## Как выполнять задачу

1. Найти только свою секцию (`grep -n -E '^### NN\.' PLAN.md`), прочитать указанные
   архитектурные документы и `Files`. Не переписывать чужие контракты.
2. Сначала написать перечисленный failing test и убедиться в причине падения, затем
   реализовать минимальный объём до pass. Не менять ожидание под ошибочную реализацию.
3. `Files: Create/Modify/Test` — исчерпывающий expected diff, кроме generated l10n/Drift,
   schema dump и обязательной регистрации в DI/router. Не создавать пустые заглушки.
4. Все UI-строки — `lib/l10n/app_ru.arb`, raw Material wrappers — только `lib/uikit/`.
   Domain не импортирует Flutter/Drift/signals; ViewModel получает зависимости конструктором.
5. Общий DoD: format; `flutter analyze --fatal-infos`; `dart analyze lib --fatal-infos`;
   `flutter test`; `flutter build apk --release`; generated файлы проверены; `git diff --check`;
   статус задачи `[x]` + дата до PR. Перед commit/PR — `task-reviewer`, при UI — также
   `design-reviewer`; DO NOT SHIP/REDESIGN REQUIRED блокирует. После функционала —
   короткий `android-tester` с append-only обновлением `TEST_PLAN.md`.
6. Каждая задача — ветка `task/<NN.NN>-<slug>` из main, sync только `git merge origin/main`.
   Commit message ниже — предложение, не разрешение на commit. **Перед PR исполнитель
   обязан отдельно спросить владельца, запускать ли `flutter test integration_test -d linux`.**
7. Если контракт невозможно выполнить, остановиться и зафиксировать blocker; не заменять
   архитектуру молча и не уменьшать тестовое покрытие.

## Индекс этапов

| Этап | Название | Задачи | Статус | Дата |
|---|---|---|---|---|
| 1 | Базовый каркас приложения | 1.1–1.3 | ✅ | 2026-11-15 |
| 2 | Архитектурный комплект и контракты | 2.1–2.5 | ✅ | 2026-11-16 |
| 3 | Ядро, БД, UIKit и навигация | 3.1–3.6 | ✅ | 2026-11-18 |
| 4 | Справочники и курсы валют | 4.1–4.3 | ✅ | 2026-11-18 |
| 5 | Активы и оценки | 5.1–5.4 | ✅ | 2026-11-19 |
| 6 | Транзакции, переводы и аудит | 6.1–6.3 | ✅ | 2026-11-18 |
| 7 | Доходы, расходы и связь со счетами | 7.1–7.4 | ✅ | 2026-11-19 |
| 8 | Финансовые цели | 8.1–8.2 | ✅ | 2026-11-19 |
| 9 | Аналитика и графики | 9.1–9.4 | ✅ | 2026-11-19 |
| 10 | Dashboard, настройки, backup и updates | 10.1–10.6 | ✅ | 2026-11-20 |
| 11 | Сквозное качество и release readiness | 11.1–11.11 | ✅ | 2026-11-20: 11.9 — ручные проверки, не блокировали v1 |
| 12 | Расширения после v1 | 12.1–12.7 | ✅ | 2026-11-21 |
| 13 | Исправления по полному QA-прогону v1 | 13.1–13.9 | ✅ | 2026-11-21 |
| 14 | Инфраструктура релиза | 14.1 | ✅ | 2026-11-21 |
| 15 | Регулярные платежи и капитализация вкладов | 15.1–15.5 | ✅ | 2026-11-22: QA recheck TC-143…145 PASS; короткий QA 10 SKIP, полный QA v0.1.2 не проводился (решение владельца) |
| 16 | Видео-заставка при запуске | 16.1 | ✅ | 2026-11-22 |

## Этап 16 — Видео-заставка при запуске

### 16.1 Видео-заставка ≤2.5 с при холодном старте — [x] (2026-11-22)

- **Приоритет/зависимости:** P1; после v0.1.2, отдельных зависимостей нет.
  **Источник:** TASKS.md 2026-11-22, файл `finsplash.mp4`.
- **Файл видео:** 1280×720, ~10,1 с, H.264/AAC, 2,5 МБ; центральная композиция
  «кошелёк + график» занимает квадрат ~720×720, по бокам размытые панели.
- **Решения владельца (2026-11-22, не менять молча):**
  - **S1.** На портретном экране показывать **центральный квадрат 1:1** (без
    размытых боковых панелей), на тёмно-зелёном фоне.
  - **S2.** Проигрывать **первые 2.5 с** исходника, звук выключен.
  - **S3.** Показывать при каждом холодном старте Android; при возврате из фона
    и после restart по импорту backup — не повторять.
  - **S4.** Видео не должно блокировать приложение: максимум 2.5 с, затем
    приложение (или статичный loading-экран, если DI ещё не готов).
- **Files:**
  - Create: `assets/video/finsplash.mp4` (копия исходника);
    `assets/video/finsplash_poster.png` (первый кадр 720×720);
    `lib/app/startup_splash.dart` (StartupSplash + StartupLoadingScreen);
    `lib/app/splash_screen.dart` (видео-экран);
    `test/app/startup_splash_test.dart`; `test/app/splash_screen_test.dart`.
  - Modify: `pubspec.yaml` (`video_player`, `assets:`), `lib/app/app_restart.dart`
    (StartupSplash вокруг FinanseApp), `lib/app/theme/app_theme.dart`
    (`splashBackground`/`splashForeground`),
    `android/app/src/main/res/values/colors.xml` (`splash_background`),
    `android/app/src/main/res/drawable{,-v21}/launch_background.xml`,
    `android/app/src/main/res/values{,-night}/styles.xml` (LaunchTheme),
    `docs/PROJECT.md` (startup), `docs/architecture/
    navigation_and_screens.md` (последовательность запуска).
  - Generated: `pubspec.lock`; Android plugin registrant — build-time, не коммитить.
- **Consumes:** `defaultTargetPlatform`, `AppTheme`, `AppSpinner`, `AppText`,
  `VideoPlayerController.asset`.
- **Produces:** видео-заставка Android при холодном старте: центральный квадрат,
  первые 2.5 с, muted; `StartupSplash` показывает splash до 2.5 с независимо от
  готовности DI, затем приложение; при DI > 2.5 с — статичный loading; на
  Linux/в тестах splash отключён; reduce-motion показывает статичный первый кадр;
  ошибка инициализации видео не блокирует приложение.
- **TDD:**
  1. `StartupSplash(enabled: true, child: null, splashBuilder: Text('splash'))`:
     splash виден в 0 и 2.4 с; в 2.5 с — loading (splash исчез); после передачи
     child — приложение.
  2. `enabled: false`: child сразу, splash отсутствует; child == null →
     `SizedBox.shrink`; Linux/e2e не меняются.
  3. Child готов сразу → splash всё равно держится ровно 2.5 с; повторный
     rebuild/new child не перезапускает splash.
  4. Таймер отменяется в dispose; нет `setState` после dispose.
  5. Android manual: видео 0–2.5 с, без звука, центральный квадрат; после —
     app lock/онбординг; backup-restart не повторяет; release APK собирается;
     Linux e2e 9/9.
- **Рабочий план:**
  1. **Asset/dependency.** Скопировать `finsplash.mp4` в `assets/video/`; в
     `pubspec.yaml` добавить `video_player` и `assets: - assets/video/finsplash.mp4`;
     `flutter pub get`; проверить, что APK собирается и размер +~2.5 МБ.
  2. **Theme.** `AppTheme.splashBackground` — тёмно-зелёный `Color(0xFF06110E)`
     (theme-зона, raw color допустим); использовать в splash/loading.
  3. **SplashScreen.** Stateful; `VideoPlayerController.asset`; `initialize`,
     `setVolume(0)`, `setLooping(false)`, `seekTo(0)`, `play`; при
     `MediaQuery.disableAnimations` видео не играет — виден постер; при ошибке
     видео остаётся постер (`finsplash_poster.png`), без тупика и текста поверх.
     `dispose` контроллера. Вёрстка:
     `LayoutBuilder` → `side = min(maxWidth, maxHeight)`, `Center(SizedBox.side)`,
     `ClipRect` + постер `BoxFit.cover` и видео `FittedBox.fitHeight` + зум 3 %,
     градиентные шторки по краям; фон `AppTheme.splashBackground`; `Semantics`
     с названием приложения.
  4. **StartupSplash.** `enabled`, `duration = 2500ms`, `fadeDuration = 200ms`,
     `child`, `splashBuilder`; таймеры в initState; `_done`; build — стабильный
     корневой `Stack` (тёмная база; splash `MaterialApp` до 2.5 с; приложение
     монтируется в последние 200 мс и проявляется `FadeTransition`; после DI >
     2.5 с — `StartupLoadingScreen`). Таймеры отменять в dispose; повторный child
     не перезапускает splash (state сохраняется в AppRestartHost); при
     reduce-motion без фейда.
  5. **AppRestartHost.** Опциональные `showSplash`, `splashDuration`,
     `splashBuilder`; default `showSplash ?? defaultTargetPlatform == android`;
     build `StartupSplash(... child: locator == null ? null : FinanseApp(...))`.
     При restart backup `_done` сохраняется → видео не повторяется; на Linux
     splash отключён, e2e-хелперы не меняются.
  6. **Tests/docs/QA.** Widget-тесты StartupSplash (splash → loading → app,
     disabled, ровно 2.5 с, no replay); docs; design-reviewer; android-tester
     short (видео/длительность/звук/кроп/reduce-motion/restart); e2e Linux;
     release APK.
- **DoD:** format/analyze/test/release APK; task-reviewer; design-reviewer;
  android-tester short; e2e 9/9; видео ≤2.5 с и без звука; нет новых строк мимо
  arb (бренд — `appTitle`); `git diff --check`; статус `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/16.1: видео-заставка при запуске`.
- **Итог:** `StartupSplash` держит splash ровно 2.5 с от первого кадра, затем
  приложение; при медленном DI — `StartupLoadingScreen` (фон + `AppSpinner`);
  `enable` по умолчанию только Android; повторный child не перезапускает splash.
  `SplashScreen` играет первые 2.5 с `finsplash.mp4` без звука, центральный
  квадрат 1:1 через `FittedBox.fitHeight` + `ClipRect`, постер-первый кадр до
  готовности видео/reduce-motion/ошибке, зум 3% и градиентные шторки по краям
  без видимого шва. После design-review добавлен кросс-фейд 200 мс (последние
  200 мс из 2.5 с, при reduce-motion мгновенно) в стабильном дереве (splash не
  ремаунтится, видео играет до 2.5 с) поверх непрозрачной тёмной базы;
  светлый спиннер loading, прозрачная иконка системного splash Android 12+,
  тёмные бары на заставке.
  Launch-тема Android и `windowSplashScreenBackground` — `#06110E`, белой
  вспышки нет. 721 тест; analyze чистый; release APK 74,8 МБ (+4,7 МБ: видео,
  постер, video_player). Linux e2e не затронут (splash выключен). Ручная
  проверка видео — короткий android-tester до PR (`TEST_PLAN.md`); e2e Linux
  не запускался по решению владельца (splash на Linux выключен).

## Текущий этап

Этап 16 «Видео-заставка при запуске» — задача 16.1 закрыта (2026-11-22),
вливается PR из ветки `task/16.1-splash-video`. Тело этапа — выше.
Завершённые этапы 1–15 — `PLAN_ARCHIVE.md`.
