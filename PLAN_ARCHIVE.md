# PLAN_ARCHIVE.md — архив завершённых этапов

Сюда `release-manager` переносит завершённые этапы из `PLAN.md` после релиза,
сохраняя индексы и нумерацию задач.

Перенесено: этапы 1–13 (2026-11-21, релиз `v0.1.1`).
Перенесено: этапы 14–15 (2026-11-22, релиз `v0.1.2`).
Перенесено: этапы 16–20 (2026-11-23, релиз `v0.9.0`).
Перенесено: этап 21 (2026-11-27, релиз `v0.10.0`).

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

### 5.4 Квартиры: стоимость, оценки и денежный поток — [x] (2026-11-19)

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
- **Итог:** repository create/update квартиры (адрес/цена покупки, currency lock),
  PropertyDetails в snapshot (одиночный и батч), пустой адрес→null; форма квартиры
  (название/адрес/цена/стоимость/валюта) и маршруты new/edit; details переиспользует
  текущую стоимость, оценки и добавление оценки, edit/archive/delete; секция денежного
  потока по квартире (месяц/год/всё, income/expense/net в RUB) с CTA дохода/расхода,
  `propertyId` в форме cashflow и маршруте; выбор «Квартира» в создании актива.
  Тесты: property snapshot/create/update/clear, cashflow→propertyId/фильтр, счёт в
  propertyId отклоняется; полный набор 384.
- **Отложено:** yield/аналитика (12.3), график cashflow квартиры, inline-ошибки/визуальный QA.

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

### 6.2 Внутренние переводы между счетами — [x] (2026-11-18)

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
- **Рабочий план (2026-11-18):**
  - **Data:** transfer-методы `AssetTransactionRepositoryImpl` уже делегируют DAO (6.1);
    добавить repository-тесты snapshot/отката.
  - **UI:** `TransferFormScreen`/VM: счёт-источник и назначение, сумма, сумма зачисления
    для разных валют, дата, комментарий; курсы через `ResolveExchangeRate` на дату;
    same-currency — сумма зачисления равна исходной; CTA «Перевести» на деталях счёта.
  - **Тесты:** same/cross-currency drafts, same account/zero/future reject, negative balance,
    успешный перевод двигает оба баланса и не создаёт cashflow.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** active unique `(transferId,kind)`, обе ноги имеют равные occurredOn/comment,
  журнал cashflow пуст; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/06.2: реализовать переводы между счетами`.
- **Итог:** `TransferFormViewModel` (счета, same/cross-currency, курсы через
  `ResolveExchangeRate`, запрет одинаковых счетов/нуля/будущей даты), `TransferFormScreen`
  (счёт-источник/назначение, суммы, дата, комментарий), маршрут
  `/transactions/transfer/new?fromId=`, CTA «Перевести» на деталях счёта. Repository-тесты:
  перевод двигает оба баланса, не создаёт cashflow, две ноги одной группы с равной датой,
  одинаковые счета/нехватка средств откатываются; VM/UI-тесты same/cross-currency,
  отрицательный баланс, сохранение формы, zero/future, кросс-валютные RUB snapshot (USD 10×90
  = EUR 9×100). По ревью: empty state с CTA «Добавить счёт» при <2 счётах, подсказка курса
  по введённым суммам, источник исключён из «На счёт», сброс суммы зачисления при смене
  счетов, ошибки баланса/курса/зачисления привязаны к полям, заголовок секции — названия
  счетов, CTA «Перевести» с иконкой и отступом, курс через `Rational`+`MoneyFormatter`
  (запятая, символы, обратное направление при курсе < 1: unit в валюте подписи), проверка
  устаревшего `fromId`, сообщение суммы зачисления на своём поле; widget-тесты подсказки
  в обе стороны.
- **Отложено:** UI журнала/ревизий перевода и удаление пары — 6.3; ручные курсы для
  перевода и доступный остаток на форме; консолидация ключей ошибок перевода;
  визуальный QA.

### 6.3 Журнал, details, revisions и мягкое удаление — [x] (2026-11-18)

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
- **Итог:** `TransactionFilter.kind` + `watchFiltered`; `AuditRepositoryImpl` с декодированием
  snapshot JSON; `revision_diff.dart`; `TransactionsViewModel` (поиск/вид/текущий месяц,
  реактивный поток, имена активов) и журнал с группами по дате, фильтрами и FAB;
  `TransactionDetailsScreen/VM` (original+RUB+base, актив, дата, комментарий, ревизии/diff,
  confirm-удаление, deleted → NotFound, блокировка удаления ноги перевода);
  `AuditAssetTransactionScreen/VM` (append-only ревизии даже после удаления) и маршрут
  `/more/audit/asset-transactions/:id`; AuditRepository в DI; тесты фильтров (в комбинации),
  ревизий/diff, удаления, NotFound, аудита удалённой операции, журнала/фильтров.
  По ревью: журнал на `AppOperationListTile` со знаком/тоном/иконкой, месяц внутри
  `AppFilterBar`, diff с локализованным видом/«—» и без обрезки, ссылка «Открыть аудит»
  с деталей, скрытие delete для ноги перевода, `reload()` без мигания и отменой подписок,
  RUB-строка только для не-RUB, регистронезависимый поиск в Dart, pending у удаления,
  «Открыть аудит» также из NotFound удалённой операции, карточка-итог с боковым отступом.
- **Отложено:** edit-форма операции и удаление пары перевода (маршруты-заглушки),
  audit денежного потока и общий экран аудита — 7.1/7.4; время ревизии с часами;
  skeleton деталей/аудита, debounce поиска, `screenPadding` заголовков; сигнальный кеш
  имён активов в журнале; inline-ошибка удаления; визуальный QA.

## Этап 7 — Доходы, расходы и связь со счетами

### 7.1 Cashflow CRUD без влияния на баланс — [x] (2026-11-19)

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
- **Рабочий план (2026-11-18):**
  - **Data:** `CashflowRepositoryImpl` (watch/getById/create/createLinked/revise/softDelete)
    с amountRub через `MoneyMath`/валюту; `CashflowDao.watchFiltered`; DI.
  - **Logic:** `CashflowCommands.save` (validate >0/future, ResolveExchangeRate, affectsBalance=false
    без счёта, edit/delete) и `CashflowCalculator.totals` (income/expense/net в RUB).
  - **UI:** журнал (группы по дате, FAB, пустые состояния), форма дохода/расхода
    (вид/категория/сумма/валюта/дата/курс/комментарий, edit), детали (сумма original+RUB,
    категория, ревизии, edit/delete), маршруты `/cashflow/new|:id|:id/edit`.
  - **Тесты:** 100000 RUB income, 250.50 expense, kind/category mismatch, zero/future/
    archived category, empty comment→null, edit revision increment, no account → нет asset tx.
- **Генерация:** gen-l10n; build_runner/schema dump при DAO changes.
- **DoD:** amountRub=original×rate, current journal only active, errors локализованы;
  общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/07.1: реализовать доходы и расходы`.
- **Итог:** `CashflowRepositoryImpl` (watch с фильтрами и поиском в Dart, getById, create/
  createLinked/revise/softDelete, amountRub через `MoneyMath`), `CashflowDao.watchFiltered`,
  DI. `CashflowCommands` (validate, ResolveExchangeRate, affectsBalance=false, edit/delete),
  `CashflowCalculator.totals`. UI: журнал с итогами/группами/датами и FAB, форма дохода/
  расхода (вид/категория/сумма/валюта/дата/курс/комментарий, edit), детали (RUB snapshot,
  категория, ревизии, edit/delete), маршруты `/cashflow/new|:id|:id/edit`. Тесты: RUB
  income/expense snapshots, kind mismatch, zero/future/archived, empty comment→null, edit
  revision+amount, delete скрывает и сохраняет ревизии, отсутствие asset tx, итоги.
  По дизайн-ревью: категории загружаются сразу в create, итоги — `AppCashflowSummary`
  с периодом, empty state центрирован через scroll-обёртку (без overflow 320dp/1.3),
  заголовок edit-формы, RUB-строка не дублируется, ревизии с датой/типографикой,
  отдельный текст ошибки удаления, «Валюта» вместо «Валюта счёта».
- **Отложено:** фильтры/поиск журнала в UI (7.3), привязка к счёту/affectsBalance (7.2),
  audit денежного потока (7.4), inline-ошибки удаления, визуальный QA; перед 7.2 —
  пробрасывать существующие linkage-поля (`affectsBalance/accountId/propertyId`) в revise.

### 7.2 Явная связь денежного потока со счётом — [x] (2026-11-19)

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
- **Итог:** `CashflowCommands` (+db) — linked-сохранение в одной транзакции: income→deposit/
  expense→withdrawal, `affectsBalance=true` требует счёт; off→on создаёт операцию и
  связывает запись, on→off мягко удаляет операцию и снимает связь, delete удаляет пару с
  ревизиями обеих; `CashflowDao.reviseWithLink`. Форма: счёт + «Влияет на баланс»,
  авто-валюта счёта, ошибка счёта; prefill editing. Тесты linked_pair: создание пары без
  дублей, нехватка баланса откатывает обе записи, off→on, on→off, delete-ревизии обеих.
  По ревью: счета загружаются в VM (активные + текущий архивный), switch → счёт (скрыт до
  включения) → сумма/валюта с причиной блокировки и очисткой суммы/курса при смене валюты,
  empty state без счетов с CTA, `propertyId` пробрасывается (квартира+счёт отклоняется),
  ошибки negativeBalance/currency mismatch локализованы, счёт виден в деталях; правка
  связанной пары покрыта тестом.
- **Отложено:** единый choice «счёт/квартира» в одной форме, badge связи в журнале и
  audit денежного потока (7.3/7.4), ручное unlink вне toggle, визуальный QA.

### 7.3 Журнал денежного потока и фильтры — [x] (2026-11-19)

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
- **Рабочий план (2026-11-19):**
  - **VM:** фильтры query/kind/period/category/account/currency, счета и категории в
    сигналах, reactive watch без утечки подписок.
  - **UI:** поиск + фильтры вида/периода + advanced-селекты (категория/счёт/валюта),
    сброс, filtered empty, группы по дате, lazy builder, summary из отфильтрованного набора.
  - **Audit:** экран ревизий денежного потока `/more/audit/cashflow/:id`; из NotFound
    удалённой записи — переход в аудит.
  - **Тесты:** account filter только affectsBalance, deleted скрыт и summary уменьшается,
    сброс восстанавливает, конец периода включителен, audit удалённой записи.
