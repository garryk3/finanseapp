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
| 17 | Числовые поля форм без стартового нуля | 17.1–17.2 | ✅ | 2026-11-22 |
| 18 | Мультивалютные инвестиции, заблокированные активы, аналитика (v0.9.0) | 18.1–18.8 | 🚧 | — |
| 19 | Главная: отступы, подушка безопасности, просроченные счета, разбивка капитала | 19.1–19.4 | ✅ | 2026-11-23 |

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
     `child`, `splashBuilder`; таймеры стартуют после первого отрисованного
     кадра (`addPostFrameCallback`), чтобы прогрев движка не съедал заставку;
     `_done`; build — стабильный корневой `Stack` (тёмная база; splash
     `MaterialApp` до 2.5 с; приложение монтируется в последние 200 мс и
     проявляется `FadeTransition`; после DI > 2.5 с — `StartupLoadingScreen`).
     Таймеры отменять в dispose; повторный child не перезапускает splash
     (state сохраняется в AppRestartHost); при reduce-motion без фейда.
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
- **Короткий QA (2026-11-22):** 9 PASS, 1 FAIL (TC-149, не блокер), 1 SKIP.
  TC-149: таймер стартовал в `initState`, первый кадр запаздывал на ~0.6 с —
  видимая заставка 1.89 с, видео ~1.5 с. Исправлено: отсчёт от первого
  отрисованного кадра (`addPostFrameCallback`), видео играет до 2.5 с.
  Recheck TC-149 — PASS (2.25–2.46 с).

## Этап 17 — Числовые поля форм без стартового нуля

### 17.1 Поле ставки не инициализируется нулём — [x] (2026-11-22)

- **Источник:** жалоба владельца 2026-11-22: при создании вклада поле ставки
  стартует с «0»; ввод «12» даёт «012» вместо «12» (то же для нулевого
  начального баланса при редактировании).
- **Причина:** `_rate = TextEditingController(text: '0')`; при загрузке
  существующего счёта нулевые `openingValue`/`annualRate` выводились как «0».
- **Решение:** пустое поле + hint «0» (пустое значение уже парсится как 0);
  при редактировании нулевые баланс и ставка показываются пустыми, ненулевые —
  как есть. Ввод начинается с первой цифры, без ведущего нуля.
- **Files:** `lib/core/features/assets/ui/account_form_screen.dart`;
  `lib/l10n/app_ru.arb` (+ generated l10n); `test/core/features/assets/ui/
  account_screens_test.dart`; `PLAN.md`.
- **TDD:**
  1. Create: контроллер ставки пуст, hint «0»; ввод «12» → `annualRate` = 12.
  2. Edit счёта с нулевыми балансом/ставкой → оба поля пустые (сохранение даёт
     нули); с ненулевой ставкой — её значение.
  3. Форма не регрессирует: пустые поля по-прежнему сохраняются как нули.
- **DoD:** format/analyze/test; task-reviewer; design-reviewer (пустое поле +
  hint); `git diff --check`; статус `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/17.1: числовые поля формы счёта без стартового нуля`.
- **Итог:** поле ставки при создании пустое + hint «0»; при редактировании
  нулевые `openingValue`/`annualRate` показываются пустыми, дробная ставка —
  «12.5»; сохранение пустых полей даёт нули. Новые тесты: create (пусто →
  «12»), edit zero (пусто → 0), edit «12.5». Всего 724 теста; format/analyze
  чисто. task-reviewer — SHIP WITH FIXES (недостающий TDD-тест добавлен),
  design-reviewer — APPROVE; e2e не запускался по решению владельца.

### 17.2 Нулевые стоимость/цена в формах инвестиций и недвижимости — [x] (2026-11-22)

- **Источник:** тот же дефект 17.1, оставшийся в edit-режиме других активов:
  сохранённый ноль выводился как «0», и ввод дописывался к нему.
- **Решение:** при загрузке нулевые `openingValue` (инвестиция, недвижимость)
  и `purchasePrice` (недвижимость) показываются пустыми; ненулевые — как есть.
  Пустые баланс/стоимость уже трактуются как ноль (`parseOpeningAmountOrZero`);
  пустая цена покупки — `null`, но загруженный ноль сохраняется (не теряется
  при сохранении без правки поля), а очистка ненулевой цены даёт `null`.
- **Files:** `lib/core/features/assets/ui/investment_form_screen.dart`;
  `lib/core/features/assets/ui/property_form_screen.dart`;
  `test/core/features/assets/ui/investment_screens_test.dart`;
  `test/core/features/assets/ui/property_form_screen_test.dart`; `PLAN.md`.
- **TDD:**
  1. Edit инвестиции с нулевым балансом → поле пустое; с 1000,00 → «1000».
  2. Edit недвижимости с нулевыми стоимостью/ценой → оба поля пустые;
     с 1000,00/50 000,00 → «1000»/«50000».
  3. Существующий тест инвестиции: пустой ввод сохраняется нулём; новые —
     сохранённый ноль покупки остаётся нулём, `null` и очистка ненулевой цены
     дают `null`.
- **DoD:** format/analyze/test; task-reviewer; design-reviewer (пустые поля);
  `git diff --check`; статус `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/17.2: нулевые числовые поля форм активов`.
- **Итог:** нулевые баланс инвестиции и стоимость/цена недвижимости при
  редактировании показываются пустыми; ненулевые — «1000»/«50000»; сохранённый
  нулевой `purchasePrice` не превращается в `null` при сохранении без правки
  этого поля. 7 новых тестов, всего 731; format/analyze чисто.
  task-reviewer — SHIP WITH FIXES (недостающие ветви тестов добавлены),
  design-reviewer — APPROVE (Medium по `purchasePrice` исправлен); e2e
  не запускался по решению владельца.

## Этап 18 — Мультивалютные инвестиции, заблокированные активы, аналитика (v0.9.0)

**Источник:** TASKS.md 2026-11-22 (перенесено 2026-11-23). Шесть пожеланий владельца:
мультивалютность инвестиционных счетов; маркировка заблокированных активов + блок на
главном; «Детализация за месяц» отдельной страницей с фильтрацией пустых периодов;
табы расходы/доходы в итогах по категориям; цветовая окраска сумм операций; релиз 0.9.0.

**Граф зависимостей:** 18.1 → 18.2 → 18.3 → 18.4; 18.5 → 18.6; 18.7 независима;
18.8 после всех. Задачи выполнять строго по одной (ветка → PR → squash merge),
не параллелить задачи, трогающие одни файлы.

**Решения и допущения этапа (не менять молча):**
- **D1.** Мультивалютность — только инвестиции (`AssetKind.investment`). Обычные счета
  и квартиры остаются одновалютными; селектор валюты в формах операций/оценок
  появляется только для инвестиции.
- **D2.** Заблокированную сумму нельзя ввести больше остатка позиции в этой валюте
  на момент ввода; при последующем уменьшении остатка отметка не пересчитывается.
  **Подтверждено владельцем 2026-11-23.**
- **D3.** «Детализация за месяц» показывает список бакетов выбранного периода
  (в режиме «Месяц» — дни, в длинных периодах — месяцы, как сейчас), пустые бакеты
  скрыты; если весь выбранный месяц пуст — «Нет операций за месяц».
- **D4.** Заблокированные активы не уменьшают стоимость инвестиции и net worth —
  это только информационная маркировка.
- **D5.** Релиз — `v0.9.0` без суффикса (последний тег `v0.1.2` без суффикса),
  версия в pubspec `0.9.0+4` (build-номер +1; versionCode берётся из `+N`).
- **D6.** Селектор валюты в форме пополнения/снятия по умолчанию заполняется
  **валютой инвестиции** (основной валютой счёта), а не базовой валютой приложения.
  **Подтверждено владельцем 2026-11-23** (уточнение формулировки TASKS.md
  «по умолчанию заполнена базовой»).

### 18.1 Мультивалютные инвестиции: схема v3, расчёты, репозитории — [x] (2026-11-23)

- **Приоритет/зависимости:** P1; первая задача этапа, зависимостей нет.
- **Суть:** инвестиция хранит позиции в нескольких валютах. Операции и оценки
  получают собственную валюту (по умолчанию — валюта актива). Стоимость считается
  по каждой валюте отдельно; все итоги (net worth, цели, базовый эквивалент)
  суммируют позиции с конвертацией в базовую валюту. UI не меняется (кроме
  автоматического следования данным) — новые элементы UI в 18.2.
- **Решения (контракты, не менять молча):**
  - **M1.** Валюта операции/оценки хранится в новой nullable-колонке `currency_code`;
    `NULL` = валюта актива (совместимость со старыми строками). При записи, если
    валюта совпадает с валютой актива, пишется `NULL` (нормализация).
  - **M2.** Для счёта/квартиры операция/оценка в валюте, отличной от валюты актива,
    → `DomainException(validation, fieldErrors: {'currencyCode':
    'validationCurrencyMismatch'})`. Для инвестиции допустима любая валюта из
    справочника (существование проверяет `_rubMinor`/DAO).
  - **M3.** Стоимость инвестиции по валюте C: последняя оценка в валюте C
    (`effectiveOn`, тай-брейк `id`) + операции в валюте C с `occurredOn >=` даты
    оценки (операция той же даты — после оценки, как сейчас). Старт: для валюты
    актива — `openingValue`, для остальных валют — 0. Удалённые операции игнорируются.
  - **M4.** `AssetSnapshot.currentValue` остаётся стоимостью в основной валюте
    актива (первая позиция). Новое опциональное поле `currencyBalances: List<Money>?`
    и геттер `List<Money> get breakdown => currencyBalances ?? [currentValue]`.
    Порядок breakdown: основная валюта актива всегда первая (даже с нулём),
    остальные — по алфавиту кода, только с ненулевым балансом.
  - **M5.** Итоги считают по `breakdown`: каждая позиция конвертируется отдельно,
    exact A→RUB→base, одно округление на итог — через `NetWorthCalculator.calculate`
    (он уже принимает список значений и суммирует по видам). Частичная сумма при
    нехватке курса не показывается (как в целях): `rateUnavailable`/«Курс недоступен».
  - **M6.** Переводы — только между счетами (без изменений). Классификация
    доход/расход — только счета (без изменений). RUB-снимок операции
    (`amountRubMinor`) считается от валюты операции по её курсу.
  - **M7.** Snapshot ревизии получает аддитивный ключ `currencyCode` (String?,
    null = валюта актива); `snapshotSchemaVersion` остаётся 1. Декодер аудита
    читает ключ с fallback на валюту актива.
  - **M8.** Фильтр журнала по валюте матчит валюту операции:
    `t.currency_code = :code OR (t.currency_code IS NULL AND a.currency_code = :code)`.
