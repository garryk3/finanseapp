# UIKit FinanseApp — контракты для реализации

Этот каталог содержит проектные контракты, а не Dart-реализацию. Создавать `.dart`
файлы разрешается только в задаче 3.4 и последующих задачах по мере необходимости.

## Порядок чтения

1. `foundations.md` — theme extension, spacing, shapes, semantic colors, типографика.
2. `primitives.md` — базовые обёртки, layout, кнопки, навигация, feedback.
3. `inputs.md` — поля, select, filters и form sections.
4. `finance.md` — деньги, активы, операции, цели и summary.
5. `charts.md` — presentation models, line/cashflow charts и доступная альтернатива.
6. `patterns.md` — empty/error/confirm и обязательные widget-тесты.
7. Корневой `DESIGN.md` — визуальные принципы и готовые экранные паттерны.

## Обязательные правила

- Public API принимает только immutable presentation values (`String`, `bool`, `num`,
  `DateTime`, UIKit options/models) и callbacks. `Asset`, `Money`, `Decimal`,
  `CashflowEntry`, repositories, DAO, `AppLocalizations` и `ServiceLocator` запрещены.
- Все видимые labels приходят готовыми русскими строками из feature View. UIKit не
  содержит словарей и не форматирует бизнес-дату/курс по собственным правилам.
- Компоненты используют `Theme.of(context)`, `ColorScheme` и `AppSemanticColors`.
  Прямые `Color(...)`, `Colors.*`, самодельные shadows/gradients запрещены даже внутри
  новых UIKit widgets; разрешённый seed и chart tokens находятся в `lib/app/theme/`.
- Сырые Material widgets существуют только внутри соответствующей UIKit-обёртки. Feature
  код не использует ignore-for-file и не обходит analyzer guard.
- Touch targets минимум 48×48dp, соседние targets разнесены минимум на 8dp. Icon-only
  action обязан иметь `tooltip`/`semanticLabel`.
- Каждый компонент проверяется light/dark, enabled/disabled/pending/error где применимо,
  320dp width, font scale 1.3 и длинным русским текстом. Не полагаться на golden как на
  единственный тест: callbacks и Semantics проверяются отдельно.
- При `MediaQuery.disableAnimations` или доступном Reduce motion индикаторы и transitions
  не содержат бесконечной декоративной анимации. Skeleton не читается TalkBack как текст.
- В сигнатурах ниже тела намеренно опущены. Дополнительные optional параметры можно
  добавлять только обратно совместимо; обязательные параметры нельзя удалять без обновления
  контракта, `DESIGN.md`, PLAN и тестов.

## Общие тестовые фикстуры

Тестовый host использует `AppTheme.light()`/`dark()`, `AppLocalizations` и bounded
320×640/800×600 размеры. Длинная строка: «Очень длинное название финансовой операции,
которое должно полностью переноситься без обрезки». Проверяются:

- отсутствие `RenderFlex overflow` и `FlutterError`;
- читаемый semantics label/value и отсутствие смысла только в цвете;
- один callback на один tap, отсутствие callback в disabled/pending;
- клавиатура/focus там, где есть input, и system insets для dialogs/sheets;
- numeric values полностью доступны, если на узком экране применяется visual ellipsis.
