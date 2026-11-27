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
| 18 | Мультивалютные инвестиции, заблокированные активы, аналитика (v0.9.0) | 18.1–18.9 | ✅ | 2026-11-23 |
| 19 | Главная: отступы, подушка безопасности, просроченные счета, разбивка капитала | 19.1–19.4 | ✅ | 2026-11-23 |
| 20 | Исправления по полному QA release candidate v0.9.0 | 20.1–20.2 | ✅ | 2026-11-23 |
| 21 | Смешанные цели, переводы с инвестициями, курсы, приватность сумм, налог, биометрия | 21.1–21.8 | ⏳ | — |

## Текущий этап

**Этап 21** (2026-11-27): 8 задач владельца из `TASKS.md` — смешанные цели,
переводы счёт↔инвестиция, автоматическое получение курсов и резервный курс с
плашкой, скрытие сумм блюром, отображение подушки безопасности, предполагаемый
налог с процентов по вкладам, биометрия сразу при блокировке. Подробные планы —
ниже; решения `D21.*` требуют подтверждения владельцем до старта кода
(особенно смена `BR-G-1` и уточнение `BR-C-2`). Завершённые этапы 1–20 —
`PLAN_ARCHIVE.md`.

## Этап 21 — Смешанные цели, переводы с инвестициями, курсы, приватность сумм, налог, биометрия

**Источник:** `TASKS.md` 2026-11-27 (перенесено 2026-11-27). Восемь пожеланий
владельца: смешивать счета и инвестиции в одной цели; переводы счёт↔инвестиция;
проверить получение курсов; скрывать суммы блюром на Главной; починить подушку
безопасности; блок предполагаемого налога с процентов по вкладам; биометрия сразу
при блокировке; всегда показывать суммы при недоступном курсе с плашкой.

**Граф зависимостей:** `21.1`, `21.2`, `21.4`, `21.6`, `21.7` независимы;
`21.3 → 21.8 → 21.5` (21.5 опирается на резервный курс 21.8; 21.6 рекомендуется
после 21.8, но не блокируется). Общие файлы: 21.3/21.8 (курсы и read-paths),
21.4/21.5/21.6/21.8 (`dashboard_view_model.dart`, `dashboard_screen.dart`).
Задачи с общими файлами выполнять последовательно: ветка `task/21.N-<slug>` из
`main` → PR → зелёный CI → squash merge.

**Решения и допущения этапа (не менять молча; подтвердить у владельца до кода):**
- **D21.1 (21.1).** Смешанная цель — новое значение `GoalCategory.mixed`;
  `category` становится **производным** от состава активов (только счета →
  `accounts`, только инвестиции → `investments`, оба вида → `mixed`); UI-селектор
  категории убирается, остаётся один список активов. Меняет `BR-G-1` и схему БД
  (v5). **Требует подтверждения владельцем.**
- **D21.2 (21.2).** Перевод разрешён между активами видов `account` и
  `investment` в любых сочетаниях; валюта ноги — основная валюта актива
  (`currency_code = NULL` → валюта актива); для мультивалютной инвестиции
  зачисление идёт в позицию основной валюты (отдельный селектор валюты перевода
  не вводится). Проверка отрицательного баланса остаётся **только для счетов**
  (инвестиции, как и при `withdrawal`, могут уходить в минус).
- **D21.3 (21.3).** Автообновление курсов на старте, при `resumed` и смене
  локальной даты + ручное обновление в справочнике валют. Строгая проверка даты
  ответа ЦБ не меняется (сохранение операций — по-прежнему точная дата,
  `BR-C-2`/`CALC-008`); отсутствие актуального курса закрывает резервный путь
  21.8, а не молчаливая подстановка при записи.
- **D21.4 (21.4).** Скрытие сумм — состояние **сессии** (не персистится), только
  Главная; блюр применяется к цифрам, подписи/названия не блюрятся; семантика
  сумм при скрытии тоже скрывается от скринридера.