- **Files:**
  - Modify (схема): `lib/core/database/tables/asset_transactions.dart`
    (+`TextColumn get currencyCode => text().nullable().references(Currencies, #code,
    onUpdate: KeyAction.restrict, onDelete: KeyAction.restrict)()`),
    `lib/core/database/tables/asset_valuations.dart` (аналогичная колонка),
    `lib/core/database/app_database.dart` (`appDatabaseSchemaVersion = 3`;
    `onUpgrade`: `if (from < 3) { await m.addColumn(assetTransactions,
    assetTransactions.currencyCode); await m.addColumn(assetValuations,
    assetValuations.currencyCode); }`; `onCreate` без новых runtime-DDL —
    список `schemaObjectsV3` не нужен).
  - Modify (data/domain): `lib/core/database/daos/transactions_dao.dart`
    (`AssetTransactionInput` +`String? currencyCode`; `create`/`revise` пишут колонку;
    `_writeRevision` передаёт `currencyCode` в snapshot; `watchFiltered` — фильтр
    валюты по M8, строки 131–133), `lib/core/database/daos/valuations_dao.dart`
    (`create` +параметр `String? currencyCode`, запись в Companion),
    `lib/core/database/revision_snapshots.dart` (`assetTransactionSnapshotFields`
    +параметр и ключ `currencyCode`), `lib/core/features/transactions/data/
    asset_transaction_mapper.dart` (`currencyCode: row.currencyCode ?? currencyCode`
    — параметр остаётся fallback-валютой актива),
    `lib/core/features/transactions/data/asset_transaction_repository_impl.dart`
    (`_createTransaction`/`_reviseTransaction`: валюта = `draft.amount.currencyCode`,
    валидация M2, нормализация M1, `_rubMinor(draft.amount, валютаОперации, rate)`),
    `lib/core/features/assets/domain/asset.dart` (`AssetSnapshot` по M4),
    `lib/core/features/assets/domain/asset_value_calculator.dart`
    (+`static List<Money> investmentBalances(InvestmentAsset asset,
    List<AssetValuation> valuations, List<AssetTransaction> transactions)` по M3/M4;
    существующий `investment()` оставить как обёртку — баланс основной валюты),
    `lib/core/features/assets/data/asset_repository_impl.dart`
    (`recordValuation`: валюта = `draft.value.currencyCode`, валидация M2 для
    квартиры, нормализация M1; `_valuationFrom`: `row.currencyCode ?? currencyCode`;
    `_buildSnapshot` ветка investment: `investmentBalances` → `currentValue` =
    первая позиция, `currencyBalances` = список),
    `lib/core/features/audit/data/revision_decoder.dart`
    (`decodeAssetTransactionSnapshot`: `data['currencyCode'] as String? ?? currencyCode`).
  - Modify (аналитика): `lib/core/features/analytics/data/analytics_mappers.dart`
    (+`static Map<String, int> investmentValuesByCurrency(AssetRow asset,
    Iterable<AssetValuationRow> valuations, Iterable<AssetTransactionRow> transactions,
    LocalDate onDate)` — группировка строк по `currencyCode ?? asset.currencyCode`,
    на каждую валюту формула M3 срезом `<= onDate`; `investmentValueMinor` оставить
    обёрткой основной валюты; `valueMinor` не менять),
    `lib/core/features/analytics/data/analytics_queries_impl.dart` (`_summaryAt`,
    строки 135–185: для investment — по записи `NetWorthAssetValue` на каждую валюту
    из `investmentValuesByCurrency`; валюта каждой позиции берётся из
    `data.currencies`, при отсутствии — `currencyNotFound`; курсы `_rateFor`
    грузятся на каждую валюту позиции != базовой; account/property — без изменений).
  - Modify (потребители): `lib/core/features/goals/logic/goal_calculator.dart`
    (`assetValues: Map<int, List<Money>>`; суммирование всех Money всех списков),
    `lib/core/features/goals/logic/calculate_goal_progress.dart` (`load`/`calculate`:
    тот же тип; конвертация каждого Money списка; нехватка курса любой позиции →
    `null` целиком), `lib/core/features/goals/ui/goals_view_model.dart:145` и
    `lib/core/features/goals/ui/goal_details_view_model.dart:131` и
    `lib/core/features/dashboard/ui/dashboard_view_model.dart:264`
    (`values[assetId] = snapshot.breakdown`),
    `lib/core/features/assets/ui/assets_view_model.dart` (`_ensureRates`: коды из
    `breakdown` всех снапшотов; `baseEquivalent`: при `breakdown.length > 1` —
    итог всех позиций в базовой валюте через `NetWorthCalculator.calculate`
    (kind = вид актива), показывается даже если базовая валюта = валюта актива;
    при одном значении — текущее поведение),
    `lib/core/features/assets/ui/account_details_view_model.dart`
    (+сигнал `breakdown: Signal<List<Money>>` из снапшота; `_loadBaseEquivalent`
    принимает снапшот и суммирует breakdown через `NetWorthCalculator.calculate`;
    курсы `rateRepository.find(code, today)` на все коды breakdown + базовую;
    нехватка любого курса → `baseRateUnavailable = true`; при `breakdown.length > 1`
    базовый эквивалент показывается и при совпадении валют),
    `lib/core/features/assets/ui/account_details_screen.dart` (`showBase` при
    `breakdown.length > 1`, автоматическое следование данным).
  - Modify (l10n): не требуется (новых строк нет).
  - Generated (коммитить): `lib/core/database/app_database.g.dart`,
    `lib/core/database/daos/transactions_dao.g.dart`,
    `lib/core/database/daos/valuations_dao.g.dart` (`dart run build_runner build`);
    `drift_schemas/drift_schema_v3.json` (`dart run drift_dev schema dump`);
    `test/generated_migrations/schema_v3.dart` + обновление
    `test/generated_migrations/schema.dart` (`dart run drift_dev schema generate`).
  - Test (create): `test/core/database/migration_v2_v3_test.dart` — образец
    `test/core/database/migration_v1_v2_test.dart`: файловая БД v2 из
    `schema_v2.dart` с фикстурами (счёт + инвестиция + операции + оценки),
    открытие как `AppDatabase` → `user_version = 3`, колонки `currency_code` есть
    в обеих таблицах (`PRAGMA table_info`), данные целы, старые строки читаются
    с валютой актива.
  - Test (modify): `test/core/features/assets/domain/investment_value_calculator_test.dart`
    (+кейсы `investmentBalances`), `test/core/features/assets/data/
    investment_repository_test.dart` и `asset_repository_test.dart` (запись валюты,
    валидация M2, breakdown снапшота), `test/core/database/revision_transaction_test.dart`
    (ключ `currencyCode` в snapshot), `test/core/features/transactions/data/
    asset_transaction_repository_test.dart` (RUB-снимок от валюты операции;
    операция по счёту в чужой валюте → validation),
    `test/core/features/transactions/ui/transactions_journal_test.dart` или
    `test/core/features/transactions/data/` (фильтр по валюте операции M8),
    `test/core/features/analytics/data/net_worth_test.dart` и `net_worth_series_test.dart`
    (мультивалютная инвестиция в итоге и исторических точках),
    `test/core/features/goals/logic/goal_calculator_test.dart`,
    `test/core/features/goals/ui/goals_view_model_test.dart` и
    `goal_details_view_model_test.dart` (тип `Map<int, List<Money>>`),
    `test/core/features/assets/ui/assets_view_model_test.dart` и
    `account_details_view_model_test.dart` (базовый эквивалент = сумма позиций),
    `test/core/features/dashboard/ui/dashboard_screen_test.dart` (фейки снапшотов —
    поле опциональное, существующие не ломаются; добавить кейс мультивалютной
    инвестиции в net worth), тесты аудита (`test/core/features/audit/`) — декодер с ключом и без.
- **Consumes:** `Money`, `MoneyMath`, `CurrencyConverter`, `NetWorthCalculator`,
  `ResolveExchangeRate` (без изменений), `AssetsDao`/`TransactionsDao`/`ValuationsDao`.
- **Produces:** схема v3; `AssetSnapshot.breakdown`; `investmentBalances`;
  мультивалютные операции/оценки инвестиции; net worth/цели/базовые эквиваленты
  учитывают все позиции; журнал и аудит показывают валюту операции.
- **TDD (сначала failing tests, затем реализация):**
  1. `investmentBalances`: opening 100 000 RUB + deposit 100 USD →
     `[100 000 RUB, 100 USD]`; оценка 120 USD меняет только USD-позицию;
     операция той же даты, что оценка, применяется после неё; withdrawal 100 USD
     обнуляет USD-позицию → она исчезает из списка, RUB остаётся первой;
     удалённые операции не учитываются; основная валюта присутствует даже с нулём.
  2. Репозиторий: deposit по инвестиции в USD → в строке `currency_code = 'USD'`,
     `amount_rub_minor` = сумма × курс USD; deposit в USD по счёту RUB →
     `validationCurrencyMismatch`; deposit в валюте актива → `currency_code IS NULL`;
     оценка инвестиции в EUR пишется с `currency_code = 'EUR'`; оценка квартиры
     в чужой валюте → validation.
  3. `getById`/`watchAll` снапшот мультивалютной инвестиции: `currentValue` =
     позиция основной валюты, `breakdown` = все позиции по M4.
  4. Миграция v2→v3 (см. Test create): данные целы, колонки на месте.
  5. Snapshot ревизии содержит `currencyCode` (null для валюты актива); декодер
     аудита возвращает валюту операции и для старых snapshot без ключа.
  6. `netWorth`: инвестиция 100 000 RUB + 120 USD при курсе 92, базовая RUB →
     вклад инвестиции 111 040 RUB (CALC-046); историческая точка на дату до
     USD-операции содержит только RUB-позицию; нехватка курса USD → `rateUnavailable`.
  7. Цели: прогресс по инвестиции с двумя позициями = сумма конвертированных
     позиций; нехватка курса одной позиции → прогресс не считается целиком.
  8. `baseEquivalent` (assets VM и account details VM/экран): мультивалютная
     инвестиция → итог всех позиций в базовой валюте, в т.ч. когда базовая =
     основная валюта.
  9. Фильтр журнала по валюте USD находит USD-операцию инвестиции с основной
     валютой RUB и не находит RUB-операции.
