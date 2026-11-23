# Drift-схема и транзакции записи

Это нормативная схема `AppDatabase.schemaVersion = 4`. Имена таблиц/колонок в Dart —
lowerCamelCase, в SQLite — snake_case. Ни одна задача не меняет тип, constraint или
индекс без обновления этого документа, schema dump и миграционного теста.

## 1. Общие правила

- PK `id` — `INTEGER PRIMARY KEY AUTOINCREMENT`, кроме `currencies.code` и
  `app_settings.key`.
- Все timestamp — UTC ISO-8601 TEXT с микросекундами; `LocalDate` — строго
  `yyyy-MM-dd`; `Decimal` — каноническая decimal TEXT без exponent-нотации.
- Денежные суммы — `INTEGER ..._minor`; валюта хранится рядом на owning entity.
  SQL не делит сумму на 100: fraction digits применяют только маппер/formatter.
- `FOREIGN KEYS = ON` включается в `beforeOpen`. Все FK к историческим сущностям —
  `ON UPDATE RESTRICT ON DELETE RESTRICT`, если явно не указано иное.
- `deletedAt IS NULL` — активная current projection. `archivedAt` не равно удалению.
- Revisions — append-only. Update/delete revisions запрещены DAO и тестами; snapshot
  содержит состояние current projection **после** действия, включая `deletedAt` для delete.
- `revisionNo = 1` при create; edit/delete/restore добавляют `max(revisionNo) + 1` и
  обновляют current projection атомарно. Restore относится к P2, enum уже зарезервирован.
- JSON snapshot — UTF-8 TEXT с ключами на английском, minor units как JSON integer,
  Decimal/date/time как String, `snapshotSchemaVersion = 1`. JSON не является вторым
  current state: чтение журналов и итогов использует только current tables.
- Запрещены `double`, `REAL`, локальные timestamp и вычисление курса в SQL через binary
  floating point.

## 2. Type converters

### `DecimalConverter extends TypeConverter<Decimal, String>`

- `toSql`: `value.toString()` после нормализации `-0` в `0`; экспоненциальная запись
  раскрывается через `Decimal.parse`/точное форматирование без потери цифр.
- `fromSql`: `Decimal.parse(value)`; невалидное значение — `FormatException`, а не `0`.
- Nullability определяется колонкой; converter не подставляет defaults.

### `LocalDateConverter extends TypeConverter<LocalDate, String>`

- `toSql`: `toIsoString()`; `fromSql`: `LocalDate.parse`.
- Хранится только календарная дата, без `T`, timezone и milliseconds.

### Остальные enum

Drift `EnumIndexConverter` запрещён: вставка значения в середине enum сломала бы данные.
Используются стабильные TEXT values: `account|investment|property`, `bank|broker`,
`income|expense`, `deposit|withdrawal|transferOut|transferIn`, `cbr|manual`,
`create|edit|delete|restore`, `accounts|investments`, `active|achieved|closed`.
Маппер отклоняет неизвестное значение явной `FormatException`.

## 3. Таблицы активов

### `assets`

| Колонка | Тип / ограничения |
|---|---|
| `id` | PK |
| `name` | TEXT NOT NULL, trimmed |
| `kind` | TEXT NOT NULL: asset kind |
| `currencyCode` | TEXT NOT NULL → currencies.code RESTRICT |
| `openingValueMinor` | INTEGER NOT NULL, `>= 0` |
| `createdAt` | TEXT NOT NULL UTC |
| `archivedAt` | TEXT NULL UTC |

Индексы: `(kind, archivedAt)`, `(currencyCode)`, `(archivedAt, name)`.

### `account_details`

| Колонка | Тип / ограничения |
|---|---|
| `assetId` | PK → assets.id RESTRICT |
| `bankId` | INTEGER NOT NULL → subgroups.id RESTRICT |
| `annualRate` | TEXT NOT NULL Decimal, `0 <= value <= 100` |
| `startDate` | TEXT NOT NULL LocalDate |
| `endDate` | TEXT NULL LocalDate |