- **Генерация:** gen-l10n; schema не меняется.
- **DoD:** фильтры не мутируют глобально другой tab, large list lazy, accessible amounts;
  общий DoD/design review. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/07.3: добавить журнал денежного потока`.
- **Итог:** VM журнала с query/kind/period (месяц/год/всё)/category/account/currency,
  reactive watch и сбросом; счета и категории в сигналах; UI — поиск, чипы вида/периода,
  advanced-селекты категории/счёта/валюты, filtered empty, summary из отфильтрованного
  набора, группы по дате; audit денежного потока (append-only ревизии) и переход в него из
  NotFound удалённой записи. Тесты: account filter только связанные записи, deleted скрыт и
  summary уменьшается, конец периода включителен, audit create/edit/delete, фильтры.
  По ревью: filtered empty с reset, счётчик всех фильтров включая advanced, advanced в
  диалоге (шапка низкая), property-фильтр, periodLabel с периодом и «Итоги в RUB»,
  widget-тест пустого фильтра и сброса.
- **Отложено:** ленивый builder при большом списке и совмещение шапки фильтров со списком,
  badge связи в журнале, визуальный QA 320dp/1.3.

### 7.4 Операции квартиры end-to-end — [x] (2026-11-19)

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
- **Итог:** property context передаётся в `CashflowFormViewModel` и валидируется через
  assetRepository (invalid id → NotFound/empty state); в форме показывается «Квартира: имя ·
  Не влияет на баланс счёта» (в т.ч. для edit по entry.propertyId), привязка к счёту на
  property-форме недоступна; после сохранения property-секция и глобальный журнал обновляются
  реактивно, стоимость квартиры не меняется. Тесты: income/expense квартиры в общем итоге и
  неизменность стоимости, invalid property id → ViewError notFound (с проверкой errorCode);
  property-фильтры глобального журнала покрыты 7.3; NotFound-CTA ведёт на dashboard.
- **Отложено:** integration_test cashflow_flow (e2e сценарий квартиры), виджет-тест формы
  (нет account switch / inline NotFound), diff в audit, badge связи, визуальный QA.

## Этап 8 — Финансовые цели

### 8.1 Цели и явная привязка активов — [x] (2026-11-19)

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
- **Итог:** `GoalRepositoryImpl` + DI; `GoalsViewModel`/список с целью/статусом; форма
  (имя, категория accounts|investments, целевая сумма+валюта, дата, multi-select активов
  с архивным бейджем, ошибки); детали (цель/категория/дата/активы, edit, achieved/closed/
  activate, soft delete, NotFound); маршруты `/goals/new|:id|:id/edit`. DAO теперь требует
  непустой assetIds. Тесты: два счёта ок, чужой kind/пустые/нулевая сумма reject, архивный
  актив сохраняет связь, closed не удаляет, soft delete скрывает, update меняет связи.
  BR-G-6: дата в прошлом отклоняется в DAO и picker'е; `setStatus` не меняет удалённую
  цель; архивные активы доступны в форме только если уже привязаны.
- **Отложено:** прогресс/дефицит/monthly contribution — 8.2; сортировка/фильтры целей;
  retry-путь формы после ошибки загрузки (системный паттерн 5.2/7.1); VM-тесты;
  widget-тесты формы/деталей; визуальный QA.

### 8.2 Автоматический прогресс и monthly contribution — [x] (2026-11-19)

- **Рабочий план:**
  - **Logic:** `GoalCalculator.calculate(goal, assetValues, today)` — сумма в валюте цели,
    deficit/surplus, `completionRatio` (без clamp), monthly contribution по календарным
    месяцам (включая текущий; `null` при отсутствии даты, нулевом дефиците и просрочке);
    `GoalCalculator.resolveStatus` — achieved при `progress >= target`, обратно active при
    снижении, `closed` не меняется вручную/автоматически. `CalculateGoalProgress` конвертирует
    стоимости связанных активов в валюту цели через `CurrencyConverter`; нет курса — прогресс
    не считается (не показываем частичную сумму и не меняем статус).
  - **VM:** `GoalsViewModel` подписан на goals + assets + currencies и пересчитывает прогресс,
    авто-синхронизирует статус (guarded, без циклов); `GoalDetailsViewModel` считает прогресс
    при загрузке и тоже синхронизирует статус. Список сортируется active → achieved → closed.
  - **UI:** список — `AppGoalCard` по секциям статусов (ratio clamp 1, точные суммы,
    дедлайн/дефицит/сверх цели), fallback `AppListTile` с «Курс недоступен»; детали —
    `AppProgress` + `AppMetric` (накоплено, осталось/сверх цели, в месяц, «Срок истёк»);
    ручная кнопка «Отметить достигнутой» убирается — статус автоматический.
  - **TDD:** CALC-026 (50 000 из 100 000 → deficit 50 000, ratio 0.5), CALC-027 (120 000 →
    surplus 20 000, achieved, ratio >1), CALC-028 (12 000 / 6 мес → 2 000; 9 500 / 5 → 1 900),
    CALC-029 (просрочка → monthly null), closed остаётся closed, смешанные валюты только
    после конверсии, отсутствие курса → progress null, asset stream обновляет прогресс и статус.
  - **Генерация:** gen-l10n; схема БД не меняется.
  - **commit:** `task/08.2: рассчитать прогресс целей`.
- **Итог:** `GoalCalculator` (CALC-026…029) и `CalculateGoalProgress` (конверсия в валюту
  цели, нет курса → progress null без частичной суммы); `GoalsViewModel` реактивно считает
  прогресс по goals+assets, пересчитывает `today` на init/reload, защищён токеном эмиссии,
  авто-синхронизирует статус (achieved/active, closed неизменен), сортирует по группам;
  детали показывают AppProgress + AppMetric (накоплено/осталось/сверх/в месяц, «Срок истёк»,
  процент в semantics) и синхронизируют статус при загрузке; список — AppGoalCard по секциям
  «Активные/Достигнутые/Закрытые», ручная кнопка «Отметить достигнутой» удалена. `AppProgress`
  получил `semanticsValue`. Тесты: 13 logic + 7 VM.
- **Отложено:** реактивный прогресс на экране деталей (считается при загрузке); widget/screen
  тесты целей и тест авто-синка деталей; единый хелпер «нужных курсов» (естественно в 9.1);
  fallback-карточка при отсутствии курса; caption «В месяц»; высота skeleton; визуальный QA.
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

### 9.1 Net worth в выбранной базовой валюте — [x] (2026-11-19)

- **Рабочий план:**
  - **Data:** `AssetsDao.allRows()`; `analytics_mappers.dart` — стоимости на дату
    (account: opening + операции `<= onDate`; investment: последняя оценка `<= onDate` +
    операции после неё; property: последняя оценка), включение актива по `createdAt`/
    `archivedAt` (A-6: с даты архивации исключён).
  - **Logic:** `NetWorthCalculator` — принимает стоимости в валютах активов, курсы к RUB и
    базовую валюту, считает exact Rational A→RUB→base, округляет общий итог один раз,
    категории — из тех же значений с распределением остатка в крупнейшую; нет курса →
    `rateUnavailable` (не ноль), RUB не конвертируется.
  - **Impl/DI:** `AnalyticsQueriesImpl.netWorth` читает активы/операции/оценки, валюты,
    базовую валюту и dated-курсы `onDate`; регистрация в DI. Остальные методы интерфейса —
    заготовки для 9.2/9.3.
  - **TDD:** account 1000 RUB + investment 10 USD×90=900 RUB + property 2 EUR×100=200 RUB
    → 2100 RUB; base EUR → 21 EUR; нет base rate → rateUnavailable; archived до/с даты архивации;
    deleted-операция не участвует; категории в сумме дают общий итог.
  - **Генерация:** схема БД не меняется; ARB не требуется (ошибки — существующие коды).
  - **commit:** `task/09.1: рассчитать совокупную стоимость`.
- **Итог:** `AssetsDao.allRows()`; `AnalyticsMappers` — стоимости на дату (account/opening+
  операции, investment/последняя оценка+операции, property/последняя оценка) и cutoff по
  `createdAt`/`archivedAt`; `NetWorthCalculator` — exact A→RUB→base, одно округление на итог,
  категории из тех же значений с распределением остатка, нет курса → `rateUnavailable`;
  `AnalyticsQueriesImpl.netWorth` + DI. Тесты: 10 data (RUB/EUR, no-rate, архив,
  deleted-операция, оценка, инвариант категорий, CALC-022, as-of операция/оценка) + 4 logic. Арифметика TDD уточнена: 2100 RUB / 21 EUR
  (в исходной формулировке было 20 900/209 — опечатка на порядок).
- **Отложено:** `netWorthSeries` (9.2), cashflow-агрегаты (9.3), подключение к Dashboard (10.1),
  общий as-of в `AssetValueCalculator` (сейчас правила стоимости продублированы в
  `AnalyticsMappers` — свести в 9.2), widget/integration-тесты; ARB не менялся.
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

### 9.2 История стоимости и серия графика — [x] (2026-11-19)

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
- **Итог:** `netWorthSeries` строит даты (старт периода + создание/архивация/операции/оценки,
  уникальные и упорядоченные) и пересчитывает net worth на каждую дату через общий
  `_summaryAt` с кэшем курсов по `(code,date)`; `AnalyticsPeriods` (месяц/3/6/год/всё время)
  с календарными границами; `NetWorthSeriesBuilder` — точки графика/exact-строки/статистика;
  `AnalyticsScreen` с period/kind-фильтрами, `AppLineChart` в `AppChartFrame` и доступным
  списком всех точек; `AnalyticsViewModel` (repeatable now, request-token); при отсутствии
  курса — error с валютой/датой и ручным вводом (`showManualRateDialog` → пересчёт);
  «всё время» начинается от earliest активности (создание/операция/оценка) через
  `earliestActivityDate` (пустая БД определяется без kind-фильтра); пустая БД — отдельное
  empty-состояние с CTA в активы, пустой kind — reset; фильтры не скрываются при загрузке;
  сводка (последнее/мин/макс/направление/диапазон/валюта), collapsible-список точек
  (5 + «показать все»), одна точка — «нет изменений» с CTA «Всё время»; тесты
  «фильтры видны при loading/error», reset и 320dp/1.3/dark; маршрут
  `/more/analytics` и tile в «Ещё». Тесты: 47 analytics (net worth 10, series 9, calculator 4, периоды 5, builder 4,
  VM 8, chart section 3, screen 4).
- **Отложено:** cashflow-агрегаты и объединённые фильтры (9.3/9.4), e2e analytics_flow
  (9.4), сведение as-of с `AssetValueCalculator`, виртуализация text alternative при
  большом числе точек, ручной курс закрывает по одной дате (BR-C-2; загрузка курсов ЦБ на
  диапазон — кандидат в 9.4/10.1), экранный тест 320dp/1.3 (секция покрыта),
  uikit-долг: нейтральный тон `AppErrorState` для отсутствующего курса и исключение
  двойной семантики `AppChartFrame`/`AppSummaryCard`, визуальный QA 320dp/1.3.

### 9.3 Cashflow aggregates по периодам и категориям — [x] (2026-11-19)

- **Рабочий план:**
  - **Data:** `cashflow(cashflowByCategory/cashflowSeries)` читают active-записи через
    `CashflowDao.watchFiltered` (+ поиск по комментарию), конвертируют каждую запись из её
    валюты в базовую по курсам `occurredOn` (исходная→RUB→base, кэш `(code,date)`), суммы
    копятся Rational, округление — на итоге; нет курса → `rateUnavailable`.
  - **Logic:** `CashflowAnalytics` — summary (income/expense/net), totals по категориям,
    серия: месячные бакеты при периоде >62 дней, иначе дневные, все бакеты заполняются
    нулями; пустой набор при `period == null` без записей.
  - **UI:** `CashflowChartSection` — `AppChartFrame` + `AppCashflowChart`, legend и доступный
    список периодов; подключается к экрану в 9.4.
  - **TDD:** income 1000/expense 250 → net 750; linked expense один раз; transfer/standalone
    deposit не участвуют; property/account filters; deleted excluded; archived category;
    USD→EUR через RUB по дате; месяцы/дни и нулевые точки; категории.
  - **Генерация:** gen-l10n; схема БД не меняется.
  - **commit:** `task/09.3: добавить аналитику денежного потока`.
- **Итог:** `cashflow`/`cashflowByCategory`/`cashflowSeries` читают active-записи через
  `watchFiltered` с поиском по комментарию, конвертируют каждую запись в базовую валюту по
  курсу `occurredOn` (исходная→RUB→base, кэш `(code,date)`, нет курса → rateUnavailable);
  `CashflowAnalytics` считает summary/категории/серию (месяцы при периоде >62 дней, иначе
  дни, нулевые бакеты включены); `CashflowChartSection` — `AppCashflowSummary`,
  `AppCashflowChart`, legend и доступный список периодов (короткие подписи, сворачивание
  5 + «показать все», нулевая серия → empty, текстовая альтернатива с MergeSemantics).
  `AppCashflowChart` получил горизонтальный скролл для многих периодов. Тесты: 23
  (13 data: linked expense один раз, transfer/standalone deposit, account/property,
  deleted, категории+архив, USD→EUR, rateUnavailable; 5 logic; 5 chart section); всего
  analytics 70.
- **Отложено:** подключение секции и категорий к экрану аналитики (9.4), проценты категорий
  и выбор категории (9.4), e2e analytics_flow (9.4), общий хелпер поиска/фильтра с журналом
  (сейчас продублирован в `CashflowRepositoryImpl.watch` и аналитике), uikit-тон ошибки курса,
  визуальный QA.
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

### 9.4 Экран аналитики и доступные графики — [x] (2026-11-19)

- **Рабочий план:**
  - **VM:** единый `period` для обеих секций; `assetKind` для net worth; `cashflowKind` и
    `categoryId` для cashflow (смена kind сбрасывает несовместимую категорию); загрузка
    категорий (включая архивные) для селекта и подписей; net worth range + cashflow
    filter.period (`all` → null), summary/byCategory/series; общий rate/manual-rate error;
    проценты категорий считаются из категориальных итогов.
  - **UI:** секция «Денежный поток» с `CashflowChartSection`, фильтры cashflow (Все/Доходы/
    Расходы + категория) перед секцией; секция «Категории» (имя, сумма, доля); period
    сохраняется при смене вида активов; empty/error/loading по секциям; 320dp/1.3.
  - **Тесты:** VM (period сохраняется, incompatible category сбрасывается, summary/series/
    categories грузятся, rate error/manual rate), screen (cashflow-секция, категории,
    фильтры), e2e `analytics_flow_test.dart` (More → Аналитика, period, empty).
  - **Генерация:** gen-l10n; схема БД не меняется.
  - **commit:** `task/09.4: реализовать экран аналитики`.
- **Итог:** VM грузит net worth + cashflow summary/byCategory/series + категории (включая
  архивные), shared period, assetKind, cashflowKind/category (смена kind сбрасывает чужую
  категорию), `all` передаёт cashflow `period=null`, доля категории из summary; экран
  показывает net worth-секцию (или empty), фильтры cashflow, `CashflowChartSection`,
  `CategoryTotalsSection` (имя/архивный чип/доля/сумма), сохраняет период при смене вида;
  нет активов и нет cashflow → empty с CTA в активы (наличие cashflow проверяется
  existence-запросом `hasAnyCashflow()` без периода/фильтров и конвертации); категории
  различают доход/расход тоном и подписью, сброс фильтров раздельный для общего блока и
  cashflow, доля скрывается при фильтре категории. Добавлен e2e `analytics_flow_test.dart`.
  Тесты: +5 VM (cashflow/категории/сброс kind/раздельные reset) +2 screen (cashflow/
  категории/фильтры; нет активов, но есть cashflow); всего 508 unit + e2e.
- **Отложено:** тройная агрегация cashflow на reload (summary/series/byCategory) — общий
  комбинированный запрос в 9.x/10; `EXISTS`/`limit(1)` для `hasAnyCashflow`; правило
  архивных опций — в VM-хелпер; проценты/фильтры категорий в отдельном диалоге;
  динамическая ширина столбца и аффорданс горизонтального скролла (uikit); визуальный QA
  320dp/1.3.
- **Приоритет/зависимости:** P1; после 9.2 и 9.3. **BR:** S-1…5, IE-13, DESIGN charts.
- **Files:** Modify `analytics_screen.dart`, `analytics_view_model.dart`,
  two chart sections, routes/DI/ARB;
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

### 10.1 Dashboard с реальными итогами и quick actions — [x] (2026-11-19)

- **Рабочий план:**
  - **VM:** подписки assets/goals/transactions + base currency; net worth через
    `AnalyticsQueries.netWorth(today)`; прогресс целей через `CalculateGoalProgress`
    (без записи статуса, achieved показывается из прогресса); последние 5 операций с именами
    активов; повторяемый `now`, токены против гонок, dispose всех подписок.
  - **UI:** `AppAdaptiveGrid` (одна колонка <600, две — шире): net worth + дата/базовая
    валюта → quick add (Доход/Расход/Перевод с prefill) → цели (до 3 AppGoalCard + «Все
    цели»/«Добавить») → последние операции (AppListTile + сумма/дата, tap в детали). Пустая
    БД — честные нули, без демо-данных, quick add как CTA.
  - **Тесты:** пустая БД (нули + CTA), данные (net worth, цель achieved, recent), реакция на
    новый поток/ошибку, dispose; widget 320dp.
  - **Генерация:** gen-l10n; схема не меняется.
  - **commit:** `task/10.1: реализовать главный экран`.
- **Итог:** `DashboardViewModel` на подписках assets/goals/transactions/base currency, net
  worth через `AnalyticsQueries.netWorth(today)`, прогресс целей через
  `CalculateGoalProgress` (achieved показывается из прогресса без записи), последние 5
  операций с именами активов, repeatable now и dispose всех подписок; экран —
  `AppAdaptiveGrid` (1/2 колонки), net worth card с датой/валютой и переходом в аналитику,
  quick actions Доход/Расход/Перевод с prefill, блок целей (3 + все/добавить), последние
  операции с переходом в детали; пустая БД — честные нули и CTA, без демо. Переводы
  показываются тоном transfer и иконкой, секция честно названа «Операции по активам» с
  переходом в журнал; ошибка курса net worth локализована карточкой, остальные блоки живы;
  `AppAdaptiveGrid` выравнивает ячейки по верху (без переполнения низких секций). Тесты:
  пустая БД, данные, повторная эмиссия/dispose, prefill quick actions, локальная ошибка
  курса, 320dp/1.3/dark; всего 514.
- **Отложено:** cashflow месяца и единые переходы (10.2), ручной/визуальный QA 320dp/1.3,
  расширенные типы операций в recent (cashflow отдельно), skeleton по точной структуре,
  `limit` для последних операций (сейчас читается весь журнал ради 5 строк), обновление
  `today` на resume, инкремент токенов в `init()`, чистка неиспользуемых `PrimaryEmptyBody`
  и ключей `dashboardEmptyTitle`/`dashboardEmptyMessage`.
- **Приоритет/зависимости:** P1; после 9.4. **BR:** S-1…5, G-2…6, IE-13.
- **Files:** Modify dashboard screen/VM, `lib/uikit/app_adaptive_grid.dart` (top-aligned
  ячейки), root router/DI/ARB/test app; Create widgets
  `{dashboard_net_worth,dashboard_goals,dashboard_recent_operations}.dart`;
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

### 10.2 Dashboard cashflow и единые переходы в аналитику — [x] (2026-11-19)

- **Рабочий план:**
  - **VM:** подписка `CashflowRepository.watch` как сигнал изменений; summary/series текущего
    месяца через `AnalyticsQueries` (то же округление/base), диапазон от injected today
    (первый/последний день включительно), локальная ошибка курса без падения всего экрана.
  - **UI:** `DashboardCashflow` — компактные доход/расход/итог + bars месяца, tap ведёт в
    Аналитику с prefill `period=month` (push), пустой месяц — CTA «Добавить расход»;
    `AnalyticsViewModel.initialPeriod` + чтение `period` из query в роутере.
  - **Тесты:** месяц от today inclusive; transfer/asset deposit не меняют виджет; повторная
    эмиссия обновляет; tap сохраняет period; empty CTA; VM/analytics prefill.
  - **Генерация:** gen-l10n; схема не меняется.
  - **commit:** `task/10.2: добавить виджет денежного потока`.
- **Итог:** DashboardVM подписан на `CashflowRepository.watch` месяца и грузит
  summary/series текущего месяца через `AnalyticsQueries` (range от injected today,
  первый/последний день включительно), ошибка курса локализована (секция показывает текст,
  а не исчезает); `DashboardCashflow` — компактные income/expense/net + недельные bars
  (height 140, 4–5 групп вместо скрытого скролла по дням), `AppCashflowSummary` тапается в
  Аналитику с prefill `?period=month`, пустой месяц — CTA «Добавить расход»;
  `AnalyticsViewModel.setInitialPeriod` + разбор `period` в роутере; недельная свёртка
  покрыта отдельным widget-тестом (30 дней → 5 групп, суммы/метки); смена базовой валюты
  перезапрашивает cashflow. Тесты: +5 dashboard (cashflow/tap prefill, empty CTA, ошибка
  курса, weekly, реактивность/валюта) +1 analytics prefill; всего 520.
- **Отложено:** prefill остальных фильтров (kind/category) из Dashboard, router-prefill в
  `initState` при переиспользуемой VM, визуальный QA 320dp/1.3, точный skeleton.
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

### 10.3 Настройки, справочники и базовая валюта — [x] (2026-11-19)

- **Рабочий план:**
  - **More:** tiles «Аналитика», «Категории», «Банки и брокеры», «Валюты»,
    «Настройки», «О приложении», «Защита»; реальные routes вместо плейсхолдеров
    settings/about; общий экран аудита остаётся вне 10.3 (его список ещё не реализован —
    записать в «Отложено»).
  - **Settings:** секция «Отчёты» с текущей базовой валютой → BaseCurrencyScreen;
    секция «О приложении» → About; VM на `SettingsRepository` (base currency), без
    backup/update (10.4/10.5).
  - **About:** отдельный экран с назначением/offline-дисклеймером; версия и проверка
    обновления подключаются в 10.5 (без служебной заглушки на витрине).
  - **TDD:** More-переходы; base currency меняется и читается; disabled/used conflict в
    repository; About показывает описание без служебной заглушки; Settings/About 320dp/dark
    (визуальный QA отложен).
  - **Генерация:** gen-l10n; схема не меняется.
  - **commit:** `task/10.3: реализовать экран настроек`.
- **Итог:** More получил секции «Справочники» (категории, банки/брокеры, валюты) и
  «Приложение» (настройки, о приложении) в дополнение к аналитике и защите; `SettingsScreen`
  (`SettingsViewModel` на watch/get base currency) показывает текущую базовую валюту и ведёт
  в BaseCurrencyScreen, плюс About; `AboutScreen` — назначение/offline-дисклеймер (версия
  подключается в 10.5, без служебной заглушки);
  settings/about routes вместо плейсхолдеров, DI обеих VM. Тесты: settings repository
  (смена/disabled conflict) + More/Settings/About widget (5); всего 525.
- **Отложено:** общий экран аудита (списка ревизий ещё нет — вне 10.3), backup/update
  секции (10.4/10.5), проверка «used base» вне repository-валидации, визуальный QA.
- **Приоритет/зависимости:** P1; после 10.2. **BR:** C-4…6.
- **Files:** Create settings repository impl/domain/logic, `settings_screen.dart`,
  `settings_view_model.dart`, `about_screen.dart`, `about_view_model.dart`;
  Modify `more_screen.dart`, `more_view_model.dart`, DI/routes/ARB;
  Test settings/more/about screens и settings repository tests.
- **Consumes:** `SettingsRepository.watchBaseCurrency/getBaseCurrency/setBaseCurrency`,
  CurrencyRepository, named routes.
- **Produces:** More tiles, Settings «Отчёты», выбранная base currency, app info;
  секции backup/update добавляются 10.4/10.5 в этот же screen без переписывания VM;
  версия About — в 10.5.
- **TDD:** set USD enabled обновляет Dashboard/Analytics, RUB audit snapshots unchanged;
  used/disabled base conflict; More ведёт categories/subgroups/currencies/audit/about;
  About показывает назначение/offline-дисклеймер без служебной заглушки (версия — 10.5).
- **Генерация:** gen-l10n.
- **DoD:** offline settings доступны, font 1.3/dark/long text pass; общий DoD/design review.
  Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/10.3: реализовать экран настроек`.

### 10.4 SQLite export/share/save/import с rollback — [x] (2026-11-19)

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
- **Итог:** deps (path_provider/path/file_picker/share_plus/cross_file/sqlite3); domain
  BackupService/exception/gateway; `LocalDatabaseBackupService` — VACUUM INTO export,
  validation (magic/integrity/application_id/user_version/foreign_key_check), candidate
  migration, rollback snapshot, безопасный replace с восстановлением;
  `BackupViewModel` с typed-статусами и blocking restoreFailed; `BackupSection` в настройках
  (равноправные tonal-кнопки с иконками/вертикальный стек, warning-тон, busy-per-action,
  destructive confirm, одиночный nondismissible restart-диалог, blocking-restoreFailed);
  `AppRestartHost` с
  пересозданием ServiceLocator/router по `appRestartTick`; Android SAF-канал
  `com.example.finanseapp/file_saver`; тесты: VM статусы/блокировки + реальные temp-SQLite
  export/import/wrong-magic/foreign-app/newer-schema/replace/reopen/rollback, BackupSection
  states/320-dark (12); всего 537. Импорт больше не пересоздаёт UI сам: при успехе диалог →
  restart, при откате показывается сообщение и кнопка перезапуска.
- **Отложено:** `backup_flow` integration test и полный SAF-прогон на Android, восстановление
  `*.pre-import` при старте, `beforeOpen`-проверка application_id, post-migration integrity/FK
  для схем >1, retry picker по расширениям, background cleanup временных файлов, desktop
  share edge-cases, визуальный QA.
- **Приоритет/зависимости:** P1; после 10.3 и 3.2. **BR:** BU-1…6.

### 10.5 Проверка обновлений через GitHub Releases — [x] (2026-11-20)

- **Рабочий план:**
  - **Domain:** `AppVersion` (v-prefix/beta/build-metadata, missing parts→0, строго 1–3 numeric
    components, numeric core compare), `ReleaseInfo`, `UpdateService`.
  - **Data:** `GithubUpdateService` через `dart:io` HttpClient, timeout, latest release JSON,
    HTTPS-only APK/html, 404→noReleases, invalid JSON/tag/version→error.
  - **VM/UI:** installed version через `package_info_plus`; ручная проверка (double-check —
    один вызов), статусы upToDate/updateAvailable/error; `UpdateSection` в Settings и версия
    в About; диалог обновления: APK через `url_launcher`, при неудаче — release page,
    обе неудачи — openFailed; HTTPS-only, `javascript:` отклоняется.
  - **TDD:** 1.0.10>1.0.9, same/older/beta/malformed; 404/500/timeout/invalid; double check
    один call; APK launch failure→page, обе failure→openFailed.
  - **Генерация:** pub get, gen-l10n; Manifest получает VIEW https (INTERNET уже есть), без
    REQUEST_INSTALL_PACKAGES; release workflow asset `app-release.apk`.
  - **commit:** `task/10.5: добавить проверку обновлений`.
- **Итог:** `AppVersion` (v/beta/build, numeric core), `ReleaseInfo`/`UpdateService`,
  `GithubUpdateService` (dart:io, timeout, 404→noReleases, HTTPS-only APK/page, invalid),
  `UpdateCheckViewModel` (installed version, ручная проверка, double-check один вызов,
  upToDate/updateAvailable/error/openFailed, APK→page fallback) и `UpdateSection` в Settings
  (версия с авто-init, проверка, статус с error-иконкой/разными сетевыми и invalid текстами, повтор
  «Открыть обновление» после openFailed, About); Manifest получил VIEW https,
  release workflow уже публикует `app-release.apk`. Тесты: AppVersion (2), VM (3), UpdateSection (5), GithubUpdateService (4: включая timeout/offline), openUpdate fallback
  (1); всего 552.