- **D21.5 (21.5).** Подушка безопасности: «деньги» считаются из неархивных
  счетов напрямую (не через `netWorth.byAssetKind`), поэтому ошибка курса в
  инвестиционной части чистого капитала не скрывает блок. Скрытие сохраняется
  только при отсутствии счетов, отсутствии расходов за 3 полных месяца или
  аномалии валют; неустранимая ошибка курса показывается inline, а не исчезает.
- **D21.6 (21.6).** Предполагаемый налог = сумма **доходов категории «Проценты по
  вкладу»** за текущий календарный год (с 1 января) в базовой валюте × ставка;
  ставка по умолчанию **13 %**, редактируется в блоке, хранится в `app_settings`
  (ключ `taxRatePercent`); блок скрыт без неархивных счетов. Учитываются и
  авто-капитализация, и ручные записи этой категории.
- **D21.7 (21.7).** При включённой и доступной биометрии лок-скрин сам вызывает
  системный диалог; PIN скрыт до неудачи/отмены биометрии или ручного запроса
  «Ввести PIN». Состояние сбрасывается на каждом локе (VM — синглтон).
- **D21.8 (21.8).** Чтение всегда даёт сумму: точный курс на дату → актуальный
  (без плашки); иначе последний известный курс **не позже** даты → сумма + плашка
  «Курс от <дата>, актуальный получить не удалось». Запись операции/оценки не
  меняется. Уточняет `BR-C-2`/`BR-C-5`/`CALC-007`/`CALC-008` (различать запись и
  чтение) и добавляет `BR-C-9`.

---

### 21.1 Смешанная цель: счета и инвестиции вместе — [ ]

- **Приоритет/зависимости:** P1; независима. Меняет `BR-G-1` и `domain_model §7`.
- **Симптом:** форма цели (сегмент «Счета | Инвестиции») и DAO не позволяют
  выбрать в одну цель и счёт, и инвестицию.
- **Суть:** одна цель может включать активы обоих видов; ограничение по виду
  снимается, появляется производная категория `mixed`.
- **Контракты (D21.1, не менять молча):**
  - **G1.** `enum GoalCategory { accounts, investments, mixed }`; конвертер
    `GoalCategoryConverter` читает/пишет `mixed`; CHECK в `goals.category`
    ослаблен до `IN ('accounts', 'investments', 'mixed')`; `schemaVersion = 5`.
  - **G2.** `category` — производное значение: `static GoalCategory? forAssets(
    Iterable<AssetKind> kinds)` — пусто → `null`; только `account` → `accounts`;
    только `investment` → `investments`; есть оба → `mixed`. Вызывается в
    `GoalsViewModel.save`/`GoalsDao` (единственная точка истины — domain-функция).
  - **G3.** `GoalsDao._requireCompatibleAssets` больше не сравнивает вид с
    категорией, но по-прежнему требует непустой набор, существование активов и
    запрещает `property` (ошибка `validationGoalAssetKind`).
  - **G4.** UI: вместо `AppSegmentedControl` категории — один список активов
    (счета и инвестиции вместе) с подписью вида в строке; выбранные активы
    сохраняются при редактировании; `_setCategory`/интерсекция удаляются.
  - **G5.** Прогресс и `GoalCalculator` не меняются (расчёт kind-agnostic).