Индекс `(bankId)`. Check `endDate IS NULL OR startDate <= endDate` выполняется domain +
DB trigger, потому что Decimal check не полагается на SQLite numeric affinity.

### `investment_details`

`assetId` PK → assets RESTRICT; `brokerId` NOT NULL → subgroups RESTRICT.
Индекс `(brokerId)`.

### `property_details`

`assetId` PK → assets RESTRICT; `address` TEXT NULL; `purchasePriceMinor` INTEGER NULL,
`>= 0`. Цена покупки выражена в `assets.currencyCode`.

Repository в одной транзакции создаёт/изменяет общую строку и ровно одну detail-строку,
соответствующую `assets.kind`. Смена `kind` после create запрещена.

### `asset_valuations`

| Колонка | Тип / ограничения |
|---|---|
| `id` | PK |
| `assetId` | INTEGER NOT NULL → assets RESTRICT |
| `effectiveOn` | TEXT NOT NULL LocalDate |
| `valueMinor` | INTEGER NOT NULL, `>= 0` |
| `currencyCode` | TEXT NULL → currencies.code RESTRICT; `NULL` = `assets.currencyCode` |
| `rateToRub` | TEXT NOT NULL Decimal `> 0` |
| `valueRubMinor` | INTEGER NOT NULL, `>= 0` |
| `createdAt` | TEXT NOT NULL UTC |

Разрешены только investment/property. Индексы `(assetId, effectiveOn DESC, id DESC)`,
`(effectiveOn)`, `(assetId, createdAt)`. Один актив может иметь несколько оценок на дату;
последняя определяется `effectiveOn`, затем `id`, а не временем устройства.

`currencyCode` — валюта оценки (M1/M2): `NULL` означает валюту актива и пишется при
совпадении. У инвестиции допустима любая валюта справочника, у квартиры — только валюта
актива, иначе `validationCurrencyMismatch`. `valueRubMinor` считается от валюты оценки
по её `rateToRub`.

## 4. Транзакции активов и переводы

### `asset_transfers`

| Колонка | Тип / ограничения |
|---|---|
| `id` | PK |
| `createdAt` | TEXT NOT NULL UTC |
| `updatedAt` | TEXT NOT NULL UTC |

Служебная группа двух ног; денежные поля не дублируются. Transfer group остаётся после
soft delete обеих ног для аудита.

### `asset_transactions`

| Колонка | Тип / ограничения |
|---|---|
| `id` | PK |
| `assetId` | INTEGER NOT NULL → assets RESTRICT |
| `kind` | TEXT NOT NULL stable enum |
| `amountMinor` | INTEGER NOT NULL `> 0`, в валюте операции |
| `currencyCode` | TEXT NULL → currencies.code RESTRICT; `NULL` = валюта актива |
| `occurredOn` | TEXT NOT NULL LocalDate |
| `rateToRub` | TEXT NOT NULL Decimal `> 0` |
| `amountRubMinor` | INTEGER NOT NULL `> 0` |
| `comment` | TEXT NULL |
| `transferId` | INTEGER NULL → asset_transfers RESTRICT |
| `revisionNo` | INTEGER NOT NULL `>= 1` |
| `createdAt` | TEXT NOT NULL UTC |
| `updatedAt` | TEXT NOT NULL UTC |
| `deletedAt` | TEXT NULL UTC |

Индексы: `(assetId, occurredOn DESC, id DESC)`, `(occurredOn)`, `(kind)`,
`(transferId)`, `(deletedAt, occurredOn DESC)`.
Unique partial index `asset_transactions_active_transfer_leg` на `(transferId, kind)`
`WHERE deletedAt IS NULL AND transferId IS NOT NULL`.
Check: transfer kinds требуют `transferId`, deposit/withdrawal требуют `NULL`;
наличие ровно transferOut у исходного и transferIn у целевого актива проверяет DAO
в транзакции и тестами.

