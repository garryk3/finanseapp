# Архитектура FinanseApp

Комплект является обязательным контекстом для реализации. Не нужно читать весь `PLAN.md`:
исполнитель открывает только свою задачу и указанные в ней разделы этих документов.

## Порядок чтения

1. `../../PRODUCT.md` — пользователь, скоуп и ограничения.
2. `business_rules.md` — поведение и ID бизнес-правил.
3. `domain_model.md` — публичные типы, repository/use-case сигнатуры и ViewState.
4. `calculations.md` — формулы и числовые эталоны.
5. `file_structure.md` — точные пути и правила зависимостей.
6. `data_schema.md` — Drift-схема, ревизии, индексы и транзакции записи.
7. `navigation_and_screens.md` — routes, экраны, поля и состояния.
8. `backup_and_updates.md` — безопасный import/export БД, SAF, restart и GitHub Updates.
9. `../uikit/design/` через `lib/uikit/design/README.md` — контракты UI.
10. Своя секция `PLAN.md` — TDD-шаги, файлы, проверки и Definition of Done.

## Канонические решения

- Feature-first: `core/features/<feature>/{domain,data,logic,ui}`.
- MVVM: View → ViewModel на `signals` → use case/repository → DAO → Drift.
- Manual DI: singleton для БД и stateless repositories, factory для ViewModel.
- Деньги — minor units; курсы — `Decimal` в TEXT; даты операций — `LocalDate` в ISO TEXT.
- RUB — неизменяемый audit snapshot; выбираемая базовая валюта — слой отчётов.
- Current projections предназначены для чтения; append-only revisions — для аудита.
- `cashflow_entries` и `asset_transactions` имеют разные агрегаты и не дублируют друг друга.
- UIKit не зависит от domain; feature View преобразует domain в presentation data.
- Domain не импортирует Flutter/Drift; UI не импортирует Drift; data не импортирует UIKit.

## Границы импортов

Разрешено:

```text
app → features.ui + core.di + uikit + l10n
features.*.ui → собственный domain/logic + общие domain/presentation + uikit
features.*.logic → domain + interfaces других features через domain
features.*.data → собственный domain + core.database + внешние пакеты
core.database → converters + tables + daos
uikit → material_ui/fl_chart + собственные presentation models
```

Запрещено:

```text
domain → Flutter / material_ui / drift / signals
ui → drift / app_database / HTTP
data → widgets / AppLocalizations / GoRouter
feature A.ui → feature B.ui
feature A.data → feature B.data
uikit → core.features / repositories / AppDatabase
```

Для orchestration двух features используется публичный command из `logic` или интерфейс
`domain`; DI связывает реализацию в `main.dart`. Циклические зависимости не допускаются.

## Definition of Done любой реализации

- Изменены только файлы своей задачи и необходимые общие регистрации/l10n.
- Сначала добавлен failing test, затем минимальная реализация; ожидаемые значения взяты
  из `calculations.md`, а не вычислены тем же алгоритмом внутри теста.
- Generated Drift/l10n и schema dump обновлены и включены в diff, когда менялись источники.
- Проходят format, оба analyze-гейта, `flutter test`, debug APK.
- Ревью выполняется **один раз на релиз** по диффу `origin/main...release/<NN>` перед слиянием
  в `main`: `task-reviewer`, для UI также `design-reviewer` (generated исключён).
- `android-tester` коротким прогоном только дописывает сценарии в `TEST_PLAN.md` — пачкой на этап.
- Перед PR владельцу задан отдельный вопрос о запуске e2e.
- Статус задачи обновлён в `PLAN.md` до PR; ветка синхронизируется только merge с
  `origin/release/<NN>`, не rebase.