- **Files:**
  - Modify: `lib/core/features/goals/domain/financial_goal.dart` (+`mixed`,
    +`forAssets`), `lib/core/database/converters/enum_converters.dart`
    (`GoalCategoryConverter` +`mixed`), `lib/core/database/tables/goals.dart`
    (CHECK), `lib/core/database/app_database.dart` (`appDatabaseSchemaVersion = 5`;
    `onUpgrade` `if (from < 5)` — пересоздание `goals` с новым CHECK через
    `m.alterTable(TableMigration(goals))` либо ручной recreate + восстановление
    индексов `goals_status_deleted`/`goals_target_date`/`goals_currency`;
    проверить, что `goal_assets` FK не блокирует recreate),
    `lib/core/database/daos/goals_dao.dart` (`_requireCompatibleAssets`,
    вычисление `category`), `lib/core/features/goals/ui/goals_view_model.dart`
    (`eligibleAssets` → все `account`+`investment`; `save` выводит категорию),
    `lib/core/features/goals/ui/goal_form_screen.dart` (убрать сегмент, единый
    список), `lib/core/features/goals/ui/goal_details_screen.dart` (подпись
    `mixed`), `lib/l10n/app_ru.arb` (+`goalCategoryMixed`).
  - Create: `test/core/database/migration_v4_v5_test.dart`.
  - Generated: `dart run build_runner build --delete-conflicting-outputs`;
    `dart run drift_dev schema dump lib/core/database/app_database.dart
    drift_schemas/` (→ `drift_schema_v5.json`); `dart run drift_dev schema
    generate drift_schemas/ test/generated_migrations/` (→ `schema_v5.dart`);
    `app_localizations*.dart`.
- **TDD (failing → pass):**
  - domain: `GoalCategory.forAssets` — счета/инвестиции/оба/пусто.
  - DAO: цель со смешанными активами создаётся и читается как `mixed`; квартира
    отклоняется (`validationGoalAssetKind`); пустой набор отклоняется.
  - миграция v4→v5: `user_version = 5`, старые строки и их `category` целы,
    `sqlite_master` содержит CHECK с `mixed` и все три индекса `goals`,
    `PRAGMA foreign_key_check`/`integrity_check` чисты.
  - UI: форма показывает оба вида; сохранение смешанной цели кладёт `mixed`;
    редактирование восстанавливает выбор. Обновить guard
    `test/core/features/goals/data/goal_repository_test.dart` (строки 53–67).
- **DoD:** format; `flutter analyze --fatal-infos`; `dart analyze lib --fatal-infos`;
  `flutter test`; `flutter build apk --release`; миграционный тест + schema dump +
  `data_schema.md` §7/§11 обновлены; `task-reviewer` + `design-reviewer`; статус
  `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.1: смешанные цели счета и инвестиции`.

### 21.2 Переводы счёт ↔ инвестиция — [x] (2026-11-27)

- **Приоритет/зависимости:** P1; независима. Развивает `BR-T-8…10` (18.1 M6).
- **Симптом:** форма перевода берёт только `AccountAsset`; DAO запрещает
  не-счета (`validationTransferRequiresAccounts`).
- **Суть:** перевод между любыми активами видов `account`/`investment` в обе
  стороны; квартира по-прежнему запрещена.
- **Контракты (D21.2):**
  - **T1.** `TransactionsDao._validateTransfer`: разрешены `from.kind` и
    `to.kind` ∈ {`account`, `investment`}; иначе
    `validationTransferAssetKind` (новый ключ; `property`).
  - **T2.** `_assertHistoryBalance`/`_assertProjectedBalance` не меняются:
    отрицательный баланс проверяется только для счетов.
  - **T3.** Ноги пишутся с `currency_code = NULL` (валюта актива); для
    мультивалютной инвестиции зачисление идёт в позицию основной валюты. RUB-снимки
    ног считаются от валюты актива (существующий `_rubMinor`).
  - **T4.** `TransferFormViewModel.accounts: Signal<List<AccountAsset>>` →
    `Signal<List<Asset>>` (+`assetById`); форма показывает оба вида с подписью
    типа; empty-state «нужно ≥ 2 актива»; кнопка «Добавить счёт» сохраняется.
  - **T5.** Кросс-валютность (`destinationAmount`, `rateHint`) — без изменений.
- **Files:**
  - Add: `lib/core/features/transactions/domain/transfer_asset_kinds.dart`
    (единый набор видов для перевода, BR-T-10; используется DAO и VM).
  - Modify: `lib/core/features/transactions/ui/transfer_form_view_model.dart`
    (тип сигнала, `assetById`, сообщения), `lib/core/features/transactions/ui/
    transfer_form_screen.dart` (списки/подписи/empty-state), `lib/core/database/
    daos/transactions_dao.dart` (`_validateTransfer`),
    `lib/core/features/transactions/data/asset_transaction_repository_impl.dart`
    (проверить, что `transfer`/`reviseTransfer` не предполагают счёт),
    `lib/l10n/app_ru.arb` (подписи/ошибка `validationTransferAssetKind`).
  - Test: `test/core/features/transactions/ui/transfer_form_test.dart`,
    `test/core/features/transactions/data/transfer_repository_test.dart`,
    `test/core/database/revision_transaction_test.dart` (guard 417–430).