- **Рабочий план:**
  1. Написать failing tests 1–3 (domain + репозиторий), убедиться в причине падения.
  2. Схема: колонки в двух таблицах, `appDatabaseSchemaVersion = 3`, `onUpgrade`;
     `build_runner`; schema dump v3; `schema generate` (schema_v3.dart + schema.dart);
     миграционный тест v2→v3.
  3. DAO: `AssetTransactionInput.currencyCode`, запись в `create`/`revise`,
     `_writeRevision` + ключ snapshot; `ValuationsDao.create` + параметр;
     `watchFiltered` по M8.
  4. Domain: `AssetSnapshot.currencyBalances`/`breakdown`;
     `AssetValueCalculator.investmentBalances` (группировка по валюте, сортировка
     оценок `(effectiveOn, id)`, старт opening/0, фильтр `>= from`);
     mapper операции и `_valuationFrom` — fallback на валюту актива.
  5. Репозитории: валидация M2, нормализация M1, `_rubMinor` от валюты операции;
     `recordValuation` с валютой оценки; `_buildSnapshot` investment через
     `investmentBalances`; декодер аудита.
  6. Аналитика: `investmentValuesByCurrency` + `_summaryAt` по позициям.
  7. Потребители: цели (тип `Map<int, List<Money>>` + три call-site), assets VM и
     account details VM (базовый эквивалент суммой позиций, курсы на все коды).
  8. Прогнать весь `flutter test`, починить регрессии (ожидания не подгонять под
     ошибочную реализацию); docs; гейты DoD.
- **Docs:** `docs/architecture/data_schema.md` §3 (`asset_valuations` +колонка),
  §4 (`asset_transactions` +колонка, убрать фразу «отдельной currencyCode у
  транзакции нет», snapshot +ключ), §7 (миграция v3); `docs/architecture/
  domain_model.md` §4 (`AssetSnapshot.breakdown`), §5 (валюта операции), §9
  (контракты); `docs/architecture/calculations.md` §3 «Инвестиция» — per-currency
  формула + примеры CALC-045 (opening 100 000 RUB + 100 USD по 90, оценка 120 USD
  по 92 → позиции 100 000 RUB и 120 USD) и CALC-046 (net worth базовая RUB →
  111 040 RUB от инвестиции); `docs/architecture/business_rules.md` — BR-A-8
  (мультивалютность только инвестиций; per-currency расчёт; конвертация на уровне
  итогов) и BR-T-12 (валюта операции инвестиции выбирается, по умолчанию валюта
  актива; у счёта/квартиры всегда валюта актива). ID 041/042 и BR-T-11 заняты
  этапом 15 — сознательно использованы следующие свободные (CALC-045/046,
  BR-T-12), coverage-тест обновлён.
- **DoD:** общий DoD (шапка плана) + миграционный тест v2→v3 зелёный + schema dump
  закоммичен; task-reviewer; design-reviewer — по diff (меняются VM в `ui/` и
  поведение отображаемых сумм, новых виджетов нет); android-tester коротким
  прогоном после merge (append TEST_PLAN.md); статус `[x]` + дата до PR;
  e2e — спросить владельца.
- **Предлагаемый commit:** `task/18.1: мультивалютные инвестиции — схема v3 и расчёты`.
- **Итог:** схема v3 (nullable `currency_code` в операциях/оценках, FK, миграция
  v2→v3, drift_schema_v3 + generated); M1–M8 реализованы: нормализация NULL,
  validation для счёта/квартиры, `investmentBalances` по M3, `AssetSnapshot.
  breakdown`, RUB-снимки от валюты операции, snapshot ревизии + `currencyCode`,
  аудит-декодер с fallback, фильтр журнала по валюте операции. Net worth/история,
  цели, assets VM, account details VM и экран (базовый эквивалент при
  `breakdown.length > 1`) суммируют позиции с конвертацией; частичный курс →
  `rateUnavailable`/скрытие. Docs обновлены (CALC-045/046, BR-A-8/BR-T-12).
  33 новых теста, всего 803; format/analyze чисто; e2e не запускался.
- **По ревью:** `countReferences`/`countRateReferences` учитывают валюту
  операций/оценок (BR-C-3/BR-C-4) + тест; widget-тест `showBase` при
  `breakdown.length > 1`; всего 805. **WILL ROT:** формула M3 продублирована в
  `analytics_mappers` (делегировать в `investmentBalances`); `fractionDigits`
  оценки брать из справочника валюты — в 18.2.

### 18.2 Мультивалютные инвестиции: UI форм и экрана инвестиции — [x] (2026-11-23)

- **Приоритет/зависимости:** P1; после 18.1.
- **Суть:** селектор валюты в форме операции и форме оценки (только для инвестиции,
  по умолчанию валюта актива); на экране инвестиции — состав по валютам и общая
  стоимость в базовой валюте (пример владельца: «100 000 ₽, 100 $, общее 108 000»).
- **Решения:**
  - **U1.** Селектор валюты — `AppCurrencySelect` (уже есть в uikit), список —
    включённые валюты (`currencyRepository.getEnabled()`), значение по умолчанию —
    валюта выбранного актива (D6, подтверждено владельцем). Для счёта/квартиры
    селектор не показывается.
    При смене актива в форме операции валюта сбрасывается на валюту нового актива,
    поле ручного курса очищается.
  - **U2.** `AppAmountField` (suffix, `maxFractionDigits`) и видимость поля ручного
    курса следуют за выбранной валютой (курс показывается, когда валюта != RUB).
    `ResolveExchangeRate` вызывается с выбранной валютой (не с валютой актива).
  - **U3.** Экран инвестиции (`account_details_screen.dart`): при
    `breakdown.length > 1` карточка «Текущая стоимость» показывает итог в базовой
    валюте (`vm.baseEquivalent`); сразу под карточкой в той же секции —
    «Состав по валютам» (`AppSectionHeader(padded:false)` + строки `AppListTile`:
    сумма позиции в её валюте). Старый блок «В базовой валюте» для
    мультивалютной инвестиции не показывается (итог уже в карточке). При
    `baseRateUnavailable` — карточка показывает «—» + «Курс недоступен», состав
    показывается. При `breakdown.length == 1` — всё как сейчас.
    *Отклонение (design-review):* состав встроен в секцию карточки (не отдельный
    `AppSection`), а недоступный курс даёт «—», чтобы частичный баланс не
    выглядел итогом.
  - **U4.** История оценок: сумма форматируется валютой самой оценки
    (`fractionDigits` из справочника, не из валюты актива); чип «Текущая» —
    у последней оценки каждой валюты (список уже отсортирован newest-first:
    первая строка каждого `currencyCode`).
  - **U5.** Карточка инвестиции в списке активов не меняется: `amountText` —
    основная валюта, `baseAmountText` — итог всех позиций (поведение 18.1).
- **Files:**
  - Modify: `lib/core/features/transactions/ui/transaction_form_screen.dart`
    (состояние `_currencyCode`; `AppCurrencySelect` между селектом актива и
    суммой, только когда `asset?.kind == AssetKind.investment`; `_save` строит
    `Money` в выбранной валюте; сброс валюты/курса в `onChanged` актива,
    строки 255–268), `lib/core/features/transactions/ui/
    transaction_form_view_model.dart` (`save`: `ResolveExchangeRate.call(
    rateRepository, amount.currencyCode, ...)` вместо `asset.currencyCode`,
    строки 143–148; маппинг ошибки `validationCurrencyMismatch`),
    `lib/core/features/assets/ui/valuation_form_screen.dart` (`AppCurrencySelect`
    для инвестиции; сохранение в выбранной валюте),
    `lib/core/features/assets/ui/valuation_form_view_model.dart`
    (+сигнал `currencies: Signal<Map<String, Currency>>` из `getEnabled()`;
    `save`: курс и draft от `value.currencyCode`; для квартиры — валидация
    совпадения валюты с активом), `lib/core/features/assets/ui/
    account_details_screen.dart` (U3/U4), `lib/core/features/assets/ui/
    account_details_view_model.dart` (+сигнал `currencies: Signal<Map<String,
    Currency>>` для fractionDigits строк состава/оценок; заполнять в `_reload`).
  - Modify (l10n): `lib/l10n/app_ru.arb` + generated:
    `transactionCurrencyLabel` = «Валюта операции»;
    `valuationCurrencyLabel` = «Валюта оценки»;
    `investmentBreakdownTitle` = «Состав по валютам»;
    `investmentTotalBase` = «Итого в базовой валюте» (subtitle карточки при
    мультивалютности, если нужен — по решению design-reviewer).
  - Test (modify): `test/core/features/transactions/ui/transaction_form_screen_test.dart`
    (селектор виден для инвестиции, скрыт для счёта; дефолт = валюта актива;
    смена актива сбрасывает валюту; сохранение USD-операции по RUB-инвестиции
    передаёт `Money(..., 'USD')` и курс USD), `test/core/features/assets/ui/
    investment_screens_test.dart` (форма оценки: селектор, сохранение в выбранной
    валюте; экран инвестиции: состав по валютам, итог в базовой, «Курс недоступен»,
    чип «Текущая» per-currency), `test/core/features/assets/ui/
    account_details_view_model_test.dart` (currencies/breakdown).
- **Consumes:** `AppCurrencySelect`/`AppCurrencyOption`, `AppAmountField`,
  `AppSection`, `AppListTile`, `AppSummaryCard`, `AppMoneyText`, `MoneyFormatter`,
  `AssetSnapshot.breakdown` (18.1), `ResolveExchangeRate`.