`currencyCode` — валюта операции (M1/M2): `NULL` означает валюту актива и пишется при
совпадении. Операция инвестиции допускает любую валюту справочника; операция счёта —
только валюту актива, иначе `validationCurrencyMismatch`. У перевода ноги всегда в
валюте своего счёта. `amountRubMinor = amountOriginal × rateToRub` считается от валюты
операции (M6), а не от валюты актива.

### `asset_transaction_revisions`

`id` PK; `transactionId` NOT NULL → asset_transactions RESTRICT; `revisionNo` NOT NULL;
`action` NOT NULL; `snapshotJson` NOT NULL; `changedAt` NOT NULL UTC.
Unique `(transactionId, revisionNo)`; индекс `(transactionId, changedAt, id)`.

Snapshot операции содержит аддитивный ключ `currencyCode` (`String?`, `null` = валюта
актива, M7); `snapshotSchemaVersion` остаётся 1. Декодер аудита читает ключ с fallback
на валюту актива — старые snapshot продолжают открываться.

## 5. Денежный поток

### `cashflow_entries`

| Колонка | Тип / ограничения |
|---|---|
| `id` | PK |
| `kind` | TEXT NOT NULL `income|expense` |
| `categoryId` | INTEGER NOT NULL → categories RESTRICT |
| `amountMinor` | INTEGER NOT NULL `> 0` |
| `currencyCode` | TEXT NOT NULL → currencies RESTRICT |
| `occurredOn` | TEXT NOT NULL LocalDate |
| `rateToRub` | TEXT NOT NULL Decimal `> 0` |
| `amountRubMinor` | INTEGER NOT NULL `> 0` |
| `affectsBalance` | INTEGER NOT NULL boolean |
| `comment` | TEXT NULL |
| `propertyId` | INTEGER NULL → assets RESTRICT |
| `accountId` | INTEGER NULL → assets RESTRICT |
| `assetTransactionId` | INTEGER NULL → asset_transactions RESTRICT |
| `recurringRuleId` | INTEGER NULL → recurring_cashflow_rules RESTRICT; правило, создавшее автооперацию |
| `revisionNo` | INTEGER NOT NULL `>= 1` |
| `createdAt` | TEXT NOT NULL UTC |
| `updatedAt` | TEXT NOT NULL UTC |
| `deletedAt` | TEXT NULL UTC |

Индексы: `(occurredOn DESC, id DESC)`, `(kind, occurredOn)`, `(categoryId, occurredOn)`,
`(currencyCode, occurredOn)`, `(propertyId, occurredOn)`, `(accountId, occurredOn)`,
`(assetTransactionId)`, `(deletedAt, occurredOn DESC)`.
Unique partial index `cashflow_active_asset_link` на `assetTransactionId`
`WHERE assetTransactionId IS NOT NULL AND deletedAt IS NULL`.
Unique partial index `cashflow_recurring_period` на `(recurringRuleId, occurredOn)`
`WHERE recurringRuleId IS NOT NULL` — одна автооперация на правило и дату, включая
soft-deleted: удалённая пользователем автооперация не пересоздаётся (BR-RC-4).

Domain + DAO checks:

- `affectsBalance = true` требует account; для связанной пары `assetTransactionId`
  обязателен. `affectsBalance = false` требует `assetTransactionId = NULL`; `accountId`
  может сохраняться только как классификация/фильтр без влияния на баланс.
- `propertyId` указывает на property, `accountId` — на account; оба одновременно запрещены.
- Для связанной пары accountId, kind, amount/currency, occurredOn и rate согласованы с
  asset transaction. `amountRub` каждой записи хранится как её собственный immutable
  snapshot, но при создании пары обязан совпасть.

### `cashflow_entry_revisions`

