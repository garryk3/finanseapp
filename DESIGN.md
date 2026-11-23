# DESIGN.md — FinanseApp

Единый визуальный контракт Android/Linux Flutter-приложения, Material 3, русская локаль.
Исполнимые API и тесты компонентов находятся в `lib/uikit/design/`. Продуктовый контекст —
`PRODUCT.md`.

## 1. Визуальные принципы

1. **Сначала понятность чисел.** Главное на экране — сумма, период, валюта и источник
   значения. Декор не конкурирует с данными.
2. **Спокойный финансовый инструмент.** Surface hierarchy, тонкие boundaries, умеренный
   accent; никаких градиентных CTA, glassmorphism, glow, confetti и декоративных shadows.
3. **Смысл не только цветом.** Доход/расход/перевод имеют знак, подпись и/или icon;
   статусы имеют текст; графики — legend, markers и text alternative.
4. **Один источник токенов.** Feature UI использует ColorScheme/AppSemanticColors,
   AppSpacing/AppRadii и Material type scale. Новые hex и одноразовые размеры запрещены.
5. **Постепенное раскрытие.** Частые действия доступны сразу, курс/аудит/связи раскрываются
   в details и advanced sections без перегрузки списка.

## 2. Цветовая система

Provisional seed `#2E7D32` сохраняется до отдельного решения владельца. Light/dark
ColorScheme генерируются `ColorScheme.fromSeed`; полную палитру не угадывать и не
копировать вручную. Единственный brand literal находится в `lib/app/theme/app_theme.dart`.

Semantic mapping:

| Значение | Роль | Обязательное дополнение |
|---|---|---|
| Доход/прирост | primary / AppSemanticColors.income | `+`, icon или «Доход» |
| Расход/уменьшение | tertiary / expense, **не error** | `−`, icon или «Расход» |
| Перевод | secondary / transfer | arrows icon + «Перевод» |
| Успех/достигнуто | primary/success | check + status text |
| Архив/удалено | onSurfaceVariant/surfaceContainerHighest | badge «Архив»/«Удалено» |
| Ошибка/destructive | error/errorContainer | error icon + конкретное сообщение |

`noReleases`, недоступный курс, отрицательный баланс в аналитике и обычный расход не являются
destructive и не окрашиваются error. Контраст текст ≥4.5:1, крупный текст/UI ≥3:1;
проверяется на вычисленных light/dark roles. См. `uikit/design/foundations.md`.

## 3. Типографика и числа

Системный Material font, никакого обязательного custom font. Заголовок страницы —
headlineSmall/large top bar, секции — titleMedium, основной текст — bodyMedium, meta —
bodySmall. Главная сумма headlineSmall с tabular figures, сумма списка titleSmall.

- Русские labels не сокращаются до непонятных аббревиатур. Валюта и знак не отрываются от
  суммы; тысячи и decimal separator форматирует presentation layer.
- При 1.3 текст переносится. В details суммы доступны полностью; ellipsis в списке имеет
  полный semanticsLabel и раскрытие по tap.
- Не использовать uppercase для длинных русских labels, letter spacing самостоятельно не
  увеличивается.

## 4. Размеры, сетка и поверхности

- Spacing scale 4/8/12/16/24/32/48. Compact screen 16, expanded 24; form max width 640,
  content max 1200.
- Card radius 16, default padding 16, border outlineVariant, elevation 0. Sections
  разделяются 24dp, связанные элементы 8/12dp.
- Compact NavigationBar, >=600 NavigationRail; пять destinations в фиксированном порядке.
- Dashboard на expanded использует две колонки, forms остаются одной колонкой. Единая
  точка входа сетки — `AppAdaptiveGrid` (uikit): `<600dp` одна колонка, `>=600dp` две
  (fold/планшет), центрирование contentMaxWidth/formMaxWidth. Приложение зафиксировано
  в вертикальной ориентации (`screenOrientation="portrait"`); адаптивность — по ширине,
  не по повороту.
- Touch targets ≥48×48dp и gaps ≥8dp. Основные list tiles обычно ≥56dp; иконка в trailing
  имеет собственный target и tooltip.