- **Отложено:** версия в About (сейчас в Settings), установка APK/unknown sources (Android),
  e2e/ручной прогон обновления, скрытие beta/prerelease nuances; inline «Открыть обновление»
  вместо диалога «Скачать/Позже» — осознанное отклонение от spec §6.
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
  `.github/workflows/ci.yml` (`flutter build apk --release` → `--release`, artifact
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

### 11.1 Golden calculations и проверка покрытия каждого BR — [x] (2026-11-20)

- **Рабочий план:**
  - **Architecture tests:** разбор BR ID из `business_rules.md` и CALC ID из `calculations.md`;
    явная карта ID→тестовые файлы для каждого правила/расчёта, проверка существования файлов
    и что каждый ID из документа покрыт (временное удаление записи → падение с ID).
  - **Golden:** независимые literal-assertions для недостающих формул (rateUnavailable,
    cashflow net, property net, RUB snapshot, category shares; yield — отложен до 12.3);
    revision/transfer history проверяются существующими repository-тестами и включаются в карту.
  - **Docs:** business_rules/calculations менять только при найденном расхождении.
  - **commit:** `task/11.1: проверить покрытие бизнес-правил`.
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
- **Итог:** `test/architecture/business_rule_coverage_test.dart` парсит 100 BR (включая
  диапазоны `BR-CAT-1…3`, `BR-P-1…2`, `BR-RE-1…2`) и 36 CALC из docs, требует явную запись
  для каждого ID, наличие конкретных тестовых файлов (CALC) и хотя бы одного `*_test.dart`
  в каталогах BR-группы, ловит устаревшие/одновременно отложенные записи; новый BR без
  карты падает с именем ID. CALC-008 проверяется CBR-тестами «ответ другой даты →
  rateUnavailable»; добавлены literal-кейсы CALC-023/024 (net/property net) и CALC-025
  (1000 USD@90 → 900 EUR, RUB-snapshot 90 000 через production-репозиторий), CALC-035
  (доли 25%/75%, нулевой итог → 0), CALC-009/011/012 (точные суммы/ревизии) и CALC-033
  (deposit без классификации). Остальные CALC привязаны к конкретным repository/calculator
  тестам с буквальными expected. CALC-036 (yield) реализован в 12.3 (`property_yield_calculator_test`).
  Всего 561 тест.
- **Отложено:** yield/CALC-036 до 12.3; ручная сверка docs с продуктом (вне automated QA).
- **DoD:** self-review подтверждает каждый BR кодом+тестом, нет тестов, вычисляющих expected
  той же функцией; общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/11.1: проверить покрытие бизнес-правил`.

### 11.2 End-to-end критических потоков, включая backup — [x] (2026-11-20)

- **Приоритет/зависимости:** P1; после 11.1. **BR:** T/IE/G/S/BU/UP.
- **Files:** Create `integration_test/{helpers/test_app,assets_flow_test,transactions_flow_test,
  cashflow_flow_test,goals_flow_test,backup_flow_test,settings_flow_test}.dart`, расширить
  `analytics_flow_test.dart`; `app_test.dart` остаётся smoke без изменений;
  TEST_PLAN append через android-tester; Test Linux integration + Android manual checklist.
- **Consumes:** реальные routes/repositories, temp AppDatabase, fake GitHub/platform
  gateways и реальные часы (детерминированные — в Отложено).
- **Produces:** e2e create account→tx→transfer→linked expense→goal→analytics; export/change/
  import/restart; invalid backup non-destructive; settings noReleases (upToDate/available —
  отложены).
- **TDD:** каждый flow фиксирует сценарий; после restart проверяются восстановленные данные,
  failed import оставляет прежние данные, сеть не используется (ленивый CBR при RUB);
  найденные дефекты — отдельным regression unit test и повторный flow.
- **Генерация:** gen-l10n/build_runner по фактическим source changes.
- **Итог:** добавлены `integration_test/helpers/test_app.dart` (in-memory/file БД,
  desktop-вьюпорт, навигация, создание счёта через UI) и 7 flow-файлов: assets (создание
  счёта → детали), transactions (пополнение → перевод → журнал), cashflow (расход, доход,
  связанный расход со списанием со счёта), goals (цель с привязанным счётом), analytics
  (пустое состояние и данные с категориями), settings (базовая валюта, версия, проверка
  обновлений, About), backup (реальный файл БД: export → изменение → import → restart,
  битый файл не разрушает данные). `buildTestLocator` получил инъекцию
  `BackupServiceFactory`/`BackupFileGateway`. На Linux: 9 e2e-сценариев зелёные,
  unit/widget suite — 561. Android QA (emulator-5556, debug): 50 сценариев — 41 PASS,
  5 FAIL (не блокируют: устаревшие детали цели/счёта, подпись валюты, нереактивная Главная
  после ручного курса, висячий «·») → задачи 11.5–11.8, 3 SKIP + 1 BLOCKED → 11.9;
  TEST_PLAN дополнен, SAF/backup проверены на устройстве.
- **Отложено:** реальная сетевая проверка GitHub update и состояния upToDate/updateAvailable,
  revision-marker после restart отдельным ассертом (данные и FK-целостность проверяются
  импортом), rollback-вилка после closeDatabase (покрыта unit-тестом failOn); детерминированные
  часы e2e (сейчас real `DateTime.now()`, возможен флейк на границе месяца/полуночи);
  ключи вместо позиционных локаторов и плейсхолдера `'—'`.
- **DoD:** все критические flows зелёные на Linux при разрешённом запуске; Android SAF/APK
  manual результаты записаны в TEST_PLAN; недоступные проверки явно названы, не «passed»;
  общий DoD. Перед PR вопрос об e2e обязателен даже после выполнения.
- **Предлагаемый commit:** `task/11.2: добавить сквозные финансовые сценарии`.

### 11.3 Accessibility, производительность и устойчивость — [x] (2026-11-20)

- **Рабочий план:**
  - **Route-матрица:** `test/accessibility/app_accessibility_test.dart` — 320dp + text 1.3
    для Главной, журналов, активов/детали, целей/формы, аналитики, настроек, About,
    форм счёта/операции/перевода/цели; после каждого экрана `takeException == null`.
  - **Semantics:** проверить labels icon-actions (FAB/toolbar), chart summary, error/
    import-действий; при находках — точечные `Semantics`.
  - **Performance:** `test/performance/journal_performance_test.dart` — 10k операций,
    журнал использует builder и создаёт ограниченное число tile; запросы не N+1,
    агрегаты не зависят от числа виджетов.
  - **Устойчивость:** повторные init/dispose/reload журналов не пишут после dispose.
  - **commit:** `task/11.3: усилить доступность и производительность`.
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
- **Итог:** `test/accessibility/app_accessibility_test.dart` — 320dp/1.3, 18 routes из
  `AppRoutes` с проверкой типа экрана (не NotFound) и `takeException`; semantics: tooltip
  FAB активов/операций/cashflow, строки импорта/обновления в настройках, chart summaries
  покрыты uikit-тестами. `journal_performance_test.dart` — 10k строк, itemCount > 10000,
  AppListView.builder, <100 tile. `transactions_view_model_test` — после dispose события БД
  не меняют state. Всего 579 тестов. Отложено: пагинация DAO (builder ограничивает виджеты,
  но запрос читает все строки), `reservedSize`/крайние подписи при text scale > 1.3,
  замеры frame/build counts на устройстве и полный TalkBack-прогон — в 11.9.
- **DoD:** нет overflow/critical semantics findings, замеры и устройство записаны, baseline
  и фактические frame/build counts приложены к PR; общий DoD/design review. Перед PR спросить
  о e2e.
- **Предлагаемый commit:** `task/11.3: усилить доступность и производительность`.

### 11.4 Release readiness и документация v1 — [x] (2026-11-20)

- **Приоритет/зависимости:** P1; после 11.3. **BR:** все release-blocking.
- **Files:** Modify README, docs/PROJECT, TEST_PLAN, AGENTS.md,
  `docs/architecture/README.md`, `.agents/agents/release-manager.md`,
  `.github/workflows/release.yml`, `android/app/build.gradle.kts` (minSdk 31), PLAN; Test CI
  gates и release APK по workflow.
- **Consumes:** фактические результаты tests/e2e/manual QA, `app-release.apk` update contract.
- **Produces:** актуальные setup/backup/update/migration docs, известные ограничения,
  release candidate без placeholder instructions.
- **TDD/checklist:** чистый checkout pub get/generate → format/analyze/test/build; проверить
  versionName/tag/APK filename, restore backup текущей schema, update URL; plan-review перед
  релизом. Найденный дефект получает failing test до fix.
- **Генерация:** сверить generated diff чист после повторной генерации.
- **Рабочий план:**
  - **README:** убрать placeholder-текст, описать возможности v1, release APK, релиз по
    тегу, TEMP_KEY и известные ограничения (backup без шифрования, Android-only).
  - **docs/PROJECT:** актуализировать состояние v1 и CI (release APK вместо debug).
  - **release.yml:** валидация тега `vX.Y.Z`, format + оба analyze перед тестами и сборкой.
  - **TEST_PLAN:** release checklist (гейты, plan-review, QA-вопрос, backup/update, тег).
  - **plan-review** перед PR; commit `task/11.4: подготовить релизную документацию`.
- **Итог:** README и PROJECT описывают готовый v1 и реальные команды/CI; release workflow
  проверяет формат тега, format/analyze/tests и собирает APK из тега; TEST_PLAN получил
  release checklist; AGENTS.md синхронизирован с release-гейтом; minSdk приведён к
  заявленному Android 12+ (31). Placeholder-инструкций не осталось, индекс этапов
  актуализирован; повторный plan-review пройден (LGTM). Фактический прогон: 579 тестов. 11.9 (ручные TalkBack/frame counts/биометрия/пагинация) открыта и v1 не блокирует.
- **DoD:** plan-review пройден; перед тегом отдельно спросить владельца о полном QA
  android-tester (~час); релизный тег/публикация только по явному запросу, не молча.
  Перед PR спросить об e2e.
- **Предлагаемый commit:** `task/11.4: подготовить релизную документацию`.

### 11.5 Детали цели и счёта показывают устаревшие данные — [x] (2026-11-20)

- **Проблема (QA, TEST_PLAN TC-019, TC-045):** экран деталей, оставленный в стеке вкладки,
  не пересчитывается после изменения данных из другой вкладки. Шаги: открыть детали цели
  («Накоплено 1 000,00 ₽», 50%) → таб «Активы» → пополнить счет до 2 000 → таб «Цели»:
  детали всё ещё «Активна, 50%, 1 000,00 ₽», хотя кнопка «Назад» показывает цель в группе
  «Достигнутые» со 100%. Аналогично для деталей счёта: открыть «Cash» (1 577,00 ₽) → таб
  «Операции» → связанный расход 50 ₽ → таб «Активы»: детали показывают 1 577,00 ₽, список —
  1 527,00 ₽. Доказательства: `screen_031_goal_details.png`, `screen_032_goals_achieved.png`,
  `screen_081_stale_check.png` (прогон 2026-11-20, emulator-5556, debug APK).
- **Предполагаемая причина:** `lib/core/features/goals/ui/goal_details_view_model.dart` и
  `lib/core/features/assets/ui/account_details_view_model.dart` загружают снимок один раз
  (`load()` без подписки на репозитории), а маршрут деталей остаётся смонтированным в
  `StatefulShellBranch` при переключении вкладок.
- **Рабочий план:**
  - **GoalDetailsViewModel:** подписки на `GoalRepository.watchAll` и
    `AssetRepository.watchAll(includeArchived: true)`; пересчёт `progress`/`status` с
    защитой от параллельных reload и dispose; `dispose()` отменяет подписки.
  - **AccountDetailsViewModel:** подписка на `AssetRepository.watchById(assetId)` вместо
    разового `getById`; при эмиссии обновлять баланс/прогноз/base equivalent; отмена в
    `dispose()`.
  - **Тесты:** VM-тесты с broadcast-стримами: эмиссия нового снимка при открытом экране
    меняет прогресс цели (50%→100%) и баланс счёта; после dispose эмиссия не падает.
  - **commit:** `task/11.5: обновлять детали цели и счёта`.
- **Итог:** оба VM стали реактивными: `watchAll`/`watchById` пересчитывают детали при
  изменении активов, операций, оценок и целей; reload сериализован (queued), dispose
  отменяет подписки, поздние ответы не пишут в сигналы. Добавлены 4 VM-теста
  (прогресс 50%→100% и статус; баланс 100→150; dispose-инварианты), плюс ошибки
  watch-потоков переводятся в storageFailure. Первая эмиссия потока пропускается, поэтому
  open/сохранение дают один reload. Всего 567 тестов. Android-повтор TC-019/TC-045
  (emulator-5556, debug): TC-051/TC-052 PASS — детали цели и счёта обновляются без выхода
  из экрана; TEST_PLAN дополнен.
- **Решение/Тест:** перевести оба VM на реактивные `watch*`-подписки (ассеты, транзакции,
  cashflow, цели) либо перезагружать данные при возврате на вкладку; widget-тест: изменить
  баланс через репозиторий при открытом экране деталей → значения обновились; вручную
  повторить TC-019/TC-045.

### 11.6 Подпись валюты на Главной при ошибке курса — [x] (2026-11-20)

- **Проблема (QA, TEST_PLAN TC-023):** при базовой валюте USD и отсутствующем курсе Главная
  показывает «Чистый капитал: Курс недоступен» с подписью «20.11.2026 · RUB». Шаги: Настройки
  → Базовая валюта → USD → сохранить → Главная. Доказательство: `screen_045_dashboard_usd.png`
  (после корректного расчёта — `screen_052_dashboard_after_restart.png` с «· USD»).
- **Предполагаемая причина:** `lib/core/features/dashboard/ui/dashboard_screen.dart`:
  `final currencyCode = summary?.total.currencyCode ?? base?.code ?? '';` — при
  `netWorthError == rateUnavailable` сигнал `netWorth` хранит прошлый снимок в RUB.
- **Рабочий план:**
  - **Fix:** в `dashboard_screen.dart` при `netWorthError == rateUnavailable` брать код из
    `vm.baseCurrency`, игнорируя устаревший снимок `netWorth` (RUB).
  - **Test:** widget-тест с базой USD, старым total в RUB и ошибкой `rateUnavailable`:
    подпись содержит `USD`, а не `RUB`; существующие RUB-кейсы не меняются.
  - **commit:** `task/11.6: исправить подпись валюты на Главной`.
- **Итог:** при любой ошибке `netWorth` подпись берётся из `vm.baseCurrency`, а не из
  устаревшего `netWorth.total`; widget-тест воспроизводит реальную последовательность
  «успешный RUB-снимок → ошибка курса + база USD» и без фикса падает (проверено), ожидая
  «· USD» и отсутствие «· RUB». Всего 568 тестов.

### 11.7 Главная не пересчитывается после ввода курса — [x] (2026-11-20)

- **Проблема (QA, TEST_PLAN TC-025):** при базе USD и «Курс недоступен» ручной курс,
  введённый из Аналитики («Ввести курс», 90 ₽ за USD), применяется на графике (20,00 $), но
  Главная продолжает показывать «Курс недоступен» до перезапуска приложения
  (`am force-stop` → «20,00 $»). Доказательства: `screen_051_dashboard_usd_rate.png`,
  `screen_052_dashboard_after_restart.png`.
- **Предполагаемая причина:** `lib/core/features/dashboard/ui/dashboard_view_model.dart`
  подписывается на счета/цели/операции/базовую валюту, но не на `ExchangeRateRepository`,
  поэтому `_reloadNetWorth()` не вызывается при создании/изменении курса.
- **Рабочий план:**
  - **Событие курса:** `exchangeRateRevision` (signal) инкрементируется в
    `ExchangeRateRepositoryImpl.saveManual`/`fetchFromCbr`; DashboardViewModel подписан,
    очищает `_rateCache` и перезапускает net worth/cashflow/цели; `dispose()` отписывается.
  - **Stale cashflow:** при `cashflowError` блок «Денежный поток» показывает ошибку, а не
    устаревшие суммы из прошлого снимка (пункт дизайн-ревью 11.6).
  - **Тесты:** событие курса пересчитывает Главную; ошибка курса скрывает stale-суммы;
    репозиторий инкрементирует revision на manual и CBR.
  - **commit:** `task/11.7: пересчитывать Главную после изменения курса`.
- **Итог:** ручной/CBR курс публикует in-process событие (первый вызов подписки
  пропускается); Главная пересчитывает net worth, cashflow и цели без перезапуска, stale
  cashflow-суммы скрыты. При ошибке курса секция «Денежный поток» показывает отдельный текст
  «Итоги месяца недоступны без курса» и действие «Ввести курс» → Аналитика (без дубля текста
  с net worth). Тесты: событие→новый total, ошибка→нет stale, оба блока без дубля,
  320dp/1.3 error-ветка, revision на manual/CBR. Всего 573 теста. Android (emulator-5556,
  debug): TC-053 PASS — USD/EUR без курса → ручной курс → net worth и cashflow пересчитаны
  без force-stop; TC-054 PASS — отдельные формулировки и CTA «Ввести курс» без дубля;
  TEST_PLAN дополнен. Наблюдение Android QA: «Итого» в базовой валюте = разность уже
  округлённых Доход/Расход (−0,55) — соответствует CALC §6 (`netCashflow = totalIncome −
  totalExpense` от rounded-итогов), дефекта нет.

### 11.8 Висячий разделитель «·» при пустом комментарии — [x] (2026-11-20)

- **Проблема (QA, TEST_PLAN TC-030):** в журналах «Операции по активам» и «Доходы и расходы»
  подпись записи без комментария отрисовывается как «Пополнение ·», «Снятие ·»,
  «Перевод (исходящий) ·» (то же в `content-desc`). Доказательство:
  `screen_084_search_state.png`.
- **Предполагаемая причина:** конкатенация `kindLabel + ' · ' + comment` без проверки пустого
  комментария в элементах журналов (`lib/core/features/transactions/ui/`,
  `lib/core/features/cashflow/ui/`).
- **Рабочий план:**
  - **Fix:** `AppOperationListTile` собирает meta-строку из непустых частей
    (`typeLabel`, `dateText`, `metaParts`) — источник хвоста был пустой `dateText`, а не
    комментарий; заодно подпись Главной не оставляет «дата · » при пустом коде валюты.
  - **Test:** widget-тест «dateText пустой → текст ровно „Расход“, без „ · “».
  - **commit:** `task/11.8: убрать висячий разделитель в журналах`.
- **Итог:** meta-строка и Semantics-label фильтруют пустые части, висячий «·»/«, » исчез
  во всех журналах (общий uikit-компонент); подпись дашборда собирается из непустых частей.
  Doc-комментарий/README/finance.md синхронизированы с фактическими потребителями; добавлен
  позитивный и негативный тест. Android TC-055 PASS: оба журнала без висячего «·» (в т.ч.
  «Пополнение», «Перевод (исходящий)»), детали/аудит чистые; TEST_PLAN дополнен. Всего 575 тестов.

### 11.9 Ручные проверки, недоступные adb-автоматизации — [x] (2026-11-20)

- **Проблема (QA, TEST_PLAN TC-047…TC-050):** в прогоне 11.2 не проверены: биометрия в защите
  приложения (в эмуляторе нет зарегистрированных отпечатков), ввод кириллицы в текстовые поля
  (`adb shell input text` падает с NPE, сторонняя IME запрещена владельцем), валидация будущей
  даты через date picker, адаптивность (размер экрана/масштаб шрифта).
- **Предполагаемая причина:** ограничения окружения adb/uiautomator, не дефект приложения.
- **Решение/Тест:** выполнить вручную на устройстве с биометрией и штатной клавиатурой (или на
  Linux e2e для дат), снять TalkBack-прогон и frame/build counts профилированием (11.3 DoD),
  зафиксировать результаты новыми `TC-*` в `TEST_PLAN.md`; при появлении дефектов завести
  отдельные задачи этапа 11.
- **Дополнительно из 11.3/11.11:** пагинация DAO журнала (сейчас builder ограничивает
  виджеты, но запрос читает все строки) и масштабирование `reservedSize`/крайних подписей
  графиков при text scale > 1.3.
- **Рабочий план:**
  - **Pagination:** `TransactionFilter.limit`, DAO `.limit`, VM страница 200 + `hasMore`
    (limit+1 без ложной кнопки) + «Показать ещё»; cashflow-журнал не пагинируется, пока
    итоги считаются по полному набору (нужен отдельный aggregate).
  - **Charts:** `reservedSize = 8 + textScaler.scale(20)` в bar/line.
  - **Manual (android-tester):** TalkBack, frame counts, date picker, 320dp/1.3; биометрия
    и кириллица — SKIP/BLOCKED.
  - **commit:** `task/11.9: закрыть ручные проверки и пагинацию`.
- **Итог:** `TransactionFilter.limit` + DAO/SQL limit; журнал операций грузит по 200, `hasMore`
  через limit+1 (без ложной кнопки), «Показать ещё» с pending; при поиске лимит не применяется
  (кириллица через SQLite LOWER невозможна — Unicode-фильтр в Dart, регрессионный тест).
  Cashflow-журнал остаётся полным: его итоги считаются по всему набору, отдельный aggregate
  отложен. `reservedSize` графиков масштабируется (8 + textScaler.scale(20)). Android:
  TC-056 TalkBack PASS (FAB/навигация/chart summary), TC-058 pagination PASS (unit/perf),
  TC-059 320dp/1.3 PASS ранее; frame counts BLOCKED (`gfxinfo` 0 под Impeller/TalkBack),
  биометрия SKIP, кириллица BLOCKED (IME запрещена); TEST_PLAN дополнен. Всего 582 теста.
- **Приоритет/зависимости:** P2; ручные проверки на реальном устройстве, **v1 не блокирует**.

### 11.10 Графики денежного потока выходят за пределы карточки — [x] (2026-11-20)

- **Проблема (QA владельца):** на Главной (и Аналитике) столбец расхода рисуется выше
  области графика и выходит за карточку, наезжая на соседний блок. Скриншот:
  dashboard, EUR: доход 0,50 / расход 1,00, столбец расхода ~2× выше области.
- **Причина:** `AppCashflowChart.maxValue` считался вложенным тернарником
  `income > max ? income : expense > max ? expense : max`, поэтому при `income < expense`
  максимум оставался равен доходу: `maxY = 0.575` при столбце `1.0`.
- **Рабочий план:** заменить fold на `math.max(max, math.max(income, expense))`;
  регрессионный тест «maxY ≥ большего столбца» (income 0.5 / expense 1.0 → 1.15).
  **commit:** `task/11.10: исправить масштаб графика денежного потока`.
- **Итог:** `maxY` учитывает оба столбца; тест в `test/uikit/charts_test.dart`; всего
  574 теста. Затронуты Dashboard и Аналитика (общий `AppCashflowChart`).

### 11.11 Подписи недель cashflow-графика слипаются на 320dp — [x] (2026-11-20)

- **Проблема (дизайн-ревью 11.10):** на 320dp подписи `01–07.11` / `08–14.11` наезжают друг на
  друга: `contentWidth = max(width, groups×36+24)`, а одна подпись `labelSmall` занимает ~47dp;
  горизонтальный скролл не включается. Доказательство: `dr11_10_labels_320dp.png`.
- **Рабочий план:**
  - **Fix:** шаг считается по фактической ширине `labelSmall` (TextPainter + text scale)
    и ширине слота; пропуск применяется в `getTitlesWidget` (BarChart игнорирует
    `interval` для подписей), шаг якорится на последний период.
  - **Test:** 320dp/1.3 (внутренняя ширина 234, 5 недель) — подписи не пересекаются и
    последняя видна; на широком экране — все пять.
  - **Docs:** правило в `charts.md §3`.
  - **commit:** `task/11.11: развести подписи cashflow-графика`.
- **Итог:** подписи фильтруются по индексу, шаг от фактической ширины текста/text scale
  и якорится на последний период; на 320dp/1.3 видны не все 5 недель (2–3 в зависимости
  от шрифта) без пересечений,
  последняя дата подписана, на широких экранах — все; горизонтальный скролл сохранён.
  Всего 576 тестов. Отложено: масштабирование `reservedSize` при text scale > 1.3 — в 11.9.
- **Приоритет/зависимости:** P2; после 11.10 / в рамках 11.3. **BR:** DESIGN/a11y.

## Этап 12 — Расширения после v1

### 12.1 Восстановление soft-deleted операций — [x] (2026-11-20)

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
- **Рабочий план:**
  - **DAO:** `TransactionsDao.restore` (deposit/withdrawal с проверкой баланса; обе ноги
    перевода), `CashflowDao.restore`/`restoreFromAsset`; restore-ревизии.
  - **Repositories:** `restore`/`restoreTransfer`; связанная пара восстанавливается через
    операцию; standalone cashflow — отдельно.
  - **UI:** кнопка «Восстановить» в аудите операции/cashflow, если последняя ревизия delete;
    pending и ошибка.
  - **BR:** BR-T-11, BR-IE-18; architecture-карта 100 BR.
  - **commit:** `task/12.1: восстановить удалённые операции`.
- **Итог:** restore возвращает операцию/перевод/связанную пару с новыми restore-ревизиями,
  повторной проверкой баланса и атомарностью; аудит показывает «Восстановить» и ошибку
  restore. Тесты: restore + повторный conflict + баланс + перевод + linked pair + standalone cashflow.
  589 тестов.
- **DoD:** до согласования не реализовывать; при реализации BR docs обновлены, migrations/
  generated и общий DoD pass. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.1: восстановить удалённые операции`.

### 12.2 Сравнение активов — [x] (2026-11-20)

- **Приоритет/зависимости:** P2; после 11.4. **BR:** S-2…5, C-5.
- **Files:** Create comparison domain/query/screen/VM/chart section и unit/widget/integration
  tests в analytics paths; Modify routes/DI/ARB/navigation docs.
- **Consumes:** netWorthSeries и asset selection.
- **Produces:** выбор 2–5 активов, общий period/base currency, normalized/absolute режим,
  accessible comparison table.
- **TDD:** разные валюты/даты, missing valuation, archived asset, empty overlap, >5 reject;
  line labels и text values совпадают.
- **Рабочий план:**
  - **Query:** `AnalyticsQueries.netWorthSeries(assetId)` — серия одного актива в base.
  - **VM:** выбор 2–5, period month/3/6/year/all, absolute/normalized (первый ненулевой = 100),
    лимит >5 игнорируется, пустые серии.
  - **UI:** экран `/more/compare` (выбор, чипы периода, segmented режим, line chart с summary,
    доступная таблица); вход из «Ещё».
  - **commit:** `task/12.2: добавить сравнение активов`.
- **Итог:** доступно сравнение 2–5 активов в base currency за общий период; absolute — суммы,
  normalized — индекс 100 от первого ненулевого; график + таблица, 320dp/1.3 route покрыт.
  Тесты VM: absolute/normalized, лимит 5, zero-start, union дат, пустая серия, архивные.
  Всего 594 теста.
- **DoD:** normalized режим явно подписан и не смешан с Money totals; общий DoD/design review.
  Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.2: добавить сравнение активов`.

### 12.3 Доходность недвижимости за 12 месяцев — [x] (2026-11-21)

- **Приоритет/зависимости:** P2; после 11.4. **BR:** RE-6.
- **Files:** Create property yield calculator/presentation section и tests; Modify property
  details VM/screen/ARB/calculations doc.
- **Consumes:** trailing 12-month cashflow и latest property valuation.
- **Produces:** gross/net yield, оценочность и null при zero current value.
- **TDD:** annual rent 120000/value 5m → gross 2.4%; expenses 20000→net 2.0%; exact 12-month
  boundaries; zero value→null; valuation repair cashflow не меняет.
- **Рабочий план:**
  - **Calculator:** `PropertyYieldCalculator` — gross/net по income/expense.amountRub и
    valueRub за 12 месяцев, null при value ≤ 0.
  - **UI:** секция в деталях недвижимости: gross/net %, «оценочно», unavailable без данных;
    value — последняя оценка.valueRub, иначе RUB currentValue.
  - **Docs/tests:** CALC-036 + golden 120k/20k/5m → 2.4/2.0; границы и отрицательный net.
  - **commit:** `task/12.3: рассчитать доходность недвижимости`.
- **Итог:** CALC-036 реализован; доходность за последние 12 месяцев показывается в деталях
  недвижимости, нулевая стоимость → «Недостаточно данных»; denominator — последняя оценка
  (`valuations.first`), данные реактивны (watch 12m + пересчёт при balance/валютe), ошибки
  показываются. Golden 2,4%/2,0%, отрицательный net, границы периода/clamp 29 февраля.
  Architecture-карта: CALC-036 покрыт. Всего 598 тестов.
- **DoD:** формулы и golden values добавлены до кода, нет обещания инвестиционной рекомендации;
  общий DoD. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.3: рассчитать доходность недвижимости`.

### 12.4 Онбординг и первичный сценарий — [x] (2026-11-21)

- **Приоритет/зависимости:** P2; после 11.4. **BR:** A-1, C-5, IE-1…3, accessibility.
- **Files:** Create onboarding domain persistence/screens/VM и tests; Modify app start/router/
  DI/ARB/navigation docs; Test first launch/complete/skip/restart.
- **Consumes:** app_settings versioned onboarding flag и реальные create asset/operation flows.
- **Produces:** короткое объяснение original currency/backup/privacy, выбор base currency,
  первый asset CTA, skip и отсутствие повторного показа.
- **TDD:** fresh DB показывает один раз; skip/complete сохраняется; import backup переносит
  флаг; offline работает; font1.3/TalkBack/back не ловят пользователя.
- **Рабочий план:**
  - **Persistence:** `OnboardingRepository` на `app_settings.onboardingCompleted` (переносится
    backup); `SettingsDao.getValue/setValue`.
  - **UI:** `OnboardingGate` в `MaterialApp.builder` внутри AppLock, экран — под собственным
    `Navigator`: первый запуск показывает объяснение приватности/backup, выбор базовой валюты,
    «Начать»/«Пропустить» (CTA закреплены внизу); системный BACK закрывает sheet онбординга,
  а не приложение.
  - **Tests:** флаг fresh/complete; первый запуск → пропуск → Главная; выбор USD + «Начать»;
    ошибка чтения → inline error + «Повторить»; без сети/демо-активов.
  - **commit:** `task/12.4: добавить первичный онбординг`.
- **Итог:** онбординг показывается один раз, skip/complete сохраняются в БД и переживают
  перезапуск/import; базовая валюта меняется через существующий SettingsRepository; гейт
  не мешает AppLock и тестам (test locator по умолчанию completed). Экран рендерится под
  собственным Navigator (модальный выбор валюты работает), CTA закреплены в bottom bar,
  дубли заголовка/валюты убраны; ошибки чтения/записи не оставляют пустой cold start.
  Тесты: флаг, skip, выбор USD + «Начать», BACK закрывает sheet, ошибки загрузки/сохранения.
  Navigation docs описывают второй гейт в цепочке builder. Ошибка загрузки валют — uikit
  `AppErrorState(compact)` с retry, ошибка сохранения — в закреплённом нижнем баре над CTA
  (bodySmall/error + liveRegion, видна без скролла и без списка валют), спиннер на нажатой
  кнопке, заголовок AppBar — одна строка «Добро пожаловать» (1.3 не обрезается), «Начать»
  недоступно, пока валюта не загружена; базовая
  валюта подмешивается в список, если её нет среди enabled.
  Отложено: skeleton загрузки и pending-состояние retry, callout-акцент для предупреждения
  о backup, icon у inline-ошибки, кадр гейта на cold start, ограничение ширины на fold
  (formMaxWidth), вертикальный баланс пустого низа экрана; вторая CTA переименована в
  «Не менять валюту» (не применяет выбор — это теперь следует из подписи), бэкфилл
  флага существующим установкам (приложение не релизилось), restart-тест на файловой БД,
  первый asset CTA (осознанно сужен до Главной с quick actions). Всего 604 теста.
- **DoD:** не создаёт демо-активы и не запрашивает сеть/аккаунт; общий DoD/design review.
  Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/12.4: добавить первичный онбординг`.

### 12.7 Иконка приложения — [x] (2026-11-21)

- **Запрос владельца:** использовать присланное изображение кошелька с графиком как иконку.
- **Files:** Modify `android/app/src/main/res/mipmap-*/ic_launcher.png`,
  `AndroidManifest.xml` (roundIcon); Create `mipmap-anydpi-v26/ic_launcher.xml`,
  `drawable-*/ic_launcher_foreground.png`, `values/colors.xml`.
- **Итог:** legacy PNG 48/72/96/144/192 и adaptive icon (foreground + background #044938)
  для Android 8+; manifest использует `ic_launcher` как icon/roundIcon. Release APK
  пересобран, иконка проверена на эмуляторе.
- **commit:** `task/12.7: обновить иконку приложения`.

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

### 12.6 Переименовать UI-категорию «Квартира» в «Недвижимость» — [x] (2026-11-20)

- **Проблема (запрос владельца):** UI называет вид актива «Квартира», хотя модель
  поддерживает любую недвижимость; нужно единое название «Недвижимость».
- **Files:** Modify `lib/l10n/app_ru.arb` (все видимые строки и описания), generated
  `app_localizations*.dart`, README/PROJECT (терминология); Test через l10n-ключи.
- **Рабочий план:** переименовать `assetKindProperty`, формы/поля/ошибки, cashflow-секцию,
  фильтры/контекст и empty states; внутренние `AssetKind.property`, таблицы и BR-термины
  не менять; `flutter gen-l10n`; прогнать suite.
  **commit:** `task/12.6: переименовать категорию в недвижимость`.
- **Итог:** все пользовательские строки говорят «недвижимость» (вид актива, формы, фильтры,
  cashflow, empty states), внутренняя модель осталась `property`; тесты используют l10n и
  проходят. Всего 579 тестов.

## Этап 13 — Исправления по полному QA-прогону v1 (release APK, 2026-11-21)

Полный ручной прогон `android-tester` на release-сборке ветки `task/12.4-onboarding`
(43 сценария, 33 PASS / 5 FAIL / 4 SKIP / 1 BLOCKED) — детали в `TEST_PLAN.md`
(TC-062…TC-104). Ниже — задачи по найденным дефектам. Наблюдения без задачи:
архив актива необратим (BR-A-5/A-6 не описывают разархивацию), экран «О приложении»
почти пуст, снятие выбора ниже 2 активов в сравнении игнорируется молча.

**Итоги этапа (2026-11-21):** все задачи 13.1–13.9 закрыты и влиты в `main` (`1d4411f`);
повторный короткий QA-прогон TC-116…TC-119 — PASS (`TEST_PLAN.md`). Локальные гейты
перед релизом: 620 тестов, `dart format`/`flutter analyze --fatal-infos`/
`dart analyze lib --fatal-infos` чисто, Linux e2e 9/9, release APK 69.5 МБ.

### 13.1 Восстановление удалённых операций недоступно из UI — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-074):** после удаления операции/записи денежного потока
  «Восстановить» невозможно вызвать: журналы скрывают soft-deleted строки, экран аудита
  открывается только из деталей существующей записи (кнопка «Открыть аудит» есть лишь в
  состоянии NotFound), а маршрут `/more/audit` — заглушка. Функция 12.1 не достижима.
  Шаги: Операции → «Операции по активам» → операция → «Удалить» → подтвердить → искать
  запись/аудит (их нет). Доказательства: дамп после удаления, `router.dart:771`
  (`audit` в `_morePlaceholders`), фильтр `deletedAt.isNull()` в
  `asset_transaction_repository_impl.dart:95`.
- **Предполагаемая причина:** отсутствует точка входа в аудит удалённых записей: нет списка
  «удалённые»/фильтра в журналах и нет реального экрана `/more/audit`
  (`lib/app/router.dart`, `lib/core/features/transactions/ui/transactions_screen.dart`,
  `lib/core/features/cashflow/ui/cashflow_screen.dart`).
- **Решение/Тест:** добавить в журналы фильтр/секцию «Удалённые» (или экран `/more/audit`
  со списком soft-deleted операций и записей), из которой открывается аудит с кнопкой
  «Восстановить»; проверить restore одиночной операции, перевода (обе ноги), связанной
  пары cashflow↔счёт, повторный conflict и отклонение при недостатке средств/архивном
  активе. Перепройти TC-074 и добавить widget-тест достижимости кнопки из журнала.
- **Итог:** реальный экран `/more/audit` («Ещё → Удалённые операции»): `AppSegmentedControl`
  «Операции по активам»/«Доходы и расходы» со счётчиками, ленивый список soft-deleted
  записей (`watchDeleted`, порядок по дате удаления), имя актива/категории в заголовке,
  знак суммы и тон как в журналах, дата удаления в meta, без бейджа (контекст задаёт экран),
  `AppEmptyState`, `ViewLoading` → спиннер, «залипающая» ошибка с retry, guard `_disposed`.
  Переход в аудит с «Восстановить»; восстановленная запись исчезает. Тесты: watchDeleted
  (только удалённые, restore убирает), экран (переключатель, empty, переход в детали).
  Тест «Ещё → Удалённые операции» проверяет достижимость экрана. Отложено (решение
  владельца): записи, удалённые отвязкой классификации, показываются в
  табе cashflow, но restore уходит в операцию и падает — скрыть или объяснить; группировка
  по датам. TC-074 перепройти на Android.

### 13.2 Форма инвестиции ломается после создания брокера из неё — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-085):** «Активы → + → Добавить инвестицию → Добавить брокера
  → создать → Назад» возвращает форму в нерабочем состоянии: «Брокер —», «Валюта —»,
  «Сохранить» disabled, подсказка «Сначала добавьте брокера…» остаётся; через несколько
  секунд состояние не восстанавливается. Выход и повторный вход в форму работают.
  Доказательства: `qa_012_inv_after_back.png`.
- **Предполагаемая причина:** `InvestmentFormViewModel.load()` после возврата ожидает
  `subgroupRepository.watchByKind(...).first`, который при повторной подписке не эмитит
  значение — загрузка валют не начинается; `_loaded` уже true, поэтому спиннер не виден
  (`lib/core/features/assets/ui/investment_form_screen.dart:142-151`,
  `lib/core/features/assets/ui/investment_form_view_model.dart:44-56`).
- **Решение/Тест:** перезагружать справочники без ожидания первой эмиссии watch-стрима
  (снимок `getByKind`/кэш репозитория) либо явно пересоздавать VM после `push`;
  показать спиннер/ошибку, если load не завершился. Проверить сценарий TC-085 и
  аналогичные возвраты из справочников (категории/валюты).
- **Итог:** причина — роутер создаёт ViewModel в `builder`, поэтому после возврата из
  справочника экран получал новый пустой экземпляр без `load()`. Формы инвестиции и счёта
  держат VM в `State`, в `didUpdateWidget` освобождают старую и грузят текущую; выбранный
  брокер/банк валидируется по актуальному списку. `SubgroupRepository.getByKind` —
  одноразовый снимок справочника. Тест строит VM в `builder` роутера, как в приложении:
  без `didUpdateWidget` падает на «Сначала добавьте брокера…», с фиксом — форма
  перезагружается. Обе формы показывают `AppSpinner`/`AppErrorState` с retry (форма счёта —
  тоже), возврат из справочника не бланкирует форму (без потери ввода/скролла), retry идёт
  через `_load()` с подстановкой брокера. TC-085 перепройти на Android после merge.

### 13.3 Пустой лист выбора банка в форме счёта — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-086):** при отсутствии банков тап по полю «Банк» открывает
  пустую панель с одним заголовком — без empty state и без действия. Пользователь в тупике:
  нужно вручную уйти в «Ещё → Банки и брокеры». В форме инвестиции аналогичный кейс решён
  кнопкой «Добавить брокера». Доказательства: `qa_003_bank_sheet2.png`.
- **Предполагаемая причина:** `AppSelect`/`AppSelectSheet` не поддерживает пустой список и
  CTA создания (`lib/uikit/app_select.dart`, `account_form_screen.dart`).
- **Решение/Тест:** для пустого списка показывать «Банков пока нет» и кнопку «Добавить банк»
  (переход в справочник + возврат с выбранным банком) либо заменить поле на CTA как в форме
  инвестиции; перепройти TC-086.
- **Итог:** при пустом справочнике вместо пустого листа формы показывают «Сначала добавьте
  банк в справочнике.» и text-CTA «Добавить банк» (переход в справочник); после возврата
  список перечитывается, банк подставляется. Тот же паттерн применён к форме инвестиции
  (брокеры): мёртвый пустой `AppSelect` скрыт, остаётся текст + «Добавить брокера».
  Переключение «Банки | Брокеры» в запушенном справочнике идёт через `pushReplacement`,
  а не `go` — стек с незасохранённой формой не теряется. Тест проверяет CTA, `kind=bank`,
  переход и обновление поля. TC-086 перепройти на Android.

### 13.4 Плейсхолдер «0» в балансе и ставке счёта вводит в заблуждение — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-083):** поля «Начальный баланс» и «Ставка, % годовых» показывают
  `0` как hint, но валидация считает их пустыми: «Сохранить» даёт «Введите неотрицательную
  сумму в основных единицах.», затем «Ставка должна быть от 0 до 100.» — пользователь видит
  «0» и не понимает, чего не хватает. Счёт с нулевым балансом создаётся только после ручного
  ввода обоих нулей. Доказательства: `qa_010_wallet_err.png`, дамп `hint="0" text=""`.
- **Предполагаемая причина:** `_opening`/`_rate` созданы пустыми с hint `0`, а
  `parseOpeningAmount`/`Decimal.tryParse` возвращают null на пустой строке
  (`account_form_screen.dart:102-119`, `account_form_view_model.dart:99-110`).
- **Решение/Тест:** инициализировать контроллеры значением `0` (или не показывать hint `0`,
  если поле обязательно), подсвечивать конкретное поле ошибкой; перепройти TC-083.
- **Итог:** пустые «Начальный баланс» и «Ставка, % годовых» трактуются как ноль при
  сохранении (подсказка `0` больше не противоречит валидации); явный неверный ввод
  по-прежнему отклоняется. Тест: счёт создаётся с пустыми полями, draft содержит
  `openingValue = 0` и `annualRate = 0`, ошибок нет. TC-083 перепройти на Android.

### 13.6 Аудит показывает невосстановимые записи — [x] (2026-11-21)

- **Проблема (ревью 13.1):** запись денежного потока, удалённая отвязкой классификации,
  попадает в таб «Доходы и расходы», но `restore` уходит в активную операцию и всегда
  падает «Не удалось восстановить запись» — мёртвая кнопка.
- **Решение/Тест:** в аудите показывать только восстановимые записи: `restorableEntries`
  скрывает записи с `assetTransactionId`, чья операция не удалена (связанные с удалённой
  операцией остаются — restore любой стороны восстанавливает пару). Счётчик таба считает
  только видимые. Тест: запись с id активной операции скрыта, со удалённой и без связи —
  видны.
- **Итог:** мёртвых restore-кнопок в аудите нет; решение для отвязанных записей —
  единственное безопасное (восстанавливать их отдельно нельзя, иначе расход/доход
  вернётся без связи со счётом). Дополнительно: `restoreFromAsset` берёт последнюю
  удалённую связанную запись (`ORDER BY id DESC LIMIT 1`), а restore-путь аудита ловит
  `Object` — дубли связей больше не дают `StateError` без сообщения. Всего 617 тестов.

### 13.5 Экран блокировки не скрывает семантику приложения — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-094):** при активном PIN-оверлее `uiautomator dump` содержит
  полное дерево экрана под блокировкой (заголовки настроек, действия, суммы), т.е. TalkBack
  может прочитать финансовые данные, пока приложение заблокировано. Доказательства: дамп
  после `keyevent 3` + `am start` (в одном дереве «Введите PIN-код» и «Отключить защиту»).
- **Предполагаемая причина:** `AppLockGate` рисует оверлей поверх приложения, не исключая
  семантику дочернего дерева (`lib/core/features/applock/ui/app_lock_gate.dart`, `app.dart`).
- **Решение/Тест:** обернуть заблокированный контент в `ExcludeSemantics`/`Semantics(hidden)`
  (и `TickerMode`), проверить TalkBack-навигацию при блокировке и после разблокировки;
  перепройти TC-094.
- **Итог:** содержимое под локом обёрнуто в `ExcludeSemantics` + `ExcludeFocus` +
  `TickerMode(enabled: false)` — узлы контента не попадают в семантическое дерево (тот же
  источник, что отдаётся платформе для TalkBack/uiautomator), после разблокировки семантика
  возвращается. Widget-тест проверяет дерево до/после unlock; негативный контроль (без
  `ExcludeSemantics`) падает — проверено вручную при отладке. Проверка на устройстве
  (`uiautomator dump`) — в TC-094, перепрогнать на Android после merge.

### 13.7 Удаление более ранней операции отвечает «Не удалось загрузить данные» — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-114):** попытка удалить операцию, после которой история баланса
  счёта стала бы некорректной (например, самое раннее «Пополнение 500» при последующем
  переводе 300), молча не удаляет запись и показывает общий snackbar «Не удалось загрузить
  данные. Попробуйте позже.». Шаги: Zero → пополнение 500 → перевод 300 → пополнение 100 →
  журнал → «Пополнение 500» → «Удалить» → подтвердить. Доказательства: `qa_r1_del_blocked.png`.
- **Предполагаемая причина:** `_assertHistoryBalance` (`lib/core/database/daos/transactions_dao.dart:263`)
  бросает конфликт с `validationNegativeBalance`, а экран деталей маппит только
  `validationTransferLegDirectEdit` (`transaction_details_screen.dart:192-207`).
- **Решение/Тест:** отдавать отдельное сообщение для `validationNegativeBalance`; тест на
  snackbar с понятным текстом. Перепройти TC-114.
- **Итог:** экран деталей различает причины отказа: нога перевода, нарушение истории баланса
  и общий случай. Для истории — «Нельзя удалить: после этой операции остаток счёта станет
  отрицательным.». Тест: fake softDelete бросает negativeBalance → snackbar с новым текстом.

### 13.8 Пустой «Начальный баланс» в формах активов: hint `0`, но ошибка — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-115):** в форме инвестиции поле «Начальный баланс» показывает
  `0` как hint, но с пустым значением «Сохранить» даёт «Введите неотрицательную сумму в
  основных единицах.». То же по коду в формах недвижимости, оценки, цели, дохода/расхода и
  перевода (13.4 исправила только счёт).
- **Предполагаемая причина:** `parseOpeningAmount` вызывается без обработки пустой строки
  (`investment_form_screen.dart`, `property_form_screen.dart`, `valuation_form_screen.dart`).
- **Решение/Тест:** трактовать пустое поле как `0` там, где ноль допустим (`allowZero`);
  общий хелпер; перепройти TC-115 и TC-108.
- **Итог:** `parseOpeningAmountOrZero` в общем хелпере; формы инвестиции и недвижимости
  сохраняют пустой начальный баланс как 0; оценка оставляет «стоимость обязательна»
  (пустое значение там — не пропущенный ноль, а незаполненное поле); цель, доход/расход и
  перевод остаются строгими — ноль там недопустим по доменным правилам. Тест: инвестиция
  с пустым балансом создаёт draft с `openingValue = 0` без ошибки; юнит-тесты хелпера
  (`''`, пробелы, `0`, `-1`, мусор). TC-115/TC-108 перепрогнать вместе с релизным QA.

### 13.9 Перевод нельзя удалить из UI — восстановление перевода непроверяемо — [x] (2026-11-21)

- **Проблема (QA, TEST_PLAN TC-113):** удалить перевод из интерфейса невозможно: в деталях
  операции кнопка «Удалить» скрыта для ног перевода (`transferId != null`), в «Действиях с
  активом» только «Архивировать»/«Удалить актив». Сценарий «удалить перевод → восстановить
  обе ноги из аудита» недостижим, хотя репозиторий умеет `softDeleteTransfer`/`restoreTransfer`.
- **Решение/Тест:** в деталях ноги перевода показывать «Удалить перевод» с подтверждением
  (удаляются обе ноги, балансы откатываются), запись попадает в «Удалённые операции»;
  восстановление возвращает пару. Перепройти TC-113 и TC-105.
- **Итог:** в деталях ноги перевода кнопка «Удалить перевод» с отдельным подтверждением
  (обе ноги, балансы откатываются); `TransactionDetailsViewModel.delete` вызывает
  `softDeleteTransfer` для перевода и `softDelete` для операции. Тексты честные для перевода:
  подтверждение без «отката» (балансы вернутся, восстановление в «Удалённых операциях»),
  отказ по балансу отдельный («на одном из двух счетов»), успех — «Перевод удалён.»,
  конфликт — «уже удалён или повреждён». После удаления обе ноги видны в «Удалённых
  операциях», restore возвращает пару. Тесты: удаление ноги вызывает `softDeleteTransfer`,
  `softDelete` не вызывается; тексты диалога и успеха проверяются.

## Этап 14 — Инфраструктура релиза

### 14.1 versionCode релиза из pubspec — [x] (2026-11-21)

- План зафиксирован постфактум: реализация велась в ветке
  `task/14.1-release-version-code`, PR #61 смержен.
- Суть: `.github/workflows/release.yml` больше не передаёт
  `--build-number=${github.run_number}` — versionCode берётся из `pubspec.yaml`
  (`+N`), как у локальных сборок. В `docs/PROJECT.md` зафиксированы правило
  versionCode и одноразовая миграция с debug-подписи (экспорт → удаление
  приложения → установка release → импорт).
- Код приложения не меняется. PR #61 смержен; правило проверено в
  `release.yml`/`docs/PROJECT.md`, первое фактическое применение — релиз
  v0.1.2 (`0.1.2+3`), versionCode APK проверяется при публикации.
- **Итог:** release workflow больше не переопределяет versionCode; debug→release
  миграция описана; первое применение — v0.1.2 (`0.1.2+3`), versionCode APK
  проверяется при публикации.

## Этап 15 — Регулярные платежи и капитализация вкладов

Источник: `TASKS.md` (2026-11-21). Пожелания владельца: (1) ежемесячные расходы
на содержание недвижимости с датой начала, автогенерацией операций и управлением
на экране объекта; (2) ежемесячные доходы с датой начала; (3) автоматическое
начисление процентов по вкладам с ежемесячной капитализацией до даты закрытия.
Требования: догон пропущенных периодов без удара по производительности;
подробные контракты для исполнения более простыми моделями.

### Решения владельца (уточнены 2026-11-21; не менять молча)

- **D1.** Расход по недвижимости — только `propertyId`, без влияния на баланс
  счёта. Действующий запрет схемы (property/account взаимоисключающи) сохраняется.
- **D2.** День платежа — день месяца из `startDate` (anniversary): 31-го →
  последний день короткого месяца (clamp). Первый платёж фиксированного правила —
  в сам `startDate` (k=0), далее ежемесячно.
- **D3.** Проценты по вкладу: сумма = фактический баланс счёта на дату начисления
  × `annualRate / 1200`, одно округление half away from zero
  (`MoneyMath.fromRational`). Даты — месячные годовщины `startDate` вклада,
  k≥1, до `min(today, endDate)` включительно. Капитализация реальная: связанная
  пара «пополнение + доход» увеличивает баланс вклада (BR-IE-6).
- **D4.** Правка/удаление правила влияет только на будущие периоды. Созданные
  операции остаются как есть (редактируются/удаляются поштучно как обычные).
  Маркер `lastGeneratedPeriod` при правке сохраняется.
- **D5.** Не-RUB без курса на точную дату: период откладывается (маркер не
  двигается), без сети на старте и без подстановки ближайшего курса
  (BR-C-2, CALC-008). Повтор при каждом запуске/возврате из фона/обновлении
  курсов; в UI отметка «ожидает курс».
- **D6.** У правила необязательная `endDate`: генерируются платежи с датой
  ≤ `endDate` включительно; пусто = бессрочно.
- **D7.** Правила без объекта разрешены (подписки и т.п.). Управление: вкладка
  «Регулярные» в журнале операций (единый список) + секции на экранах
  недвижимости/счёта. Автоправило процентов в UI только для чтения (управляется
  формой счёта: ставка/даты).
- **D8.** Производительность и момент генерации: инкрементальный маркер
  `last_generated_period` ('YYYY-MM') на правиле — у актуальных правил нет
  записи вообще (один SELECT активных правил). Триггеры catch-up: холодный
  старт (unawaited после регистрации DI, не блокирует первый кадр), возврат
  из фона (`AppLifecycleState.resumed`), изменение курсов
  (`exchangeRateRevision`), сохранение правила/счёта. Долгое отсутствие →
  только пропущенные периоды, хронологически; транзакция на период
  (операция + маркер атомарно); yield event-loop каждые 200 периодов;
  идемпотентность (pre-check + unique index); ошибка не роняет старт.

### Общая архитектура этапа (контракт; задачи не переписывают чужие части)

- Схема v2: таблица `recurring_cashflow_rules` + колонка
  `cashflow_entries.recurring_rule_id` + частичные unique-индексы.
- Новый feature-каталог `lib/core/features/recurring/`:
  `domain/` (RecurringRule, RecurringRepository), `data/` (impl),
  `logic/` (RecurringSchedule — чистые функции дат; RecurringGenerator —
  генерация через DAO; RecurringCatchupService — коалесцирующий триггер;
  RecurringCommands — CRUD правил с валидацией, появляется в 15.2),
  `ui/` (экраны/VM, появляются в 15.2/15.3).
- Генератор пишет через `CashflowDao`/`TransactionsDao` напрямую, НЕ через
  `CashflowCommands.save` (тот зовёт `ResolveExchangeRate` с сетью ЦБ).
  Курс: RUB → `Decimal.one`; иначе только `rateRepository.find(code, date)`.
- Связанную пару создаёт общий `LinkedCashflowWriter` (15.3):
  `transactionsDao.create(...)` + `cashflowDao.create(..., assetTransactionId)`;
  вызывающий оборачивает вызов в `db.transaction` — так делают
  `CashflowCommands._saveLinked` и генератор. Рублёвый эквивалент —
  `CashflowCommands.rubAmount(amount, currency, rate)` (публичный static).
- Автооперация — обычная `CashflowEntry` (revisionNo 1, ревизия create)
  с `recurringRuleId`; в журнале/аудите выглядит как обычная операция.
- DI: `RecurringDao`, `RecurringRepository`, `RecurringGenerator`,
  `RecurringCatchupService` — в `registerCoreServices`; VM — фабрики
  в `main.dart`/`router.dart` по существующему образцу.

### 15.1 Схема v2, домен и движок регулярных платежей (без UI) — [x] (2026-11-21) · PR #63

- **Приоритет/зависимости:** P1; базовая задача этапа, до 15.2 и 15.3.
  **BR:** новые BR-RC-1…8, 11, 13; существующие BR-VAL-5, BR-IE-6, BR-C-2.
- **Files:**
  - Create: `lib/core/database/tables/recurring_cashflow_rules.dart`;
    `lib/core/database/daos/recurring_dao.dart`;
    `lib/core/features/recurring/domain/recurring_rule.dart`;
    `lib/core/features/recurring/domain/recurring_repository.dart`;
    `lib/core/features/recurring/data/recurring_repository_impl.dart`;
    `lib/core/features/recurring/logic/recurring_schedule.dart`;
    `lib/core/features/recurring/logic/recurring_generator.dart`;
    `lib/core/features/recurring/logic/recurring_catchup_service.dart`;
    `test/core/features/recurring/recurring_schedule_test.dart`;
    `test/core/features/recurring/recurring_dao_test.dart`;
    `test/core/features/recurring/recurring_repository_test.dart`;
    `test/core/features/recurring/recurring_generator_test.dart`;
    `test/core/database/migration_v1_v2_test.dart`;
    `test/generated_migrations/` (generated, коммитится);
    `drift_schemas/drift_schema_v2.json`.
  - Modify: `lib/core/database/app_database.dart` (таблица/DAO в списках,
    `schemaVersion => 2`, `onUpgrade`, `schemaObjectsV2`, onCreate);
    `lib/core/database/tables/cashflow_entries.dart` (`recurringRuleId`);
    `lib/core/database/daos/cashflow_dao.dart` (`CashflowEntryInput.recurringRuleId`,
    create, снапшот); `lib/core/database/revision_snapshots.dart`
    (`cashflowSnapshotFields` + `recurringRuleId`);
    `lib/core/features/audit/data/revision_decoder.dart` (терпимое чтение);
    `lib/core/features/cashflow/domain/cashflow_entry.dart`
    (`CashflowEntry.recurringRuleId`, опциональный параметр);
    `lib/core/features/cashflow/data/cashflow_repository_impl.dart` (маппер);
    `lib/core/database/converters/enum_converters.dart`
    (`RecurringStrategyConverter`); `lib/core/domain/common/local_date.dart`
    (`plusMonthsClamped`);
    `lib/core/features/assets/logic/account_forecast_calculator.dart`
    (делегировать clamp); `lib/core/database/daos/assets_dao.dart`
    (referenceCounts/countReferences + правила);
    `lib/core/features/assets/domain/asset_repository.dart`
    (`AssetReferenceCounts.recurringRules`);
    `lib/core/features/assets/data/asset_repository_impl.dart` (маппинг counts);
    `lib/core/features/assets/ui/account_details_screen.dart`
    (`assetInUseMessage` — 5-й аргумент); `lib/l10n/app_ru.arb`;
    `lib/core/di/register_core_services.dart`; `lib/main.dart`; `lib/app/app.dart`;
    `lib/core/features/backup/data/local_database_backup_service.dart`
    (`installedSchemaVersion = appDatabaseSchemaVersion`);
    `integration_test/helpers/test_app.dart` (ожидание DI в `tapTab`);
    `docs/architecture/data_schema.md`, `business_rules.md`, `domain_model.md`,
    `calculations.md` (§4a — расписание регулярных платежей).
  - Generated (коммитятся): `app_database.g.dart`, `cashflow_dao.g.dart`,
    `recurring_dao.g.dart`, `app_localizations*.dart`, schema dump v2,
    `test/generated_migrations/`.
  - Test: перечисленные выше + расширение `test/core/database/app_database_test.dart`
    (объекты v2 в `sqlite_master`), `test/core/features/backup/` (импорт v1-копии
    в v2-приложение мигрирует), `test/core/domain/` (plusMonthsClamped),
    golden-тесты прогноза вклада остаются зелёными без изменений ожиданий.
- **Consumes:** существующие `CashflowDao`/`TransactionsDao` (create + ревизии +
  проверка истории баланса), `ExchangeRateRepository.find` (кэш точной даты),
  `AppDatabase.today()/clock()`, `MoneyMath`, `LocalDate`.
- **Produces:** схему v2 и миграцию; домен/DAO/репозиторий правил; чистое
  расписание дат; генератор с догоном и отложением периодов; сервис catch-up
  с тремя триггерами; запрет удаления актива с активными правилами.
- **TDD (сначала failing tests, затем реализация):**
  1. `RecurringSchedule.dueDates`: start 31.01.2026, today 17.11.2026, marker
     null, offset 0 → 10 дат: 31.01, 28.02, 31.03, 30.04, 31.05, 30.06, 31.07,
     31.08, 30.09, 31.10 (30.11 > today — исключена).
  2. Clamp високосного года: start 31.01.2024 → 29.02.2024; start 29.02.2024,
     +12 мес → 28.02.2025, +24 мес → 28.02.2026, +48 мес → 29.02.2028.
  3. Marker: marker '2026-09' → только октябрь/ноябрь; marker ≥ текущий период →
     пусто. `endDate` 15.10.2026 → даты ≤ 15.10 включительно. Future start →
     пусто; `nextPayment` возвращает будущую дату (без фильтра today).
  4. Offset: fixed k=0 (первый платёж = startDate); depositInterest k=1.
  5. DAO: create/revise/softDelete; каждая ошибка валидации (список ключей ниже);
     revise сохраняет `lastGeneratedPeriod` и `strategy`; watchByAccount/
     watchByProperty не видят удалённые.
  6. Генератор (in-memory БД, `testNow` = 2026-11-17): правило расхода по
     недвижимости, start 15.09.2026 → 3 операции (15.09/15.10/15.11),
     revisionNo 1, ревизия create, `recurringRuleId` заполнен, маркер '2026-11';
     повторный run → 0 новых.
  7. Доход со счётом `affectsBalance` → связанная пара deposit+income, баланс
     вырос; расход со счётом при нехватке средств → pending `negativeBalance`,
     маркер не сдвинут, операций нет.
  8. USD-правило без курса → pending `rateUnavailable`, маркер не сдвинут;
     после `saveManual` → run генерирует с этим курсом, `amountRubMinor` точный.
     RUB-правило офлайн → генерируется (курс 1).
  9. Удалённая пользователем автооперация не пересоздаётся (pre-check видит
     soft-deleted), маркер двигается.
  10. Архивный актив/архивная категория → pending, операций нет. Удалённое
     правило → не генерирует. Правка суммы → прошлые операции не тронуты,
     следующий период по новой сумме.
  11. Долгое отсутствие: start 15.01.2020 → 83 периода, маркер '2026-11';
     start 31.01.2020 → 82 периода (последняя 31.10.2026), маркер '2026-10'.
  12. Миграция v1→v2: данные v1 целы, `user_version` = 2, новые таблица/колонка/
     индексы на месте; импорт v1-backup в v2-приложение проходит.
  13. `deleteIfUnused` актива с активным правилом → conflict `validationAssetInUse`;
     `referenceCounts` учитывает правила.
- **Рабочий план:**
  1. **Схема.** Таблица `RecurringCashflowRules`
     (`@DataClassName('RecurringCashflowRuleRow')`), колонки:
     `id` (autoIncrement PK); `strategy` TEXT NOT NULL
     CHECK IN ('fixed','deposit_interest') через новый
     `RecurringStrategyConverter` (enum `RecurringStrategy { fixed, depositInterest }`
     в `recurring_rule.dart`, конвертер — по образцу существующих, неизвестное
     значение → `FormatException`); `kind` TEXT NOT NULL CHECK IN
     ('income','expense') (`CashflowKindConverter`); `categoryId` INTEGER NOT NULL
     REFERENCES categories(id) RESTRICT; `amountMinor` INTEGER NULL
     CHECK (amount_minor IS NULL OR amount_minor > 0); `currencyCode` TEXT NOT NULL
     REFERENCES currencies(code) RESTRICT; `accountId`/`propertyId` INTEGER NULL
     REFERENCES assets(id) RESTRICT; `affectsBalance` BOOLEAN NOT NULL;
     `startDate` TEXT NOT NULL (`LocalDateConverter`); `endDate` TEXT NULL;
     `comment` TEXT NULL; `lastGeneratedPeriod` TEXT NULL ('YYYY-MM');
     `createdAt`/`updatedAt` TEXT NOT NULL (`UtcTimestampConverter`);
     `deletedAt` TEXT NULL. Табличные CHECK:
     `NOT (property_id IS NOT NULL AND account_id IS NOT NULL)`;
     `affects_balance = 0 OR account_id IS NOT NULL`;
     `end_date IS NULL OR start_date <= end_date`;
     `(strategy = 'fixed' AND amount_minor IS NOT NULL) OR (strategy = 'deposit_interest' AND amount_minor IS NULL)`;
     `strategy = 'fixed' OR (kind = 'income' AND account_id IS NOT NULL AND affects_balance = 1)`.
     Индексы: `{#deletedAt}`, `{#accountId}`, `{#propertyId}`.
     В `CashflowEntries` добавить `recurringRuleId` INTEGER NULL REFERENCES
     recurring_cashflow_rules(id) RESTRICT (без нового индекса в drift —
     частичный unique ниже).
  2. **Runtime DDL.** `const schemaObjectsV2 = <String>[...]`:
     `CREATE UNIQUE INDEX recurring_active_deposit_interest ON recurring_cashflow_rules (account_id) WHERE strategy = 'deposit_interest' AND deleted_at IS NULL`;
     `CREATE UNIQUE INDEX cashflow_recurring_period ON cashflow_entries (recurring_rule_id, occurred_on) WHERE recurring_rule_id IS NOT NULL`
     (unique по всем строкам, включая soft-deleted: удаление автооперации
     пользователем окончательно, BR-RC-4). onCreate применяет V1+V2;
     `onUpgrade: (m, from, to) async { if (from < 2) { await m.createTable(recurringCashflowRules); await m.addColumn(cashflowEntries, cashflowEntries.recurringRuleId); for (final s in schemaObjectsV2) { await customStatement(s); } } }`.
     Дамп: `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`.
  3. **Миграционный тест.** `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`
     (generated коммитится). Тест: сгенерированный `SchemaVerifier` →
     `startAt(1)` → `AppDatabase(executor: connection)` (drift сам выполнит
     onUpgrade при первом запросе) → ассерты: `PRAGMA user_version` = 2;
     таблица/колонка/оба индекса v2 в `sqlite_master`; fixture-строки v1
     (актив, cashflow) целы; `PRAGMA foreign_key_check` пуст.
     `verifier.migrateAndValidate` НЕ использовать: schema dump не содержит
     runtime DDL (schemaObjectsV1/V2), семантическое сравнение даст ложный
     `SchemaMismatch`. Присутствие объектов V1 на свежей БД уже покрыто
     `app_database_test.dart` — расширить его объектами V2.
  4. **Домен.** `recurring_rule.dart`: `enum RecurringStrategy`;
     `final class RecurringRule` (id, strategy, kind, categoryId, `Money? amount`
     (null только у depositInterest), currencyCode, accountId, propertyId,
     affectsBalance, startDate, endDate, comment, `String? lastGeneratedPeriod`,
     createdAt, updatedAt, deletedAt); `final class RecurringRuleDraft`
     (strategy, kind, categoryId, `Money? amount`, currencyCode, accountId,
     propertyId, affectsBalance, startDate, endDate, comment).
     `RecurringRepository` (abstract): `Stream<List<RecurringRule>>
     watchActive({RecurringStrategy? strategy})`,
     `watchByAccount(int)`, `watchByProperty(int)`,
     `Future<RecurringRule> getById(int)`, `Future<int> create(draft)`,
     `Future<void> revise(int id, draft)`, `Future<void> softDelete(int id)`.
     Impl мапит row↔domain (Money по currencyCode; amount null ↔ depositInterest).
  5. **DAO.** `RecurringDao extends DatabaseAccessor<AppDatabase>`
     `@DriftAccessor(tables: [RecurringCashflowRules, Assets, Categories, CashflowEntries])`:
     `watchActive({strategy})` (deletedAt IS NULL, order by id),
     `watchByAccount/watchByProperty` (активные), `getById` (нет →
     `DomainException(notFound, {'ruleId': 'validationRuleNotFound'})`),
     `create(RecurringRuleInput)`, `revise(id, input)` (strategy и
     lastGeneratedPeriod не меняются; удалённое → conflict
     `validationRuleDeleted`), `softDelete(id)` (повтор → conflict),
     `Future<List<RecurringCashflowRuleRow>> activeRules()`,
     `updateLastGeneratedPeriod(id, String period)`,
     `Future<CashflowEntryRow?> findGeneratedEntry(int ruleId, LocalDate date)`
     (по recurringRuleId+occurredOn, ВКЛЮЧАЯ deleted),
     `Future<int> countActiveByAsset(int assetId)`.
     Валидация create/revise (зеркало `CashflowDao._validate`, ключи
     fieldErrors): amount>0 для fixed (`validationAmountPositive`); категория
     существует/ kind совпадает/ не архивна (`validationCategoryNotFound`,
     `validationCategoryKindMismatch`, `validationCategoryArchived`);
     property — kind=property (`validationPropertyKind`); account — kind=account
     (`validationAccountKind`) и валюта счёта = валюта правила
     (`validationCurrencyMismatch`); взаимоисключение
     (`validationPropertyAndAccountExclusive`); affectsBalance⇒account
     (`validationBalanceRequiresAccount`); endDate<startDate
     (`validationRecurringDates`); depositInterest создаётся только генератором
     (в публичном create strategy всегда fixed; `validationRecurringStrategy`).
  6. **Расписание.** В `LocalDate` добавить `LocalDate plusMonthsClamped(int months)`
     (перенос логики `AccountForecastCalculator._addMonthsClamped`: тот же день
     месяца, clamp до последнего дня; `months >= 0`); forecast-калькулятор
     делегирует (его golden-тесты CALC-016…018 не менять).
     `abstract final class RecurringSchedule`:
     `static String periodKey(LocalDate d)` → 'YYYY-MM' (padLeft);
     `static List<LocalDate> dueDates({required LocalDate startDate,
     LocalDate? endDate, required LocalDate today,
     required String? lastGeneratedPeriod, required int firstPeriodOffset})` —
     даты `startDate.plusMonthsClamped(k)`, k от firstPeriodOffset, фильтр:
     `date <= today`, `endDate == null || date <= endDate`,
     `lastGeneratedPeriod == null || periodKey(date) > lastGeneratedPeriod`;
     по возрастанию; страховка k ≤ 12000;
     `static LocalDate? nextPayment({startDate, endDate, lastGeneratedPeriod,
     firstPeriodOffset})` — первая годовщина после маркера с учётом endDate,
     БЕЗ фильтра today (для UI «следующий платёж»).
  7. **Генератор.** `class RecurringGenerator({required AppDatabase db,
     required ExchangeRateRepository rateRepository,
     required CurrencyRepository currencyRepository})`;
     `Future<RecurringGenerationReport> run({int chunkSize = 200})`.
     `RecurringGenerationReport { int generated; List<RecurringPending> pending }`;
     `RecurringPending { int ruleId; LocalDate date; RecurringPendingReason reason }`;
     `enum RecurringPendingReason { rateUnavailable, negativeBalance,
     categoryUnavailable, assetArchived, validation }`.
     Алгоритм (в 15.1 только strategy=fixed; depositInterest добавит 15.3):
     a) один SELECT активных правил + активы одним запросом (map id→row);
     b) правило с архивным активом → pending `assetArchived` (все due-даты не
     генерируются; маркер не двигается); dueDates через RecurringSchedule
     (offset 0, today = `db.today()`);
     c) собрать пары (rule, date), сортировка `(date, strategy fixed раньше
     depositInterest, ruleId)` — чтобы проценты видели все потоки того же дня;
     d) для каждой пары: pre-check `findGeneratedEntry` — есть (даже удалённая)
     → только двигать маркер; курс: RUB → 1, иначе `rateRepository.find` —
     null → pending `rateUnavailable` и STOP оставшихся периодов этого правила
     (маркер не двигается), остальные правила продолжаются;
     e) запись в `db.transaction`: при `affectsBalance` —
     `transactionsDao.create(AssetTransactionInput(kind: deposit/withdrawal,
     assetId: accountId, amountMinor, occurredOn: date, rateToRub,
     amountRubMinor, comment: rule.comment))` затем
     `cashflowDao.create(CashflowEntryInput(..., affectsBalance: true,
     accountId, assetTransactionId: txId, recurringRuleId: rule.id))`; иначе
     `cashflowDao.create(..., affectsBalance: false, propertyId/accountId,
     recurringRuleId: rule.id)`; в той же транзакции
     `updateLastGeneratedPeriod(rule.id, periodKey(date))`;
     f) `DomainException` периода (negativeBalance, архивная категория,
     несовпадение валюты и т.п.) → pending с соответствующим reason, STOP
     правила; прочие исключения → `developer.log`, STOP правила; `run()`
     никогда не бросает; g) каждые `chunkSize` обработанных периодов —
     `await Future<void>.delayed(Duration.zero)` (уступка event-loop).
     Рублёвый эквивалент: `CashflowCommands.rubAmount` + валюта из
     `currencyRepository.watchAll().first` (orElse — fallback Currency как
     в существующих командах).
  8. **Сервис и триггеры.** `class RecurringCatchupService({required
     RecurringGenerator generator})`: `Future<void> catchUp()` — коалесцирование
     (`_running`/`_queued` по образцу `AccountDetailsViewModel._reloading`);
     результат — `developer.log` (generated/pending); никогда не бросает.
     Регистрация в `registerCoreServices`: `db.recurringDao`,
     `RecurringRepositoryImpl`, `RecurringGenerator(db, rateRepository,
     currencyRepository)`, `RecurringCatchupService`.
     Триггеры: `main.dart` — после регистрации сервисов
     `unawaited(locator.get<RecurringCatchupService>().catchUp())`;
     `app.dart` — `_FinanseAppState with WidgetsBindingObserver`
     (initState addObserver/dispose removeObserver):
     `didChangeAppLifecycleState(resumed)` → catchUp; в initState —
     `effect(() { exchangeRateRevision.value; unawaited(catchUp()); })`
     (с очисткой в dispose; подписка по образцу DashboardViewModel).
  9. **Ссылочная целостность.** `assets_dao.referenceCounts` + пятый
     подзапрос `(SELECT COUNT(*) FROM recurring_cashflow_rules
     WHERE (account_id = ?1 OR property_id = ?1) AND deleted_at IS NULL) AS recurring`;
     `countReferences` включает его; `AssetReferenceCounts.recurringRules`
     (+ total); `assetInUseMessage` в arb получает 5-й аргумент
     («правил: {count}»), единственный вызов —
     `account_details_screen.dart` `_delete`.
  10. **Снапшоты/аудит.** `cashflowSnapshotFields` + параметр
     `required int? recurringRuleId` → ключ 'recurringRuleId'; все вызовы
     (cashflow_dao) передают row.recurringRuleId; `revision_decoder` читает
     `data['recurringRuleId'] as int?` (старые снапшоты без ключа → null);
     `CashflowEntry` — опциональный `this.recurringRuleId`; маппер
     `cashflow_repository_impl` заполняет. `CashflowEntryInput` — опциональный
     `this.recurringRuleId`; `create` пробрасывает в Companion; revise-методы
     колонку не трогают (связь сохраняется).
  11. **Docs.** `data_schema.md`: §5 — колонка recurring_rule_id; новый §10
     «Регулярные платежи» (DDL, индексы, маркер); §7 — миграция v2.
     `business_rules.md`: секция BR-RC (правила 1…8, 11, 13 ниже) + строки
     покрытия. `domain_model.md`: RecurringRule. `calculations.md`: §4a
     «Расписание регулярных платежей» (anniversary+clamp, offset 0/1, маркер).
     BR-RC-1 состав правила; BR-RC-2 даты (D2); BR-RC-3 только ≤ today и
     ≤ endDate, маркер; BR-RC-4 одна операция на (правило, дата), удаление
     окончательно; BR-RC-5 автооперация = обычная запись с ревизией;
     BR-RC-6 курс точной даты, отложение (D5); BR-RC-7 правка только будущих
     периодов (D4); BR-RC-8 архивные актив/категория останавливают генерацию;
     BR-RC-11 триггеры/инкрементальность (D8); BR-RC-13 удаление актива с
     активными правилами запрещено.