`id` PK; `entryId` → cashflow_entries RESTRICT; `revisionNo`; `action`; `snapshotJson`;
`changedAt`. Unique `(entryId, revisionNo)`; индекс `(entryId, changedAt, id)`.

## 6. Справочники, валюты и цели

### `subgroups`

`id` PK; `kind` TEXT `bank|broker`; `name` TEXT; `normalizedName` TEXT;
`createdAt` UTC. Unique `(kind, normalizedName)`; индекс `(kind, name)`.
`normalizedName = trim + collapse whitespace + lowercase` вычисляется в Dart и хранится
только для uniqueness, UI использует `name`.

### `currencies`

`code` TEXT PK uppercase; `name` TEXT; `normalizedName` TEXT; `fractionDigits` INTEGER
NOT NULL `0..8`; `isPreset` boolean; `isEnabled` boolean. Unique `normalizedName` среди
активных справочников обеспечивает repository; RUB защищён от disable/delete триггером.

### `exchange_rates`

`id` PK; `currencyCode` → currencies RESTRICT; `date` LocalDate; `rateToRub` Decimal >0;
`source` `cbr|manual`; `fetchedAt` UTC. Unique `(currencyCode, date)`; индекс
`(currencyCode, date DESC)`. RUB не получает строк кэша: его курс 1 создаёт resolver.

### `categories`

`id` PK; `kind` `income|expense`; `name`; `normalizedName`; `colorKey` NULL;
`iconKey` NULL; `isPreset` boolean; `archivedAt` UTC NULL.
Unique partial index `(kind, normalizedName) WHERE archivedAt IS NULL`;
индексы `(kind, archivedAt, name)`, `(archivedAt)`.

### `goals`

`id` PK; `name`; `category` `accounts|investments`; `targetAmountMinor` >0;
`currencyCode` → currencies RESTRICT; `status` stable enum; `targetDate` LocalDate NULL;
`createdAt`, `updatedAt` UTC; `deletedAt` UTC NULL.
Индексы `(status, deletedAt)`, `(targetDate)`, `(currencyCode)`.

### `goal_assets`

`goalId` → goals RESTRICT; `assetId` → assets RESTRICT; PK `(goalId, assetId)`;
индекс `(assetId, goalId)`. Цель с `accounts` связывается только с account, с
`investments` — только с investment. Удаление goal только soft, поэтому cascade не нужен.

### `app_settings`

`key` TEXT PK; `value` TEXT NOT NULL; `updatedAt` UTC NOT NULL.
В v1 единственный обязательный ключ `baseCurrencyCode = RUB`. Неизвестные ключи при
импорте сохраняются, но читаются только зарегистрированными адаптерами. Секреты и пути
к временным backup-файлам здесь не хранятся.

## 7. Инициализация и миграции

- `AppDatabase` принимает `QueryExecutor`; production path —
  `<applicationDocuments>/finanseapp.sqlite` из `app_database_path.dart`.
- `schemaVersion = 4`, `onCreate`: все таблицы/индексы v1–v4, затем
  `ReferenceSeeder.seed` внутри одной транзакции. `onUpgrade` из v1: создать
  `recurring_cashflow_rules`, добавить `cashflow_entries.recurring_rule_id`, применить
  runtime-DDL `schemaObjectsV2` (частичные unique-индексы), затем добавить
  `asset_transactions.currency_code` и `asset_valuations.currency_code`, затем создать
  `investment_locked_amounts`. Из v2: те же две nullable-колонки и таблица отметок.
  Из v3: только `createTable(investment_locked_amounts)`. Runtime-DDL v3/v4 не нужен:
  FK на `currencies.code` объявлен в таблицах и создаётся вместе с ними, PK отметок
  `(asset_id, currency_code)` создаётся вместе с таблицей.
- `beforeOpen`: `PRAGMA foreign_keys = ON`; в release не выполняются destructive fallback,
  `deleteAllTables` или молчаливая подмена схемы.
