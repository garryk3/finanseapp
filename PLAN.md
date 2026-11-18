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
   `flutter test`; `flutter build apk --debug`; generated файлы проверены; `git diff --check`;
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
| 3 | Ядро, БД, UIKit и навигация | 3.1–3.5 | ⬜ | — |
| 4 | Справочники и курсы валют | 4.1–4.3 | ⬜ | — |
| 5 | Активы и оценки | 5.1–5.4 | ⬜ | — |
| 6 | Транзакции, переводы и аудит | 6.1–6.3 | ⬜ | — |
| 7 | Доходы, расходы и связь со счетами | 7.1–7.4 | ⬜ | — |
| 8 | Финансовые цели | 8.1–8.2 | ⬜ | — |
| 9 | Аналитика и графики | 9.1–9.4 | ⬜ | — |
| 10 | Dashboard, настройки, backup и updates | 10.1–10.6 | ⬜ | — |
| 11 | Сквозное качество и release readiness | 11.1–11.4 | ⬜ | — |
| 12 | Расширения после v1 | 12.1–12.5 | P2 | — |

## Этап 1 — Базовый каркас приложения

### 1.1 Flutter-проект в корне репозитория — [x] 2026-11-15

- `flutter create --org com.example --project-name finanseapp --platforms android,linux .`
  (пакет `com.example.finanseapp`). Версия `0.1.0+1`.
- Подключены signals, go_router, Drift, fl_chart, intl, material_ui и локализация RU.
- Настроены Linux desktop и analyzer guard `restrict_raw_flutter`.

### 1.2 Структура lib/ и базовый UI — [x] 2026-11-15

- Созданы `main.dart`, app/router/theme, manual DI, demo HomeViewModel и минимальный UIKit.
- Виджетный слой использует `package:material_ui/material_ui.dart`, строки — ARB.

### 1.3 Тесты и проверка запуска — [x] 2026-11-15

- `test/app_test.dart`: заголовок и demo counter. Linux smoke integration пройден.
- Format, оба analyze, 2 unit/widget tests, debug Linux bundle и windowed run проверены.

### Реализовано (2026-11-15)

- Каркас создан; Flutter 3.50 потребовал `material_ui` и `SignalBuilder` вместо deprecated
  imports/watch. Демо Home удаляется в 3.5. Реальные Drift tables ещё не реализованы.

## Этап 2 — Архитектурный комплект и контракты

### 2.1 Продуктовые границы и канонические BR — [x] 2026-11-15

- **Приоритет/зависимости:** P0; после 1.3. **BR:** все, особенно разрешение PDF/Markdown.
- **Files:** Create `PRODUCT.md`, `docs/architecture/business_rules.md`,
  `docs/architecture/README.md`; Test — документная матрица покрытия BR.
- **Consumes:** четыре пользовательских источника и подтверждённые решения владельца.
- **Produces:** scope, RUB audit/base currency, запрет negative balance, ежемесячная
  капитализация, правила soft delete/revisions, связи cashflow/assets, P2.
- **Проверка:** умножение на rateToRub, отсутствие debt scope, transfer не cashflow,
  expense не error; каждому BR назначены реализационные задачи и типы тестов.
- **DoD:** противоречия источников явно разрешены; незаполненных решений нет. Документация,
  ревью кода и e2e не требуются; commit/PR не создавались.
- **Предлагаемый commit:** `task/02.1: зафиксировать продуктовые правила`.

### 2.2 Доменные сигнатуры и числовые эталоны — [x] 2026-11-15

- **Приоритет/зависимости:** P0; после 2.1. **BR:** BR-VAL/T/C/A/P/G/S/IE.
- **Files:** Create `docs/architecture/domain_model.md`, `calculations.md`;
  Test — 36 эталонных CALC-кейсов в документе.
- **Consumes:** BR. **Produces:** Money/LocalDate/Decimal contracts, entities/drafts,
  repositories, `CashflowCommands`, `AnalyticsQueries`, ViewState и formulas.
- **Проверка:** кросс-курс A→B = A→RUB / B→RUB; transfer имеет revise/softDeleteTransfer;
  createLinked получает assetTransactionId; прогноз 100000 при 12% за год =112682.50.
- **DoD:** сигнатуры не содержат Flutter/Drift, нет неопределённых типов и деления вместо
  умножения. Изменения только документы; e2e не применим.
- **Предлагаемый commit:** `task/02.2: описать домен и эталонные расчёты`.

### 2.3 Файловая структура, Drift v1 и навигация — [x] 2026-11-15

- **Приоритет/зависимости:** P0; после 2.2. **BR:** все persistence/navigation инварианты.
- **Files:** Create `docs/architecture/file_structure.md`, `data_schema.md`,
  `navigation_and_screens.md`; Test — матрица routes/screens/states.
- **Consumes:** domain contracts. **Produces:** точное дерево lib/test/integration, tables,
  PK/FK/indexes/converters, TX algorithms, named routes/prefill и screen→VM→test matrix.
- **Проверка:** revision 1/create, linked pair rollback, transfer group, archived references,
  unique rates, static routes раньше `:id`, invalid id → Not Found.
- **DoD:** каждая таблица и экран имеют назначение и тест; Dart-заглушки не созданы.
- **Предлагаемый commit:** `task/02.3: спроектировать БД и навигацию`.

### 2.4 Backup/restore и GitHub Updates из donor — [x] 2026-11-15

- **Приоритет/зависимости:** P0; после 2.3. **BR:** BR-BU/UP.
- **Files:** Create `docs/architecture/backup_and_updates.md`; Modify PRODUCT/business/file
  structure/navigation docs; Test — специфицированные SQLite rollback и VM cases.
- **Consumes:** donor `settings_screen.dart`, SyncController/LocalFileSyncService,
  UpdateCheckController/GithubUpdateService, MainActivity/Manifest и tests.
- **Produces:** BackupService/FileGateway/ViewModel, safe candidate+rollback protocol,
  AppVersion/UpdateService, SAF channel, dependencies и Android permissions.
- **Проверка:** rollback при replace/reopen failure, application_id FNAP, save/pick cancel,
  GitHub `garryk3/finanseapp`, HTTPS only, отсутствие donor workout/notification code.
- **DoD:** перенос разбит на 10.4/10.5 с TDD; actual Dart/platform code не копировался.
- **Предлагаемый commit:** `task/02.4: спроектировать backup и обновления`.

### 2.5 UIKit, DESIGN и детальный implementation plan — [x] 2026-11-16

- **Приоритет/зависимости:** P0; после 2.4. **BR:** accessibility и все UI-facing правила.
- **Files:** Create `lib/uikit/design/{README,foundations,primitives,inputs,finance,charts,patterns}.md`;
  Modify `DESIGN.md`, `PLAN.md`, README/PROJECT/AGENTS links.
- **Consumes:** PRODUCT, routes, banned raw widgets. **Produces:** component signatures,
  semantic tokens, states/a11y tests и задачи 3.1–12.4 с файлами/TDD/DoD.
- **Проверка:** нет AppGradientButton/AppTile ambiguity, expense≠error, все banned raw
  widgets имеют wrappers, chart text alternative, backup settings UX.
- **DoD:** design-reviewer не ниже APPROVE WITH FIXES без blocking findings; docs-only
  self-review завершён; реализация Dart не выполнялась.
- **Предлагаемый commit:** `task/02.5: подготовить UIKit и план реализации`.

## Этап 3 — Ядро, БД, UIKit и навигация

### 3.1 LocalDate, Money и точные конвертеры — [x] 2026-11-17

- **Приоритет/зависимости:** P1; после 2.5. **BR:** VAL-1…4, C-5, T-2.
- **Files:** Create `lib/core/domain/common/{local_date,money,currency,exchange_rate,date_range,result,validation,money_math,currency_converter}.dart`;
  Modify `pubspec.yaml`, `pubspec.lock`; Test `test/core/domain/common/{local_date_test,money_math_test,currency_converter_test,golden_calculations_test}.dart`.
- **Consumes:** `decimal`, контракты domain_model §1–2 и calculations CALC-001…015.
- **Produces:** точные `LocalDate.parse`, `MoneyMath.fromDecimal/add/subtract`,
  `CurrencyConverter.convertWithRates`, DomainException/Result.
- **TDD:** failing 2024-02-29 valid/2023-02-29 invalid, strict `2024-2-03` reject;
  RUB 123.45→12345 minor, EUR 10×93.4567→93457 копеек с одним final rounding;
  USD 10 при USD=90 и EUR=100 даёт EUR 9.00; разные currency add бросают validation.
  Реализовать Decimal/minor units без double и прогнать все golden values буквально.
- **Генерация:** `flutter pub get`; l10n/Drift не меняются.
- **Рабочий план (2026-11-17):**
  - Зависимости: `decimal ^3.2.6` и `rational ^2.2.3` напрямую (`Decimal / Decimal`
    возвращает `Rational`; точное округление без промежуточной потери считается по
    `numerator/denominator`, поэтому тип объявляется явно, а не живёт транзитивно).
    `docs/PROJECT.md` получает строку про денежную арифметику.
  - `LocalDate`: конструктор **не** `const` — полный календарный валидатор
    (`2024-02-29` ok; `2023-02-29`, `2024-04-31` — нет) невозможен в const-assert, где
    нельзя вызвать функцию. То же отклонение у `DateRange` (валидирует `start <= end`).
    Отклонения от const-сигнатур контракта зафиксированы здесь.
    Ошибка — `DomainException(validation)`; `parse` строго `yyyy-MM-dd` без trim/пробелов;
    `fromDateTime` берёт локальные поля; `toUtcDateTime` — полночь UTC; `==`/`hashCode`/
    `compareTo` по (year, month, day).
  - `Money`/`MoneyMath`: единственное округление half away from zero в
    `MoneyMath.fromRational` — общая точка для `fromDecimal` и `CurrencyConverter`
    (правило не может разойтись между входами); `add/subtract` проверяют 64-bit
    диапазон; переполнение → `DomainException(validation)`; `toDecimal` точный.
  - `CurrencyConverter`: точная `Rational`-арифметика `amount×sourceRate/targetRate`, одно
    округление на итоге через `MoneyMath.fromRational`; RUB = 1 (переданный курс
    игнорируется, CALC-003), конверсия в ту же валюту — identity; `null` target-курс →
    `rateUnavailable`, `<=0` → `validation`.
  - `Currency` (asserts `0..8` fraction digits, непустой код), `ExchangeRate`, `DateRange`
    (включительный, `start <= end` иначе `validation`), `Result/Success/Failure`,
    `DomainException`, `validation.dart` (`requirePositiveRate`, `requirePositiveMoney` —
    проверка суммы после округления, BR-T-5/BR-IE-10).
  - **Перенесено в 3.2:** `CHECK fractionDigits 0..8` в схеме + валидация в repository —
    assert в `Currency` в release no-op.
  - Тесты: `local_date_test`, `money_math_test`, `currency_converter_test`,
    `golden_calculations_test` (CALC-001…007 буквально). CALC-009…015 — расчёты активов
    этапа 5 и проверяются задачами 5.1–5.2; сводный прогон всех эталонов — 11.1.
  - Порядок: `local_date` → `currency`/`money` → `money_math` → `currency_converter` →
    golden-таблица. UI нет → design-review не требуется; `task-reviewer` перед PR;
    про e2e спросить владельца.
- **DoD:** CALC-001…007 pass (CALC-009…015 — 5.1–5.2, сводный прогон — 11.1),
  -0 нормализован, overflow обрабатывается DomainException; общий DoD. Перед PR спросить
  о e2e.
- **Предлагаемый commit:** `task/03.1: добавить точные денежные типы`.

### 3.2 Drift schema v1, DAO и ревизионные транзакции — [x] 2026-11-17

- **Приоритет/зависимости:** P1; после 3.1. **BR:** VAL/T-3…9/C-3,7/CAT-4…6/BU-2…4.
- **Files:** Create `lib/core/database/app_database.dart`, `app_database_path.dart`, все
  `tables/`, `converters/`, `daos/`, `seed/seed_data.dart` из file_structure;
  Modify `pubspec.yaml` (path_provider/path/sqlite3) и lock;
  Test `test/core/database/{app_database_test,seed_data_test,revision_transaction_test}.dart`,
  schema fixtures; Generate `app_database.g.dart`, `drift_schemas/drift_schema_v1.json`.