## 5. Компонентные правила

- **Buttons:** primary filled AppButton только для главного Save/Create; tonal для
  вторичных/backup/update; text для навигационных действий; destructive только delete/
  replace. Pending spinner сохраняет ширину и блокирует повтор.
- **Cards/lists:** AppCard/AppListTile, один primary tap на tile, overflow menu для редких
  действий. Summary value визуально важнее metadata, но не за счёт микроскопического meta.
- **Forms:** AppFormSection и labels над inputs. Errors inline и сохраняются до исправления.
  Currency lock объясняется текстом. Date/amount/currency имеют специализированные inputs.
- **Dialogs/sheets:** конкретный title, последствие и named action. Import/destructive delete
  нельзя подтвердить случайным tap по barrier. Blocking restore не закрывается.
- **Feedback:** первичный loading skeleton, локальный error+retry, пустое состояние с одним
  CTA. SnackBar только как дополнительное подтверждение, не единственная ошибка.

Полные сигнатуры — `primitives.md`, `inputs.md`, `finance.md`, `patterns.md`.

## 6. Финансовые экраны

### Dashboard

Порядок: Net worth + базовая валюта/дата → заблокированные активы (если есть отметки;
сумма и доля от инвестиций с тултипом) → quick add → просроченные счета (если есть) →
подушка безопасности (если есть) → cashflow месяца → цели → последние операции. Нули при
пустой БД честны и не заменяются декоративной демо-статистикой. Cards ведут к уже
отфильтрованным данным.

### Активы

Единый список/segments счетов, инвестиций, недвижимости. Tile: icon, name, subgroup/kind,
исходная стоимость; base equivalent secondary. Details объясняет состав стоимости и даёт
операции/оценки. Прогноз вклада визуально отделён от фактического баланса словом «Прогноз».

### Операции

Переключатель «Доходы и расходы / Операции по активам / Регулярные» внутри раздела;
на узких экранах он прокручивается горизонтально, показывает контрастный scrollbar
с track и edge-fade и подводит выбранную вкладку в видимую область. Группировка по датам,
filter chips сверху, amount alignment по цифрам. Связанная операция имеет badge, но один
журнал не превращается в двойной итог другого. Transfer использует двунаправленную icon.

### Цели

Progress bar + exact current/target/status. При >100% bar полон, текст показывает фактический
процент/surplus. Closed/achieved отличаются labels; archived linked assets явно отмечены.

### Настройки

Секции «Отчёты», «Резервная копия», «О приложении». Backup actions — три равноправные
кнопки с upload/save/download icons, при узком экране vertical/full width. Предупреждение
о незашифрованном финансовом файле и замене данных видно до действия. Версия и статус
проверки обновления не имеют ложного зелёного success до ответа.

## 7. Графики

Line chart для net worth, grouped bars для income/expense. ChartSeriesColors из theme;
series различаются labels/dash/markers. Tooltip показывает exact formatted values, axes не
перегружены. Под каждым графиком доступен expandable text list тех же точек и summary.
Empty/single/zero range обрабатываются без бесконечных coordinates. Подробнее — `charts.md`.

## 8. Accessibility и platform

- WCAG 2.2 AA, Semantics labels/values, keyboard focus и activation, TalkBack порядок совпадает
  с визуальным. Icon-only actions имеют tooltip; errors связаны с полем.
- Обязательные проверки light/dark, 320dp, font scale 1.3, длинный русский текст, keyboard,
  system insets, Android Back и Remove animations.
- Charts/import warning/destructive confirmations/form errors дополнительно проходят manual
  TalkBack сценарии. Offline не лишает доступа к локальным данным.

## 9. Definition of Done дизайна

- Использованы существующие UIKit contracts; новый primitive добавлен через отдельный
  контракт и тест, а не скопирован локально.
- Нет raw Material/hex/gradient/glass в feature UI, нет error-color для обычного расхода.
- Все states и accessibility matrix из `patterns.md` проверены; design-reviewer получил
  только diff UI/docs и не выдал REDESIGN REQUIRED.