- **Produces:** пользователь может пополнить/снять инвестицию в любой валюте и
  задать оценку в любой валюте; экран инвестиции показывает состав и общий итог
  в базовой валюте.
- **TDD:**
  1. Форма операции: выбрана инвестиция RUB → селектор валюты виден, дефолт RUB;
     выбор USD → suffix «USD», поле курса появилось; сохранение → draft в USD.
  2. Форма операции: выбран счёт → селектора нет; поведение не регрессирует.
  3. Смена актива инвестиции RUB → инвестиции USD сбрасывает выбранную валюту
     на USD и очищает ручной курс.
  4. Форма оценки инвестиции: селектор валюты, дефолт = валюта актива; оценка
     120 USD сохраняется с курсом USD; для квартиры селектора нет.
  5. Экран инвестиции с breakdown `[100 000 RUB, 100 USD]`, базовая RUB, курс 90 →
     карточка «109 000,00 ₽», секция «Состав по валютам» с двумя строками;
     старый блок «В базовой валюте» отсутствует.
  6. Курс USD недоступен → карточка показывает «—» + «Курс недоступен»,
     состав виден.
  7. История оценок: оценка EUR форматируется с fractionDigits EUR; чип «Текущая»
     у последней оценки каждой валюты.
- **Рабочий план:**
  1. Failing widget-тесты 1–4 (формы), затем реализация селекторов и правок VM.
  2. Failing тесты 5–7 (экран инвестиции), затем U3/U4 в экране и VM.
  3. l10n-ключи + `flutter gen-l10n`; прогон тестов; docs; гейты.
- **Docs:** `docs/architecture/navigation_and_screens.md` §5 (матрица: форма
  операции/оценки — селектор валюты для инвестиции; экран инвестиции — состав),
  `docs/architecture/domain_model.md` §11 (сигналы VM, если перечислены).
- **DoD:** общий DoD; task-reviewer + design-reviewer (UI); android-tester коротким
  прогоном; статус `[x]` до PR; e2e — спросить.
- **Итог:** U1–U5: `AppCurrencySelect` в форме операции и оценки только для
  инвестиции (дефолт — валюта актива, сброс валюты и ручного курса при смене
  актива), `AppAmountField` и поле курса следуют выбранной валюте,
  `ResolveExchangeRate` вызывается с валютой операции/оценки; мультивалютная
  карточка «Текущая стоимость» показывает `baseEquivalent`, сразу под ней —
  секция «Состав по валютам» (до кнопок действий), старый блок «В базовой
  валюте» скрыт; при недоступном курсе карточка «—» + «Курс недоступен»,
  состав виден; история оценок форматируется валютой оценки, чип «Текущая» —
  per-currency; U5 не менялся. По ревью: сброс валюты/курса только при реальной
  смене актива; `AssetValuationDraft.fractionDigits` удалён (репозиторий берёт
  digits из справочника) + тесты дефолта на USD-активе. WILL ROT 18.1 закрыт:
  `AssetRepositoryImpl.recordValuation` берёт `fractionDigits` из
  `currenciesDao.find`. 15 новых тестов, всего 820; format/analyze/dart analyze
  чисто; release-сборка и e2e не запускались.
- **WILL ROT 18.2:** чип «Текущая» без кода валюты (при нескольких валютах
  появляется в середине истории); расхождение U5: список даёт primary =
  основная валюта, детали — итог в базовой; единый хелпер резолва
  «код → Currency» вместо пяти копий. Отложено на 18.x.
- Отклонение: в TDD-примере 5 итог `[100 000 RUB + 100 USD]` по курсу 90
  равен 109 000 ₽ (108 000 в исходном тексте арифметически неверны); тест
  проверяет корректную формулу CALC-046.
- **Предлагаемый commit:** `task/18.2: мультивалютные инвестиции — UI`.

### 18.3 Заблокированные активы: схема v4 и маркировка на экране инвестиции — [x] (2026-11-23)

- **Приоритет/зависимости:** P1; после 18.2 (общие файлы экрана/VM инвестиции).
- **Суть:** по каждой валюте инвестиции можно отметить сумму заблокированных
  активов (пример владельца: счёт 100 000 ₽ + 100 $ + 10 €, отметить 99 $ и 5 €).
  Маркировка хранится в БД, видна на экране инвестиции; блок на главной — 18.4.
- **Решения:**
  - **L1.** Новая таблица `investment_locked_amounts`: `asset_id` INTEGER NOT NULL
    → assets.id RESTRICT, `currency_code` TEXT NOT NULL → currencies.code RESTRICT,
    `amount_minor` INTEGER NOT NULL CHECK (`> 0`), `created_at`/`updated_at` TEXT
    NOT NULL UTC; PK `(asset_id, currency_code)`. Одна отметка на валюту;
    повторная установка — upsert; сумма 0 — удаление строки.
  - **L2.** Валидация при установке: актив — инвестиция; валюта есть в справочнике;
    `0 < amount <=` баланс позиции в этой валюте (из `investmentBalances`);
    позиции нет или баланс меньше → `DomainException(validation, fieldErrors:
    {'amount': 'validationLockedExceedsBalance'})`. При последующем изменении
    баланса отметка не пересчитывается (D2).
  - **L3.** Отметки не входят в `referenceCounts` (BR-A-5) и физически удаляются
    вместе с активом в `deleteIfUnused` (в той же транзакции). Архивация отметки
    сохраняет; на архивной инвестиции UI read-only.
  - **L4.** `AssetSnapshot` +опциональное поле `lockedBalances: List<Money>?`
    и геттер `List<Money> get locked => lockedBalances ?? const []`;
    репозиторий наполняет поле из таблицы (батч в `_snapshotsOf`, одиночный
    запрос в `_snapshotOf`). Стоимость актива и net worth отметки не меняют (D4).
  - **L5.** UI: на экране инвестиции (только `AssetKind.investment`) секция
    «Заблокированные активы» после сводной карточки: строка `AppListTile` на
    каждую валюту breakdown — title: название/код валюты, subtitle:
    «Заблокировано: {сумма}» или «Не отмечено», trailing: `AppIconButton`
    (иконка `Icons.lock_outline`, semanticLabel «Изменить заблокированную сумму»)
    → диалог `showAppDialog` + `AppDialog` с `AppAmountField` (валюта строки,
    hint «Доступно: {баланс позиции}»), кнопки «Сохранить»/«Отмена»; пустое поле
    или 0 → снятие отметки. Ошибка валидации — текст под полем.
- **Files:**
  - Create: `lib/core/database/tables/investment_locked_amounts.dart`
    (`@DataClassName('InvestmentLockedAmountRow')`, конвертер
    `UtcTimestampConverter`, FK как в `asset_details.dart`);
    `test/core/database/migration_v3_v4_test.dart` (образец v1→v2/v2→v3).
  - Modify (схема): `lib/core/database/app_database.dart` (+таблица в
    `@DriftDatabase(tables: [...])`, `appDatabaseSchemaVersion = 4`, `onUpgrade`:
    `if (from < 4) { await m.createTable(investmentLockedAmounts); }` —
    `@TableIndex` нет, PK создаётся с таблицей; runtime-DDL не нужен).
  - Modify (data/domain): `lib/core/database/daos/assets_dao.dart`
    (+`InvestmentLockedAmounts` в `@DriftAccessor(tables: [...])`;
    `Future<void> setLockedAmount({required int assetId, required String
    currencyCode, required int amountMinor})` — upsert/delete, валидация kind и
    валюты; `Future<List<InvestmentLockedAmountRow>> lockedRowsForAsset(int
    assetId)`; `Future<List<InvestmentLockedAmountRow>> allLockedRows()`;
    `deleteIfUnused` (строка 310) — удаление отметок актива в транзакции),
    `lib/core/features/assets/domain/asset.dart` (`AssetSnapshot.lockedBalances`),
    `lib/core/features/assets/domain/asset_repository.dart`
    (+`Future<void> setLockedAmount(int assetId, String currencyCode, Money
    amount)` — 0 удаляет; +`Future<List<Money>> lockedAmounts(int assetId)`),
    `lib/core/features/assets/data/asset_repository_impl.dart`
    (реализация: проверка L2 через `investmentBalances` снапшота; наполнение
    `lockedBalances` в `_snapshotOf`/`_snapshotsOf`).
  - Modify (UI): `lib/core/features/assets/ui/account_details_screen.dart`
    (секция L5, только инвестиция; archived — без кнопки редактирования),
    `lib/core/features/assets/ui/account_details_view_model.dart`
    (+сигнал `locked: Signal<List<Money>>`; метод `Future<Result<void>>
    setLockedAmount(String currencyCode, Money amount)` с маппингом
    `DomainException` → `Failure`; обновление после записи через существующий
    стрим `watchById`).
  - Modify (l10n): `lib/l10n/app_ru.arb` + generated:
    `lockedAssetsTitle` = «Заблокированные активы»;
    `lockedAmountSubtitle` = «Заблокировано: {amount}» (placeholder String);
    `lockedNotMarked` = «Не отмечено»;
    `lockedEditTitle` = «Заблокированная сумма»;
    `lockedAvailableHint` = «Доступно: {amount}» (placeholder String);
    `lockedEditAction` = «Изменить заблокированную сумму»;
    `lockedErrorExceeds` = «Сумма превышает остаток в этой валюте.»;
    `lockedSaved` = «Заблокированная сумма сохранена.»;
    `lockedRemoved` = «Отметка о блокировке снята.».
  - Generated: `app_database.g.dart`, `assets_dao.g.dart`,
    `drift_schemas/drift_schema_v4.json`, `test/generated_migrations/schema_v4.dart`
    + `schema.dart`.
  - Test (modify/create): `test/core/features/assets/data/investment_repository_test.dart`
    (upsert, 0 → удаление, L2-валидации, `lockedBalances` снапшота,
    `deleteIfUnused` чистит отметки, `referenceCounts` не считает отметки),
    `test/core/features/assets/ui/account_details_view_model_test.dart`
    (`setLockedAmount` success/failure), `test/core/features/assets/ui/
    investment_screens_test.dart` (секция, диалог, снятие отметки, archived
    read-only), `test/core/database/migration_v3_v4_test.dart`.