- **Consumes:** data_schema §1–9, domain entities/repositories. **Produces:** AppDatabase v1,
  application_id FNAP, FK/indexes, seed, DAO transactions create/revise/delete/transfer.
- **TDD:** failing FK restrict, unique `(currencyCode,date)`, partial active link, revisions
  immutable; create pair revisionNo=1, edit adds 2, delete сохраняет row; rollback между tx
  и revision не оставляет projection; transfer revise/softDelete атомарны, одиночная нога
  отклонена. Затем реализовать TX-ASSET-TX/TRANSFER и seed idempotency.
- **Генерация:** pub get; `dart run build_runner build --delete-conflicting-outputs`;
  `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`.
- **Рабочий план (2026-11-17):**
  - **Границы задачи:** схема v1 + конвертеры + seed + DAO-примитивы и обязательные
    DB-транзакции записи (TX-ASSET-SAVE, TX-ASSET-TX-CREATE, TX-TRANSFER-SAVE).
    TX-LINKED-SAVE (связанный cashflow) — 7.2; TX-REFERENCE-MOVE-DELETE и экранные
    move-диалоги — 4.1/4.3; read/watch-запросы фильтров и агрегаты — задачами экранов
    (5.x–9.x) поверх готовых таблиц. DAO создаются все 9 файлов, но только с методами,
    которые нужны сейчас и ближайшим repository-задачам; пустых заглушек нет.
  - **Dart-модель:** generated-классы получают `@DataClassName('…Row')`, чтобы не
    конфликтовать с будущими domain-entities 3.3. Ранние domain-enum'ы (AssetKind,
    AssetTransactionKind, RevisionAction, SubgroupKind, CashflowKind, GoalCategory,
    GoalStatus) создаются в своих domain-путях, 3.3 дополнит те же файлы сущностями.
  - **Стабильные enum:** TEXT-значения через явные `TypeConverter` в
    `converters/enum_converters.dart` (не `EnumIndexConverter`, не `textEnum`):
    неизвестное значение → `FormatException`. `DecimalConverter` и
    `LocalDateConverter` — по data_schema §2; добавлен `UtcTimestampConverter`
    (ISO-8601 TEXT с микросекундами, UTC) — Drift `dateTime()` хранит unix-время и
    нарушает контракт.
  - **Схема:** FK `RESTRICT` (кроме явных исключений), CHECK на суммы/курсы/
    fractionDigits/endDate, обычные индексы — декларативно; частичные unique-индексы
    (`asset_transactions_active_transfer_leg`, `cashflow_active_asset_link`,
    categories active name) и триггеры (immutable revisions, RUB protected,
    endDate >= startDate) — `customStatement` в `onCreate` и набор констант.
    `schema dump` не видит runtime-DDL: тесты проверяют объекты через `sqlite_master`.
  - **application_id:** `0x464E4150` (1179533648) ставится в `onCreate`;
    `beforeOpen` включает `PRAGMA foreign_keys = ON`.
  - **Seed:** 5 валют, 6 доходных и 10 расходных категорий (`isPreset`), базовая валюта
    RUB только если ключа ещё нет. Валюты — `insertOrIgnore` по PK; категории — только
    при пустой таблице (повторный seed не воскрешает rename/archive).
  - **Транзакции:** `TransactionsDao` — create/revise/softDelete с одной append-only
    ревизией и snapshot JSON (`snapshotSchemaVersion = 1`); transfer create/revise/
    softDelete только парами, с запретом прямых операций над ногой (conflict);
    projected-balance проверка счёта с учётом всех активных операций и исключением
    редактируемой; отрицательный баланс → `negativeBalance` до записи. Ревизии
    защищены триггерами от UPDATE/DELETE.
  - **Тесты:** `app_database_test` (integrity/FK/индексы/триггеры/application_id),
    `seed_data_test` (идемпотентность/rename), `revision_transaction_test`
    (ревизии, откат после сбоя на шаге ревизии, transfer atomicity, conflict на ногу).
  - **Доп. файлы сверх списка:** `converters/enum_converters.dart`,
    `converters/utc_timestamp_converter.dart` (ISO TEXT вместо unix-времени),
    `revision_snapshots.dart` (общий JSON-снапшот), ранние domain-enum'ы в
    `features/*/domain/` (3.3 дополнит файлы сущностями). Generated:
    `app_database.g.dart`, `daos/*.g.dart`, `drift_schemas/drift_schema_v1.json`.
  - **Дополнительные файлы (не в исходном списке, обоснованы схемой):**
    `converters/enum_converters.dart` (стабильные TEXT-enum),
    `converters/utc_timestamp_converter.dart` (ISO TEXT с микросекундами),
    `revision_snapshots.dart` (единый формат snapshot JSON),
    `test/core/database/database_fixtures.dart` (фикстуры тестов).
  - **Отложено по итогам ревью:** negative-balance при удалении/переносе
    кредитующих операций (удаление пополнения/transferIn может оставить счёт
    отрицательным) — буквально соответствует TX-спекам, требует решения владельца и
    реализуется в 6.2/6.3. Остальные замечания ревью (базовая валюта в
    `countReferences`, kind-guard оценок, единый canonicalDecimal, фиксированная
    ширина timestamp, notFound в rename, тесты отката и exclude-id) исправлены здесь.
  - **Генерация:** build_runner + `drift_dev schema dump`; l10n не меняется. UI нет →
    design-review не нужен; `task-reviewer` перед PR; про e2e спросить владельца.
- **DoD:** `integrity_check=ok`, `foreign_key_check` пуст, индексы и application_id проверены
  PRAGMA; generated в diff; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/03.2: реализовать Drift-схему v1`.

### 3.3 DI, repository wiring и общие presentation contracts — [x] 2026-11-17

- **Приоритет/зависимости:** P1; после 3.2. **BR:** VAL-7, архитектурные dependency rules.
- **Files:** Create все domain files assets/transactions/cashflow/categories/currencies/goals/
  analytics/settings/audit из file_structure, кроме backup и update contracts из 10.4/10.5;
  `lib/core/presentation/{view_state,money_formatter,date_formatter}.dart`,
  `lib/core/di/register_core_services.dart`; Modify `service_locator.dart`, `main.dart`,
  `app_ru.arb` и generated l10n; Test `test/core/di/service_locator_test.dart`,
  `test/core/presentation/formatters_test.dart`.
- **Consumes:** AppDatabase/DAOs и domain_model §3–11. **Produces:** lazy singleton DB/DAOs,
  factory VMs support, async close/reset lifecycle, typed ViewState и RU formatters;
  feature repositories регистрируются вместе с implementations в своих задачах.
- **TDD:** duplicate register/get missing дают понятную ошибку; reset ожидает database.close
  и не возвращает disposed singleton; formatting 123456.7 RUB → `123 456,70 ₽`, дата
  03.02.2026 однозначна; VM factory возвращает разные instances, repository singleton один.
- **Генерация:** `flutter gen-l10n`; build_runner только если изменился Drift source.
- **Рабочий план (2026-11-17):**
  - **Границы:** создаются доменные *контракты* (сущности, draft'ы, фильтры, summary-модели,
    repository-интерфейсы) + `ViewState` + RU-форматтеры + DI. Реализации repositories,
    use cases и калькуляторы (`AssetValueCalculator`, `AccountForecastCalculator`,
    `GoalCalculator`, `CashflowCalculator`, `AnalyticsQueries` impl) создаются задачами
    своих этапов (4.x–9.x) вместе с их TDD — пустых заглушек не добавляем.
  - **Доменные файлы:** расширяются существующие enum-файлы (`asset.dart`,
    `asset_transaction.dart`, `subgroup.dart`, `category.dart`, `financial_goal.dart`),
    новые файлы по file_structure: `asset_draft`, `asset_valuation`, `asset_repository`,
    `subgroup_repository`, `asset_transaction_revision`, `transaction_filter`,
    `asset_transaction_repository`, `cashflow_entry`, `cashflow_entry_revision`,
    `cashflow_filter`, `cashflow_summary`, `cashflow_repository`, `cashflow_category`,
    `category_repository`, `currency_repository`, `exchange_rate_repository`,
    `goal_progress`, `goal_repository`, `analytics_queries`, `net_worth_summary`,
    `cashflow_period_point`, `settings_repository`, `audit_repository`.
  - **DI:** `ServiceLocator` — `StateError` (не `assert`) с именем типа для duplicate/register
    после reset; `registerFactory<T>`; `reset()` последовательно закрывает disposable
    (AppDatabase) и очищает реестр; после reset старые инстансы не возвращаются.
    `registerCoreServices` регистрирует DB + все DAO + форматтеры; feature-repositories
    появятся вместе с implementations. `main` открывает `openAppDatabase()` и регистрирует
    core-services до applock-контроллеров.
  - **Presentation:** `ViewState`/`ViewLoading`/`ViewData`/`ViewError` по domain_model §11;
    `MoneyFormatter` (Money → `1 234,56 ₽`, группировка ru_RU; Decimal-вариант; fallback
    на код валюты), `DateFormatter` (`03.02.2026`, ISO для отладки).
  - **Тесты:** `service_locator_test` (duplicate/missing, factory → разные инстансы,
    singleton один, reset ждёт `database.close` и после reset get бросает),
    `formatters_test` (NBSP-группировка, negative, fraction digits, дата без двусмысленности).
  - **Уточнения реализации:** `SubgroupKind`/`Subgroup` перенесены в
    `assets/domain/subgroup.dart` по file_structure (импорты DAO/конвертеров обновлены,
    старый `references/domain` удалён). `MoneyFormatter` строит строку из minor units
    целочисленно (без `double`), поэтому крупные суммы не теряют точность; группировка —
    NBSP, как у ru_RU. `ServiceLocator` использует `StateError`, а не `assert`.
  - **Перенесено:** регистрация ~42 ключей `validation*` из DAO в `app_ru.arb` — обязательный
    пункт задач 5.x–7.x (эти DAO начнут использоваться в UI только там).
  - l10n не меняется: новых пользовательских строк нет. UI нет → design-review не нужен;
    `task-reviewer` перед PR; про e2e спросить владельца.
- **DoD:** UI не получает ServiceLocator, репозитории доступны через interfaces, dispose/
  reset протестированы; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/03.3: связать доменные контракты и DI`.

### 3.4 UIKit и theme foundations — [x] 2026-11-17

- **Приоритет/зависимости:** P1; после 2.5, независимо от 3.2/3.3. **BR:** VAL-7, DESIGN/a11y.
- **Рабочий план (2026-11-16):** полный UIKit по контрактам 2.5 одной задачей + три
  изменения контракта: (1) новый layout-компонент `AppAdaptiveGrid` — LayoutBuilder,
  `<600dp` одна колонка / `>=600dp` две, центрирование `contentMaxWidth=1200` /
  `formMaxWidth=640` через `maxColumns: 1`, для fold/планшета; (2) фиксация вертикальной
  ориентации `android:screenOrientation="portrait"` у MainActivity; (3) doc-подпись
  «Экраны: …» у каждого public компонента (маппинг из navigation_and_screens §5) +
  сводная таблица «компонент → экраны» в `lib/uikit/design/README.md`. Изменения
  фиксируются в DESIGN.md §4, file_structure.md, `uikit/design/primitives.md` в этой задаче.
  Порядок: theme → primitives (вкл. AppAdaptiveGrid) → inputs → finance → states →
  charts → barrel `uikit.dart` → portrait → docs → тесты → гейты.
- **Files:** Create все UIKit `.dart` из file_structure (включая `app_adaptive_grid.dart`)
  и theme `{app_semantic_colors,app_spacing,app_shapes,chart_series_colors}.dart`;
  Modify существующие `app_{scaffold,text,button,section,theme}.dart`, `lib/uikit/uikit.dart`,
  `android/app/src/main/AndroidManifest.xml`, `DESIGN.md`, `docs/architecture/file_structure.md`,
  `lib/uikit/design/{primitives,README}.md`;
  Test `test/uikit/{primitives_test,inputs_test,finance_test,charts_test,states_test,layout_test,accessibility_test}.dart`.