- **TDD:** account→investment и investment→account создают две ноги и попадают в
  баланс/журнал; investment→investment; property → ошибка; отрицательный баланс
  счёта по-прежнему ловится; отрицательный остаток инвестиции допускается;
  кросс-валютный перевод с `destinationAmount`; редактирование и soft delete обеих
  ног атомарны.
- **DoD:** format/analyze/test/build; `task-reviewer` + `design-reviewer`; статус
  `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.2: переводы счета и инвестиции`.

### 21.3 Автоматическое получение курсов валют — [ ]

- **Приоритет/зависимости:** P1; независима; база для 21.8.
- **Симптом:** курс из сети запрашивается только при сохранении формы
  (`ResolveExchangeRate`); при старте/смене дня кэша на новую дату нет, все
  read-paths возвращают `null` → «Курс недоступен».
- **Суть:** приложение само обновляет курс на «сегодня»; есть ручное обновление;
  работоспособность подтверждена тестами (клиент ЦБ доступен, 200 OK).
- **Контракты (D21.3):**
  - **R1.** Новый `RateRefreshService.refreshToday({bool force = false})`:
    берёт `CurrencyRepository.getEnabled()`, пропускает RUB, для каждой валюты
    вызывает `ExchangeRateRepository.fetchFromCbr(code, today)`; ошибки по
    валюте изолируются и агрегируются в отчёт; повторный вызов в тот же день без
    `force` — no-op (in-memory guard по дате).
  - **R2.** Вызовы: cold start (после первого кадра, не блокируя UI), `resumed`,
    смена локальной даты. При успехе `markExchangeRateChanged()` уже
    инкрементируется репозиторием → дашборд пересчитывается.
  - **R3.** Ручное обновление — действие в справочнике валют (иконка в app bar
    или кнопка) с индикатором и snackbar-результатом; сетевая ошибка не скрывает
    данные.
  - **R4.** Строгая проверка даты ответа ЦБ сохраняется; при неудаче актуального
    курса работает резервный путь 21.8.
- **Files:**
  - Create: `lib/core/features/currencies/logic/rate_refresh_service.dart`,
    `test/core/features/currencies/logic/rate_refresh_service_test.dart`.
  - Modify: `lib/core/di/register_core_services.dart` (регистрация),
    `lib/app/app.dart` (старт/`resumed`/смена даты),
    `lib/core/features/currencies/ui/currencies_view_model.dart` и
    `currencies_screen.dart` (ручное обновление), `lib/l10n/app_ru.arb`.
- **TDD:** обновляет только enabled не-RUB; пропускает уже закэшированный курс;
  второй вызов в тот же день без `force` — no-op; ошибка одной валюты не мешает
  другим; успех инкрементит revision; UI-кнопка показывает pending/результат.
- **DoD:** format/analyze/test/build; `task-reviewer` + `design-reviewer`; статус
  `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.3: автообновление курсов валют`.

### 21.4 Скрытие сумм на Главной блюром — [ ]

- **Приоритет/зависимости:** P1; независима; пересекается по файлам с 21.5/21.6/21.8.
- **Суть:** иконка «скрыть суммы» в правом верхнем углу Главной; при нажатии все
  денежные значения прячутся за блюром.