- **Consumes:** `investmentBalances`/`AssetSnapshot.breakdown` (18.1),
  `AppDialog`/`showAppDialog`, `AppAmountField`, `AppListTile`, `AppIconButton`,
  `AppSection`, `MoneyFormatter`, `UtcTimestampConverter`.
- **Produces:** маркировка заблокированных сумм по валютам инвестиции; данные
  доступны снапшотом для дашборда (18.4).
- **TDD:**
  1. DAO/репозиторий: установка 99 USD при позиции 100 USD → строка; повторная
     установка 50 USD → upsert; 0 → строки нет; 101 USD →
     `validationLockedExceedsBalance`; отметка по валюте без позиции → validation;
     отметка по счёту/квартире → validation.
  2. Снапшот инвестиции содержит `lockedBalances` `[99 USD, 5 EUR]`; у счёта — пусто.
  3. `deleteIfUnused` инвестиции с отметками (без других связей) удаляет актив и
     отметки; `referenceCounts` отметки не учитывает.
  4. Миграция v3→v4: таблица создана, `user_version = 4`, данные целы.
  5. VM: `setLockedAmount` → Success и обновление сигнала `locked`; превышение →
     Failure с `validationLockedExceedsBalance`.
  6. Widget: секция показывает «Заблокировано: 99,00 $» и «Не отмечено»; диалог
     сохраняет сумму; пустой ввод снимает отметку (snackbar «Отметка снята»);
     архивная инвестиция — без кнопки редактирования.
- **Рабочий план:**
  1. Failing тесты 1–4 → таблица, DAO, миграция, generated, dump.
  2. Domain/repository: `setLockedAmount`/`lockedAmounts`, `lockedBalances`
     снапшота, валидация L2, cascade в `deleteIfUnused`.
  3. Failing тесты 5–6 → VM и секция UI с диалогом.
  4. l10n + gen; прогон; docs; гейты.
- **Docs:** `docs/architecture/data_schema.md` — новый раздел «§11. Заблокированные
  активы (schema v4)» (таблица, PK, CHECK, cascade-удаление), §7 миграция v4;
  `docs/architecture/domain_model.md` §4/§9 (`lockedBalances`, методы репозитория);
  `docs/architecture/business_rules.md` — BR-A-9 (L2/L3/D4 словами правила).
- **DoD:** общий DoD + миграционный тест v3→v4 + dump v4; task-reviewer +
  design-reviewer; android-tester коротким прогоном; статус `[x]` до PR; e2e — спросить.
- **Предлагаемый commit:** `task/18.3: заблокированные активы — хранение и маркировка`.
- **Итог:** схема v4 (таблица `investment_locked_amounts`, PK
  `(asset_id, currency_code)`, FK RESTRICT, миграция v3→v4, dump/generated);
  L1–L5: DAO upsert/0→delete/validation, cascade в `deleteIfUnused`,
  `referenceCounts` без отметок, `readsFrom` для `watchById`;
  `AssetSnapshot.lockedBalances`/`locked`; репозиторные `setLockedAmount`/
  `lockedAmounts` с проверкой через `investmentBalances`; VM `locked`/
  `setLockedAmount`; секция «Заблокированные активы» на экране инвестиции
  (строки по breakdown + осиротевшие отметки, сумма крупно, lock/lock_open,
  tap по строке и кнопке, диалог с подсказкой снятия, доступным остатком в
  ошибке, snackbar только при реальном изменении); архив read-only.
  По design-review: иерархия суммы, осиротевшие валюты, иконки состояния,
  a11y-подписи с валютой, 320dp/1.3/dark-тест. По task-review: смена валюты
  инвестиции с отметками запрещена (`validationCurrencyLocked`), stream-тест
  `readsFrom`/`watchById` после `setLockedAmount`. 18 новых тестов, всего 838;
  format/analyze чисто; e2e не запускался.
- **WILL ROT 18.3:** секция блокировки отдельная по L5 (дублирует валюты из
  состава; возможное слияние в строки состава — полировка 18.x).

### 18.4 Заблокированные активы: блок на главном экране — [x] (2026-11-23)

- **Приоритет/зависимости:** P1; после 18.3 (и 18.1 — мультивалютный итог инвестиций).
- **Суть:** на дашборде — общая сумма заблокированных активов по всем инвестициям
  в базовой валюте + процент от общей стоимости инвестиций, с тултипом-пояснением.
  Если заблокированных нет — блок не показывается.
- **Решения:**
  - **B1.** Источник данных — `assetRepository.watchAll(includeArchived: true)`
    (уже подписан в `DashboardViewModel`, строки 143–157): берутся только
    неархивные инвестиции с непустым `lockedBalances`.
  - **B2.** `lockedTotal` = сумма всех отметок, конвертированная в базовую валюту
    через `NetWorthCalculator.calculate` (каждая отметка — `NetWorthAssetValue(
    kind: AssetKind.investment, value: Money, currency)`); курсы —
    `rateRepository.find(code, today)` с кэшем `_rateCache`. Знаменатель процента —
    `netWorth.byAssetKind[AssetKind.investment]` (уже вычисляется).
    `lockedShare` = Rational(lockedTotal.minorUnits) / Rational(investmentTotal.minorUnits)
    → Decimal scale 4, clamp 0..1; при investmentTotal <= 0 → null.
  - **B3.** Новые сигналы VM: `hasLockedAssets: Signal<bool>`,
    `lockedTotal: Signal<Money?>`, `lockedShare: Signal<Decimal?>`,
    `lockedError: Signal<DomainErrorCode?>`. Пересчёт — везде, где вызывается
    `_reloadNetWorth` (стримы активов/курсов, смена базовой валюты,
    `exchangeRateRevision`). При `rateUnavailable`: `hasLockedAssets = true`,
    `lockedTotal = null`, `lockedError = rateUnavailable` → карточка показывает
    «Курс недоступен» (как net worth-карточка).
  - **B4.** UI: новый виджет `DashboardLockedAssets` — `AppSummaryCard(
    title: l10n.dashboardLockedTitle, value: итог или «Курс недоступен»,
    subtitle: «{X,X}% от инвестиций» (одна десятичная, запятая; при share null —
    subtitle отсутствует), trailing: AppTooltip(message: пояснение, child:
    AppIcon(Icons.info_outline, semanticLabel: l10n.dashboardLockedInfoLabel)),
    onTap: context.push(AppRoutes.assets))`. Размещается в `AppAdaptiveGrid`
    сразу после секции обзора (net worth), только при `vm.hasLockedAssets.value`.
  - **B5.** Текст тултипа (l10n `dashboardLockedTooltip`): «Часть стоимости
    инвестиций, недоступная по внешним причинам. Сумма всех заблокированных
    активов по инвестиционным счетам в базовой валюте; процент — от общей
    стоимости инвестиций.»
- **Files:**
  - Create: `lib/core/features/dashboard/ui/dashboard_locked_assets.dart`;
    тесты в `test/core/features/dashboard/ui/dashboard_screen_test.dart` (modify).
  - Modify: `lib/core/features/dashboard/ui/dashboard_view_model.dart`
    (сигналы B3 + метод `_reloadLocked()`; вызовы рядом с `_reloadNetWorth`,
    строки 127–172, 232–254), `lib/core/features/dashboard/ui/
    dashboard_screen.dart` (`_body`: вставка блока после net worth-секции,
    строки 111–123), `lib/l10n/app_ru.arb` + generated:
    `dashboardLockedTitle` = «Заблокированные активы»;
    `dashboardLockedShare` = «{percent}% от инвестиций» (placeholder String);
    `dashboardLockedTooltip` = текст B5;
    `dashboardLockedInfoLabel` = «О заблокированных активах».
  - Test: `test/core/features/dashboard/ui/dashboard_screen_test.dart` — фейк
    `_Assets` отдаёт снапшоты с `lockedBalances`; кейсы: без отметок блок скрыт;
    с отметками — сумма и процент; тултип с текстом B5; ошибка курса — «Курс
    недоступен», блок виден; пересчёт после изменения курса/базовой валюты;
    320dp/1.3/dark без overflow.
- **Consumes:** `AssetSnapshot.lockedBalances` (18.3), `NetWorthSummary.byAssetKind`
  (18.1 корректно считает мультивалютные инвестиции), `NetWorthCalculator`,
  `AppSummaryCard` (trailing/tone), `AppTooltip` (`lib/uikit/app_tooltip.dart`),
  `AppIcon`, `MoneyFormatter`.
- **Produces:** информационный блок заблокированных активов на дашборде.
- **TDD:**
  1. VM: две инвестиции с отметками 99 USD (курс 90) и 5 EUR (курс 100), базовая
     RUB → `lockedTotal` = 9 410,00 ₽; `hasLockedAssets` true; нет отметок → false,
     `lockedTotal` null.
  2. VM: `lockedShare` = lockedTotal / byAssetKind[investment] (пример CALC-043:
     инвестиция 100 000 RUB + 120 USD по 92 = 111 040 ₽, заблокировано 99 USD по
     92 = 9 108 ₽ → доля ≈ 0,0820); архивная инвестиция с отметками не учитывается.
  3. VM: нехватка курса → `lockedError = rateUnavailable`, `lockedTotal` null,
     `hasLockedAssets` true; после появления курса — пересчёт.
  4. Widget: блок скрыт без отметок; с отметками — title, сумма, «8,2% от
     инвестиций», info-иконка с тултипом B5; тап ведёт на экран активов.
- **Рабочий план:**
  1. Failing VM-тесты 1–3 → `_reloadLocked` + сигналы + подключение к существующим
     триггерам пересчёта.
  2. Failing widget-тест 4 → `DashboardLockedAssets` + вставка в `_body`.
  3. l10n + gen; прогон; docs; гейты.
- **Docs:** `DESIGN.md` §6 Dashboard (+блок), `docs/architecture/
  navigation_and_screens.md` §5 (матрица дашборда), `docs/architecture/
  calculations.md` — CALC-047 (пример B/тест 2).
- **DoD:** общий DoD; task-reviewer + design-reviewer; android-tester коротким
  прогоном; статус `[x]` до PR; e2e — спросить.