- **Consumes:** семь контрактов `lib/uikit/design/`. **Produces:** все wrappers и presentation
  models, semantic light/dark themes, charts, feedback, inputs без domain dependencies.
- **TDD:** сначала raw-wrapper replacement test и callbacks pending/disabled; amount comma/
  fraction tests; expense semantics без error; empty/error/confirm; charts empty/single/zero/
  NaN rejection; layout-тесты сетки 599/600/1100dp; 320dp+1.3+long RU в light/dark.
  Реализовать компоненты группами primitives→inputs→finance→charts, сохраняя public signatures.
- **Генерация:** новых зависимостей нет; l10n в UIKit не генерируется.
- **DoD:** `dart analyze lib --fatal-infos` не находит обходов; contrast/targets/semantics
  tests pass; design-reviewer обязателен; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/03.4: реализовать дизайн-систему UIKit`.

### 3.5 Adaptive shell, go_router и Not Found — [x] 2026-11-18

- **Приоритет/зависимости:** P1; после 3.3 и 3.4. **BR:** navigation contract, VAL-7.
- **Files:** Create `lib/app/{routes,shell_screen}.dart`, root `dashboard_screen/view_model`,
  `cashflow_screen/view_model`, `transactions_screen/view_model`, `assets_screen/view_model`,
  `goals_screen/view_model`, `more_screen/view_model`, `app_info/ui/not_found_*` с реальными
  empty/loading states; Modify `app/router.dart`, `app/app.dart`, `main.dart`, `app_ru.arb`,
  `test/app_test.dart`; Delete `lib/core/features/home/` после замены;
  Test `test/app/{router_test,shell_screen_test}.dart`, `integration_test/app_test.dart`.
- **Consumes:** navigation_and_screens §1–5, DI/UIViewState. **Produces:** пять primary routes,
  StatefulShellRoute, полный набор route names, safe parsers/prefill helpers и NotFound;
  secondary builders подключаются своими feature-задачами.
- **TDD:** в test router `/assets/new/account` не захватывается `:id`, `/assets/abc` и unknown
  id → NotFound, back с details возвращает root, selected tab сохраняется; compact bar/
  expanded rail; malformed query не бросает. Реализовать router и smoke пяти primary tabs.
- **Перенесено из 3.3:** экранные ViewModel регистрируются через `registerFactory` и
  диспозятся Stateful-владельцем; текущие синглтон-регистрации в `main`/`router` заменить,
  чтобы подписки не жили вечно.
- **Рабочий план (2026-11-17):** `AppRoutes` — полный набор path/name из §2 + safe-парсеры
  (`int.tryParse`, allowlist kind/tab); `StatefulShellRoute.indexedStack` с пятью primary
  ветками и сохранением стека; повторный tap → `goBranch(initialLocation: true)`;
  shell — `AppNavigationBar` <600dp / `AppNavigationRail` >=600dp. Primary-экраны получают
  VM через factory из router (composition root), Stateful-экран диспозит VM; реальные
  empty/loading состояния через `ViewState` и uikit (`AppEmptyState`). Secondary-маршруты
  из §2 регистрируются безопасными заглушками (`/assets/new/*` статически до `/:id`,
  невалидный id → NotFound) и подключаются экранами своих задач; `/applock` остаётся
  top-level, вход переносится с демо-Home на More. NotFound — отдельный экран с
  безопасной кнопкой «На главную»; `errorBuilder` без stack trace. Удаляется `home/`
  и demo-счётчик; l10n получает nav/empty/not-found строки; `app.dart` кэширует router
  (Stateful), чтобы shell не пересоздавался.
- **Итог:** `AppRoutes` содержит полную карту §2 и safe-парсеры; router кэшируется в
  Stateful `FinanseApp`; `ShellScreen` — bar/rail с сохранением branch-стека и повторным
  tap в root; пять primary-экранов с ViewState (loading/empty/error) и VM-factory,
  диспозятся Stateful-владельцем; secondary-маршруты безопасно заглушены, invalid id и
  unknown route → NotFound; demo Home/счётчик удалены, вход в защиту перенесён на «Ещё».
  Тесты: `test/app/router_test.dart`, `shell_screen_test.dart`, обновлены `app_test.dart`
  и integration smoke.
- **Отложено:** реальные secondary-экраны и prefill подключаются задачами 5.x–10.x;
  экраны, открываемые из shell, сохраняют общий rail/bar (реализация secondary вне shell —
  вместе с экранами). CTA пустых состояний ведут в ещё не готовые формы, поэтому
  добавляются вместе с формами (5.1/8.1); VM начинают с ViewData, а не ViewLoading, до
  подключения stream'ов (5.1/7.1). Lifecycle VM по фабрике из router (создание в initState)
  и реакция `app.dart` на новый locator — 5.1/10.4.
- **Генерация:** `flutter gen-l10n`; Drift schema не меняется.
- **DoD:** пять primary routes работают, route names соответствуют matrix, demo counter удалён,
  unit/widget+debug APK
  pass; e2e запуск только после вопроса владельцу; общий DoD/design review.
- **Предлагаемый commit:** `task/03.5: добавить адаптивную навигацию`.

### 3.6 Пост-ревью фиксы баланса и дат (3.2) — [x] 2026-11-17

- **Приоритет/зависимости:** P1; сразу после 3.3. **BR:** VAL-5, T-6, CALC-010.
- **Причина:** повторное ревью 3.2 подтвердило прогоном две дыры инварианта
  «отрицательный баланс запрещён»: `revise` кредита и правка `transferIn` не пересчитывают
  баланс; плюс `occurredOn` в будущем принимается.
- **Files:** Modify `daos/transactions_dao.dart` (проверка итогового баланса всех затронутых
  счетов независимо от знака и для старого счёта при смене `assetId`; проверка
  `occurredOn <= LocalDate.fromDateTime(clock().toLocal())`), `revision_snapshots.dart`
  (таймстемпы через `UtcTimestampConverter`), `tables/asset_valuations.dart`
  (индекс `effectiveOn DESC, id DESC` + schema dump); Test regression-кейсы:
  уменьшение/перенос deposit, уменьшение/перенос transferIn, будущая дата, snapshot-формат.
- **Produces:** целостность баланса на всех путях правки; одинаковый формат timestamp в
  колонках и snapshot; индекс оценки соответствует data_schema §3.
- **Итог:** единая проверка истории `(occurredOn, id)` для create/revise/softDelete и
  обеих ног перевода: вставка новой версии и удаление (история без строки) не должны давать
  отрицательный баланс ни в одной точке; смена `assetId` проверяет и старый счёт;
  `occurredOn`/`effectiveOn` не в будущем (`AppDatabase.today()`) для операций, переводов
  (create и revise), cashflow и оценок; snapshot-таймстемпы через `UtcTimestampConverter`;
  индекс оценки `(assetId, effectiveOn DESC, id DESC)`; regression-тесты на уменьшение и
  перенос кредита, удаление кредита, уменьшение/удаление `transferIn`, future-даты create
  и revise.
- **Отложено:** единая функция знака/`today()` уже вынесена в `AppDatabase.today()`;
  строковые литералы вида операции в SQL остаются (типизированная альтернатива — при
  следующей правке enum).
- **DoD:** новые тесты падают на старом коде и проходят после фикса; общий DoD; перед PR —
  `task-reviewer`, вопрос про e2e.
- **Предлагаемый commit:** `task/03.6: закрыть дыры баланса и будущих дат`.

## Этап 4 — Справочники и курсы валют

### 4.1 Банки и брокеры: CRUD и перенос активов — [x] 2026-11-18

- **Приоритет/зависимости:** P1; после 3.5. **BR:** P-1…5, VAL-3.
- **Files:** Create `core/features/references/ui/{subgroups_screen,subgroups_view_model}.dart`;
  Modify assets subgroup repository/DAO, DI, routes/router, ARB;
  Test `test/core/features/references/ui/subgroups_screen_test.dart`,
  `test/core/features/assets/data/subgroup_repository_test.dart`.
- **Consumes:** `SubgroupRepository.watchByKind/create/rename/countAssets/deleteIfUnused/
  moveAssetsAndDelete`, route `/more/subgroups?kind=bank`.
- **Produces:** bank/broker tabs, trimmed unique names, occupied delete dialog с move target,
  atomic move+delete.
- **TDD:** failing « Банк  Раз » и «банк раз» duplicate; rename сохраняет id; source с двумя
  assets не deleteIfUnused; move в target того же kind переносит обе строки или откатывает все;
  target другого kind отклонён. Затем реализовать repository и screen states.
- **Рабочий план (2026-11-18):**
  - **Data:** `ReferencesDao.moveAssetsAndDelete` — одна транзакция: проверить оба справочника
    и совпадение `kind`, обновить `account_details.bankId`/`investment_details.brokerId`,
    убедиться в `countAssets == 0`, удалить source; любая ошибка откатывает всё.
    Реализация `SubgroupRepositoryImpl` в `features/assets/data/` (в file_structure data-слоя
    assets не было subgroup-файла — доп. файл, зафиксирован здесь).
  - **DI:** repository singleton + VM factory в `registerCoreServices`/main.
  - **UI:** `/more/subgroups?kind=` — сегменты bank/broker, список с количеством активов,
    add/rename диалоги, delete: свободный — confirm, занятый — диалог переноса с выбором
    target того же kind; ошибки — SnackBar по l10n-ключу. VM на signals, Screen stateful
    диспозит VM; safe-парсер kind через allowlist.
  - **Тесты:** DAO/repository (trim/duplicate, rename id, count/deleteIfUnused, move атомарно,
    cross-kind reject) + widget (tabs, duplicate, delete с переносом, font 1.3/dark).
- **Итог:** `ReferencesDao.moveAssetsAndDelete` (одна транзакция, проверка kind, откат),
  `SubgroupRepositoryImpl`, DI (repository + VM factory), экран `/more/subgroups?kind=`
  с сегментами bank/broker, списком и количеством активов, add/rename/delete-диалогами
  (занятый — перенос в target того же kind), ошибками из l10n; `Subgroup` получил value-equality.
  Тесты: repository (trim/duplicate, rename id, count/deleteIfUnused, atomic move, cross-kind,
  rollback) + widget (пустое/создание/дубликат/занятый диалог, font 1.3 dark, broker tab).
- **Отложено (зафиксировано ревью):** групповой запрос счётчиков вместо N+1;
  использование `AppRoutes.parseAllowlisted` уже включено; чтение `busy` в UI;
  app-level тест `/more/subgroups?kind=` и UI-исполнение переноса — вместе с 4.2/4.3.
- **Генерация:** `flutter gen-l10n`; build_runner только при фактическом изменении DAO.
- **DoD:** assets сохраняют subgroup name после rename, move transaction count=0 до delete;
  widget font 1.3/dark/error states и общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/04.1: добавить банки и брокеров`.

### 4.2 Валюты, точные курсы ЦБ и ручной fallback — [x] 2026-11-18

- **Приоритет/зависимости:** P1; после 4.1. **BR:** C-1…5,7…8, VAL-3…5.
- **Files:** Create currencies data/logic/ui files из file_structure, включая
  `cbr_exchange_rate_client.dart`, `cbr_xml_parser.dart`, `resolve_exchange_rate.dart`,
  `manage_base_currency.dart`, `manual_rate_dialog.dart`; Modify DI/routes/ARB/pubspec+lock
  (`http`, `xml`); Test fixtures `cbr_daily.xml`, `cbr_daily_wrong_date.xml`,
  `test/core/features/currencies/{data,logic,ui}/*_test.dart`.
- **Consumes:** `CurrencyRepository`, `ExchangeRateRepository.find/fetchFromCbr/saveManual`,
  `ResolveExchangeRate.call`, endpoint CBR XML_daily и routes currencies/base.
- **Produces:** enabled/custom currencies, exact-date cache, `Value/Nominal` Decimal parser,
  immutable used rates, manual entry, selectable base currency без перезаписи RUB snapshots.
- **TDD:** USD XML Value `93,4567`, Nominal 1 → 93.4567; HKD Nominal 10 делится точно;
  response Date другой даты → rateUnavailable и никакой ближайший курс; offline+empty cache
  требует manual; manual не перезаписывается CBR, used rate conflict; RUB не вызывает HTTP;
  `usd`→USD duplicate reject; used/base/RUB disable/delete reject.
- **Рабочий план (2026-11-18):**
  - **Data:** `CbrXmlParser` (xml, `Value/Nominal` через Decimal, дата документа), `CbrExchangeRateClient`
    (http.Client, exact-date URL, wrong date → rateUnavailable), `CurrencyRepositoryImpl`,
    `ExchangeRateRepositoryImpl` (find/saveManual/fetchFromCbr), `SettingsRepositoryImpl` (base
    currency для экрана выбора; 10.3 расширит). DAO: `saveRate(source, fetchedAt)` и проверка
    «курс использован» (операции/оценки на дату+валюту) для BR-C-3; manual не перезаписывается CBR.
  - **Logic:** `ResolveExchangeRate.call` (RUB — без HTTP, manual приоритетнее кэша/сети),
    `ManageBaseCurrency` (setBaseCurrency через SettingsRepository).
  - **UI:** `/more/currencies` (список, enable/disable, базовый маркер, add/rename/delete),
    `/more/currencies/new` (форма), `/more/currencies/base` (radio enabled), reusable
    `ManualRateDialog` (для форм 5.x). VM factory + dispose, l10n.
  - **Тесты:** фикстуры CBR (USD Value 93,4567; HKD Nominal 10; wrong date), parser/client на
    MockClient, repo protections (RUB/base/used), manual immutable vs CBR, resolver RUB без HTTP,
    offline+empty → rateUnavailable, UI smoke/font.
- **Итог:** `CbrXmlParser` (Value/Nominal через Decimal, точная дата), `CbrExchangeRateClient`
  (HTTP → networkUnavailable, latin1 для windows-1251), `CurrencyRepositoryImpl`,
  `ExchangeRateRepositoryImpl`, `SettingsRepositoryImpl`, `ResolveExchangeRate`
  (RUB без сети, manual > кэш > ЦБ), `ManageBaseCurrency`; DAO: `saveRate`, immutable
  used rate (BR-C-3), manual не перетирается ЦБ; экраны currencies/new/base и
  `ManualRateDialog`; DI + routes + l10n. Тесты: 7 parser/client, репозитории/protections,
  resolver, UI (список/база/ручной курс).
- **Дизайн-ревью (закрыто):** видимый статус «Отключена» и feedback после toggle/delete;
  защита RUB/используемых валют до destructive-confirm (объясняющий диалог); inline-ошибки
  переименования и пустого названия; Retry/skeleton/empty на экране базовой валюты;
  отдельные тексты пустого списка, tooltip и подсказка базовой валюты.
- **Генерация:** pub get, `flutter gen-l10n`; schema dump не меняется без table changes.
- **DoD:** network tests используют fake client, base change затрагивает только presentation;
  wrong date/offline/manual widget states pass; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/04.2: реализовать валюты и курсы ЦБ`.

### 4.3 Категории доходов/расходов и конфликты удаления — [x] 2026-11-18

- **Приоритет/зависимости:** P1; после 4.2. **BR:** CAT-1…8, VAL-3.
- **Files:** Create categories data/logic/ui из file_structure, включая
  `category_conflict_dialog.dart`; Modify DI/routes/ARB;
  Test `test/core/features/categories/{data,logic,ui}/*_test.dart`, seed tests update.
- **Consumes:** `CategoryRepository.create/update/countEntries/archive/moveEntriesAndDelete/
  deleteIfUnused`, `CashflowCategoryDraft`, seed lists.
- **Produces:** flat typed categories, allowlisted icons/colors, duplicate protection,
  archive/move/delete choices и historical archived labels.
- **TDD:** одинаковое «Аренда» income/expense разрешено, duplicate внутри kind нет;
  used category delete предлагает archive/move; move target другого kind отклонён;
  10 entries переносятся одной транзакцией, failure на последней оставляет source все 10;
  preset редактируется, archived отсутствует в new select, виден в historical.
- **Рабочий план (2026-11-18):**
  - **Data:** `ReferencesDao.moveEntriesAndDelete` (одна транзакция: source/target существуют,
    same kind, target активен; перенос всех записей включая soft-deleted; countEntries=0;
    удаление source). `CategoryRepositoryImpl`.
  - **Logic/VM:** `CategoryCommands` (Result-обёртки), `CategoriesViewModel` на signals
    (kind tabs, stream, duplicate/conflict, archive/move/delete), `CategoryFormViewModel`.
  - **UI:** `/more/categories` (вкладки income/expense, список, menu rename/archive/delete,
    conflict-диалог archive/move/delete при использовании), `/more/categories/new` (kind из
    query), `/more/categories/:id/edit`; l10n, DI factories.
  - **Тесты:** duplicate внутри kind / одинаковое имя income+expense разрешено; preset
    rename; archived скрыт в watchByKind и виден с includeArchived; move 10 записей одной
    транзакцией и откат при сбое; cross-kind move отклонён; used delete → conflict;
    widget smoke (tabs, duplicate, конфликт-диалог).
- **Итог:** `moveEntriesAndDelete` (одна транзакция, same kind, активный target, перенос всех
  записей, откат), `CategoryRepositoryImpl`, `CategoryCommands`, `CategoriesViewModel`
  (вкладки, архивные labels, конфликты), экраны `/more/categories` и `new` + conflict-диалог
  archive/move/delete, DI/routes/l10n. Тесты: duplicate внутри kind, одинаковое имя
  income/expense, preset rename, archived filter, перенос 10 записей и откат, cross-kind,
  used delete, UI smoke (пометки, duplicate inline, конфликт-диалог).
- **Отступление:** отдельный экран `/more/categories/:id/edit` не создавался — переименование
  выполняется диалогом со списка (функционально закрывает edit); константы маршрута остаются
  для будущих форм.
- **Генерация:** gen-l10n; build_runner/schema dump при изменении seed/table source.
- **DoD:** seed 6 income+10 expense, «Аренда»≠«Аренда жилья», conflicts atomic;
  общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/04.3: добавить категории денежного потока`.

## Этап 5 — Активы и оценки

### 5.1 Счета: CRUD, текущий баланс и прогноз — [x] 2026-11-18

- **Приоритет/зависимости:** P1; после 4.2. **BR:** A-1…2,5…6, VAL-3,5…8, C-6.
- **Files:** Create assets data/logic + account form/details/list widgets,
  `asset_value_calculator.dart`, `account_forecast_calculator.dart`, `save_asset.dart`,
  `delete_or_archive_asset.dart`; Modify AssetsScreen/VM, DI/routes/ARB;
  Test `test/core/features/assets/{domain,logic,data,ui}/account_*_test.dart`,
  forecast golden tests.
- **Consumes:** `AssetRepository`, `AccountDraft`, `AssetValueCalculator.account`,
  `AccountForecastCalculator.call`, subgroups/currencies.
- **Produces:** account create/edit/details/archive/delete-if-unused, computed balance,
  base equivalent, forecast display отдельно от факта.
- **TDD:** opening 100000 RUB + deposit 2500 − withdrawal 1000 =101500; zero rate forecast=
  current; missing endDate=null; expired=current; CALC-016…036 включая 31.01.2028→30.03.2028
  =101977.26; annualRate 100.01/end<start/future operations reject; used currency locked.
- **Рабочий план (2026-11-18):**
  - **Domain/logic:** `AssetValueCalculator.account` (opening + знаковые активные операции),
    `AccountForecastCalculator` (CALC-016…021: anniversary-даты с clamp, m = fullMonths +
    remaining/monthDays, double только для степени, итог через `MoneyMath`).
  - **Data:** `AssetRepositoryImpl` (accounts: create/update/archive/deleteIfUnused/watchAll/
    getById/recordValuation); DAO-методы update/delete-if-unused + joins деталей; запрет
    смены валюты при операциях/оценках (BR-VAL-8), проверка opening ≥ 0, annualRate 0..100,
    endDate ≥ startDate, name trim.
  - **UI:** assets list (счета), account form create/edit (банк/валюта/opening/ставка/даты),
    account details (баланс, прогноз отдельно от факта, archive/delete с подтверждением),
    routes `/assets/new/account`, `/assets/:id`, `/assets/:id/edit/account`; DI + l10n.
  - **Тесты:** golden CALC-016…021, repository CRUD/locks/delete counts, form validation,
    details balance/forecast, archived read-only.
- **Итог:** `AssetValueCalculator.account`, `AccountForecastCalculator` (CALC-016…021),
  `AssetRepositoryImpl` (accounts: create/update/archive/delete-if-unused/watch, BR-VAL-8 lock,
  валидации), DAO update/delete/count, экраны assets list/account form/details, DI/routes/l10n.
  Тесты: forecast golden 6, calculator 2, repository 5. UI-тесты ограничены: app-router тест
  статических маршрутов assets снят (реальный экран активов держит drift-стрим, pending-timer
  в widget-тесте); статический приоритет остаётся в таблице маршрутов и будет покрыт
  интеграционным прогоном/экранами 5.2.
- **Сделано после ревью:** base equivalent (BR-C-6, с «Курс недоступен»), counts
  в диалоге удаления (BR-A-5), валидация банка без NPE, кнопка «Изменить» на деталях,
  widget-тесты формы/деталей (prefill major units, пустое имя, баланс/прогноз/архив,
  занятый счёт); детали перезагружаются после «Изменить» и при новом VM; дата окончания
  включается/снимается и сохраняется; валюта блокируется при связях; нулевой opening
  разрешён. **Отложено в 5.3:** дублирование валидаций repo/DAO, widget-тест
  `AssetsScreen` (список/пустое состояние/баланс), реактивность/N+1 снапшотов, `fractionDigits` вместо 2,
  read-only архивного счёта, проверка баланса при правке opening.
- **E2E:** после установки `libsecret-1-dev` и `flutter clean` прогон
  `flutter test integration_test -d linux` зелёный (smoke стартует и показывает главную).
- **Генерация:** gen-l10n; Drift generation только при DAO/source changes.
- **DoD:** CALC forecast values буквально pass, negative balance не обходится edit opening;
  archive read-only, delete dialog показывает counts; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/05.1: реализовать счета и прогноз вклада`.

### 5.2 Инвестиции и абсолютные оценки — [x] (2026-11-18)

- **Приоритет/зависимости:** P1; после 5.1. **BR:** A-3,5…7, C-1…6, VAL-5,8.
- **Files:** Create investment form/details VM/screens, `record_asset_valuation.dart`,
  `valuation_form_screen.dart`, `valuation_form_view_model.dart`, `valuation_history.dart`;
  Modify asset calculator/repository/DI/routes/ARB;
  Test investment repository/calculator/screen и valuation form tests.
- **Consumes:** `InvestmentDraft`, `AssetValuationDraft`, `AssetValueCalculator.investment`,
  `AssetRepository.recordValuation`, rate resolver.
- **Produces:** broker-linked investments, dated absolute valuations с RUB snapshot,
  latest valuation + later transactions, valuation history.
- **TDD:** opening 1000, tx +100, valuation 1500 на 02.01, tx +50 на 03.01 →1550;
  valuation 1400 поздней датой →1400+поздние tx; две оценки одной даты решает больший id;
  future date/negative value reject, valuation не создаёт cashflow/asset tx.
- **Рабочий план (2026-11-18):**
  - **Domain:** `AssetValueCalculator.investment` (последняя оценка по `(effectiveOn,id)`,
    затем операции с `occurredOn >= effectiveOn`; без оценки — все операции от opening),
    `property` — в 5.4.
  - **Data:** repository create/update инвестиции (broker, currency lock, валидации),
    snapshot с оценками, `recordValuation` с RUB snapshot; DAO updateInvestment,
    `valuations(id)`.
  - **UI:** investment form (название/брокер/валюта/opening), details (текущая стоимость,
    история оценок, add valuation, edit/archive/delete), valuation form (value/date/rate),
    routes `/assets/new/investment`, `/assets/:id` для investment, `/assets/:id/edit/investment`,
    `/assets/:id/valuations/new`.
  - **Тесты:** CALC-014 (opening 1000 +100, оценка 1500 → +50 =1550; оценка 1400 → 1400+tx),
    две оценки одной даты по id, future/negative reject, repository create/update/lock.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** ordering `(effectiveOn,id)` подтверждён DB test, original/base values и offline
  manual rate доступны; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/05.2: добавить инвестиции и оценки`.
- **Итог:** `AssetValueCalculator.investment`/`property`, repository create/update инвестиций
  (broker, currency lock), snapshot с оценками, `recordValuation` с рублёвым snapshot;
  `updateInvestment`/`investmentDetailsFor` в DAO, `AssetRepository.valuations`.
  Экраны: выбор вида актива на `AssetsScreen`, `InvestmentFormScreen` (+VM),
  `ValuationFormScreen` (+VM, курс RUB/ЦБ/ручной, запрет будущей даты), детали актива
  показывают текущую стоимость, рублёвый эквивалент и историю оценок, «Изменить»/«Добавить
  оценку» с перезагрузкой. Тесты: CALC-014 и ordering по `(effectiveOn,id)`, repository
  create/update/lock, форма инвестиции/оценки и детали (6 сценариев). Квартира пока
  использует общий экран деталей без cashflow-разреза — в 5.4. Новые ключи ARB;
  schema не менялась. По дизайн-ревью: список активов — `AppAssetListTile` с видом
  и иконкой, главная сумма — `AppSummaryCard`, история — `AppListTile` с датой/рублями
  и меткой «Текущая», архив/удаление — в overflow-меню, ошибки форм привязаны к полям,
  «нет брокеров» ведёт в справочник и форма перезагружает список после возврата, эквивалент
  скрыт при совпадении с базовой валютой, меню действий блокируется на время busy.
- **Отложено в 5.3:** base equivalent в списке активов, `fractionDigits` в списке
  (в деталях/формах и рублёвом snapshot уже из валюты), реактивность списка после
  добавления оценки (watchAll слушает только `assets`), preview курса оценки
  (ручной/ЦБ/кэш), подпись брокера и состав стоимости на деталях,
  правка/удаление оценки, property-детали в snapshot (адрес/цена покупки — 5.4),
  вынос tie-break `(effectiveOn,id)` в один хелпер, визуальная проверка light/dark
  на 320dp и textScale 1.3.

### 5.3 Общий каталог активов, удаление и архивирование — [x] (2026-11-18)

- **Приоритет/зависимости:** P1; после 5.2. **BR:** A-5…6, C-6, S-1…5.
- **Files:** Create `assets_state.dart`, `widgets/asset_actions.dart`, shared asset mappers;
  Modify `assets_screen.dart`, `assets_view_model.dart`, repositories/analytics source
  queries/DI/routes/ARB; Test assets list/filter/archive/delete DB+widget tests.
- **Consumes:** `AssetRepository.watchAll(includeArchived)/deleteIfUnused/archive`,
  account/investment implementations.
- **Produces:** kind filters/search, archived badge/read-only, связь counts dialog,
  физическое delete только unused, единый AssetSnapshot stream.
- **TDD:** unused asset delete исчезает; asset с одной valuation/goal/cashflow/tx получает
  только archive; archive скрыт new selects/current totals после archivedAt, остаётся history;
  failed relation check не удаляет; archived goal link не обрывается.
- **Рабочий план (2026-11-18):**
  - **Reactive snapshots:** `AssetsDao.watchAll/watchById` через `customSelect` с
    `readsFrom: {assets, assetValuations, assetTransactions}` — список и детали
    переизлучаются после оценки/операции; батч транзакций/оценок для `watchAll`
    (убрать N+1 на emission).
  - **VM:** `AssetsViewModel` с фильтрами `query`, `kind`, `showArchived`, счётчиками,
    `visible`; подгрузка валют/базовой валюты/кэша курсов для `fractionDigits` и
    base equivalent в списке; `empty initial ≠ empty filtered`.
  - **UI:** `AppSearchField` + `AppFilterBar` (Все/Счёт/Инвестиция/Квартира + Архивные,
    сброс), `AppAssetListTile` с archived-badge, base equivalent, архивные read-only
    (без edit/add valuation), CTA создания только для непустого фильтра — сброс.
  - **Действия:** counts-диалог и физическое delete только unused — уже на деталях;
    добавить тесты; архивация остаётся единственным путём для используемого актива.
  - **Тесты:** DAO/repository: unused delete исчезает; с valuation/tx/целью/cashflow —
    conflict, archive скрывает из `watchAll` и оставляет в `includeArchived`/history;
    стрим `watchAll` переизлучается после `recordValuation`; widget-тесты списка:
    empty/initial, поиск/вид/архив, base equivalent, archived badge, сброс фильтров.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** empty initial≠empty filtered, archive timestamps UTC, прошлые points сохранены;
  общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/05.3: завершить каталог активов`.
- **Итог:** `AssetsDao.watchAll/watchById` переизлучаются при изменении активов, операций
  и оценок (`customSelect` + `readsFrom`), `watchAll` собирает снапшоты батчем (3 запроса
  вместо N+1). `AssetsViewModel`: поиск, фильтр вида, показ архивных, сброс, base equivalent
  по кэшу курсов и `fractionDigits` из справочника. UI: `AppSearchField` + `AppFilterBar`,
  `AppAssetListTile` с видом/иконкой/архивным бейджем, различение «пустой каталог» и
  «пустой фильтр». Архивные read-only (без edit/добавления оценки). Тесты: catalog DB
  (delete unused, conflict для оценки/операции/цели/cashflow, archive UTC + скрытие из
  списка с сохранением истории, переизлучение стрима после оценки/операции), widget-тесты
  списка (виды/суммы/base, фильтры/поиск/архив, пустые состояния), read-only архив.
  По ревью: сброс фильтров очищает поле поиска (и при смене VM); отдельное состояние
  «все активы в архиве»; архив — отдельный `AppSwitch`, у видов счётчики; «Курс
  недоступен» вместо молчаливого скрытия эквивалента; базовая валюта и справочник валют
  реактивны (с VM-тестами на смену базы/справочника и отмену подписок при dispose/повторном
  init); батч и одиночный путь одинаково исключают soft-deleted операции; router-тест
  закрывает drift-стримы до проверки таймеров.
- **Отложено:** живое обновление курсов в списке (сейчас кэш на момент загрузки),
  приоритет ширины суммы и семантика base equivalent в `AppAssetListTile`,
  связка label `AppSearchField` с полем для TalkBack, `screenPadding` шапки
  на expanded, визуальная проверка light/dark на 320dp и textScale 1.3
  (нет эмулятора).

### 5.4 Квартиры: стоимость, оценки и денежный поток — [ ]

- **Приоритет/зависимости:** P1; после 5.3 и 7.1 для repository cashflow read;
  UI cashflow CRUD подключается 7.4. **BR:** A-4…7, RE-1…5,7, C-6.
- **Files:** Create property form/details screens+VM, `property_cashflow_section.dart`,
  property mappers; Modify assets/cashflow queries, DI/routes/ARB;
  Test property calculator/repository/details/period tests.
- **Consumes:** `PropertyDraft`, `AssetValueCalculator.property`, valuation repository,
  `CashflowRepository.watch(CashflowFilter(propertyId:...))`.
- **Produces:** name+optional address+purchasePrice, market valuations, period cashflow
  income/expense/net, add income/expense prefill; отсутствие asset transaction CTA.
- **TDD:** пустой address→null; opening 5 млн + valuation 5.5 млн=5.5 млн; expense ремонт
  100 тыс. не меняет стоимость; месяц/год/all/custom фильтруют occurredOn включительно;
  propertyId не ссылается на account; доход аренда один раз в aggregate.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** details работает offline, нет yield до 12.3, нет tx kinds для property;
  общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/05.4: реализовать учёт недвижимости`.

## Этап 6 — Транзакции, переводы и аудит

### 6.1 Пополнение/снятие и связанная классификация — [x] (2026-11-18)

- **Приоритет/зависимости:** P1; после 5.3 и 4.3. **BR:** T-1…7,10, IE-1…6,16…17, VAL-5,7.
- **Files:** Create transactions data/logic + transaction form screen/VM,
  `save_asset_transaction.dart`; Modify cashflow commands implementation, DI/routes/ARB;
  Test `test/core/features/transactions/{data,logic,ui}/transaction_*_test.dart`,
  `test/core/features/cashflow/logic/linked_pair_test.dart`.
- **Consumes:** `AssetTransactionRepository.create/revise`, `CashflowCommands.saveFromAssetTransaction`,
  rate/category/asset repositories.
- **Produces:** deposit/withdrawal original+RUB snapshots, optional linked income/expense,
  revision pairs, negative balance rollback.
- **TDD:** deposit 100 USD×90=9000 RUB snapshot; withdrawal >balance выбрасывает
  negativeBalance и linked cashflow отсутствует; category kind mismatch/future date/zero
  reject; edit суммы обновляет обе projections и revisionNo; связь unique; double Save один call.
- **Рабочий план (2026-11-18):**
  - **Domain:** `AssetTransactionDraft.classification` (`CashflowKind` + categoryId) —
    только для счетов; deposit↔income, withdrawal↔expense.
  - **Data:** `AssetTransactionRepositoryImpl` поверх `AppDatabase`: create/revise/softDelete
    в одной DB-транзакции с `CashflowDao` (linked entry: `accountId`, `affectsBalance=true`,
    `assetTransactionId`, original/RUB snapshot из операции); find link по
    `assetTransactionId`; DAO `watchFiltered`, `reviseLinked`, `findLinked`; transfer-методы
    делегируют существующие DAO (UI — 6.2).
  - **Logic:** `save_asset_transaction.dart` — одна команда create/update/delete
    (классификация опциональна), amountRub через `MoneyMath`, kind/category validation.
  - **UI:** форма `/transactions/new` (актив счёт/инвестиция, kind deposit/withdrawal,
    сумма, дата, курс RUB/ЦБ/ручной, комментарий, опция «Доход/Расход» с категорией для
    счёта), VM с per-field ошибками и защитой от двойного Save; CTA с деталей счёта/инвестиции.
  - **Тесты:** USD 100×90 snapshot; withdrawal > balance → negativeBalance без cashflow;
    kind mismatch/zero/future; edit суммы обновляет обе проекции и revisionNo; повторный
    Save не дублирует; property запрещён; сбой cashflow откатывает tx+revision.
- **Генерация:** gen-l10n; build_runner/schema dump при DAO changes.
- **DoD:** property запрещён, amountRub округлён один раз, crash при cashflow insert откатывает
  asset tx+revision; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/06.1: добавить транзакции активов`.
- **Итог:** `AssetTransactionRepositoryImpl` (create/revise/softDelete в одной DB-транзакции
  с cashflow, transfer-методы делегируют DAO), `TransactionClassification` в draft,
  `CashflowDao` — `assetTransactionId`, `findLinked`, `reviseFromAsset`, `softDeleteFromAsset`;
  `watchFiltered` (период/актив/вид/валюта/поиск) для журнала 6.3; единый маппер операции.
  UI: форма `/transactions/new?assetId=&kind=` (актив, пополнение/снятие, сумма, дата, курс,
  комментарий, классификация доход/расход для счёта), кнопки «Пополнить/Снять» на деталях,
  защита от двойного Save, per-field ошибки. Тесты: USD 100×90 snapshot + linked entry,
  negative balance без cashflow, kind mismatch, zero/future, edit обеих проекций и ревизий,
  снятие классификации, добавление классификации через revise со связью, property, откат при
  сбое cashflow, форма/двойной Save, маршрут «Снять» = withdrawal. По ревью: CTA «Снять»
  передаёт вид операции, revise добавляет `assetTransactionId`, смена актива сбрасывает
  классификацию/курс, CTA операций только для счёта/инвестиции, блоки действий разведены.
- **Отложено:** UI журнала/фильтров/ревизий и transfer-форма — 6.2/6.3; итог в ₽ и
  доступный остаток на форме, CTA при пустых активах/категориях, вид актива в селекте,
  scroll-to-error после неудачного Save, классификация инвестиций (только счёт),
  визуальный QA 320dp/textScale 1.3 (эмулятор не подключён).

### 6.2 Внутренние переводы между счетами — [ ]

- **Приоритет/зависимости:** P1; после 6.1. **BR:** T-2,5…9, C-1…3, IE-1.
- **Files:** Create `transfer_assets.dart`, `transfer_form_screen.dart`,
  `transfer_form_view_model.dart`; Modify transaction repository/DAO/details/router/DI/ARB;
  Test transfer DB/VM/form/golden tests.
- **Consumes:** `TransferDraft(amount,destinationAmount,fromRateToRub,toRateToRub)`,
  `transfer`, `reviseTransfer`, `softDeleteTransfer`.
- **Produces:** same/cross-currency transfer с двумя ногами и transfer group, independent
  RUB snapshots, edit/delete pair only.
- **TDD:** RUB 1000→RUB 1000 создаёт out/in и zero cashflow; USD 10→EUR 9 при 90/100;
  same account/zero/negative reject; insufficient source откатывает группу+обе ноги+revisions;
  одиночный revise/softDelete leg conflict; reviseTransfer меняет обе суммы/дату атомарно.
- **Генерация:** gen-l10n; schema dump при изменении DAO source.
- **DoD:** active unique `(transferId,kind)`, обе ноги имеют равные occurredOn/comment,
  журнал cashflow пуст; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/06.2: реализовать переводы между счетами`.

### 6.3 Журнал, details, revisions и мягкое удаление — [ ]

- **Приоритет/зависимости:** P1; после 6.2. **BR:** T-3…4,8…9, S-2…5, IE-11…15.
- **Files:** Create transactions state/list/filter, transaction details screen/VM,
  audit data/ui files, `revision_diff.dart`; Modify transactions screen/VM, repositories/
  routes/DI/ARB; Test journal filters/details/revisions/diff/delete/audit screens.
- **Consumes:** watch(TransactionFilter), getById, AuditRepository watch revisions,
  softDelete/reviseTransfer.
- **Produces:** grouped lazy journal, filters, original/RUB/base details, append-only audit,
  soft delete hidden everywhere кроме audit.
- **TDD:** period/asset/kind/currency/query комбинируются; delete создаёт revision+deletedAt,
  list итогов обновляется; revision 1 неизменна, diff edit показывает old/new; deleted details
  обычный route NotFound, audit route доступен; Restore отсутствует.
- **Генерация:** gen-l10n; generated DB при DAO changes.
- **DoD:** deleted не входит balances/net worth/cashflow; transfer audit содержит обе ноги;
  общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/06.3: добавить журнал и аудит транзакций`.

## Этап 7 — Доходы, расходы и связь со счетами

### 7.1 Cashflow CRUD без влияния на баланс — [ ]

- **Приоритет/зависимости:** P1; после 4.3 и 6.3. **BR:** IE-1…7,10,12, CAT-8, VAL-5,7.
- **Files:** Create cashflow data/logic + form/details screens/VM,
  `cashflow_commands.dart`, `cashflow_calculator.dart`; Modify DI/routes/ARB;
  Test `test/core/features/cashflow/{domain,data,logic,ui}/cashflow_*_test.dart`.
- **Consumes:** `CashflowEntryDraft`, `CashflowRepository.create/getById/revise`,
  `CashflowCommands.save`, categories/rates.
- **Produces:** income/expense original+RUB snapshots, comments, category validation,
  revisions/delete и affectsBalance=false по умолчанию без account.
- **TDD:** Salary 100000 RUB → income; Food 250.50 RUB expense; kind/category mismatch,
  zero/future/archived category reject; empty comment→null; edit revision increment;
  без account никогда не создаётся asset tx.
- **Генерация:** gen-l10n; build_runner/schema dump при DAO changes.
- **DoD:** amountRub=original×rate, current journal only active, errors локализованы;
  общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/07.1: реализовать доходы и расходы`.

### 7.2 Явная связь денежного потока со счётом — [ ]

- **Приоритет/зависимости:** P1; после 7.1. **BR:** IE-8…17, VAL-7, T-3…4.
- **Files:** Modify `cashflow_commands.dart`, linked repository implementations,
  cashflow form VM/sections, transaction repository/DI/ARB;
  Test `linked_pair_test.dart`, `cashflow_form_view_model_test.dart`, DB rollback tests.
- **Consumes:** `createLinked`, `save/saveFromAssetTransaction/delete`, account repository.
- **Produces:** affectsBalance requires account, income→deposit/expense→withdrawal,
  atomic create/edit/delete/off→on/on→off lifecycle.
- **TDD:** expense 100 при balance 99 откатывает обе записи; off→on создаёт новую tx и
  edit cashflow; on→off soft-deletes tx и обнуляет link новой revision; delete пары создаёт
  delete revisions обеим; manual unlink запрещён; double tap не создаёт две tx.
- **Генерация:** gen-l10n; DB generation при source changes.
- **DoD:** единственный FK cashflow.assetTransactionId, derived reverse join, итоги не
  дублируются; все TX-LINKED-SAVE cases pass; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/07.2: связать расходы и доходы со счетами`.

### 7.3 Журнал денежного потока и фильтры — [ ]

- **Приоритет/зависимости:** P1; после 7.2. **BR:** IE-10…15, S-2…5, RE-3.
- **Files:** Create cashflow state/list/filter sheet; Modify cashflow screen/VM/details,
  operations host, analytics query sources, routes/DI/ARB;
  Test cashflow journal/filter/summary/details/deleted widget+DB tests.
- **Consumes:** `watch(CashflowFilter)`, `CashflowCalculator.summarize`, audit repository.
- **Produces:** date groups, period/kind/category/currency/property/account/query filters,
  summary из cashflow only, soft-deleted audit path.
- **TDD:** transfer и deposit без cashflow не попадают; связанный expense попадает один раз;
  account filter показывает affectsBalance entries; deleted скрыт, summary уменьшается;
  empty filtered Reset восстанавливает; date end inclusive.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** фильтры не мутируют глобально другой tab, large list lazy, accessible amounts;
  общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/07.3: добавить журнал денежного потока`.

### 7.4 Операции квартиры end-to-end — [ ]

- **Приоритет/зависимости:** P1; после 5.4 и 7.3. **BR:** RE-1…5,7, IE-3,10,13.
- **Files:** Modify property details/cashflow form/list/analytics mappers, routes/DI/ARB;
  Create `test/core/features/assets/ui/property_cashflow_test.dart`,
  `integration_test/cashflow_flow_test.dart` property scenario.
- **Consumes:** prefill `propertyId`, typed expense categories, property details period VM.
- **Produces:** add rent income/maintenance expense из property, возврат в details,
  общий journal filters и сохранение рыночной стоимости.
- **TDD:** property prefill несовместим accountId; maintenance 10k обновляет expense/net,
  valuation unchanged; «Аренда» income и «Аренда жилья» expense различны; deletion обновляет
  property+global summaries одной командой; invalid property id inline NotFound.
- **Генерация:** gen-l10n; e2e не запускать без вопроса перед PR.
- **DoD:** нет автоматического изменения стоимости/второй asset tx, property periods совпадают
  с global aggregate; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/07.4: завершить денежный поток недвижимости`.

## Этап 8 — Финансовые цели

### 8.1 Цели и явная привязка активов — [ ]

- **Приоритет/зависимости:** P1; после 5.3. **BR:** G-1…7, VAL-3,7.
- **Files:** Create goals data/logic/ui из file_structure, включая `save_goal.dart`,
  goal form/details; Modify goal DAO/repository, DI/routes/ARB;
  Test `test/core/features/goals/{data,logic,ui}/goal_*_test.dart`.
- **Consumes:** `GoalDraft`, `GoalRepository.watchAll/getById/create/update/setStatus/
  softDelete`, eligible account/investment streams.
- **Produces:** target Money/date, category accounts|investments, non-empty assetIds,
  active/achieved/closed statuses, multi-select и archived badges.
- **TDD:** accounts goal принимает два account, отклоняет investment/property; investments
  наоборот; empty assetIds/target 0 reject; archive linked asset сохраняет связь и badge;
  close не удаляет goal; soft delete скрывает из default watch.
- **Генерация:** gen-l10n; build_runner/schema dump при DAO source changes.
- **DoD:** goal_assets PK и kind constraints проверены DB, closed не вычисляется автоматически
  обратно в active; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/08.1: добавить финансовые цели`.

### 8.2 Автоматический прогресс и monthly contribution — [ ]

- **Приоритет/зависимости:** P1; после 8.1. **BR:** G-2…6, C-5…6.
- **Files:** Create `goal_calculator.dart`, `calculate_goal_progress.dart`, goals state и
  details progress widgets; Modify goals screen/VM, asset value conversion/DI/ARB;
  Test `goal_calculator_test.dart`, goals progress screen tests, CALC goal cases.
- **Consumes:** `GoalCalculator.calculate(goal,assetValues,today)`, `GoalProgress`,
  current asset values и base currency converter.
- **Produces:** progress/deficit/surplus/completionRatio/monthlyContribution, auto achieved,
  список active/achieved/closed.
- **TDD:** target 100000, values 30000+20000=50000, deficit 50000, ratio .5;
  120000 → surplus 20000, achieved, visual ratio clamp 1; zero target запрещён формой;
  deadline уже наступил и deficit>0 → monthlyContribution=null; closed остаётся closed;
  разные currencies складываются только после conversion.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** нет infinity/NaN, >100% текст сохранён, изменение asset stream обновляет прогресс;
  общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/08.2: рассчитать прогресс целей`.

## Этап 9 — Аналитика и графики

### 9.1 Net worth в выбранной базовой валюте — [ ]

- **Приоритет/зависимости:** P1; после 5.4, 6.3 и 8.2. **BR:** S-1…5, C-5…6, A-6.
- **Files:** Create analytics data/logic `analytics_queries.dart`,
  `net_worth_summary.dart`, `analytics_queries_impl.dart`, `analytics_mappers.dart`;
  Modify DI/repositories/ARB; Test `test/core/features/analytics/{data,logic}/net_worth_test.dart`.
- **Consumes:** `AnalyticsQueries.netWorth(LocalDate)`, AssetValueCalculator, dated rates,
  SettingsRepository.watchBaseCurrency.
- **Produces:** total+byAssetKind Money, RUB snapshot conversion A→RUB→base, archive cutoff.
- **TDD:** account RUB 1000 + investment USD 10×90=900 RUB + property EUR 2×100=200 EUR:
  RUB total=20900 RUB, EUR total=209 EUR; отсутствие base rate → rateUnavailable, не zero;
  archived до даты включается/после исключается по A-6; deleted tx не участвует.
- **Генерация:** l10n для errors; DB schema не меняется.
- **DoD:** Dashboard/Analytics вызывают один query, нет cashflow double count, Decimal
  округление один раз на итог согласно calculations; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/09.1: рассчитать совокупную стоимость`.

### 9.2 История стоимости и серия графика — [ ]

- **Приоритет/зависимости:** P1; после 9.1. **BR:** S-2…5, A-3,4,6,7, C-5.
- **Files:** Create `build_net_worth_series.dart`, `net_worth_chart_section.dart`,
  analytics screen/state/VM; Modify analytics queries/router/DI/ARB;
  Test net worth series boundaries/archive/valuation/order tests и chart section tests.
- **Consumes:** `netWorthSeries(period,assetKind)`, `NetWorthPoint`, chart contracts.
- **Produces:** dated historical reconstruction из transactions/valuations, line chart,
  accessible point list, period/kind filters.
- **TDD:** операция внутри дня применяется к точке даты; оценка заменяет прошлый accumulated
  investment только с effectiveOn; archived asset остаётся в прошлых точках; range start/end
  inclusive; empty period→empty, single point finite, deleted revisions влияют по текущей
  истории согласно calculations, без случайного ORDER BY.
- **Генерация:** gen-l10n; generated DB при query source changes.
- **DoD:** chart values и text table равны, deterministic today явно передан; общий DoD.
  Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/09.2: построить историю стоимости`.

### 9.3 Cashflow aggregates по периодам и категориям — [ ]

- **Приоритет/зависимости:** P1; после 7.4 и 9.1. **BR:** IE-10…15, RE-3…5, C-5.
- **Files:** Create `cashflow_period_point.dart`, `cashflow_analytics.dart`,
  `cashflow_chart_section.dart`; Modify analytics queries/DAO/DI/ARB;
  Test `test/core/features/analytics/{data,logic}/cashflow_analytics_test.dart`.
- **Consumes:** `cashflow`, `cashflowByCategory`, `cashflowSeries`, CashflowFilter.
- **Produces:** income/expense/net, category totals, month/year/custom period points только
  из active cashflow entries и base currency.
- **TDD:** income 1000 expense 250→net750; linked expense учитывается один раз, transfer/
  standalone deposit не учитывается; archived category сохраняет historical label; property
  filter совпадает с details; deleted excluded; разные currencies через dated RUB→base.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** нет SQL double сумм, период inclusive, empty category/chart не показывает нули
  как существующие операции; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/09.3: добавить аналитику денежного потока`.

### 9.4 Экран аналитики и доступные графики — [ ]

- **Приоритет/зависимости:** P1; после 9.2 и 9.3. **BR:** S-1…5, IE-13, DESIGN charts.
- **Files:** Modify `analytics_screen.dart`, `analytics_view_model.dart`,
  `analytics_state.dart`, two chart sections, routes/DI/ARB;
  Test `test/core/features/analytics/ui/analytics_screen_test.dart`,
  `integration_test/analytics_flow_test.dart`.
- **Consumes:** AnalyticsQueries всех методов, AppLineChart/AppCashflowChart, base currency.
- **Produces:** единый period/filter state, line+grouped bars, exact tooltips, text alternative,
  loading/empty/error/offline/no-rate states.
- **TDD:** switching account→investment сохраняет period, сбрасывает несовместимый filter;
  category selection обновляет summary+chart; unavailable rate показывает error без подмены
  нулём; large values finite; 320dp/1.3 text list доступен и совпадает с tooltip.
- **Генерация:** gen-l10n; e2e только после вопроса.
- **DoD:** нет самостоятельных вычислений в View, analytics и Dashboard totals совпадают;
  общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/09.4: реализовать экран аналитики`.

## Этап 10 — Dashboard, настройки, backup и updates

### 10.1 Dashboard с реальными итогами и quick actions — [ ]

- **Приоритет/зависимости:** P1; после 9.4. **BR:** S-1…5, G-2…6, IE-13.
- **Files:** Modify dashboard screen/VM/state; Create widgets `{dashboard_net_worth,dashboard_goals,
  dashboard_recent_operations}.dart`; Modify root router/DI/ARB/test app;
  Test `test/core/features/dashboard/ui/dashboard_screen_test.dart`.
- **Consumes:** AnalyticsQueries.netWorth/cashflow, GoalRepository/progress, операции watch.
- **Produces:** net worth, quick add, goals, recent operations и базовая валюта на `/`.
- **TDD:** пустая БД показывает нулевые totals+create CTA, не демо; новая связанная expense
  обновляет cashflow и account/net worth без двойного вычета; quick income/expense/transfer
  имеют корректный prefill; goal achieved status совпадает с GoalsScreen.
- **Генерация:** gen-l10n; DB schema не меняется.
- **DoD:** streams dispose, refresh после import/edit работает, expanded две колонки и compact
  одна без overflow; общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/10.1: реализовать главный экран`.

### 10.2 Dashboard cashflow и единые переходы в аналитику — [ ]

- **Приоритет/зависимости:** P1; после 10.1. **BR:** IE-10…15, S-1…5.
- **Files:** Create `dashboard_cashflow.dart`; Modify dashboard VM/state/screen, analytics
  prefill/routes/ARB; Test dashboard cashflow widget+navigation tests.
- **Consumes:** current month CashflowSummary/series и CashflowFilter.
- **Produces:** income/expense/net месяца, compact chart/summary, переход в Analytics с тем
  же периодом и базовой валютой.
- **TDD:** месяц вычисляется от injected today; first/last day inclusive; transfer не меняет
  widget; tap сохраняет period/filter; empty month CTA ведёт add expense/income, а не рисует
  фиктивный chart.
- **Генерация:** gen-l10n.
- **DoD:** Dashboard, journal, property и analytics используют одинаковые entries/rounding;
  общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/10.2: добавить виджет денежного потока`.

### 10.3 Настройки, справочники и базовая валюта — [ ]

- **Приоритет/зависимости:** P1; после 10.2. **BR:** C-4…6.
- **Files:** Create settings repository impl/domain/logic, `settings_screen.dart`,
  `settings_view_model.dart`, `about_screen.dart`, `about_view_model.dart`;
  Modify `more_screen.dart`, `more_view_model.dart`, DI/routes/ARB;
  Test settings/more/about screens и settings repository tests.
- **Consumes:** `SettingsRepository.watchBaseCurrency/getBaseCurrency/setBaseCurrency`,
  CurrencyRepository, named routes.
- **Produces:** More tiles, Settings «Отчёты», выбранная base currency, app info;
  секции backup/update добавляются 10.4/10.5 в этот же screen без переписывания VM.
- **TDD:** set USD enabled обновляет Dashboard/Analytics, RUB audit snapshots unchanged;
  used/disabled base conflict; More ведёт categories/subgroups/currencies/audit/about;
  About показывает «Версия появится после подключения сведений о пакете» до 10.5.
- **Генерация:** gen-l10n.
- **DoD:** offline settings доступны, font 1.3/dark/long text pass; общий DoD/design review.
  Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/10.3: реализовать экран настроек`.

### 10.4 SQLite export/share/save/import с rollback — [ ]

- **Приоритет/зависимости:** P1; после 10.3 и 3.2. **BR:** BU-1…6.
- **Files:** Create `lib/app/app_restart.dart`, backup domain/data/logic files и
  `settings/ui/widgets/backup_section.dart` из backup_and_updates §3;
  Modify `app_database.dart`, `app_database_path.dart`, `service_locator.dart`,
  `register_core_services.dart`, `main.dart`, `app/app.dart`, settings screen,
  `MainActivity.kt`, `AndroidManifest.xml`, `pubspec.yaml`, lock, ARB;
  Test `test/core/features/backup/{data/local_database_backup_service_test,
  logic/backup_view_model_test}.dart`, `settings/ui/backup_section_test.dart`,
  `test/core/database/import_identity_test.dart`, `integration_test/backup_flow_test.dart`.
- **Consumes:** BackupService/BackupFileGateway, `VACUUM INTO`, AppDatabase application_id,
  SAF channel `com.example.finanseapp/file_saver`, restart tick.
- **Produces:** consistent export, system share/SAF save, validated candidate import,
  migrations, rollback snapshot, DI/router rebuild и restart dialog.
- **TDD:** failing wrong magic/empty/corrupt/other app/FK/new schema оставляют marker доступным;
  valid export содержит marker+revisions; valid import заменяет marker; injected candidate
  migration/final rename/reopen failures дают `importFailed`, восстанавливают старую БД и
  вызывают onRollback. Отдельные rollback/rollback-reopen failures дают `restoreFailed`,
  сохраняют rollback-файл, блокируют actions и не утверждают восстановление прежней БД.
  Share dismissed → `shareCancelled` без error, unavailable → `shareResultUnknown` без error;
  exception/unsupported platform → `exportFailed`; save/pick cancel нейтральны, double tap
  один service call; затем реализовать по §5–8.
- **Генерация:** `flutter pub get`, `flutter gen-l10n`, build_runner+schema dump при изменении
  AppDatabase source; Android SAF сценарий проверить на устройстве отдельно.
- **DoD:** donor workout/sound/notification отсутствует; broad storage permission отсутствует;
  failed import не пересоздаёт успешно новый UI, success требует restart и восстанавливает
  все streams; rollback/reopen tests реальные temp SQLite. Widget Semantics различает отмену
  share, неизвестный результат отправки, подтверждённый rollback и blocking rollback failure;
  при последнем backup actions
  disabled, повторный tap не очищает состояние; общий DoD/design review.
  Перед PR спросить о e2e, включая backup_flow.
- **Предлагаемый commit:** `task/10.4: добавить резервное копирование БД`.

### 10.5 Проверка обновлений через GitHub Releases — [ ]

- **Приоритет/зависимости:** P1; после 10.3. **BR:** UP-1…3.
- **Files:** Create settings `domain/{update_service,app_version}.dart`,
  `data/github_update_service.dart`, `logic/update_check_view_model.dart`,
  `ui/widgets/update_section.dart`; Modify settings/about screens, DI, Manifest, pubspec+lock,
  ARB, `.github/workflows/release.yml` для asset name;
  Test `test/core/features/settings/{domain/app_version_test,data/github_update_service_test,
  logic/update_check_view_model_test,ui/update_section_test}.dart`.
- **Consumes:** ReleaseInfo/UpdateService/AppVersion, PackageInfo, url_launcher,
  API/APK URLs из backup_and_updates §9.
- **Produces:** installed version, manual latest check, statuses, update dialog,
  HTTPS external APK и release page fallback.
- **TDD:** `1.0.10>1.0.9`, same/older/beta/malformed; 404 noReleases, 500/timeout/offline,
  invalid JSON/tag/version; double check один call; APK launch failure→release page,
  обе failure→openFailed; `javascript:`/HTTP reject; затем service+VM+UI.
- **Генерация:** pub get, gen-l10n; Drift не меняется. Manifest получает INTERNET/VIEW https,
  но не REQUEST_INSTALL_PACKAGES.
- **DoD:** offline Dashboard не затронут, release workflow публикует `app-release.apk`,
  production GitHub проверка описана manual, unit tests не ходят в сеть; общий DoD/design
  review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/10.5: добавить проверку обновлений`.

### 10.6 Подпись release APK временным ключом — [x] 2026-11-16

- **Приоритет/зависимости:** P1; без зависимостей — нужна для тестирования release-сборок
  на реальном устройстве. **BR:** нет (инфраструктура сборки).
- **Files:** Create `android/key.properties` (с дисклеймером TEMP_KEY) и
  `android/app/upload-keystore.jks`; Modify `android/app/build.gradle.kts` (загрузка
  key.properties с фолбэком на debug при отсутствии, `signingConfigs.release`,
  `buildTypes.release.signingConfig`), `.gitignore` и `android/.gitignore` (убрать
  исключения `key.properties`/`*.jks` с комментарием об осознанном решении MVP),
  `.github/workflows/ci.yml` (`flutter build apk --debug` → `--release`, artifact
  `app-release.apk`).
- **Consumes:** keystore из keytool (RSA 2048, validity 10000, alias `upload`,
  storePassword=keyPassword — ограничение PKCS12); образец — донорский проект fitnessappai
  (задача 48.6): оба файла лежат в git, ключ — «несекрет», заменяется перед Google Play.
- **Produces:** подписанный release APK, устанавливаемый на реальное устройство;
  SHA-256 отпечаток ключа записан в этой секции; CI-гейт реально проверяет подпись.
- **Отпечаток TEMP_KEY (SHA-256):**
  `F2:C9:B7:BC:28:CD:60:A9:26:3D:23:3F:58:D0:12:E6:6A:FE:E5:5E:5B:F0:27:F2:05:4B:92:F6:72:66:05:CA`
  (alias `upload`, validity до 2054-04-03). При замене ключа — обновить здесь.
- **TDD:** не применимо (Dart-кода нет). Проверки: `flutter build apk --release`
  собирается и подписывается; `apksigner verify --print-certs` показывает alias `upload`;
  временное удаление `key.properties` → сборка откатывается на debug без ошибки.
- **DoD:** дисклеймер «заменить перед публикацией в Google Play» в key.properties;
  отпечаток SHA-256 в секции; общий DoD (format, оба analyze, flutter test,
  `git diff --check`); design review не требуется (UI нет).
- **Предлагаемый commit:** `task/10.6: подписать release-сборку временным ключом`.

## Этап 11 — Сквозное качество и release readiness

### 11.1 Golden calculations и проверка покрытия каждого BR — [ ]

- **Приоритет/зависимости:** P1; после 10.5. **BR:** все.
- **Files:** Create дополнения `test/core/domain/common/golden_calculations_test.dart`,
  `test/architecture/business_rule_coverage_test.dart`, fixtures для rollback/audit;
  Modify `docs/architecture/business_rules.md` только при найденном несоответствии;
  Test весь unit/widget suite.
- **Consumes:** CALC-001…036, матрица business_rules §14, публичные contracts.
- **Produces:** автоматический тест наличия task/test mapping для каждого BR ID и буквальные
  golden assertions независимо от production algorithm.
- **TDD:** временный missing BR mapping должен падать с именем ID; каждая формула получает
  минимум positive+boundary case; удалённая ревизия/transfer/cross-rate/forecast covered;
  затем восстановить mapping и прогнать suite.
- **Генерация:** не требуется, если contracts не менялись; любое изменение поведения начинается
  с BR doc и отдельного failing regression test.
- **DoD:** self-review подтверждает каждый BR кодом+тестом, нет тестов, вычисляющих expected
  той же функцией; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/11.1: проверить покрытие бизнес-правил`.

### 11.2 End-to-end критических потоков, включая backup — [ ]

- **Приоритет/зависимости:** P1; после 11.1. **BR:** T/IE/G/S/BU/UP.
- **Files:** Create `integration_test/{helpers/test_app,assets_flow_test,transactions_flow_test,
  cashflow_flow_test,goals_flow_test,analytics_flow_test,backup_flow_test,settings_flow_test}.dart`;
  Modify `integration_test/app_test.dart`, TEST_PLAN append через android-tester;
  Test Linux integration после разрешения владельца + Android manual checklist.
- **Consumes:** реальные routes/repositories, temp AppDatabase, fake CBR/GitHub/platform
  gateways, deterministic clock.
- **Produces:** e2e create account→tx→transfer→linked expense→goal→analytics; export/change/
  import/restart; invalid backup non-destructive; settings update states.
- **TDD:** каждый flow сначала фиксирует воспроизводимый дефицит сценария; marker revision
  проверяется после restart, failed import оставляет новые данные, UI не использует сеть;
  затем исправить найденное отдельным regression unit test и повторить flow.
- **Генерация:** gen-l10n/build_runner по фактическим source changes.
- **DoD:** все критические flows зелёные на Linux при разрешённом запуске; Android SAF/APK
  manual результаты записаны в TEST_PLAN; недоступные проверки явно названы, не «passed»;
  общий DoD. Перед PR вопрос об e2e обязателен даже после выполнения.
- **Предлагаемый commit:** `task/11.2: добавить сквозные финансовые сценарии`.

### 11.3 Accessibility, производительность и устойчивость — [ ]

- **Приоритет/зависимости:** P1; после 11.2. **BR:** VAL-7, DESIGN/a11y, S-1…5.
- **Files:** Create `test/accessibility/app_accessibility_test.dart`,
  `test/performance/journal_performance_test.dart`, profiling fixtures;
  Modify только компоненты с подтверждёнными findings, DESIGN/UIKit contracts при API change;
  Test semantics/contrast/overflow/large dataset.
- **Consumes:** patterns matrix, 48dp/WCAG/font1.3, lazy journals/chart alternatives.
- **Produces:** accessibility fixes, measured rendering budget, bounded queries и отсутствие
  disposed stream callbacks.
- **TDD:** 320dp+1.3+long Russian каждый route; TalkBack labels для icon actions/errors/
  charts/import; 10k transactions list builder не создаёт 10k widgets, aggregate query bounded;
  repeated edit/delete не вызывает setState after dispose; animations disabled.
- **Генерация:** по изменённым источникам; profiling output не коммитить.
- **DoD:** нет overflow/critical semantics findings, замеры и устройство записаны, baseline
  и фактические frame/build counts приложены к PR; общий DoD/design review. Перед PR спросить
  о e2e.
- **Предлагаемый commit:** `task/11.3: усилить доступность и производительность`.

### 11.4 Release readiness и документация v1 — [ ]

- **Приоритет/зависимости:** P1; после 11.3. **BR:** все release-blocking.
- **Files:** Modify README, docs/PROJECT, TEST_PLAN, `.github/workflows/release.yml`;
  Test CI gates и debug/release APK по workflow.
- **Consumes:** фактические результаты tests/e2e/manual QA, `app-release.apk` update contract.
- **Produces:** актуальные setup/backup/update/migration docs, известные ограничения,
  release candidate без placeholder instructions.
- **TDD/checklist:** чистый checkout pub get/generate → format/analyze/test/build; проверить
  versionName/tag/APK filename, restore backup текущей schema, update URL; plan-review перед
  релизом. Найденный дефект получает failing test до fix.
- **Генерация:** сверить generated diff чист после повторной генерации.
- **DoD:** plan-review пройден; перед тегом отдельно спросить владельца о полном QA
  android-tester (~час); релизный тег/публикация только по явному запросу, не молча.
  Перед PR спросить об e2e.
- **Предлагаемый commit:** `task/11.4: подготовить релизную документацию`.

## Этап 12 — Расширения после v1

### 12.1 Восстановление soft-deleted операций — [ ]

- **Приоритет/зависимости:** P2; после 11.4, отдельное согласование UX. **BR:** T-3…4,
  IE-15, S-4.
- **Files:** Create restore use cases/UI actions и `test/**/restore_*_test.dart` в существующих
  transactions/cashflow/audit paths; Modify domain repositories, DAO, audit screens/ARB/DI.
- **Consumes:** RevisionAction.restore, deleted current projections и linked transfer pairs.
- **Produces:** restore с новым snapshot/revisionNo, повторная проверка balances/references,
  атомарное восстановление связанных пар.
- **TDD:** restore delete revision создаёт новую restore, не изменяет историю; insufficient
  balance/archived asset отклоняет; transfer восстанавливает две ноги, cashflow pair обе
  записи; повторный restore conflict.
- **DoD:** до согласования не реализовывать; при реализации BR docs обновлены, migrations/
  generated и общий DoD pass. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.1: восстановить удалённые операции`.