- **Контракты (D21.4):**
  - **H1.** `DashboardViewModel.amountsHidden: Signal<bool>` (default false,
    сбрасывается в `init()`; не персистится).
  - **H2.** Новый uikit-скоуп `AppMoneyVisibility` (`InheritedWidget` с `bool
    hidden`); `AppMoneyText` при `hidden` оборачивает строку в
    `ImageFiltered(ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4))` и ставит
    `Semantics(hidden: true)`. Через `AppMoneyText` покрываются `AppSummaryCard`,
    `AppMetric`, `AppMoneyDelta`, `DashboardNetWorth`/`Locked`/`RecentOperations`.
  - **H3.** Денежные значения на `AppText` переводятся на `AppMoneyText`
    (`AppGoalCard.progressText/targetText`, `DashboardSafetyCushion` значения) или
    оборачиваются в `AppAmountBlur`; подписи/названия не блюрятся. График
    `AppCashflowChart` (подписи-тултипы сумм) оборачивается целиком.
  - **H4.** Переключатель — `AppIconButton` (`visibility`/`visibility_off`) в
    `AppTopAppBar.actions` с тултипом и семантикой; состояние общее для всех
    блоков.
- **Files:**
  - Create: `lib/uikit/app_money_visibility.dart`, `lib/uikit/app_amount_blur.dart`,
    тесты `test/uikit/app_money_visibility_test.dart`.
  - Modify: `lib/core/features/dashboard/ui/dashboard_view_model.dart`,
    `dashboard_screen.dart` (actions + скоуп), `lib/uikit/app_money_text.dart`,
    `app_metric.dart`, `app_goal_card.dart`, `lib/core/features/dashboard/ui/
    dashboard_safety_cushion.dart`, `dashboard_recent_operations.dart`,
    `lib/l10n/app_ru.arb` (тултип/семантика).
- **TDD:** тумблер скрывает/показывает все денежные блоки; `AppMoneyText` при
  hidden применяет фильтр, при show — нет; подписи не блюрятся; семантика сумм
  скрыта; иконка меняет состояние; 320dp/2.0 без overflow.
- **DoD:** format/analyze/test/build; `task-reviewer` + `design-reviewer`; статус
  `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.4: скрытие сумм на главной блюром`.

### 21.5 Подушка безопасности отображается — [ ]

- **Приоритет/зависимости:** P1; после 21.8 (нужен резервный курс).
- **Симптом:** блок «Подушка безопасности» не отображается у пользователя.
- **Причины (проверить и устранить):**
  - **S1.** `_recomputeSafety` скрывает блок при любом `netWorthError != null`
    (частый случай — `rateUnavailable` из-за мультивалютной инвестиции в чистом
    капитале), хотя подушке нужны только счета и денежный поток.
  - **S2.** Ошибка `queries.cashflow` за 3 полных месяца (неконвертируемая запись
    → `rateUnavailable`) молча ставит `safetyCushion = null`.
  - **S3.** Законные скрытия (сохранить): нет неархивных счетов; нет расходов за
    3 полных месяца; аномалия валют.
- **Контракты (D21.5):**
  - **S4.** `cash` считается как сумма `AssetSnapshot.currentValue` неархивных
    счетов, сконвертированная в базовую валюту (с резервным курсом 21.8), **не
    через** `netWorth.byAssetKind`; `netWorthError` больше не влияет.
  - **S5.** Новый `safetyCushionError: Signal<DomainErrorCode?>`; при
    неустранимой ошибке курса блок остаётся и показывает inline-состояние
    («Курс недоступен» + retry), а не исчезает.
- **Files:** `lib/core/features/dashboard/ui/dashboard_view_model.dart`
  (независимый расчёт `cash`, `safetyCushionError`, `_recomputeSafety`),
  `dashboard_screen.dart`, `dashboard_safety_cushion.dart`,
  `lib/core/features/dashboard/logic/safety_cushion.dart` (при необходимости),
  `lib/l10n/app_ru.arb`, тесты `test/core/features/dashboard/logic/
  safety_cushion_test.dart`, `test/core/features/dashboard/ui/
  dashboard_safety_cushion_test.dart`, `dashboard_screen_test.dart`.
