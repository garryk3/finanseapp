# docs/PROJECT.md — стабильный технический контекст FinanseApp

Документ содержит краткий стек и ссылки на нормативные архитектурные контракты.
Живые задачи и статусы находятся только в `PLAN.md`.

## Стек

- Flutter / Dart stable без пина; Android 12+ (minSdk 31), Linux desktop для integration.
- `signals` + `signals_flutter`, MVVM; Riverpod/Bloc/GetX запрещены.
- SQLite через Drift; generated Drift/l10n и schema dumps коммитятся.
- Деньги — `decimal` + `rational` (exact-арифметика без `double`), на границе —
  int64 `minorUnits`; округление half away from zero один раз на итоге.
- `go_router`, `fl_chart`, `flutter_localizations` + `intl`, русская локаль.
- Manual DI через конструкторы, feature-first внутри `lib/core/features/`.
- Material 3 через `package:material_ui/material_ui.dart`; светлая и тёмная темы.
- UI только через `lib/uikit/`; analyzer guard `restrict_raw_flutter` обязателен.
- Offline-first; сеть нужна для точных курсов ЦБ РФ и ручной проверки GitHub Updates.
- Защита доступа (12.5): `local_auth` (биометрия, graceful fallback на PIN),
  `flutter_secure_storage` (хэш PIN и флаги вне БД — backup их не переносит),
  `crypto` (PBKDF2-HMAC-SHA256 для salted hash PIN).
- CI: format, оба analyze-гейта, unit/widget tests и debug APK; releases по тегам `v*`.

## Архитектурные контракты

Начинать с `docs/architecture/README.md`. Нормативные документы:

- `../PRODUCT.md` — пользователь, scope, принципы и accessibility.
- `architecture/business_rules.md` — канонические BR и матрица покрытия.
- `architecture/domain_model.md` — entities, drafts, repositories, use cases, ViewState.
- `architecture/calculations.md` — формулы и 36 числовых эталонов.
- `architecture/file_structure.md` — целевые пути lib/test/integration/drift_schemas.
- `architecture/data_schema.md` — Drift v1, constraints, indexes и DB-транзакции.
- `architecture/navigation_and_screens.md` — routes, экраны, prefill и состояния.
- `architecture/backup_and_updates.md` — SQLite export/import, rollback, SAF, GitHub Releases.
- `../lib/uikit/design/README.md` — контракты всех UI-компонентов.
- `../DESIGN.md` — визуальная система.

## Ключевые решения

- Деньги — integer minor units; курсы — Decimal TEXT; операции — LocalDate `yyyy-MM-dd`;
  timestamps — UTC. `rateToRub` означает RUB за единицу валюты, конвертация в RUB — умножение.
- RUB snapshot неизменяем; пользовательская базовая валюта применяется только к отчётам.
- Current projections отделены от append-only revisions; create/edit/delete атомарны.
- Cashflow и asset transactions имеют разные итоги. Единственная связь —
  `cashflow_entries.assetTransactionId`; reverse join производный.
- Перевод — две ноги transfer group, никогда не доход/расход. Отрицательный баланс запрещён.
- Backup проверяется до закрытия текущей БД; candidate мигрируется отдельно, rollback snapshot
  восстанавливает старые данные при любой ошибке replace/reopen/rebuild.
- Импорт/обновления находятся в Settings; backup не является облачной синхронизацией.

## Текущая структура

Этап 1 содержит только каркас `main.dart`, app/router/theme, demo Home и минимальный UIKit.
Целевое дерево — `architecture/file_structure.md`; пустые Dart-заглушки заранее не создаются.
Этап 2 содержит проектные документы без реализации продукта. Демо Home удаляется задачей 3.5.

## Окружение

- Эмулятор AVD `Pixel_10_Pro` (x86_64, Android 16), SDK `~/Android/Sdk`.
- JDK 21 (Temurin); детали окружения — `docs/AGENTS_DETAILS.md`.
- Integration: `flutter test integration_test -d linux`, только после вопроса владельцу
  перед PR; в CI не запускаются.