- После каждой схемной задачи: `dart run build_runner build --delete-conflicting-outputs`,
  `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`.
- Тест v1 проверяет все FK/unique/indexes через `sqlite_master`, `foreign_key_check` и
  `PRAGMA integrity_check`; seed запускается дважды без дублей и перезаписи rename.
  Тест v2→v3 на файловой БД проверяет `user_version`, наличие nullable-колонок
  (`PRAGMA table_info`), целостность старых строк и чтение их в валюте актива.
  Тест v3→v4 проверяет `user_version = 4`, колонки/PK/CHECK/FK `investment_locked_amounts`,
  целостность старых строк и установку отметки через репозиторий после апгрейда.
- При будущем импорте более старой схемы она открывается только через новый AppDatabase,
  который выполняет последовательный upgrade **до** открытия приложения.

## 8. Обязательные DB-транзакции

### TX-ASSET-SAVE

1. Проверить справочники, kind, name, opening value и запрет смены currency при связях.
2. Insert/update assets + detail. При create связей/revisions нет.
3. Любая ошибка откатывает обе записи.

### TX-ASSET-TX-CREATE

1. Заблокировать повтор команды на уровне ViewModel; прочитать актив и проверить kind/date.
2. Вычислить minor amounts заранее через MoneyMath; для withdrawal проверить projected
   balance с учётом даты/порядка и всей текущей истории, не только конечный баланс.
3. Insert tx с revisionNo 1, затем revision create с идентичным snapshot.
4. Commit. Если linked cashflow требуется, эта транзакция расширяется TX-LINKED-SAVE,
   а не вызывается отдельно из UI.

### TX-LINKED-SAVE

1. Для create: insert asset transaction + revision 1.
2. Вызвать `CashflowRepository.createLinked(draft, assetTransactionId: id)` в том же
   `AppDatabase.transaction`; insert cashflow + revision 1.
3. Для edit: одной транзакцией revise обе current projections, каждую с собственным
   increment revisionNo и snapshot. Проверить новый баланс до commit.
4. Отключение `affectsBalance`: старая tx получает delete revision и deletedAt; новая
   cashflow revision имеет affectsBalance/assetTransactionId = false/null. accountId
   сохраняется для фильтра либо становится null только при явном удалении счёта из формы.
5. Включение `affectsBalance`: создаётся новая tx + create revision, cashflow получает
   edit revision с новой связью. Старая удалённая tx не воскрешается.
6. Soft delete cashflow мягко удаляет связанную tx со своей delete revision. Любое
   исключение откатывает обе стороны.

### TX-TRANSFER-SAVE

1. Проверить два разных account, обе суммы, курсы и исходный баланс.
2. Create: insert transfer group; insert transferOut + transferIn с общим transferId;
   по одной create revision каждой ноге.
3. Edit: `reviseTransfer` обновляет обе ноги одним draft и добавляет edit revision каждой.
4. Delete: `softDeleteTransfer` добавляет delete revision и deletedAt обеим ногам.
5. Обычные `revise`/`softDelete` для transfer leg выбрасывают conflict. Частичный commit
   и перевод как income/expense запрещены тестами.

### TX-REFERENCE-MOVE-DELETE

Перенос всех ссылок в target того же kind, проверка `count = 0`, затем delete source —
одна транзакция. При конфликте unique ничего не переносится. Использованные курсы,
валюты и связанные активы физически не удаляются.

## 9. Запросы и согласованность

- Списки автоматически фильтруют `deletedAt IS NULL`; audit явно читает revisions и
  удалённые current projections.
- Балансы не используют cashflow entries; cashflow aggregates не используют asset tx.
- Связь `AssetTransaction.cashflowEntryId` получается join по
  `cashflow_entries.assetTransactionId`, второй FK в asset_transactions отсутствует.