- **TDD:** нет счетов → скрыт; есть счета + расходы → показан; `rateUnavailable`
  в инвестиционной части net worth → подушка показана; нет курса для расхода →
  показана с предупреждением/резервным курсом; диапазон ровно 3 полных месяца;
  смена базовой валюты пересчитывает.
- **DoD:** format/analyze/test/build; `task-reviewer` + `design-reviewer`; статус
  `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.5: подушка безопасности отображается`.

### 21.6 Предполагаемый налог с процентов по вкладам — [ ]

- **Приоритет/зависимости:** P1; независима (рекомендуется после 21.8).
- **Суть:** блок «Предполагаемый налог» на Главной: сумма процентов по вкладам за
  текущий год × ставка; ставка редактируется в блоке; инфо-тултип; скрыт без
  счетов.
- **Контракты (D21.6):**
  - **X1.** База = сумма `kind = income` категории «Проценты по вкладу» за
    период `1 января текущего года … today` в базовой валюте (авто-капитализация
    и ручные записи; резервный курс 21.8).
  - **X2.** `tax = round(base × ratePercent / 100)`; `ratePercent` по умолчанию
    **13**, допустимо 0…100 (валидация), хранится в `app_settings` ключ
    `taxRatePercent`; при отсутствии — дефолт.
  - **X3.** Блок скрыт, если нет неархивных счетов.
  - **X4.** Информационный тултип/диалог с формулой расчёта.
  - **X5.** Неустранимая ошибка курса — inline-состояние, не исчезновение.
- **Files:**
  - Create: `lib/core/features/dashboard/logic/tax_estimate.dart` (чистый расчёт),
    `lib/core/features/dashboard/ui/dashboard_tax_estimate.dart`, тесты
    `test/core/features/dashboard/logic/tax_estimate_test.dart`,
    `test/core/features/dashboard/ui/dashboard_tax_estimate_test.dart`.
  - Modify: `lib/core/features/settings/domain/settings_repository.dart` +
    `data/settings_repository_impl.dart` (`getTaxRatePercent`/
    `setTaxRatePercent`, ключ `taxRatePercent`), `lib/core/features/categories/
    domain/category_repository.dart` + `data/category_repository_impl.dart` +
    `lib/core/database/daos/references_dao.dart` (`findActiveIdByName` — по
    образцу `RecurringGenerator._activeCategoryId`), `dashboard_view_model.dart`
    (сигналы `taxEstimate`/`taxRatePercent`, запрос категории за год),
    `dashboard_screen.dart`, `lib/l10n/app_ru.arb`.
- **TDD:** сумма за год; ставки 13/0/изменённая; нет процентов → 0; нет счетов →
  скрыт; тултип; изменение ставки пересчитывает; ручные записи категории учтены;
  320dp/2.0.
- **DoD:** format/analyze/test/build; `task-reviewer` + `design-reviewer`; статус
  `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.6: предполагаемый налог с процентов по вкладам`.

### 21.7 Биометрия сразу при блокировке — [ ]

- **Приоритет/зависимости:** P1; независима. Уточняет `BR-Sec-4/6`.
- **Симптом:** при включённой биометрии сначала показывается PIN; отпечаток —
  только по кнопке.
- **Суть:** лок-скрин сам вызывает биометрию; PIN показывается только при
  выключенной биометрии, неудаче/отмене или ручном запросе.
- **Контракты (D21.7):**
  - **B1.** `ApplockViewModel`: `Signal<bool> pinVisible`; `init()`: `biometricVisible
    = enabled && available`; если `biometricVisible` → `pinVisible = false`, иначе
    `true`; `entered/error` сбрасываются.
  - **B2.** Экран после `init()` (после первого кадра) автоматически вызывает
    `authenticateBiometric`; `true` → unlock; `false` → `pinVisible = true`.
  - **B3.** UI: пока `biometricVisible && !pinVisible` — биометрический
    статус/CTA и кнопка «Ввести PIN-код»; иначе — клавиатура PIN (кнопка
    биометрии по-прежнему доступна).
  - **B4.** VM — синглтон; `init()` сбрасывает состояние на каждом локе; lifecycle-
    нюанс (`inactive` игнорируется) не ломается.