- **DoD:** общий DoD; миграция проверена тестом на реальных v1-данных;
  прогноз вклада (CALC-016…018) не изменился; catch-up не блокирует старт
  (unawaited) и не ходит в сеть; `git diff --check`; статус `[x]` + дата до PR;
  task-reviewer (UI нет — design-reviewer не нужен, кроме строки
  assetInUseMessage — при сомнении запустить). Перед PR спросить о e2e.
- **Итог:** схема v2 и миграция проверены на файловой v1-БД (таблица, колонка,
  3 drift-индекса + 2 runtime-индекса, данные целы, `foreign_key_check` пуст);
  генератор идемпотентен, не-RUB без курса откладывает без сети, RUB работает
  офлайн; catch-up не блокирует старт. По ревью 15.1 добавлены drift-индексы в
  `onUpgrade`; при удалении актива у перевешенных автоопераций очищается ссылка
  на soft-deleted правило, после чего правило удаляется (FK RESTRICT и CHECK
  `affects_balance` не ломаются, операции и их ревизии сохраняются). Общий writer
  связанной пары вынесен в 15.3 (WILL ROT). Всего 670 тестов; release APK
  собирается.
- **Предлагаемый commit:** `task/15.1: схема и движок регулярных платежей`.

### 15.2 UI ежемесячных платежей: форма, вкладка «Регулярные», секции активов — [x] (2026-11-21) · PR #64