### 12.2 Сравнение активов — [ ]

- **Приоритет/зависимости:** P2; после 11.4. **BR:** S-2…5, C-5.
- **Files:** Create comparison domain/query/screen/VM/chart section и unit/widget/integration
  tests в analytics paths; Modify routes/DI/ARB/navigation docs.
- **Consumes:** netWorthSeries и asset selection.
- **Produces:** выбор 2–5 активов, общий period/base currency, normalized/absolute режим,
  accessible comparison table.
- **TDD:** разные валюты/даты, missing valuation, archived asset, empty overlap, >5 reject;
  line labels и text values совпадают.
- **DoD:** normalized режим явно подписан и не смешан с Money totals; общий DoD/design review.
  Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.2: добавить сравнение активов`.

### 12.3 Доходность недвижимости за 12 месяцев — [ ]

- **Приоритет/зависимости:** P2; после 11.4. **BR:** RE-6.
- **Files:** Create property yield calculator/presentation section и tests; Modify property
  details VM/screen/ARB/calculations doc.
- **Consumes:** trailing 12-month cashflow и latest property valuation.
- **Produces:** gross/net yield, оценочность и null при zero current value.
- **TDD:** annual rent 120000/value 5m → gross 2.4%; expenses 20000→net 2.0%; exact 12-month
  boundaries; zero value→null; valuation repair cashflow не меняет.
- **DoD:** формулы и golden values добавлены до кода, нет обещания инвестиционной рекомендации;
  общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.3: рассчитать доходность недвижимости`.