- Текущая стоимость и аналитика всегда определяют порядок по `(effectiveOn/occurredOn,
  id)`, а не по порядку выборки SQLite.
- Все write-методы работают внутри переданного Drift transaction executor; вложенный
  вызов repository не открывает независимое соединение и не делает premature commit.

## 10. Регулярные платежи (schema v2)

### `recurring_cashflow_rules`

| Колонка | Тип / ограничения |
|---|---|
| `id` | PK |
| `strategy` | TEXT NOT NULL `fixed|deposit_interest` |
| `kind` | TEXT NOT NULL `income|expense` |
| `categoryId` | INTEGER NOT NULL → categories RESTRICT |
| `amountMinor` | INTEGER NULL `> 0`; NOT NULL только у `fixed` |
| `currencyCode` | TEXT NOT NULL → currencies RESTRICT |
| `accountId` | INTEGER NULL → assets RESTRICT |
| `propertyId` | INTEGER NULL → assets RESTRICT |
| `affectsBalance` | INTEGER NOT NULL boolean |
| `startDate` | TEXT NOT NULL LocalDate |
| `endDate` | TEXT NULL LocalDate |
| `comment` | TEXT NULL |
| `lastGeneratedPeriod` | TEXT NULL `YYYY-MM`; маркер catch-up |
| `createdAt` / `updatedAt` | TEXT NOT NULL UTC |
| `deletedAt` | TEXT NULL UTC |

CHECK: property/account взаимоисключающи; `affectsBalance` требует account;
`startDate <= endDate`; `fixed` имеет сумму, `deposit_interest` — нет; у
`deposit_interest` всегда `income`, `accountId != NULL`, `affectsBalance = 1`.
Индексы: `(deletedAt)`, `(accountId)`, `(propertyId)`.
Unique partial index `recurring_active_deposit_interest` на `(accountId)`
`WHERE strategy = 'deposit_interest' AND deletedAt IS NULL` — одно автоправило на счёт.

Правило не хранит ревизий: изменение правил не переписывает созданные операции
(они живут как обычные `cashflow_entries` со своими ревизиями). `last_generated_period`
двигается в той же транзакции, что и автооперация.

Автоправило `deposit_interest` синхронизируется с `account_details` при каждом
catch-up: ставка > 0 и актив не архивный → upsert (маркер сохраняется), ставка 0/архив →
soft delete; повторное включение восстанавливает ту же строку с маркером, поэтому
проценты не дублируются. Начисления — обычные связанные пары `deposit + income`
с `recurring_rule_id`; сумма считается от фактического баланса на дату.

## 11. Заблокированные активы (schema v4)

### `investment_locked_amounts`

| Колонка | Тип / ограничения |
|---|---|
| `assetId` | INTEGER NOT NULL → assets RESTRICT |
| `currencyCode` | TEXT NOT NULL → currencies RESTRICT |
| `amountMinor` | INTEGER NOT NULL `> 0` |
| `createdAt` / `updatedAt` | TEXT NOT NULL UTC |

PK `(assetId, currencyCode)` — одна отметка на валюту инвестиции. Повторная установка
делает upsert (`updatedAt` обновляется, `createdAt` сохраняется); `amountMinor = 0`
удаляет строку. SQL не проверяет kind актива: инвестицию, известную валюту и баланс
проверяют DAO и репозиторий до записи (BR-A-9): `0 < amount <=` баланс валютной
позиции из `investmentBalances`. Отметка не пересчитывается при последующем изменении
баланса и не входит в `referenceCounts` (BR-A-5), потому что удаляется вместе с
активом в той же транзакции `deleteIfUnused` (FK RESTRICT). Архивация отметки
сохраняет; UI архивной инвестиции работает read-only. Стоимость актива, `net worth`
и валютные позиции отметки не меняют (D4). Индексов нет: выборки идут по PK
`asset_id` и батчем по всем строкам для снапшотов.