- **Приоритет/зависимости:** P1; после 15.1. **BR:** BR-RC-1…8, 11, 12;
  BR-VAL-7; accessibility.
- **Files:**
  - Create: `lib/core/features/recurring/logic/recurring_commands.dart`;
    `lib/core/features/recurring/ui/recurring_rules_screen.dart`;
    `lib/core/features/recurring/ui/recurring_rules_view_model.dart`;
    `lib/core/features/recurring/ui/recurring_rule_form_screen.dart`;
    `lib/core/features/recurring/ui/recurring_rule_form_view_model.dart`;
    `lib/core/features/recurring/ui/recurring_rules_section.dart`;
    `test/core/features/recurring/recurring_commands_test.dart`;
    `test/core/features/recurring/ui/recurring_rules_view_model_test.dart`;
    `test/core/features/recurring/ui/recurring_rule_form_screen_test.dart`;
    `test/core/features/recurring/ui/recurring_screens_test.dart`;
    `test/core/features/cashflow/ui/cashflow_form_recurring_test.dart`.
  - Modify: `lib/core/features/cashflow/ui/cashflow_form_screen.dart`
    (чекбокс + поля правила); `lib/core/features/cashflow/ui/cashflow_view_model.dart`
    (`CashflowFormViewModel`: опциональная зависимость
    `RecurringCommands? recurringCommands`, метод saveRecurring);
    `lib/core/features/cashflow/ui/cashflow_details_screen.dart`
    (бейдж автооперации + переход к правилу);
    `lib/core/features/cashflow/ui/operations_tabs.dart` (сегмент 'recurring');
    `lib/app/routes.dart` (`operationsTabs` + 'recurring'; маршруты
    `/recurring/new`, `/recurring/:id/edit` + path-хелперы);
    `lib/app/router.dart` (`_operationsScreen`: ветка recurring; новые GoRoute
    с созданием VM в builder); `lib/core/features/assets/ui/account_details_screen.dart`
    (секция для PropertyAsset и AccountAsset);
    `lib/core/features/assets/ui/account_details_view_model.dart`
    (прокинуть RecurringRepository в секцию); `lib/main.dart`/DI-фабрики VM;
    `lib/l10n/app_ru.arb`; `docs/architecture/navigation_and_screens.md`,
    `business_rules.md` (BR-RC-12).