### 12.4 Онбординг и первичный сценарий — [ ]

- **Приоритет/зависимости:** P2; после 11.4. **BR:** A-1, C-5, IE-1…3, accessibility.
- **Files:** Create onboarding domain persistence/screens/VM и tests; Modify app start/router/
  DI/ARB/navigation docs; Test first launch/complete/skip/restart.
- **Consumes:** app_settings versioned onboarding flag и реальные create asset/operation flows.
- **Produces:** короткое объяснение original currency/backup/privacy, выбор base currency,
  первый asset CTA, skip и отсутствие повторного показа.
- **TDD:** fresh DB показывает один раз; skip/complete сохраняется; import backup переносит
  флаг; offline работает; font1.3/TalkBack/back не ловят пользователя.
- **DoD:** не создаёт демо-активы и не запрашивает сеть/аккаунт; общий DoD/design review.
  Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.4: добавить первичный онбординг`.

### 12.5 App lock: PIN-код и биометрия — [x] 2026-11-17

- **Приоритет/зависимости:** P2 (можно поднять — финансовые данные); реализуется сразу
  после 3.4 (в main). Зависимость от 10.3 снята решением ниже. **BR:** BR-Sec — описаны
  в `business_rules.md` §14 до кода.
- **Решения (зафиксированы до кода):**
  - `app_settings` (10.3) в коде ещё нет → флаги защиты (biometric, auto-lock, счётчик
    попыток, lockoutUntil) хранятся рядом с хэшем в secure storage. При появлении 10.3
    миграция настроек — отдельная задача.
  - Overlay-блокировка (не guard go_router): `AppLockGate` в `builder` у
    `MaterialApp.router` — работает над любым текущим маршрутом и не требует 3.5.
  - Точка входа управления защитой — демо-секция Home (экран настроек появится в 10.3,
    entry перенесётся туда).
  - Пакет хэширования — `crypto` (PBKDF2-HMAC-SHA256, per-PIN salt); зафиксировано
    в `docs/PROJECT.md`.
- **Files:** Create `lib/core/features/applock/{domain,data,logic,ui}/…` (pin value,
  hasher, сервис попыток, secure storage gateway, biometric gateway, контроллер и VM,
  экран блокировки, manage-экран, keypad/dots, `AppLockGate`), `lib/app/routes.dart`;
  Modify pubspec + lock (`local_auth`, `flutter_secure_storage`, `crypto`), DI, router,
  `app.dart`, Home (entry), `AndroidManifest.xml` + `MainActivity.kt`
  (`FlutterFragmentActivity`, `USE_BIOMETRIC`), `lib/l10n/app_ru.arb`, BR docs,
  навигационные docs, `docs/PROJECT.md`; Test `test/core/features/applock/…` unit + widget.
- **Consumes:** `local_auth` (биометрия; на Linux/desktop — graceful fallback на PIN),
  `flutter_secure_storage` (хранилище хэша PIN и флагов, вне БД — backup/import их не
  переносит), `crypto` (PBKDF2-хэш), AppLifecycle (блокировка на cold start и при
  возврате из фона), uikit-компоненты 3.4.
- **Produces:** PIN 4–6 цифр с подтверждением при включении; отключение только по PIN;
  опциональная биометрия с fallback на PIN при недоступности/отмене; политика попыток
  (5 неудачных → блокировка с экспоненциальной задержкой); настройка auto-lock
  (сразу / через N минут в фоне); экран блокировки на uikit-компонентах.
- **TDD:** salted hash/verify (включая wrong PIN); 5 неверных → lockout-задержка;
  biometric unavailable/cancelled → fallback на PIN; fresh install → lock выключен;
  backup import не восстанавливает хэш (secure storage вне БД); back из экрана блокировки
  не обходит защиту; затем service+VM+UI.
- **Генерация:** pub get; Drift не меняется (хэш и флаги — в secure storage); gen-l10n.
- **DoD:** хэш PIN никогда не в Drift/логах; биометрия за интерфейсом (fake в тестах,
  Linux/CI не падает); общий DoD/design review (UI-задача). Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.5: добавить защиту входа PIN-кодом и биометрией`.