- **Предлагаемый commit:** `task/18.4: заблокированные активы — блок на главном`.
- **Итог:** `DashboardLockedAssets` на Главной сразу после net worth: сумма
  отметок неархивных инвестиций в базовой валюте через `NetWorthCalculator`
  (курсы `rateRepository.find` + `_rateCache`), доля от инвестиций (Rational →
  Decimal scale 4, clamp 0..1), «Курс недоступен» при нехватке курса, тултип;
  сигналы `hasLockedAssets`/`lockedTotal`/`lockedShare`/`lockedError`,
  пересчёт на стримах активов/курсов/базовой валюты. Дополнительно закрыт
  остаточный риск 18.3: валюта отметки учитывается в `countReferences` (защита
  от сырой FK-ошибки при удалении/отключении валюты). По ревью: справочник
  валют обновляется подпиской `watchAll` (кастомные валюты), блок оформлен
  `AppSection`, info — кнопка с диалогом, `lockedError` различает
  pending/rate/storage, переход `go`; вес суммы — `titleLarge`.
  12 новых тестов, всего 850; format/analyze/dart analyze/test зелёные;
  release APK и e2e не запускались.
- **WILL ROT 18.4:** округление доли (<0,1%/100,0%), сброс старой суммы при
  смене базовой валюты до пересчёта, фильтр «инвестиции» при переходе в активы,
  дублирование секции/карточки — полировка 18.x.
- **Отклонение:** CALC-043 из плана занят этапом 15 (как 041/042), поэтому кейс
  зафиксирован как **CALC-047** в `calculations.md`; coverage-тест обновлён
  (46 → 47).

### 18.5 Аналитика: «Детализация за месяц» отдельной страницей — [ ]

- **Приоритет/зависимости:** P2; независима от 18.1–18.4; 18.6 после неё.
- **Суть:** список значений по периодам (сейчас внутри `CashflowChartSection`,
  заголовок «Значения по периодам») переносится на отдельную страницу
  «Детализация за месяц»; на экране аналитики остаётся ссылка. Пустые периоды
  (доход = 0 и расход = 0) не показываются. Если за выбранный месяц вообще нет
  операций — «Нет операций за месяц».
- **Решения:**
  - **A1.** Новый роут `/more/analytics/details` (name `cashflow-details`),
    query-параметры: `period` (allowlist `month|3m|6m|year|all`, default `month`),
    `kind` (`income|expense`), `categoryId` (int). VM создаётся inline в builder
    роутера (образец `comparison`, `lib/app/router.dart:468–479`).
  - **A2.** Новые файлы: `cashflow_details_view_model.dart` (зависимости:
    `AnalyticsQueries`, `SettingsRepository`, `CurrencyRepository`,
    `ExchangeRateRepository`, `LocalDate Function() now`; сигналы: `state`,
    `period`, `cashflowKind`, `categoryId`, `points` (уже отфильтрованные),
    `summary`, `baseCurrency`, `currencies`, `missingRate`; логика — образец
    `AnalyticsViewModel._reload`: `analyticsRange` + `CashflowFilter` →
    `queries.cashflowSeries` + `queries.cashflow`; фильтрация пустых бакетов:
    оставить точки, у которых `!(income.isZero && expense.isZero)`; сортировка
    по `periodStart` по убыванию; `submitManualRate` — как в `AnalyticsViewModel`),
    `cashflow_details_screen.dart` (AppScaffold title «Детализация за месяц»;
    чипы периода `AppFilterBar`+`AppFilterChip` по `AnalyticsPeriod.values` →
    `vm.selectPeriod`; список; empty state; ошибка курса — `AppErrorState` +
    `showManualRateDialog`, образец `analytics_screen.dart:267–299`),
    `cashflow_period_list.dart` (общий виджет списка периодов: строка = дата +
    «Доход: …» + «Расход: …» + «Итого: …», текущая вёрстка
    `cashflow_chart_section.dart:151–176`; принимает точки и `formatMoney`).
  - **A3.** Из `CashflowChartSection` удаляются: список периодов (строки 141–188),
    `_expanded`/`_collapsedCount`, кнопки «Показать все периоды»/«Свернуть».
    Секция оставляет summary + график + легенду. Поведение «вся серия нулевая →
    AppEmptyState» не меняется. Список дат net worth («Значения по датам»,
    `net_worth_chart_section.dart`) НЕ трогать.
  - **A4.** На экране аналитики после cashflow-секции — `AppListTile(
    title: l10n.analyticsDetailsTitle, trailing: AppIcon(Icons.chevron_right,
    semanticLabel: null), onTap: push cashflowDetailsPath с текущими
    vm.period/vm.cashflowKind/vm.categoryId)`. Показывается при
    `vm.baseCurrency.value != null` (как секция категорий), независимо от
    наличия точек.
  - **A5.** Empty state страницы: отфильтрованный список пуст → при
    `period == month` — `AppEmptyState(title: «Нет операций за месяц», message:
    «Добавьте операцию или измените период.»)`; иначе — существующие
    `analyticsCashflowEmptyTitle/Message`. Фильтры kind/category наследуются
    через query и на странице не редактируются (меняются на экране аналитики).
  - **A6.** `CashflowAnalytics.series` не менять: нулевые бакеты нужны графику;
    фильтрация — только в VM страницы детализации.
- **Files:**
  - Create: `lib/core/features/analytics/ui/cashflow_details_screen.dart`,
    `lib/core/features/analytics/ui/cashflow_details_view_model.dart`,
    `lib/core/features/analytics/ui/cashflow_period_list.dart`;
    `test/core/features/analytics/ui/cashflow_details_screen_test.dart`,
    `test/core/features/analytics/ui/cashflow_details_view_model_test.dart`.
  - Modify: `lib/app/routes.dart` (+`cashflowDetails = '/more/analytics/details'`,
    +хелпер `cashflowDetailsPath({String period = 'month', String? kind,
    int? categoryId})` — образец `categoriesPath`; строки period — те же токены
    `month|3m|6m|year|all`, что парсит роутер; вызывающий мапит enum в строку,
    routes.dart от фич не зависит), `lib/app/router.dart`
    (+GoRoute внутри ветки `/more` рядом с analytics; парсинг query — образец
    `_analyticsPeriod` и `parseAllowlisted`), `lib/core/features/analytics/ui/
    cashflow_chart_section.dart` (A3), `lib/core/features/analytics/ui/
    analytics_screen.dart` (A4), `lib/l10n/app_ru.arb` + generated:
    +`analyticsDetailsTitle` = «Детализация за месяц»;
    +`analyticsCashflowEmptyMonthTitle` = «Нет операций за месяц»;
    +`analyticsCashflowEmptyMonthMessage` = «Добавьте операцию или измените период.»;
    −`analyticsPeriodsTitle`, −`analyticsShowAllPeriods`, −`analyticsCollapsePeriods`
    (больше не используются; проверить grep перед удалением).
  - Test (modify): `test/core/features/analytics/ui/cashflow_chart_section_test.dart`
    (убрать кейсы списка/сворачивания; оставить summary/график/пустую серию),
    `test/core/features/analytics/ui/analytics_screen_test.dart` (ссылка видна,
    push с текущими фильтрами), `test/app/` навигационные тесты роутера (если
    есть паттерн проверки query — добавить разбор нового роута).
- **Consumes:** `AnalyticsQueries.cashflowSeries/cashflow`, `analyticsRange`,
  `CashflowFilter`, `CashflowPeriodPoint`, `AppFilterBar`/`AppFilterChip`,
  `AppEmptyState`, `AppListTile`, `AppErrorState`, `showManualRateDialog`,
  `MoneyFormatter`, `DateFormatter`.
- **Produces:** страница «Детализация за месяц» без пустых периодов; ссылка на
  неё на экране аналитики; cashflow-секция аналитики компактнее.
- **TDD:**
  1. VM: серия с нулевыми месяцами → `points` содержит только ненулевые,
     newest-first; kind/category из query попадают в `CashflowFilter`.
  2. VM: период month, все бакеты нулевые → `points` пуст; экран показывает
     «Нет операций за месяц»; период year, все нулевые → «Нет операций за период».
  3. VM: смена периода чипами перезагружает серию; ошибка курса → `missingRate`,
     `submitManualRate` перезагружает.
  4. Widget: ссылка на экране аналитики пушит роут с query текущих фильтров;
     страница рендерит строки дата/доход/расход/итого; пустых строк нет.
  5. `CashflowChartSection` больше не содержит список периодов и кнопки
     «Показать все периоды»; график и summary не регрессируют.
- **Рабочий план:**
  1. Failing VM-тесты 1–3 → VM страницы (копировать паттерны `AnalyticsViewModel`,
     не наследоваться от него).
  2. Роут + routes-хелпер + парсинг query.
  3. Failing widget-тесты 4–5 → `CashflowPeriodList`, экран страницы, удаление
     списка из `CashflowChartSection`, ссылка в `analytics_screen`.
  4. l10n (+новые, −устаревшие) + gen; прогон; docs; гейты.
- **Docs:** `docs/architecture/navigation_and_screens.md` §2 (карта routes),
  §3 (query parameters), §5 (матрица экранов: новая страница).
- **DoD:** общий DoD; task-reviewer + design-reviewer; android-tester коротким
  прогоном; статус `[x]` до PR; e2e — спросить.
- **Предлагаемый commit:** `task/18.5: детализация за месяц — отдельная страница`.

### 18.6 Аналитика: табы «Расходы»/«Доходы» в итогах по категориям — [ ]

- **Приоритет/зависимости:** P2; после 18.5 (общий файл `analytics_screen.dart`).
- **Суть:** в секции «Итоги по категориям» доходы и расходы не смешиваются:
  переключатель (табы) «Расходы» | «Доходы».