- **Consumes:** 15.1 (репозиторий, расписание, catch-up, колонка
  recurringRuleId); uikit: `AppCheckbox`, `AppDatePickerField`, `AppSelect`,
  `AppSegmentedControl`, `AppAmountField`, `AppCurrencySelect`,
  `AppCategorySelect`, `AppSwitch`, `AppListTile`, `AppSection`, `AppButton`,
  `AppConfirmDialog`, `AppChip`, `AppEmptyState`, `AppPopupMenu`.
- **Produces:** создание правила из формы дохода/расхода (чекбокс), единый
  список правил с правкой/удалением, секции на экранах активов, отметки
  «ожидает курс»/«автоплатёж».
- **TDD:**
  1. Форма cashflow (create): чекбокс «Повторять ежемесячно» открывает поля
     даты начала/окончания; сохранение создаёт правило (не разовую запись);
     при startDate ≤ today первая операция появляется сразу (catch-up);
     чекбокс скрыт при редактировании записи.
  2. Форма правила: валидации (сумма>0, категория, endDate≥startDate,
     взаимоисключение цели, валюта счёта) дают inline-ошибки; сохранение
     create/revise; повторное нажатие заблокировано (BR-VAL-7).
  3. Вкладка «Регулярные»: список активных правил (сумма+категория, расписание,
     цель, следующий платёж); пустое состояние с CTA; переход в форму правки;
     автоправило процентов (если есть) → детали счёта, без правки/удаления.
  4. Секция недвижимости: правила объекта, «Добавить платёж» открывает форму
     с preset propertyId; архивный объект → readOnly.
  5. Удаление правила: confirm-диалог; прошлые операции остаются; правило
     исчезает из списков; генерация прекращается.
  6. Pending-курс: правило USD без курса на ближайшую due-дату → чип
     «Ожидает курс»; после появления курса и catch-up чип исчезает.
  7. Детали cashflow: у записи с recurringRuleId бейдж «Автоплатёж» и переход
     к правилу; у обычной — нет.
- **Рабочий план:**
  1. **RecurringCommands** (`logic/recurring_commands.dart`, конструктор:
     repository, catchup, today): `Future<Result<int>> save({int? id,
     required CashflowKind kind, required int categoryId, required Money amount,
     required String currencyCode, int? accountId, int? propertyId,
     required bool affectsBalance, required LocalDate startDate,
     LocalDate? endDate, String? comment})` — клиентская валидация (те же
     ключи, что DAO; сумма>0, категория выбрана, endDate≥startDate),
     create/revise через repository, затем `await catchup()` (в DI —
     tear-off `RecurringCatchupService.catchUp`);
     `Future<Result<void>> delete(int id)` → softDelete. Ошибки —
     `DomainException`/`Result` по образцу `CashflowCommands`.
  2. **Форма cashflow.** В `_CashflowFormScreenState` (только create,
     `!vm.isEditing`): `AppCheckbox` «Повторять ежемесячно» после поля даты.
     При включении: поле даты меняет label на «Дата начала» (значение
     переносится), ниже — `AppDatePickerField` «Дата окончания
     (необязательно)» + текстовая кнопка «Сбросить» (AppDatePickerField не
     умеет clear — кнопка рядом, обнуляет `_recurringEndDate`). Сохранение
     при включённом чекбоксе → `vm.saveRecurring(...)` (startDate = выбранная
     дата, endDate, остальные поля формы как есть) вместо `vm.save`.
     `CashflowFormViewModel`: новая опциональная зависимость
     `RecurringCommands? recurringCommands` (catch-up запускается командами);
     `saveRecurring` пробрасывает в commands; router передаёт их в builder.
     Диапазон дат: firstDate DateTime(2000), lastDate DateTime(2100) —
     будущая дата начала разрешена (правило ждёт, операции не создаются).
  3. **Форма правила** `RecurringRuleFormScreen` (create/edit, route
     `/recurring/new?propertyId=&accountId=&kind=` и `/recurring/:id/edit`):
     поля — kind (AppSegmentedControl), категория, сумма, валюта, цель:
     preset-режим (propertyId/accountId из query → контекстная подпись как
     в cashflow-форме) либо generic-режим (два AppSelect «Счёт»/«Недвижимость»
     со значением null = «Не выбран»; выбор одного сбрасывает другой);
     AppSwitch «Влияет на баланс счёта» только при выбранном счёте (валюта
     подтягивается со счёта, как в cashflow-форме); дата начала (обязательна,
     default today); дата окончания (необязательна + «Сбросить»); комментарий;
     CTA «Сохранить»; в edit-режиме — «Удалить правило» (destructive,
     AppConfirmDialog «Правило будет удалено. Созданные операции останутся.»).
     VM: загрузка правила/справочников (категории по kind, валюты, активные
     счета/недвижимость), сигналы состояния по образцу CashflowFormViewModel;
     сохранение → commands.save → pop(true).
  4. **Вкладка «Регулярные».** `AppRoutes.operationsTabs` =
     ['cashflow','transactions','recurring']; `OperationsTabs` — третий сегмент
     (l10n `operationsRecurringTab` = «Регулярные»); `_operationsScreen` —
     ветка `tab == 'recurring'` → `RecurringRulesScreen`.
     `RecurringRulesViewModel`: watchActive() + справочники (категории, валюты,
     активы) + для каждого правила `RecurringSchedule.nextPayment` и pending-
     проверка: ближайшая due-дата ≤ today и валюта ≠ RUB →
     `rateRepository.find(code, date)` == null → «ожидает курс» (без сети).
     Экран: список `AppListTile` (title: категория + сумма; subtitle:
     «Ежемесячно, день {N} · с {date}[ · по {date}]» + имя цели; trailing:
     дата следующего платежа или чип «Ожидает курс»); tap: fixed → форма
     правки, depositInterest → детали счёта; кнопка «Добавить платёж» →
     `/recurring/new`; пустое состояние — `AppEmptyState` с CTA.
  5. **Секции активов.** `RecurringRulesSection` (образец —
     `PropertyCashflowSection`: подписка на watchByAccount/watchByProperty,
     didUpdateWidget, dispose): заголовок «Ежемесячные платежи», компактные
     строки правил (сумма/категория/следующий платёж, tap → форма правки),
     кнопка «Добавить платёж» (preset цели), readOnly при архиве.
     В `AccountDetailsScreen`: для PropertyAsset — рядом с
     PropertyCashflowSection; для AccountAsset — после сводки.
     `AccountDetailsViewModel` получает `RecurringRepository` (router).
  6. **Детали операции.** `CashflowDetailsScreen`: при
     `entry.recurringRuleId != null` — `AppChip` «Автоплатёж» и текстовая
     кнопка «Изменить правило» → `/recurring/{id}/edit`. Редактирование самой
     записи остаётся обычным (D4: правка записи не меняет правило).
  7. **l10n** (все строки только в `app_ru.arb`): вкладка/список/форма/секция;
     статусы «Следующий/Просрочен/Завершено/Ожидает курс»; удалённое правило;
     ключи auto/процентов добавлены в 15.3/15.5 (`recurringAutoChip`,
     `recurringAutoInterestMeta`, `recurringNextAccrual`,
     `recurringLastAccrualLabel`, `accountRateAutoHint`).
  8. **Docs.** `navigation_and_screens.md`: вкладка, маршруты, секции;
     `business_rules.md`: BR-RC-12 (управление, автоправило read-only);
     покрытие.