- **Files:** `lib/core/features/applock/logic/applock_view_model.dart`,
  `lib/core/features/applock/ui/applock_screen.dart`, `lib/l10n/app_ru.arb`
  (+`appLockEnterPin`), тесты `test/core/features/applock/logic/
  applock_view_model_test.dart`, `test/core/features/applock/ui/
  applock_screen_test.dart`, при необходимости `test/core/features/applock/
  fakes.dart`.
- **TDD:** при показе с включённой биометрией — авто-вызов; успех → unlock;
  отмена/неудача → PIN виден; биометрия выключена → PIN виден, авто-вызова нет;
  ручной показ PIN; повторный лок снова авто-вызывает.
- **DoD:** format/analyze/test/build; `task-reviewer` + `design-reviewer`; статус
  `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.7: биометрия сразу при блокировке`.

### 21.8 Резервный последний курс и плашка на Главной — [ ]

- **Приоритет/зависимости:** P1; после 21.3; до 21.5.
- **Симптом:** после смены дня на Главной в блоках «Чистый капитал» и
  «Заблокированные активы» — «Курс недоступен» вместо сумм.
- **Суть:** читающие пути всегда отдают сумму, используя последний известный курс
  не позже даты, и показывают плашку с датой курса.
- **Контракты (D21.8):**
  - **C1.** Новый `ExchangeRateRepository.findLatestOnOrBefore(code, date)`
    (DAO: `WHERE currency_code = ? AND date <= ? ORDER BY date DESC LIMIT 1`).
  - **C2.** Read-резолвер возвращает `(rate, effectiveDate, stale)`: точная дата →
    `stale = false`; иначе последний ≤ даты → `stale = true`; иначе ошибка.
    **Запись** операций/оценок не меняется: при сохранении нужен точный курс или
    ручной (`BR-C-2`).
  - **C3.** Потребители чтения (дашборд net worth/locked/cashflow/safety, активы,
    детали счёта, аналитика, цели) используют резервный курс и помечают дату.
  - **C4.** `DashboardViewModel` собирает `staleRateDate` (самая свежая дата
    использованного резервного курса); новый uikit `AppWarningBanner` вверху
    Главной: «Курс валют от {дата}: актуальный получить не удалось».
  - **C5.** Плашка скрыта, когда все курсы актуальны (после 21.3).
  - **C6.** Документы: уточнить `BR-C-2` (запись vs чтение), `BR-C-5`,
    `CALC-007`/`CALC-008`; добавить `BR-C-9` (резервный курс чтения + плашка).
- **Files:**
  - Create: `lib/uikit/app_warning_banner.dart` + тест.
  - Modify: `lib/core/features/currencies/domain/exchange_rate_repository.dart`,
    `data/exchange_rate_repository_impl.dart`, `lib/core/database/daos/
    currencies_dao.dart` (`findLatestOnOrBefore`), `lib/core/features/analytics/
    data/analytics_queries_impl.dart` (`_rateFor` + fallback), `lib/core/features/
    assets/ui/assets_view_model.dart`, `account_details_view_model.dart`,
    `lib/core/features/dashboard/ui/dashboard_view_model.dart` (stale-дата +
    плашка), `dashboard_screen.dart`, `lib/core/features/goals/logic/
    calculate_goal_progress.dart`, `lib/l10n/app_ru.arb`,
    `docs/architecture/business_rules.md`, `docs/architecture/calculations.md`.
- **TDD:** точная дата → сумма без плашки; нет точной, есть прошлая → сумма +
  плашка с датой; нет никакой → «Курс недоступен»; сохранение операции без
  точного курса по-прежнему требует ручной (`BR-C-2`); граница даты (`<=`);
  заблокированные активы; активы/детали счёта/цели.
- **DoD:** format/analyze/test/build; docs обновлены; `task-reviewer` +
  `design-reviewer`; статус `[x]` до PR; e2e спросить.
- **Предлагаемый commit:** `task/21.8: резервный курс и плашка на главной`.