- **Решения:**
  - **C1.** `CategoryTotalsSection` становится `StatefulWidget` с локальным
    `_kind: CashflowKind` (default `expense`). Переключатель —
    `AppSegmentedControl<CashflowKind>` (single-select; сегменты: «Расходы» =
    `l10n.analyticsCashflowExpense`, «Доходы» = `l10n.analyticsCashflowIncome`;
    порядок — расходы первые). Образец использования —
    `asset_comparison_screen.dart:114–128`.
  - **C2.** Новый параметр `cashflowKind: CashflowKind?` (из
    `vm.cashflowKind.value`): если задан — таб принудительно следует за фильтром
    (в `didUpdateWidget` и при первом build); пользователь может переключать таб
    только когда фильтр «Все операции». При активном фильтре kind список и так
    сужен — таб показывает этот kind.
  - **C3.** Список фильтруется по `categories[total.categoryId]?.kind == _kind`;
    сортировка по убыванию суммы сохраняется. Доли (`shareOf`) уже считаются
    раздельно по kind (`AnalyticsViewModel.categoryShare`) — не менять.
  - **C4.** Пустой таб → `AppText(l10n.analyticsCategoriesEmptyExpense/Income)`
    вместо списка (секция с заголовком и табами остаётся). Если `totals` пуст
    целиком — секция по-прежнему `SizedBox.shrink()`.
  - **C5.** Из подзаголовка строки убрать суффикс «· Доходы/Расходы»
    (`_shareText`, строки 41–48) — kind теперь задаётся табом; процент и бейдж
    архива оставить. Тон суммы (`AppMoneyTone.income/expense`) сохраняется.
- **Files:**
  - Modify: `lib/core/features/analytics/ui/category_totals_section.dart`
    (C1–C5), `lib/core/features/analytics/ui/analytics_screen.dart` (передача
    `cashflowKind: vm.cashflowKind.value`, строки 154–162),
    `lib/l10n/app_ru.arb` + generated:
    +`analyticsCategoriesEmptyExpense` = «Нет расходов за период»;
    +`analyticsCategoriesEmptyIncome` = «Нет доходов за период».
  - Test (create): `test/core/features/analytics/ui/category_totals_section_test.dart`
    (переключение табов фильтрует список; дефолт — расходы; preselect из
    `cashflowKind`; пустой таб — текст; доли знаменатель по kind; архивный бейдж).
  - Test (modify): `test/core/features/analytics/ui/analytics_screen_test.dart`
    (тест «cashflow-секция, категории и фильтр по типу», строка ~320: ожидания
    под табы; при фильтре «Доходы» таб следует за фильтром).
- **Consumes:** `AppSegmentedControl`/`AppSegment`, `CategoryTotal`,
  `CashflowCategory.kind`, `AppMoneyText`/`AppMoneyTone`, `AppChip`.
- **Produces:** итоги по категориям разделены на расходы и доходы.
- **TDD:**
  1. Смешанные totals (2 расхода + 1 доход) → дефолтный таб «Расходы» показывает
     только расходы; переключение на «Доходы» — только доход.
  2. `cashflowKind = income` → таб «Доходы» выбран; смена фильтра на expense →
     таб следует; при «Все операции» таб переключается пользователем.
  3. Пустой таб → текст «Нет расходов за период»/«Нет доходов за период»;
     пустые totals → секция скрыта.
  4. Доли: расходы 25 000 и 75 000 → 25%/75% (CALC-035 не регрессирует);
     суффикс «· Расходы» в строке отсутствует.
- **Рабочий план:**
  1. Failing тесты новой секции → реализация C1–C5.
  2. Передача `cashflowKind` с экрана; правка существующего screen-теста.
  3. l10n + gen; прогон; docs (при необходимости §5 матрицы); гейты.
- **DoD:** общий DoD; task-reviewer + design-reviewer; android-tester коротким
  прогоном; статус `[x]` до PR; e2e — спросить.
- **Предлагаемый commit:** `task/18.6: итоги по категориям — табы расходы/доходы`.

### 18.7 Цветовая окраска сумм операций по типам — [ ]

- **Приоритет/зависимости:** P2; независима (можно параллелить с 18.5/18.6,
  файлы не пересекаются).
- **Суть:** суммы разных типов операций сливаются. Причина найдена: в
  `AppOperationListTile` тон суммы перебивается явным `style.color`
  (`lib/uikit/app_operation_list_tile.dart:140–146`, `primaryText` = `onSurface`),
  поэтому во всех журналах сумма монохромная, цвет есть только у иконки. Плюс
  карточки деталей операций не передают тон.
- **Решения:**
  - **K1.** `AppOperationListTile`: для неудалённых операций убрать явный
    `color: primaryText` из style суммы (тон `AppMoneyTone` применяется через
    `resolveMoneyToneColor`); для deleted сохранить приглушение (явный цвет —
    намеренный приоритет, документирован в `AppMoneyText`). Иконка уже
    окрашивается тоном — не менять. Знаки «+»/«−» экраны уже добавляют — не менять.
  - **K2.** `transaction_details_screen.dart:116–123`: `AppSummaryCard` получает
    `tone` по виду операции: deposit → income, withdrawal → expense,
    transferOut/transferIn → transfer (маппинг как `_tone` в
    `dashboard_recent_operations.dart:82–87`).
  - **K3.** `cashflow_details_screen.dart:117–124`: `AppSummaryCard` получает
    `tone: income ? AppMoneyTone.income : AppMoneyTone.expense` (флаг `income`
    уже вычислен, строка 112).
  - **K4.** `dashboard_recent_operations.dart`: добавить знак к сумме
    («+» deposit/transferIn, «−» withdrawal/transferOut) — образец
    `transactions_screen.dart:313`; тон уже применяется.
  - **K5.** Не трогать: балансы/карточки активов (это не операции), аудит
    (deleted-приглушение by design), метрики итогов (тон уже есть), токены
    `AppSemanticColors` (income → primary, expense → tertiary, НЕ error —
    контракт DESIGN.md §2 не менять).
- **Files:**
  - Modify: `lib/uikit/app_operation_list_tile.dart` (K1),
    `lib/core/features/transactions/ui/transaction_details_screen.dart` (K2),
    `lib/core/features/cashflow/ui/cashflow_details_screen.dart` (K3),
    `lib/core/features/dashboard/ui/dashboard_recent_operations.dart` (K4).
  - Test (modify): `test/uikit/finance_test.dart` (сумма `AppOperationListTile`
    окрашена тоном: income/expense/transfer дают разные цвета; deleted —
    приглушение), `test/core/features/dashboard/ui/dashboard_screen_test.dart`
    (знаки +/− в последних операциях), тесты деталей операций/денежного потока
    (`test/core/features/transactions/ui/`, `test/core/features/cashflow/ui/` —
    тон карточки), `test/uikit/accessibility_test.dart` (контраст тонов не
    регрессирует, если там есть проверки).
  - Docs: `lib/uikit/design/finance.md` — зафиксировать, что сумма операции
    окрашивается тоном (explicit color только для deleted/archived приглушения).
- **Consumes:** `AppMoneyTone`, `resolveMoneyToneColor`, `AppMoneyText`,
  `AppSummaryCard.tone`.
- **Produces:** суммы доходов/расходов/переводов визуально различимы во всех
  журналах и деталях операций.
- **TDD:**
  1. `AppOperationListTile` с tone income/expense/transfer → цвет текста суммы
     равен `resolveMoneyToneColor(context, tone)` (три разных цвета); deleted →
     приглушённый цвет, не тон.
  2. Детали операции deposit → карточка с tone income; withdrawal → expense;
     transfer → transfer.
  3. Детали денежного потока: доход → income, расход → expense.
  4. Последние операции дашборда: deposit «+…», withdrawal «−…».
- **Рабочий план:**
  1. Failing тесты 1–4.
  2. K1–K4 (минимальные правки, без рефакторинга виджетов).
  3. Прогон всех тестов (цветовые ожидания в существующих тестах могли
     фиксировать монохром — обновлять только там, где контракт изменился
     осознанно); docs; гейты.
- **DoD:** общий DoD; task-reviewer + design-reviewer (обязательно: цвет/контраст);
  android-tester коротким прогоном; статус `[x]` до PR; e2e — спросить.
- **Предлагаемый commit:** `task/18.7: цветовая окраска сумм операций`.

### 18.8 Релиз v0.9.0 — [ ]

- **Приоритет/зависимости:** P1; после merge 18.1–18.7. Исполнитель —
  `release-manager` (`.agents/agents/release-manager.md`) с отклонением от
  штатного patch-bump: версия задана владельцем — **0.9.0** (D5).
- **Чек-лист:**
  1. Все задачи 18.1–18.7 закрыты (`[x]` + дата), PR смержены в main, CI зелёный;
     `task-reviewer`/`design-reviewer` пройдены по каждой задаче.
  2. **Спросить владельца:** запускать ли полный QA-прогон `android-tester`
     (~час; обязательно спросить, отказ не блокирует; решение зафиксировать).
     **Спросить про e2e** (`flutter test integration_test -d linux`).
  3. `plan-review` по задачам этапа 18; блокирующие замечания — стоп.
  4. Локально: `dart format --output=none --set-exit-if-changed lib test tool
     integration_test`; `flutter analyze --fatal-infos`; `dart analyze lib
     --fatal-infos`; `flutter test`; `flutter build apk --release`.
  5. В `main`: `pubspec.yaml` → `version: 0.9.0+4`; отдельный коммит
     `release: поднять версию до v0.9.0`; запушить до тега.
  6. Аннотированный тег `v0.9.0` на bump-коммите; проверка
     `git show v0.9.0:pubspec.yaml | grep 'version:'` → `0.9.0+4`;
     `git log -1 --format=%s v0.9.0` → `release: поднять версию до v0.9.0`;
     пуш тега → `.github/workflows/release.yml`.
  7. Проверить `gh release list` / `gh run list`: workflow прошёл, APK опубликован.
  8. Сжатие `PLAN.md`: завершённые этапы 16–18 → `PLAN_ARCHIVE.md` (дословно,
     индекс и нумерация сохраняются); коммит `chore: сжатие PLAN.md — архив этапов NN`.
- **DoD:** релиз опубликован, версия в APK 0.9.0 (versionCode 4), PLAN сжат,
  отчёт release-manager владельцу.
- **Предлагаемый commit:** `release: поднять версию до v0.9.0`.

## Этап 19 — Главная: отступы, подушка безопасности, просроченные счета, разбивка капитала

Источник: `TASKS.md` (2026-11-23, 4 задачи владельца). Этап 18 (мультивалютные
инвестиции, заблокированные активы, аналитика) запланирован отдельно и не
меняется. 18.4 и 19.x оба трогают `dashboard_screen.dart`/`dashboard_view_model.dart`:
при синхронизации объединять блоки, чужие контракты не переписывать.