- **DoD:** общий DoD + design-reviewer по diff-файлам UI; a11y (чекбокс/свитч
  одним target ≥48dp, семантика чипов, font 1.3 без overflow); raw Material
  вне uikit не появляется; статус `[x]` + дата до PR. Перед PR спросить о e2e.
- **Итог:** добавлены вкладка «Регулярные» (третий сегмент журнала), экран
  списка с ближайшим платежом и чипом «Ожидает курс», форма правила
  (kind/сумма/валюта/категория/цель/affectsBalance/даты/комментарий) с
  удалением через confirm и read-only режимом автоправила процентов, секции
  «Ежемесячные платежи» на экранах недвижимости и счёта. В форме дохода/расхода
  чекбокс «Повторять ежемесячно» показывает дату начала/окончания и создаёт
  правило через `RecurringCommands` (сразу запускается catch-up); при
  редактировании чекбокс скрыт. В деталях автооперации — бейдж «Автоплатёж» и
  переход к правилу. По ревью: чип выровнен, пустое состояние получило
  отдельный поясняющий текст, ссылка на удалённое правило показывает спокойное
  состояние вместо тупика, preset-URL собирается через `recurringNewPath`,
  добавлены тесты создания правила из формы cashflow, бейджа, удалённого
  правила и маршруты в a11y-harness 320dp/1.3. По design-review: доход/расход
  различаются знаком, тоном и подписью типа; сумма вынесена из заголовка в
  trailing; архивный актив не открывает правило; три вкладки — горизонтальный
  скролл; ошибка даты окончания inline и `firstDate` = дата начала; чекбокс
  стоит до даты и при снятии возвращает дату в today; список сортируется по
  ближайшему платежу; статусы «Следующий/Просрочен/Завершено/Ожидает курс»
  видны и в семантике. Всего 689 тестов.
  Отложено (полировка после этапа 15, не входит в v0.1.2): skeleton вместо
  спиннера, единый контрол типа цели, `initialDate` в uikit date picker,
  терминология «Регулярные/Ежемесячные», UI для `negativeBalance`/
  `categoryUnavailable` (сейчас правило выглядит «Просроченным»).
  **WILL ROT:** `CASE`-знак в SQL `balanceAsOfMinor` дублирует Dart
  `_signedDelta`; копии `firstPeriodOffset`; дедуп VM-хелперов форматирования;
  skeleton; uikit `initialDate`.
- **Предлагаемый commit:** `task/15.2: UI ежемесячных платежей`.

### 15.3 Автоматическая капитализация процентов по вкладам — [x] (2026-11-21) · PR #65

- **Приоритет/зависимости:** P1; после 15.1 (можно параллельно с 15.2, но
  генератор общий — рекомендована последовательность 15.1 → 15.2 → 15.3).
  **BR:** новые BR-RC-9, 10; BR-VAL-6, BR-IE-6, CALC §4.
- **Files:**
  - Create: `test/core/features/recurring/recurring_interest_test.dart`;
    `test/core/database/transactions_balance_asof_test.dart`;
    `lib/core/features/cashflow/logic/linked_cashflow_writer.dart`.
  - Modify: `lib/core/features/recurring/logic/recurring_generator.dart`
    (reconcile + strategy depositInterest); `lib/core/database/daos/transactions_dao.dart`
    (`balanceAsOfMinor`); `lib/core/database/daos/recurring_dao.dart`
    (`upsertDepositInterestRule`, soft-delete, последнее начисление);
    `lib/core/features/recurring/domain/recurring_repository.dart` и
    `data/recurring_repository_impl.dart` (`lastGenerated`);
    `lib/core/features/recurring/ui/recurring_rules_section.dart`
    (read-only `AppCard` процентов); `lib/core/features/cashflow/logic/cashflow_commands.dart`
    (использует `LinkedCashflowWriter`);
    `lib/core/features/assets/ui/account_details_screen.dart`
    (передача `AccountAsset` в секцию);
    `lib/core/features/assets/ui/account_form_screen.dart` (helperText при
    ставке > 0); `lib/core/features/assets/ui/account_form_view_model.dart`
    (`Future<void> Function()? catchup` после успешного save);
    `lib/app/router.dart`; `lib/l10n/app_ru.arb`;
    `docs/architecture/calculations.md` (§4b + CALC-037…041),
    `business_rules.md` (BR-RC-9/10 + покрытие), `data_schema.md`
    (reconcile-контракт).
  - Test: `test/core/features/recurring/recurring_interest_test.dart`,
    `test/core/database/transactions_balance_asof_test.dart`,
    `test/core/features/recurring/ui/recurring_screens_test.dart` (карточка/
    авто-строка), `test/core/features/assets/ui/account_screens_test.dart`
    (helperText/catch-up), `test/architecture/business_rule_coverage_test.dart`
    (BR-RC-9/10, CALC-037…041).
- **Consumes:** 15.1 (таблица strategy deposit_interest, unique-индекс одного
  активного автоправила на счёт, генератор, маркер); `AccountDetails`
  (annualRate/startDate/endDate уже существуют — форма счёта не расширяется);
  сид-категория «Проценты по вкладу» (income).
- **Produces:** фактические ежемесячные начисления процентов в доходы с
  увеличением баланса вклада; догон с даты открытия вклада; остановка по
  endDate/архиву/нулевой ставке; read-only карточка в деталях счёта.
- **TDD (golden, сначала failing):**
  1. CALC-037: вклад 100 000 RUB, 12%, start 15.01.2026, today 20.04.2026,
     endDate null → начисления 15.02 (1 000,00), 15.03 (1 010,00),
     15.04 (1 020,10); баланс 103 030,10; три связанные пары deposit+income,
     категория «Проценты по вкладу», recurringRuleId заполнен.
  2. CALC-038 (округление): баланс 10,50 RUB (1050 minor), 12% →
     1050×12/1200 = 10,5 → 11 minor (0,11), half away from zero.
  3. CALC-039: endDate 15.03.2026 → только февраль+март; баланс 102 010,00;
     апрельское начисление не создаётся даже при today > endDate.
  4. CALC-040 (clamp): start 31.01.2026 → даты 28.02, 31.03, 30.04.
  5. CALC-041 (снятие между начислениями): 100 000, 12%, start 15.01;
     снятие 50 000 от 20.01 → 15.02: 500,00 (баланс 50 500,00);
     15.03: 505,00 (баланс 51 005,00).
  6. Reconcile: счёт со ставкой 0 → автоправила нет; ставка стала >0 →
     правило создано; ставка обнулена/счёт архивирован → автоправило
     soft-deleted; правка ставки/дат → зеркальные поля обновлены, маркер и
     прошлые начисления сохранены; повторный reconcile идемпотентен.
     **Повторное включение ставки после 0:** автоправило восстановлено
     (тот же id, маркер сохранён), прошлые начисления не продублированы;
     reconcile не создаёт второе правило.
  7. Нулевой процент (баланс 0 или округление до 0) → период закрывается
     (маркер двигается), операция не создаётся (CHECK amount>0).
  8. Категория «Проценты по вкладу» архивирована/переименована → начисления
     приостановлены (pending categoryUnavailable), без падения.
  9. USD-вклад без курса на дату начисления → отложение (D5), маркер стоит.
  10. `balanceAsOfMinor`: opening + операции ≤ даты (включая весь день даты),
     soft-deleted исключены; порядок (occurredOn, id) не влияет на сумму.
  11. Сохранение счёта формой запускает catch-up (начисления появляются без
     перезапуска); детали счёта показывают следующее начисление и последнее
     начисленное значение.
- **Рабочий план:**
  1. **balanceAsOfMinor.** В `TransactionsDao`:
     `Future<int> balanceAsOfMinor(int assetId, LocalDate date)` —
     `openingValueMinor` + знаковая сумма активных (`deletedAt IS NULL`)
     операций с `occurredOn <= date` (deposit/transferIn +, withdrawal/
     transferOut −; знак — `_signedDelta`). Один SQL-запрос.
  2. **Reconcile (шаг 0 в `RecurringGenerator.run`, одна транзакция).**
     Для каждого `AccountDetailsRow` с активным неархивным активом:
     `annualRate > 0` → найти активную income-категорию с
     `normalizeEntityName('Проценты по вкладу')` (прямой select по categories;
     нет → pending `categoryUnavailable`, счёт пропущен); upsert автоправила:
     существующее активное deposit_interest-правило счёта → обновить
     зеркальные поля (categoryId, currencyCode = валюта счёта, startDate =
     detail.startDate, endDate = detail.endDate, kind income,
     affectsBalance true, comment null), маркер сохранить; нет → создать
     (маркер null). `annualRate == 0` или актив архивирован → soft-delete
     активного автоправила (если есть).
     **Повторное включение ставки:** soft-deleted автоправило этого счёта
     восстанавливается (`deletedAt = null`) с сохранённым маркером, а не
     создаётся новое — иначе прошлые начисления продублируются, ведь
     unique-индекс `cashflow_recurring_period` привязан к `rule_id`.
     Для этого `RecurringDao.upsertDepositInterestRule` ищет правило включая
     soft-deleted, обновляет зеркальные поля и снимает `deletedAt`, сохраняя
     маркер; новое правило создаётся только если строки не было вовсе
     (ставка была 0 с момента создания счёта) — тогда маркер null корректен.
     Unique-индекс
     `recurring_active_deposit_interest` гарантирует одно правило на счёт.
  3. **Генерация процентов.** Для deposit_interest-правил: dueDates с
     `firstPeriodOffset: 1`; сумма =
     `MoneyMath.fromRational(Rational.fromBigInt(BigInt.from(balanceMinor)) *
     annualRate.toRational() / Rational.fromInt(1200), currency)` где
     `balanceMinor = transactionsDao.balanceAsOfMinor(accountId, date)`,
     `annualRate` — из `AccountDetails` (читать в run одним запросом).
     Процент ≤ 0 после округления → только маркер. Иначе связанная пара
     deposit+income (комментарий операции — константа генератора
     «Капитализация процентов», data-строка по образцу seed; category —
     «Проценты по вкладу»), курс по D5. Сортировка пар (дата, fixed раньше
     interest, ruleId) уже задана в 15.1 — проценты видят все потоки дня.
     **Перед этим** вынести общий writer связанной пары из
     `CashflowCommands._saveLinked` (WILL ROT ревью 15.1) и использовать его
     и в ручных командах, и в генераторе — чтобы поля пары не разъезжались.
     Пополнение не может дать negativeBalance, но общий catch остаётся.
  4. **UI деталей счёта.** Для AccountAsset с annualRate > 0: в секции
     регулярных платежей read-only карточка автоправила — «Проценты по
     вкладу · {rate}% годовых · капитализация ежемесячно», дата следующего
     начисления (`nextPayment`, offset 1) и сумма последнего начисления
     (последняя неудалённая операция правила); tap → форма правки счёта.
     Правка/удаление автоправила из UI недоступны (D7).
  5. **Форма счёта.** Подсказка под полем ставки при значении > 0:
     «Проценты будут начисляться автоматически ежемесячно в дату годовщины
     начала вклада» (l10n `accountRateAutoHint`). `AccountFormViewModel`
     получает опциональный `Future<void> Function()? catchup`; после
     успешного save — `unawaited(catchup!())` (router передаёт tear-off
     `RecurringCatchupService.catchUp`).
  6. **Docs.** `calculations.md` §4b «Фактическое начисление процентов»:
     формула, offset k≥1, endDate включительно, база — фактический баланс,
     одно округление; golden CALC-037…041 (значения выше). Отличие от §4
     (прогноз-оценка) зафиксировать явно. `business_rules.md`: BR-RC-9
     (автоправило, формула, нулевой процент), BR-RC-10 (endDate включительно,
     правка ставки/дат — только будущие начисления, архив/ноль ставки
     останавливают); покрытие.
- **DoD:** общий DoD + design-reviewer (карточка/подсказка); прогноз вклада
  не изменился (§4 остаётся оценкой); начисления идемпотентны и переживают
  backup/restore (правила и маркеры в файле БД); статус `[x]` + дата до PR.
  Перед PR спросить о e2e. После задачи — короткий android-tester (append
  TEST_PLAN.md: сценарии регулярных платежей и капитализации).
- **Итог:** reconcile создаёт/обновляет одно автоправило процентов на активный
  вклад (маркер сохраняется), останавливает при ставке 0/архиве и
  восстанавливает ту же строку с маркером при возобновлении; `balanceAsOfMinor`
  считает фактический баланс на дату; процент = баланс × ставка/1200 с одним
  округлением; нулевой процент закрывает период без операции; отсутствие
  категории и не-RUB без курса — отложенные периоды. Golden CALC-037…041
  (100 000 под 12% → 103 030,10; округление 0,11; endDate; clamp 31-го;
  снятие). В деталях счёта — read-only `AppCard` процентов («Проценты по
  вкладу», ставка, следующее/просроченное/завершённое начисление, «Ожидает
  курс», «Начисления остановлены» для архива, последнее начисление с суммой и
  датой); в форме счёта — helperText при ставке > 0 и catch-up после
  успешного сохранения. При недоступной категории автоправило останавливается
  (маркер сохраняется) и не начисляет после `endDate`; общий writer связанной
  пары вынесен в `LinkedCashflowWriter` и используется командами и
  генератором. Документация: calculations §4b, BR-RC-9/10, data_schema
  reconcile. Всего 709 тестов.
- **Предлагаемый commit:** `task/15.3: капитализация процентов по вкладам`.

### 15.4 Вкладка «Регулярные» обрезается до «Р» — [x] (2026-11-22) · PR #66

- **Источник:** короткий QA этапа 15, TC-122 (`/tmp/opencode/qa15_recurring.png`).
- **Симптом:** на планшете (1280×2856, font 1.0) третий сегмент «Регулярные» шириной ~164 px
  против ~510 px у соседей, видна только «Р»; тап работает.
- **Причина:** `OperationsTabs` → `AppSegmentedControl(expanded: false)` + три длинные
  подписи; `SegmentedButton` в горизонтальном скролле сжимает/клипает третий сегмент.
- **Files:** `lib/core/features/cashflow/ui/operations_tabs.dart`,
  `lib/uikit/app_segmented_control.dart` (auto-scroll выбранного сегмента +
  scrollbar для `expanded: false`), `lib/uikit/design/inputs.md`, `DESIGN.md`,
  `test/core/features/cashflow/ui/operations_tabs_test.dart`,
  `test/app_test.dart`, `integration_test/transactions_flow_test.dart`.
- **Fix:** вернуть полные подписи «Доходы и расходы» / «Операции по активам» /
  «Регулярные» и `expanded: false`: на узком экране переключатель прокручивается,
  показывает контрастный scrollbar с track, edge-fade по краям и автоматически
  подводит выбранную вкладку; прокручивается только горизонтальная полоса
  (`position.ensureVisible`), вертикальный список не прыгает; reduce-motion
  отключает анимацию.
- **TDD:** pump `OperationsTabs(current: 'recurring')` в 320×900/font1.3 → все
  полные подписи в дереве, выбранная «Регулярные» после авто-скролла внутри
  bounds; тап «Доходы и расходы» после `ensureVisible` вызывает `onChanged`;
  scrollbar с `trackVisibility`; в вертикальном `SingleChildScrollView` offset
  остаётся 0; `takeException()` == null.
- **DoD:** общий DoD; короткий design-review по копирайту вкладок; e2e спросить перед PR.
- **Итог:** полные подписи возвращены; `AppSegmentedControl(expanded: false)`
  прокручивается, показывает контрастный scrollbar с track и edge-fade,
  подводит выбранную вкладку только по горизонтали (вертикальный список не
  прыгает), reduce-motion уважается. Тест 320dp/1.3 проверяет авто-скролл
  «Регулярных», переключение, scrollbar и отсутствие вертикального сдвига.
  На 427dp/font1.0 невыбранная третья вкладка до свайпа читается как «Р» с
  fade — это принятый владельцем scroll-дизайн (TC-143 PASS), не FAIL.
  TC-122 закрыт.
- **Предлагаемый commit:** `task/15.4: вкладка регулярных платежей`.

### 15.5 Список «Регулярные» не обновляет справочники без перезахода — [x] (2026-11-22) · PR #66

- **Источник:** короткий QA этапа 15, TC-123.
- **Симптом:** после холодного старта авто-правило показывает «Без привязки к активу»
  вместо имени счёта, у USD-правила нет «Ожидает курс» (только «Просрочен»), иногда
  категория «—»; после ухода/возврата значения появляются.
- **Причина:** `RecurringRulesScreen` читает `categoryNames/assets/currencies/ratePending`
  внутри `ListView.builder` (itemBuilder), вне зоны трекинга внешнего `SignalBuilder`;
  обновления сигналов не перерисовывают список.
- **Files:** `lib/core/features/recurring/ui/recurring_rules_screen.dart`
  (справочники во внешнем `SignalBuilder`, auto-строка: trailing `AppChip`
  «Авто» вместо `AppMoneyText` «Автоплатёж», subtitle без дубля названия),
  `lib/l10n/app_ru.arb` (описание `recurringAutoChip`),
  `test/core/features/recurring/ui/recurring_screens_test.dart`.
- **Fix:** прочитать сигналы справочников во внешнем `SignalBuilder` (зарегистрировать
  зависимости) и передать значения/локальные форматтеры в itemBuilder; подписи,
  суммы и pending берутся из этих значений. Заодно auto-строка списка получила
  `AppChip` «Авто» и перестала дублировать название в subtitle.
- **TDD:** после pump в VM установить `categoryNames`, `assets`, `ratePending` без
  перезахода → строка списка показывает новую категорию, имя цели и «Ожидает курс».
- **DoD:** общий DoD; design-review обязателен (включая auto-строку списка);
  e2e спросить перед PR.
- **Итог:** `categoryNames/assets/currencies/ratePending` читаются во внешнем
  `SignalBuilder`, itemBuilder получает локальные значения; reactive-тест
  обновляет категорию/цель/pending без перезахода; auto-строка показывает
  `AppChip` «Авто» без дубля названия. TC-123 закрыт. Всего после 15.4/15.5 —
  713 тестов.
- **Предлагаемый commit:** `task/15.5: обновлять справочники регулярных платежей`.

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

**Граф зависимостей:** 18.1 → 18.2 → 18.3 → 18.4; 18.5 → 18.9; 18.5 → 18.6;
18.7 независима; 18.8 после всех. Задачи трогающие одни файлы выполнять
последовательно (ветка → PR → squash merge); 18.6/18.9 разрабатывались
параллельно, но merged последовательно после общего recheck.

**Решения и допущения этапа (не менять молча):**
- **Нумерация:** D1–D6 этого этапа = **D18.1–D18.6** (D1–D8 этапа 15 не
  переиспользуются); 18.6 — **D18.7**, 18.9 — **D18.8**.
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
- **D18.7.** 18.6: при активном kind-фильтре табы скрыты, показана подпись
  типа; выбор таба переживает reload и сброс фильтра.
