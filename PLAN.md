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
| 13 | Исправления по полному QA-прогону v1 | 13.1–13.9 | ✅ | 2026-11-21 |
| 14 | Инфраструктура релиза | 14.1 | ✅ | 2026-11-21 |
| 15 | Регулярные платежи и капитализация вкладов | 15.1–15.3 | 🟨 | план 2026-11-21 |

## Этап 14 — Инфраструктура релиза

### 14.1 versionCode релиза из pubspec — [x] (2026-11-21)

- План зафиксирован постфактум: реализация велась в ветке
  `task/14.1-release-version-code`, PR #61 смержен.
- Суть: `.github/workflows/release.yml` больше не передаёт
  `--build-number=${github.run_number}` — versionCode берётся из `pubspec.yaml`
  (`+N`), как у локальных сборок. В `docs/PROJECT.md` зафиксированы правило
  versionCode и одноразовая миграция с debug-подписи (экспорт → удаление
  приложения → установка release → импорт).
- Код приложения не меняется. Статус обновляется при мерже PR #61.

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
- Связанная пара повторяет `CashflowCommands._saveLinked`:
  `transactionsDao.create(...)` + `cashflowDao.create(..., assetTransactionId)`
  в одной `db.transaction`. Рублёвый эквивалент —
  `CashflowCommands.rubAmount(amount, currency, rate)` (публичный static).
- Автооперация — обычная `CashflowEntry` (revisionNo 1, ревизия create)
  с `recurringRuleId`; в журнале/аудите выглядит как обычная операция.
- DI: `RecurringDao`, `RecurringRepository`, `RecurringGenerator`,
  `RecurringCatchupService` — в `registerCoreServices`; VM — фабрики
  в `main.dart`/`router.dart` по существующему образцу.

### 15.1 Схема v2, домен и движок регулярных платежей (без UI) — [x] (2026-11-21)

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
     +12 мес → 28.02.2025, +24 мес → 29.02.2028? (нет: 2028 високосный → 29.02;
     проверить 2025/2026/2027 → 28.02).
  3. Marker: marker '2026-09' → только октябрь/нобрь; marker ≥ текущий период →
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
  11. Долгое отсутствие: start 31.01.2020 → 83 периода до 17.11.2026, все даты
     clamp-корректны, маркер '2026-11'.
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

### 15.2 UI ежемесячных платежей: форма, вкладка «Регулярные», секции активов

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
    `test/core/features/recurring/ui/recurring_rules_screen_test.dart`;
    `test/core/features/recurring/ui/recurring_rules_section_test.dart`;
    widget-тест формы cashflow (расширение существующих в
    `test/core/features/cashflow/ui/`).
  - Modify: `lib/core/features/cashflow/ui/cashflow_form_screen.dart`
    (чекбокс + поля правила); `lib/core/features/cashflow/ui/cashflow_view_model.dart`
    (`CashflowFormViewModel`: зависимости recurringCommands/catchup,
    метод saveRecurring); `lib/core/features/cashflow/ui/cashflow_details_screen.dart`
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
    `business_rules.md` (BR-RC-12), `domain_model.md`.
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
     create/revise через repository, затем `await catchup.catchUp()`;
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
     `CashflowFormViewModel`: новые опциональные зависимости
     `RecurringCommands? recurringCommands`, `RecurringCatchupService? catchup`;
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
     `PropertyCashflowSection`: подписка на watchByProperty/watchByProperty,
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
  7. **l10n** (все строки только в `app_ru.arb`, ключи camelCase):
     `operationsRecurringTab`, `recurringTitle`, `recurringEmpty`,
     `recurringEmptyAction`, `recurringAdd`, `recurringNew`, `recurringEdit`,
     `recurringMonthly` («Повторять ежемесячно»), `recurringStartDate`,
     `recurringEndDate`, `recurringEndDateOptional`, `recurringEndClear`,
     `recurringScheduleLine` (placeholders: day, from, to),
     `recurringNextPayment`, `recurringPendingRate`, `recurringPendingBalance`,
     `recurringPendingCategory`, `recurringAutoBadge`, `recurringAutoInterest`,
     `recurringRuleLink`, `recurringDeleteTitle`, `recurringDeleteMessage`,
     `recurringDeleted`, `recurringSaved`, `recurringTargetAccount`,
     `recurringTargetProperty`, `recurringNoTarget`, `recurringErrorDates`,
     `recurringErrorStrategy` + плейсхолдеры/описания по образцу файла.
  8. **Docs.** `navigation_and_screens.md`: вкладка, маршруты, секции;
     `business_rules.md`: BR-RC-12 (управление, автоправило read-only);
     покрытие.
- **DoD:** общий DoD + design-reviewer по diff-файлам UI; a11y (чекбокс/свитч
  одним target ≥48dp, семантика чипов, font 1.3 без overflow); raw Material
  вне uikit не появляется; статус `[x]` + дата до PR. Перед PR спросить о e2e.
- **Предлагаемый commit:** `task/15.2: UI ежемесячных платежей`.

### 15.3 Автоматическая капитализация процентов по вкладам

- **Приоритет/зависимости:** P1; после 15.1 (можно параллельно с 15.2, но
  генератор общий — рекомендована последовательность 15.1 → 15.2 → 15.3).
  **BR:** новые BR-RC-9, 10; BR-VAL-6, BR-IE-6, CALC §4.
- **Files:**
  - Create: `test/core/features/recurring/recurring_interest_test.dart`;
    `test/core/database/transactions_balance_asof_test.dart`;
    widget-тест секции/карточки процентов (расширение тестов деталей счёта).
  - Modify: `lib/core/features/recurring/logic/recurring_generator.dart`
    (шаг reconcile + strategy depositInterest);
    `lib/core/database/daos/transactions_dao.dart` (`balanceAsOfMinor`);
    `lib/core/features/assets/ui/account_details_screen.dart` /
    `account_details_view_model.dart` (карточка автоправила: ставка, следующий
    платёж, последнее начисление);
    `lib/core/features/assets/ui/account_form_screen.dart` (подсказка при
    ставке > 0); `lib/core/features/assets/ui/account_form_view_model.dart`
    (catch-up после сохранения); `lib/core/features/recurring/ui/`
    (read-only отображение автоправила в списке/секции, если не сделано в 15.2);
    `lib/l10n/app_ru.arb`; `docs/architecture/calculations.md` (§4b +
    CALC-037…041), `business_rules.md` (BR-RC-9/10 + покрытие),
    `data_schema.md` (reconcile-контракт).
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
     Для этого добавить `RecurringDao.restoreDepositInterestRule(id)`
     (или `restore(id)` с той же семантикой); правило ищется включая
     soft-deleted. Новое правило создаётся только если строки не было вовсе
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
     получает опциональный `RecurringCatchupService? catchup`; после
     успешного save — `unawaited(catchup.catchUp())` (router передаёт).
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
- **Предлагаемый commit:** `task/15.3: капитализация процентов по вкладам`.
