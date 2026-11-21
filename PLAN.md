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
| 11 | Сквозное качество и release readiness | 11.1–11.11 | 🟨 | 2026-11-20: 11.9 (ручные проверки) не блокирует v1 |
| 12 | Расширения после v1 | 12.1–12.7 | ✅ | 2026-11-21 |
| 13 | Исправления по полному QA-прогону v1 | 13.1–13.5 | 🟥 | 2026-11-21 |

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

### 13.1 Восстановление удалённых операций недоступно из UI — [ ]

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

### 13.3 Пустой лист выбора банка в форме счёта — [ ]

- **Проблема (QA, TEST_PLAN TC-086):** при отсутствии банков тап по полю «Банк» открывает
  пустую панель с одним заголовком — без empty state и без действия. Пользователь в тупике:
  нужно вручную уйти в «Ещё → Банки и брокеры». В форме инвестиции аналогичный кейс решён
  кнопкой «Добавить брокера». Доказательства: `qa_003_bank_sheet2.png`.
- **Предполагаемая причина:** `AppSelect`/`AppSelectSheet` не поддерживает пустой список и
  CTA создания (`lib/uikit/app_select.dart`, `account_form_screen.dart`).
- **Решение/Тест:** для пустого списка показывать «Банков пока нет» и кнопку «Добавить банк»
  (переход в справочник + возврат с выбранным банком) либо заменить поле на CTA как в форме
  инвестиции; перепройти TC-086.

### 13.4 Плейсхолдер «0» в балансе и ставке счёта вводит в заблуждение — [ ]

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

### 13.5 Экран блокировки не скрывает семантику приложения — [ ]

- **Проблема (QA, TEST_PLAN TC-094):** при активном PIN-оверлее `uiautomator dump` содержит
  полное дерево экрана под блокировкой (заголовки настроек, действия, суммы), т.е. TalkBack
  может прочитать финансовые данные, пока приложение заблокировано. Доказательства: дамп
  после `keyevent 3` + `am start` (в одном дереве «Введите PIN-код» и «Отключить защиту»).
- **Предполагаемая причина:** `AppLockGate` рисует оверлей поверх приложения, не исключая
  семантику дочернего дерева (`lib/core/features/applock/ui/app_lock_gate.dart`, `app.dart`).
- **Решение/Тест:** обернуть заблокированный контент в `ExcludeSemantics`/`Semantics(hidden)`
  (и `TickerMode`), проверить TalkBack-навигацию при блокировке и после разблокировки;
  перепройти TC-094.