- **D18.8.** 18.9: `AnalyticsViewModel` — singleton в DI, экран не диспозит VM;
  фильтры живут на время вкладки (by design), политика сброса при будущем
  logout/multi-account не определена.

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
  digits из справочника) + тесты дефолта на USD-активе. WILL ROT 18.1 частично закрыт:
  `AssetRepositoryImpl.recordValuation` берёт `fractionDigits` из
  `currenciesDao.find`; дублирование формулы M3 в `analytics_mappers` остаётся
  открытым (18.x). 15 новых тестов, всего 820; format/analyze/dart analyze
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
  2. VM: `lockedShare` = lockedTotal / byAssetKind[investment] (пример CALC-047:
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

### 18.5 Аналитика: «Детализация за месяц» отдельной страницей — [x] (2026-11-23)

- **Приоритет/зависимости:** P2; независима от 18.1–18.4; 18.6 после неё.
- **Суть:** список значений по периодам (сейчас внутри `CashflowChartSection`,
  заголовок «Значения по периодам») переносится на отдельную страницу
  «Детализация за месяц»; на экране аналитики остаётся ссылка. Пустые периоды
  (доход = 0 и расход = 0) не показываются. Если за выбранный месяц вообще нет
  операций — «Нет операций за месяц».
- **Решения:**
  - **A1.** Новый роут `/more/analytics/details` (name `analytics-details`),
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
    semanticLabel: null), onTap: push analyticsDetailsPath с текущими
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
  - Modify: `lib/app/routes.dart` (+`analyticsDetails = '/more/analytics/details'`,
    +хелпер `analyticsDetailsPath({String period = 'month', String? kind,
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
- **Итог:** страница `/more/analytics/details` (name `analytics-details`) с
  query `period/kind/categoryId`, VM по образцу аналитики, фильтрация нулевых
  периодов и newest-first, чипы периода, общий `CashflowPeriodList`, empty state
  «Нет операций за месяц»; из `CashflowChartSection` удалён список/сворачивание,
  на экране аналитики — ссылка с текущими фильтрами. По дизайн-ревью: унаследованные
  фильтры показаны read-only чипами и сбрасываются вместе с периодом, пустое
  состояние поясняет фильтры; месячные бакеты подписаны «Ноябрь 2026»; AppFilterBar
  получил scrollbar/edge-fade/авто-скролл выбранного чипа — фикс QA TC-175
  (recheck PASS в прогоне 18.9; программный сброс не оставляет чип за экраном). Гранулярность
  подписей «Всё время» считается по фактической серии (≤62 дней — дни), скроллбар
  приглушён. 22 новых тестовых функции (8 VM, 9 widget, 3 route, 2 uikit),
  всего 872; format/analyze чисто.
- **WILL ROT 18.5:** имя категории в read-only чипе и его «тапабельность»;
  заголовок «Детализация за месяц» при периодах год/всё время; на странице нет
  сводки/валюты и правого выравнивания сумм; `queries.cashflow` питает
  неиспользуемый `summary`; net worth сохраняет inline-список, cashflow —
  страницу; leading-иконка ссылки; все точки в неленивом Column.
- **Отклонение:** имена `analyticsDetails`/`analyticsDetailsPath`/
  `analytics-details` вместо `cashflowDetails*`, потому что последние уже заняты
  деталями cashflow-записи (`/cashflow/:id`); `MissingRate` переиспользован из
  `AnalyticsViewModel`.

### 18.6 Аналитика: табы «Расходы»/«Доходы» в итогах по категориям — [x] (2026-11-23)

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
- **Итог:** табы «Расходы/Доходы» (`AppSegmentedControl`) с дефолтом «Расходы»,
  фильтрацией/сортировкой внутри типа, пустыми состояниями и снятым суффиксом;
  при активном kind-фильтре табы скрыты и показана подпись типа (по ревью —
  вместо полу-disabled контрола с провалом контраста); выбор таба переживает
  reload (state в `AnalyticsScreen` + `selectedKind`/`onKindChanged`);
  `integration_test/analytics_flow_test.dart` переключает таб перед проверкой
  доходной категории; активный kind-фильтр запоминается в state экрана, поэтому
  после сброса фильтра таб показывает последний фильтрованный тип. 5 новых
  тестов, всего 883; format/analyze чисто.
- **WILL ROT 18.6:** порядок сегментов в чипах kind (Все/Доходы/Расходы) и табах
  (Расходы/Доходы) различается — выровнять при следующем касании; disabled-обёртка
  вынесена из uikit в feature и ждёт `enabled` у `AppSegmentedControl`.

### 18.7 Цветовая окраска сумм операций по типам — [x] (2026-11-23)

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
- **Итог:** журналы окрашивают суммы тоном (`AppOperationListTile`), карточки
  деталей операции/денежного потока получают `tone`, в последних операциях
  дашборда — знаки `+`/`−`; `AppMoneyText`: смысловой тон сильнее цвета
  `style` (M3 textTheme окрашивал все стили и глушил тон), `style.color`
  учитывается только при `neutral` — deleted/archived приглушение.
  6 новых тестов (включая поведенческие проверки отрисованного цвета карточек),
  всего 856; format/analyze/dart analyze/test зелёные. Побочный эффект в рамках
  контракта DESIGN §2: тона «ожили» в `AppCashflowSummary`, deficit/surplus
  целей, итогах категорий и «+поступление» регулярных (раньше глушились M3).
- **WILL ROT 18.7:** trailing последних операций без `maxLines` — на
  экстремально длинной сумме возможен overflow (pre-existing, не регрессия
  18.7); income/transfer — самая близкая пара палитры (ΔE ~20), пересмотр при
  смене токенов.
- **Отклонение:** правка `lib/uikit/app_money_text.dart` (вне списка Files) —
  без неё `AppSummaryCard.tone` не доходил до текста; выявлено task-reviewer.

### 18.8 Релиз v0.9.0 — [x] (2026-11-23)

- **Приоритет/зависимости:** P1; после merge 18.1–18.7 и 18.9. Исполнитель —
  `release-manager` (`.agents/agents/release-manager.md`) с отклонением от
  штатного patch-bump: версия задана владельцем — **0.9.0** (D18.5).
- **Чек-лист:**
  1. Все задачи 18.1–18.7 и 18.9 закрыты (`[x]` + дата), PR смержены в main,
     CI зелёный; `task-reviewer`/`design-reviewer` пройдены по каждой задаче.
  2. **QA/e2e выполнены 2026-11-23** (владелец разрешил): полный QA TC-185…220 —
     33 PASS / 2 FAIL (TC-200, TC-213) / 1 SKIP (TC-206: UI-фильтра валюты нет,
     покрыт unit-тестами); FAIL исправлены в 20.1–20.2 (PR #84), recheck
     TC-221–224 PASS. `flutter test integration_test -d linux` — **9/9 PASS**.
  3. `plan-review` по задачам этапа 18; блокирующие замечания — стоп.
  4. Локально: `dart format --output=none --set-exit-if-changed lib test tool
     integration_test`; `flutter analyze --fatal-infos`; `dart analyze lib
     --fatal-infos`; `flutter test`; **`flutter clean`** (после QA/эмулятора)
     и `flutter build apk --release` — общий гейт для задач, где release-сборка
     не запускалась; generated проверены; `git diff --check`.
  5. В `main`: `pubspec.yaml` → `version: 0.9.0+4`; отдельный коммит
     `release: поднять версию до v0.9.0`; запушить и **дождаться зелёного CI
     на bump-коммите** до тега.
  6. Аннотированный тег `v0.9.0` на bump-коммите; проверка
     `git show v0.9.0:pubspec.yaml | grep 'version:'` → `0.9.0+4`;
     `git log -1 --format=%s v0.9.0` → `release: поднять версию до v0.9.0`;
     пуш тега → `.github/workflows/release.yml`.
  7. Проверить `gh release list` / `gh run list`: workflow прошёл, APK опубликован.
  8. Зафиксировать: 18.8 → `[x] (дата)`, индекс этапа 18 → ✅ (дата), тег
     `v0.9.0` и успешный run release.yml — в PLAN/отчёте; переписать «Текущий
     этап»: релиз v0.9.0 опубликован, активных этапов нет, 16–20 в архиве.
  9. Сжатие `PLAN.md`: завершённые этапы **16–20** → `PLAN_ARCHIVE.md` (дословно,
     индекс и нумерация сохраняются; в архиве — строка «Перенесено: этапы
     16–20 (2026-11-23, релиз `v0.9.0`).»); коммит
     `chore: сжатие PLAN.md — архив этапов 16–20`.
- **DoD:** релиз опубликован, версия в APK 0.9.0 (versionCode 4), e2e и полный
  QA зафиксированы в TEST_PLAN/PLAN, PLAN сжат, отчёт release-manager владельцу.
- **Предлагаемый commit:** `release: поднять версию до v0.9.0`.
- **Итог:** bump-коммит `76ebfd6` (`release: поднять версию до v0.9.0`), CI
  success; тег `v0.9.0` → release.yml run 45247083677 success; GitHub Release
  `v0.9.0` с APK `app-release.apk` 75 197 290 байт, versionName 0.9.0 /
  versionCode 4 (apkanalyzer). Локально: format/analyze/`dart analyze lib`
  чисто, 889 тестов PASS, release APK 75.2 MB.

### 18.9 Исправления по короткому QA 18.5: фильтры Аналитики при возврате — [x] (2026-11-23)

- **Приоритет/зависимости:** P1; после merge 18.5, до релиза 18.8.
  Источник — TEST_PLAN TC-173 (2026-11-23); TC-175: фикс в 18.5, recheck PASS
  в прогоне 18.9.
- **Проблема 1 (QA, TEST_PLAN TC-173):** после возврата со страницы
  «Детализация за месяц» экран Аналитики теряет фильтры. Шаги: «Аналитика» →
  чип «Год» → «Детализация за месяц» → системный «Назад» → на Аналитике активен
  «Месяц». Повтор с фильтром типа: «Доходы» (итоги Расход 0,00) → «Детализация»
  → «Назад» → снова «Все операции», Расход 300,00, «Сбросить фильтры» исчезла;
  список прокручивается к началу. Доказательства: скриншоты
  `/tmp/opencode/qa185_analytics_year.png` → `qa185_details_year.png` →
  `qa185_analytics_after_back.png`, дампы `uiautomator`.
  - **Предполагаемая причина:** `AnalyticsViewModel` регистрируется фабрикой
    (`lib/main.dart:101`), роутер получает VM в builder (`lib/app/router.dart:488`);
    pop перестраивает маршрут Аналитики, фабрика отдаёт новый VM с дефолтными
    `period=month`, `kind=null`, экран пересоздаётся (сброс скролла).
  - **Решение:** держать VM Аналитики на время жизни вкладки (ленивый singleton
    в DI или создание на уровне маршрута с сохранением состояния), не сбрасывать
    сигналы при повторном построении; проверить аналогичный возврат из других
    подстраниц Аналитики (сравнение активов, детали записи).
  - **Тест:** TC-173 — после «Назад» сохраняются «Год» и kind/category,
    предпочтительно позиция скролла; widget-тест на пересборку экрана с тем же
    VM и без потери фильтров.
- **Проблема 2 (QA, TEST_PLAN TC-175) — закрыта в 18.5:** при прокрученной строке чипов
  «Сбросить фильтры» оставляет активный чип «Месяц» вне видимой области —
  видна полоска ~2 dp у левого края (`bounds [48,360][50,504]`), пользователь
  не видит выбранный период. Шаги: страница «Детализация за месяц» → свайп
  чипов влево → выбрать «Всё время»/«Год» → «Сбросить фильтры». Воспроизведено
  на `emulator-5554` и `emulator-5556`; доказательства `/tmp/opencode/
  empty_reset.png`, `reset2.png`, `reset3.png`.
  - **Предполагаемая причина:** в `c9ac53e` `AppFilterBar`
    (`lib/uikit/app_filter_bar.dart`) — `StatelessWidget` с горизонтальным
    `ListView` без авто-скролла к выбранному чипу: при программном сбросе
    периода offset списка не меняется. Поведение общее для всех `AppFilterBar`
    (Операции/Активы/Аналитика/Аудит/Детализация).
  - **Решение:** подводить выбранный чип в видимую область после программной
    смены выбора (stateful-обёртка с `ScrollController.animateTo`/`ensureVisible`
    по ключу выбранного ребёнка, post-frame с проверкой актуального контекста);
    тест AppFilterBar на программную смену выбора при прокрученной строке.
    В рабочем дереве на момент QA уже появились незакоммиченные правки этого
    файла (не автора QA) — при взятии задачи сверить с ними, не переписывать
    молча.
  - **Тест:** TC-175 на «Детализации за месяц», дополнительно smoke на
    Операциях и Аналитике.
- **Files:** `lib/main.dart`, `lib/app/router.dart` (время жизни VM),
  `lib/core/features/analytics/ui/analytics_screen.dart` (владение VM);
  `test/app/router_test.dart`, `test/app/test_app_locator.dart`.
- **DoD:** общий DoD; task-reviewer; android-tester recheck TC-173 (TC-175 уже
  закрыт в 18.5); статус `[x]` до PR; e2e — спросить.
- **Предлагаемый commit:** `task/18.9: сохранять фильтры Аналитики при возврате`.
- **Итог:** `AnalyticsViewModel` регистрируется singleton'ом в DI (`main.dart`,
  `test_app_locator.dart`) и принадлежит контейнеру; `AnalyticsScreen` получил
  `disposeViewModel` (router передаёт `false`), поэтому пересборка маршрута при
  возврате с подстраницы не создаёт VM с дефолтными фильтрами и не диспозит
  рабочую. Регресс: router-тест «Год → детализация → назад» сохраняет период,
  плюс unit-тест идентичности из locator. 880 тестов, format/analyze чисто.
  TC-175: фикс в 18.5, recheck PASS в 18.9; TC-173 — recheck PASS 2026-11-23.
- **WILL ROT 18.9:** singleton VM живёт всё приложение; фильтры не сбрасываются
  при выходе с вкладки (by design); reset-политика при logout/multi-account
  не определена.

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

## Этап 20 — Исправления по полному QA release candidate v0.9.0

Источник — полный QA-прогон release-сборки (TEST_PLAN.md, TC-185…TC-220,
2026-11-23): 33 PASS / 2 FAIL / 1 SKIP. Найдены полным QA и исправлены **до**
тега v0.9.0 (PR #84); recheck TC-221–224 PASS 2026-11-23.

### 20.1 Понятная ошибка при ручном курсе на дату с уже используемым курсом — [x] (2026-11-23)

- **Приоритет/зависимости:** P2; независима.
- **Проблема (QA, TEST_PLAN TC-200):** в форме USD-оценки инвестиции
  («Добавить оценку» → валюта USD → стоимость 120 → «Курс к рублю» = 92) и в
  форме USD-операции («Снять» → 10 USD → «Курс к рублю» = 90) сохранение
  падает с общим текстом «Не удалось загрузить данные. Попробуйте позже.»,
  хотя повтор невозможен. Причина: на 23.11.2026 уже есть курс USD, на который
  ссылаются операции (`countRateReferences > 0`), поэтому
  `currencies_dao.saveRate` кидает `DomainException(conflict,
  fieldErrors: {'rate': 'validationRateImmutable'})`, а формы не маппят этот
  ключ. Пользователь не понимает, что поле курса нужно оставить пустым (пустое
  поле использует сохранённый курс и сохраняет успешно — контрольный шаг в TC-200).
- **Предполагаемая причина:** `lib/core/database/daos/currencies_dao.dart`
  (209–214) — источник ошибки; отсутствие строки в `lib/l10n/app_ru.arb` и
  ветки маппинга в `lib/core/features/assets/ui/valuation_form_screen.dart`
  (110–126) и форме операции
  (`lib/core/features/transactions/ui/transaction_form_screen.dart`).
- **Решение/Тест:** добавить l10n-строку (например, «Курс на эту дату уже
  используется операциями и не может быть изменён. Оставьте поле пустым, чтобы
  взять сохранённый курс.») и маппинг ключа `validationRateImmutable` в обеих
  формах; widget-тест «конфликт курса показывает понятное сообщение», повтор
  TC-200 в TEST_PLAN (оценка/операция с непустым курсом → сообщение; пустой
  курс → успех).

### 20.2 Текст защиты валюты от отключения для не-RUB — [x] (2026-11-23)

- **Приоритет/зависимости:** P3; независима.
- **Проблема (QA, TEST_PLAN TC-213):** «Ещё» → «Валюты» → USD → «Действия с
  валютой» → «Отключить»: диалог имеет заголовок «Валюта используется или
  выбрана базовой.», но текст — «RUB нельзя отключить или удалить.» для USD.
  Сообщение называет другую валюту.
- **Предполагаемая причина:** `lib/core/features/currencies/ui/
  currencies_screen.dart` — `_explainProtected()` (240–256) всегда подставляет
  `l10n.currencyErrorRub`; вызывается из `_toggle` (180–193) и `_delete`
  (215–238) для любой валюты.
- **Решение/Тест:** параметризовать сообщение кодом валюты (новая l10n-строка
  вида «{code} нельзя отключить или удалить: валюта используется.» либо
  нейтральный текст «Валюту нельзя отключить или удалить: она используется.»);
  widget-тест «отключение используемой не-RUB валюты показывает её код»;
  повтор TC-213.
- **Итог 20.1:** ключ `validationRateImmutable` замаплен в форме оценки и форме
  операции на `rateErrorImmutable` («Курс на эту дату уже используется
  операциями…»), ошибка показывается под полем курса и переносится
  (`AppTextField.errorMaxLines = 4`, иначе подсказка обрезалась); widget-тесты
  обеих форм и переноса ошибки.
- **Итог 20.2:** `_explainProtected(currency)` для не-RUB показывает
  `currencyErrorInUseCode(code)` с кодом валюты; RUB сохраняет прежний текст;
  widget-тест USD. Всего 888 тестов, format/analyze чисто.

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
Задачи с общими файлами выполнять последовательно: ветка `task/21.NN-<slug>` из
`release/21` → PR в `release/21` → зелёный CI → squash merge.

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

### 21.1 Смешанная цель: счета и инвестиции вместе — [x] (2026-11-27)

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
  - Create: `test/core/database/migration_v4_v5_test.dart`,
    `test/core/features/goals/domain/goal_category_test.dart`,
    `test/core/features/goals/ui/goal_form_test.dart`.
  - Generated: `dart run build_runner build --delete-conflicting-outputs`;
    `dart run drift_dev schema dump lib/core/database/app_database.dart
    drift_schemas/drift_schema_v5.json`; `dart run drift_dev schema
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
  `data_schema.md` §7/§12 обновлены; `task-reviewer` + `design-reviewer`; статус
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

### 21.3 Автоматическое получение курсов валют — [x] (2026-11-27)

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
- **DoD:** format/analyze/test/build; PR в `release/21`; статус `[x]` до PR; e2e спросить.
  Ревью — один раз на релиз (`task-reviewer` + `design-reviewer` по диффу `release/21` → `main`).
- **Предлагаемый commit:** `task/21.3: автообновление курсов валют`.

### 21.4 Скрытие сумм на Главной блюром — [x] (2026-11-27)

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
  - **H5.** Персистентная настройка «скрывать суммы при входе»: ключ
    `amountsHidden` в `app_settings` (`'true'`/`'false'`);
    `SettingsRepository.watchAmountsHidden()/getAmountsHidden()/
    setAmountsHidden(bool)`; переключатель `AppSwitch` в секции «Отображение»
    экрана «Настройки»; `DashboardViewModel.init()` берёт начальное значение
    `amountsHidden` из настройки (иконка на Главной остаётся session-only и не
    переписывает настройку).
- **Files:**
  - Create: `lib/uikit/app_money_visibility.dart`, `lib/uikit/app_amount_blur.dart`,
    тесты `test/uikit/app_money_visibility_test.dart`.
  - Modify: `lib/core/features/dashboard/ui/dashboard_view_model.dart`,
    `dashboard_screen.dart` (actions + скоуп), `lib/uikit/app_money_text.dart`,
    `app_metric.dart`, `app_goal_card.dart`, `lib/core/features/dashboard/ui/
    dashboard_safety_cushion.dart`, `dashboard_recent_operations.dart`,
    `lib/core/database/daos/settings_dao.dart`,
    `lib/core/features/settings/domain/settings_repository.dart`,
    `lib/core/features/settings/data/settings_repository_impl.dart`,
    `lib/core/features/settings/ui/settings_view_model.dart`,
    `lib/core/features/settings/ui/settings_screen.dart`,
    `lib/l10n/app_ru.arb` (тултип/семантика/настройка).
- **TDD:** тумблер скрывает/показывает все денежные блоки; `AppMoneyText` при
  hidden применяет фильтр, при show — нет; подписи не блюрятся; семантика сумм
  скрыта; иконка меняет состояние; 320dp/2.0 без overflow; настройка
  `amountsHidden` персистится, читается и задаёт начальное состояние Главной.
- **DoD:** format/analyze/test/build; PR в `release/21`; статус `[x]` до PR; e2e спросить.
  Ревью — один раз на релиз (`task-reviewer` + `design-reviewer` по диффу `release/21` → `main`).
- **Предлагаемый commit:** `task/21.4: скрытие сумм на главной блюром`.

### 21.5 Подушка безопасности отображается — [x] (2026-11-27)

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
- **DoD:** format/analyze/test/build; PR в `release/21`; статус `[x]` до PR; e2e спросить.
  Ревью — один раз на релиз (`task-reviewer` + `design-reviewer` по диффу `release/21` → `main`).
- **Предлагаемый commit:** `task/21.5: подушка безопасности отображается`.

### 21.6 Предполагаемый налог с процентов по вкладам — [x] (2026-11-27)

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
- **DoD:** format/analyze/test/build; PR в `release/21`; статус `[x]` до PR; e2e спросить.
  Ревью — один раз на релиз (`task-reviewer` + `design-reviewer` по диффу `release/21` → `main`).
- **Предлагаемый commit:** `task/21.6: предполагаемый налог с процентов по вкладам`.

### 21.7 Биометрия сразу при блокировке — [x] (2026-11-27)

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
- **DoD:** format/analyze/test/build; PR в `release/21`; статус `[x]` до PR; e2e спросить.
  Ревью — один раз на релиз (`task-reviewer` + `design-reviewer` по диффу `release/21` → `main`).
- **Предлагаемый commit:** `task/21.7: биометрия сразу при блокировке`.

### 21.8 Резервный последний курс и плашка на Главной — [x] (2026-11-27)

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
- **DoD:** format/analyze/test/build; docs обновлены; PR в `release/21`; статус `[x]` до PR;
  e2e спросить. Ревью — один раз на релиз (`task-reviewer` + `design-reviewer` по диффу
  `release/21` → `main`).
- **Предлагаемый commit:** `task/21.8: резервный курс и плашка на главной`.