### 19.1 Отступ контента Главной как на Операциях — [x] (2026-11-23)

- **Симптом:** на Главной заголовки секций и карточки стоят с отступом 32dp
  (16dp `AppAdaptiveGrid` + 16dp `AppSection`), на Операциях — 16dp.
- **Решение:** `AppSection`/`AppSectionHeader` получают `padded` (default true);
  дашборд передаёт `padded: false` своим секциям, включая
  `DashboardCashflow`/`DashboardGoals`/`DashboardRecentOperations` (новый
  параметр). Внешний отступ остаётся один — `AppAdaptiveGrid.screenPadding`
  (16 compact / 24 expanded, как в дизайн-системе); на телефоне 16dp совпадает
  с Операциями.
- **Files:** `lib/uikit/app_section.dart`; `lib/core/features/dashboard/ui/
  dashboard_screen.dart`, `dashboard_cashflow.dart`, `dashboard_goals.dart`,
  `dashboard_recent_operations.dart`; `test/core/features/dashboard/ui/
  dashboard_screen_test.dart`; при необходимости `lib/uikit/design/containers.md`.
- **TDD:** на 427dp левый край карточки/заголовка = 16dp (было 32); на 640dp —
  24dp; существующие layout/a11y-тесты без регрессий; 320dp/1.3 без overflow.
- **DoD:** format/analyze/test; design-reviewer; `git diff --check`; статус
  `[x]` до PR; e2e спросить.
- **Итог:** `AppSection`/`AppSectionHeader` получили `padded` (default true);
  секции Главной (`Обзор`, быстрые действия, cashflow, цели, операции) идут
  с `padded: false`, внешний отступ даёт `AppAdaptiveGrid` (16 compact / 24
  expanded). На 427dp левый край карточки и заголовка — 16dp (было 32), как на
  Операциях. Новые layout-тесты: все секции на 427dp, 640dp (24) и 2 колонки
  на 1000dp; всего 734 теста, format/analyze чисто.

### 19.2 Карточка «Подушка безопасности» — [x] (2026-11-23)

- **Решения владельца (2026-11-23, не менять молча):**
  - **D19.1.** Формула **C**: runway = деньги / средние расходы; цель =
    6 × средние расходы; при прибыли — срок достижения цели.
  - **D19.2.** Период — **среднее за 3 полных месяца** (не текущий неполный).
  - **D19.3.** «Деньги на счетах» — **все неархивные счета**, включая вклады,
    в базовой валюте.
- **Данные:** `netWorth.byAssetKind[account]` (сумма счетов в базовой валюте);
  доходы/расходы — `queries.cashflow` за диапазон трёх полных месяцев до
  текущего, делённые на 3. Новых таблиц/схемы не требуется.
- **Расчёт:**
  - `cash = max(0, byAssetKind[account])`;
  - `avgExpenses`, `avgIncome` — средние за 3 полных месяца;
  - `months = avgExpenses > 0 ? floor(cash / avgExpenses) : null`;
  - `target = 6 * avgExpenses`, `monthsToTarget` = `max(0, ceil((target - cash) /
    avgProfit))` при `avgProfit > 0`; если цель достигнута — 0; при прибыли ≤ 0 —
    срок не показывается.
- **Текст:** «При текущих тратах хватит на {X} мес» (+ «≈ {Y} г. {Z} мес»),
  «Цель — 6 месяцев расходов», «До цели — {M} мес при прибыли {P}/мес»,
  «Цель достигнута». Если расходов нет или счетов нет — блок скрыт.
- **UI:** `AppSection`/`AppCard` на Главной после быстрых действий и
  просроченных счетов (DESIGN.md §6); без графиков;
  tap не обязателен (можно вести в аналитику расходов).
- **Files:** `dashboard_view_model.dart` (запрос 3 месяцев + сигнал),
  новый `lib/core/features/dashboard/logic/safety_cushion.dart` (чистый расчёт),
  `dashboard_screen.dart`, новый `dashboard_safety_cushion.dart`, `app_ru.arb`,
  тесты VM/логики/экрана.
- **TDD:** нулевые/отрицательные остатки; расходы 0; прибыль ≥ 0/отрицательная;
  цель достигнута; округление месяцев; текст лет/месяцев; скрытие блока;
  диапазон ровно 3 полных месяца.
- **DoD:** format/analyze/test; task-reviewer + design-reviewer; статус `[x]`
  до PR; e2e спросить.
- **Итог:** `SafetyCushion.calculate` (целочисленно в minor units): runway =
  деньги × 3 / расходы за 3 полных месяца (floor), цель = 6 × средние расходы,
  ETA = ceil((цель − деньги) × 3 / профицит) при профиците > 0; при достигнутой
  цели — 0, при профиците ≤ 0 — срока нет, при расходах 0/разных валютах —
  null. VM запрашивает `queries.cashflow` за 3 полных месяца (для 23.11 —
  август–октябрь) отдельной подпиской, деньги — `byAssetKind[account]`;
  карточка после быстрых действий и просроченных счетов (DESIGN.md §6), скрыта
  без расходов/счетов/курса. Текст: «При текущих тратах хватит на N мес»
  (+ годы/месяцы), для нуля — «Запаса нет»/«Меньше чем на месяц», для >100 лет
  — «100+ лет»; цель и ETA (>10 лет — сокращённо), «если откладывать» вместо
  «прибыли». Значение срока в `FittedBox`, семантика — одной строкой. После
  ревью: clamp отрицательного cash во всех формулах, перезагрузка при смене
  базовой валюты/курса, скрытие на error-путях net worth, `_safetyReady` в
  гейте эмиссии, скрытие без счетов, пороги `>1200`/`>120`. Новые тесты:
  логика (floor/ceil, отрицательный cash), карточка (13/24/0/1500 мес,
  «меньше месяца», success, семантика 13/0/100+, 256dp/2.0), дашборд (валюта,
  ошибка net worth/safety, без счетов, 320/1.3/dark); всего 770;
  format/analyze чисто.

### 19.3 Предупреждение о просроченных счетах — [x] (2026-11-23)

- **Логика:** среди неархивных `AccountAsset` с `endDate != null` и
  `today > endDate`; если список пуст — блок не показывается.
- **UI:** предупреждающий `AppSection`/`AppCard` на Главной (например, после
  быстрых действий): заголовок «Просроченные счета», строки «Имя — срок истёк
  {дата}», tap → детали счёта; несколько счетов — список, не больше 3 + «Ещё».
- **Files:** `dashboard_view_model.dart` (сигнал `overdueAccounts`),
  `dashboard_screen.dart`, новый `dashboard_overdue_accounts.dart`,
  `app_ru.arb`, тесты VM/экрана.
- **TDD:** пусто → блока нет; один/несколько; архивный исключён; `today ==
  endDate` не просрочен; обновление при изменении активов; tap ведёт в детали.
- **DoD:** format/analyze/test; task-reviewer + design-reviewer; статус `[x]`
  до PR; e2e спросить.
- **Итог:** `DashboardViewModel.overdueAccounts` — неархивные `AccountAsset`
  с `today > endDate`, сортировка по дате; блок `DashboardOverdueAccounts`
  после быстрых действий: 3 строки, «Ещё N» разворачивает остальные на месте,
  tap строки → детали счёта, иконка в тоне warning (не error).
  `today == endDate` не просрочен, архивные исключены. Новые тесты: фильтр,
  пусто, реактивное обновление по стриму, разворачивание/переход,
  320dp/1.3/dark с длинными именами; всего 739; format/analyze чисто.

### 19.4 Разбивка чистого капитала по категориям — [x] (2026-11-23)

- **Данные:** `NetWorthSummary.byAssetKind` уже содержит суммы в базовой
  валюте; показывать только ненулевые категории (`account`, `investment`,
  `property`), порядок — счета → инвестиции → недвижимость.
- **UI:** в карточке чистого капитала под итогом — компактные строки/чипы
  «Счета 1 500 000 ₽ · Инвестиции 500 000 ₽ · Недвижимость 8 000 000 ₽»;
  при ошибке курса разбивка не показывается (как и итог).
- **Files:** `dashboard_net_worth.dart`, `dashboard_screen.dart`, `app_ru.arb`,
  `test/core/features/dashboard/ui/dashboard_screen_test.dart`.
- **TDD:** только имеющиеся категории; нулевые скрыты; отрицательный счёт
  показывается; порядок; форматирование валюты; rate error → нет разбивки.
- **DoD:** format/analyze/test; design-reviewer; статус `[x]` до PR; e2e спросить.
- **Итог:** `AppSummaryCard` получил опциональный `footer` (обновлён
  `finance.md`); `DashboardNetWorth` показывает строки «Счета / Инвестиции /
  Недвижимость — сумма» из `byAssetKind`, только ненулевые, включая
  отрицательные счета; при ошибке курса разбивки нет. Footer читается одной
  семантической строкой; сумма в `FittedBox` и не теряет цифры при 200%.
  Тесты: нули/отрицательные/ошибка/порядок, 320dp/1.3/dark, 320dp/2.0,
  uikit footer — 6 новых, всего 745; design-reviewer — APPROVE WITH FIXES
  (3 Medium закрыты); e2e не запускался по решению владельца.

## Текущий этап

Этап 18 «Мультивалютные инвестиции, заблокированные активы, аналитика (v0.9.0)» —
18.1–18.4 закрыты 2026-11-23 (PR #76–#79); 18.5 (детализация за месяц) в работе.
Порядок: 18.1 → 18.2 → 18.3 → 18.4; 18.5 → 18.6; 18.7 независима; 18.8 после всех.
D2 и D6 подтверждены владельцем 2026-11-23; остальные допущения (D1, D3–D5)
действуют по умолчанию, при возражениях владельца — править план до кода.
Этап 19 «Главная: отступы, подушка, просроченные счета, разбивка капитала»
закрыт 2026-11-23 (PR #72–#75).
Этапы 16 (16.1) и 17 (17.1–17.2) закрыты 2026-11-22, ожидают сжатия после
релиза v0.9.0. Завершённые этапы 1–15 — `PLAN_ARCHIVE.md`.
