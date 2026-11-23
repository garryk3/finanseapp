# Навигация, экраны и состояния

Документ — контракт `go_router`, View и ViewModel. Все видимые строки берутся из
`app_ru.arb`; route names/paths и query keys не локализуются.

## 1. Shell и адаптивная навигация

Пять primary destinations в фиксированном порядке:

| Index | Label | Icon | Path |
|---|---|---|---|
| 0 | Главная | dashboard_outlined | `/` |
| 1 | Операции | receipt_long_outlined | `/operations` |
| 2 | Активы | account_balance_wallet_outlined | `/assets` |
| 3 | Цели | flag_outlined | `/goals` |
| 4 | Ещё | more_horiz | `/more` |

- Compact width `< 600dp`: `AppNavigationBar`; medium/expanded `>= 600dp`:
  `AppNavigationRail`, контент получает bounded width и не растягивает формы на весь экран.
- StatefulShellRoute сохраняет navigation stack каждого раздела. Повторный tap по
  текущему destination возвращает на его root, не создаёт бесконечный стек.
- Secondary pages отображают back button и не добавляют второй NavigationBar/Rail.
- Android back: закрыть dialog/sheet → pop secondary page → root предыдущего раздела →
  системное завершение только на корневом стеке. Unsaved form требует confirm discard.
- После create/update/delete ViewModel сначала подтверждает commit; только затем View
  делает pop/push и SnackBar. При ошибке форма остаётся открытой.

## 2. Полная карта routes

Статические сегменты регистрируются **до** `/:id`. `id` и `transferId` — decimal int >0;
невалидное/отсутствующее значение не передаётся в repository.

| Name | Path | Экран |
|---|---|---|
| dashboard | `/` | DashboardScreen |
| operations | `/operations?tab=cashflow` | Operations host: CashflowScreen / TransactionsScreen / RecurringRulesScreen |
| assets | `/assets` | AssetsScreen |
| account-new | `/assets/new/account` | AccountFormScreen(create) |
| investment-new | `/assets/new/investment` | InvestmentFormScreen(create) |
| property-new | `/assets/new/property` | PropertyFormScreen(create) |
| asset-details | `/assets/:id` | Account/Investment/PropertyDetailsScreen по kind |
| account-edit | `/assets/:id/edit/account` | AccountFormScreen(edit) |
| investment-edit | `/assets/:id/edit/investment` | InvestmentFormScreen(edit) |
| property-edit | `/assets/:id/edit/property` | PropertyFormScreen(edit) |
| valuation-new | `/assets/:id/valuations/new` | ValuationFormScreen |
| transaction-new | `/transactions/new` | TransactionFormScreen(create) |
| transfer-new | `/transactions/transfer/new` | TransferFormScreen(create) |
| transaction-details | `/transactions/:id` | TransactionDetailsScreen |
| transaction-edit | `/transactions/:id/edit` | TransactionFormScreen(edit) |
| transfer-edit | `/transactions/transfer/:transferId/edit` | TransferFormScreen(edit) |
| cashflow-new | `/cashflow/new` | CashflowFormScreen(create) |
| cashflow-details | `/cashflow/:id` | CashflowDetailsScreen |
| cashflow-edit | `/cashflow/:id/edit` | CashflowFormScreen(edit) |
| recurring-new | `/recurring/new` | RecurringRuleFormScreen(create) |
| recurring-edit | `/recurring/:id/edit` | RecurringRuleFormScreen(edit; auto interest read-only) |
| goals | `/goals` | GoalsScreen |
| goal-new | `/goals/new` | GoalFormScreen(create) |
| goal-details | `/goals/:id` | GoalDetailsScreen |
| goal-edit | `/goals/:id/edit` | GoalFormScreen(edit) |
| more | `/more` | MoreScreen |
| analytics | `/more/analytics` | AnalyticsScreen |
| analytics-details | `/more/analytics/details` | CashflowDetailsScreen (детализация периодов) |
| settings | `/more/settings` | SettingsScreen |
| categories | `/more/categories` | CategoriesScreen |
| category-new | `/more/categories/new` | CategoryFormScreen(create) |
| category-edit | `/more/categories/:id/edit` | CategoryFormScreen(edit) |
| subgroups | `/more/subgroups?kind=bank` | SubgroupsScreen |
| currencies | `/more/currencies` | CurrenciesScreen |
| currency-new | `/more/currencies/new` | CurrencyFormScreen |
| base-currency | `/more/currencies/base` | BaseCurrencyScreen |
| audit | `/more/audit` | AuditScreen |
| audit-asset-transaction | `/more/audit/asset-transactions/:id` | AuditEntryDetailsScreen(asset tx) |
| audit-cashflow | `/more/audit/cashflow/:id` | AuditEntryDetailsScreen(cashflow) |
| about | `/more/about` | AboutScreen |
| not-found | `/not-found` | NotFoundScreen |
| applock-manage | `/applock` | ApplockManageScreen (управление защитой; переедет в `/more/settings` в 10.3) |

`errorBuilder` ведёт в NotFoundScreen с безопасной кнопкой «На главную». Unknown route,
invalid int, wrong kind для typed edit и удалённый/отсутствующий id показывают Not Found;
stack trace и сырое исключение пользователю не выводятся. Для details архивный актив
доступен в read-only режиме; soft-deleted операция доступна только из audit route.

Экран блокировки приложения (ApplockScreen) route'ом не является: это overlay
(`AppLockGate` в `builder` у `MaterialApp.router`), который перекрывает любой текущий
маршрут при локе на cold start или возврате из фона (BR-Sec-6). Кнопка «назад»
лок-скрин не закрывает.

Онбординг первого запуска (`OnboardingGate`) стоит в той же цепочке `builder`, но **внутри**
`AppLockGate` (лок перекрывает онбординг, BR-Sec-6): пока флаг `app_settings.onboardingCompleted`
не выставлен, `child` (Router) не монтируется. Экран онбординга рендерится под собственным
`Navigator`, поэтому uikit-модалки (`AppSelect`, bottom sheet, диалоги) работают без Router.
Системный BACK в этом состоянии закрывает открытый sheet/диалог онбординга
(`WidgetsBindingObserver.didPopRoute` в гейте) и не завершает приложение; на корне
онбординга без модалки BACK работает как обычно — выходит из приложения.

### Холодный старт: видео-заставка

`AppRestartHost` оборачивает приложение в `StartupSplash` (гейт 2.5 с):

1. Первый кадр Flutter — `SplashScreen` с `VideoPlayerController.asset`
   (`assets/video/finsplash.mp4`, звук 0, без цикла): центральный квадрат 1:1
   исходника 16:9 на фоне `AppTheme.splashBackground`; до готовности видео виден
   постер `assets/video/finsplash_poster.png` (первый кадр), при
   `MediaQuery.disableAnimations` — только постер, ошибка инициализации —
   постер без видео; края растворяются в фоне градиентными шторками.
2. Ровно через 2.5 с гейт скрывает заставку, даже если DI/БД ещё собираются:
   приложение проявляется поверх неё за последние 200 мс (видимо ≤2.5 с;
   reduce-motion — мгновенно); пока `locator == null`, показывается
   `StartupLoadingScreen` (фон + спиннер), затем `FinanseApp`.
3. Гейт включён только на Android (`defaultTargetPlatform`): Linux e2e и
   widget-тесты не ждут видео. `StartupSplash` сохраняет state между обновлениями
   child, поэтому restart по импорту backup видео не повторяет.

Android launch-тема (`LaunchTheme`, drawable `launch_background`) и
`windowSplashScreenBackground` используют тот же `#06110E`, поэтому белой
вспышки до первого кадра нет.

## 3. Query parameters и prefill

| Route | Keys | Правила |
|---|---|---|
| `/operations` | `tab=cashflow|transactions|recurring` | default cashflow; invalid → cashflow без crash |
| `/subgroups` | `kind=bank|broker` | default bank; переключатель сохраняет выбранный tab |
| `/transactions/new` | `assetId`, `kind=deposit|withdrawal`, `cashflow=true` | только существующий account/investment; cashflow=true требует account и категорию |
| `/cashflow/new` | `kind=income|expense`, `accountId`, `propertyId`, `affectsBalance=true|false` | accountId и propertyId взаимоисключающи; affectsBalance без accountId игнорируется с подсказкой; чекбокс «Повторять ежемесячно» создаёт правило |
| `/recurring/new` | `kind=income|expense`, `accountId`, `propertyId` | preset-цель из экрана актива; иначе выбор счёта/недвижимости; endDate ≥ startDate |
| `/goals/new` | `category=accounts|investments` | default accounts |
| `/assets` | `kind=account|investment|property`, `query` | filters не попадают в journal других разделов |
| `/more/audit` | `type=assetTransaction|cashflow`, `query` | default assetTransaction |
| `/more/analytics/details` | `period=month|3m|6m|year|all`, `kind=income|expense`, `categoryId` | default month; invalid period/kind/categoryId игнорируются; kind/category наследуются с аналитики и на странице не редактируются |

Все query values читаются через allowlist и `int.tryParse`; repository не получает строку
из URL. Несуществующий prefill id показывает inline error и оставляет форму, а не создаёт
запись с нулевым FK.

## 4. Общие состояния экранов

Каждый stateful экран явно обрабатывает:

- `loading`: первичный `AppSkeleton`; повторная загрузка не стирает текущие данные.
- `data`: immutable snapshot; списки имеют стабильные keys и semantics labels.
- `empty`: `AppEmptyState` с объяснением и одним релевантным CTA, не бесконечный spinner.
- `error`: `AppErrorState` + Retry; текущий введённый текст не сбрасывается.
- `offline`: локальные данные доступны без баннера; network-only ЦБ/GitHub получает
  inline статус и действие «Ввести курс»/«Повторить», приложение не блокируется.
- `archived/deleted`: архивный объект read-only с badge; deleted скрыт вне audit; гонка
  «объект удалён, пока форма открыта» превращается в conflict, не crash.
- `busy`: повторный Save/Import/Export/Check блокируется, progress виден; навигация назад
  во время irreversible restore отключена, остальные операции можно отменить системно.

При font scale 1.3, 320dp width и длинном русском тексте actions переносятся или
складываются вертикально; суммы не обрезаются без доступного полного значения в details.

## 5. Матрица экранов и контрактов

VM — ViewModel, создаваемая через DI. «Тест» — минимальный обязательный widget/unit
сценарий помимо loading/error и навигации.

| Экран | VM и данные | Ключевой UI/действия | Обязательный тест |
|---|---|---|---|
| Dashboard | DashboardViewModel: net worth, заблокированные активы (если есть отметки), цели, последние операции, cashflow месяца | Summary, блок заблокированных с долей и тултипом, charts teaser, quick add | Пустая БД показывает нули и CTA; блок скрыт без отметок; сумма/доля и ошибка курса; tap ведёт в нужный prefill |
| CashflowScreen | CashflowViewModel: watch(filter), summary | Фильтры, date groups, add income/expense | Удалённая запись скрыта; transfer отсутствует |
| TransactionsScreen | TransactionsViewModel: watch(filter) | Deposit/withdrawal/transfer, filters | Связанный расход имеет badge, но не дублирует сумму cashflow |
| RecurringRulesScreen | RecurringRulesViewModel: watchActive + справочники | Список правил, следующий платёж, «Ожидает курс», CTA | Автоправило процентов ведёт в детали счёта, без правки |
| RecurringRuleForm | RecurringRuleFormViewModel: rule/categories/currencies/assets | Kind/amount/currency/category, target, affectsBalance, даты, comment | endDate ≥ startDate; авто-правило read-only; удаление с confirm |
| RecurringRulesSection | watchByAccount/watchByProperty | Правила объекта/счёта + CTA | Архивный актив → readOnly |
| AssetsScreen | AssetsViewModel: watchAll + filters | Три kind, архив filter, add menu | Account/investment/property имеют корректные стоимости |
| AccountForm | AccountFormViewModel: banks, currencies, save | Name, bank, currency, opening, annualRate, start/end | 0%, end<start, used currency lock |
| AccountDetails | AccountDetailsViewModel: snapshot, tx, forecast, breakdown/currencies | Баланс, состав по валютам, итог в базовой, прогноз, history | После tx прогноз обновляется; мультивалютный итог и состав; archive read-only |
| InvestmentForm | InvestmentFormViewModel | Name, broker, currency, opening | Занятый broker нельзя удалить из связанного flow |
| InvestmentDetails | InvestmentDetailsViewModel: valuations + tx + breakdown | Текущая стоимость, состав по валютам, add valuation/tx | Итог в базовой только при rate; чип «Текущая» per-currency |
| PropertyForm | PropertyFormViewModel | Name, address, currency, opening, purchase price | Пустой address → null; нет annualRate |
| PropertyDetails | PropertyDetailsViewModel: valuations + cashflow | Оценка, поток за period, add income/expense | Ремонт не меняет valuation |
| ValuationForm | ValuationFormViewModel: asset, currencies + rate resolver | Absolute value, currency for investment, date, manual rate | Селектор только инвестиции; две оценки одной даты: больший id последний |
| TransactionForm | TransactionFormViewModel: asset/rate/category | Amount/date/kind/currency for investment/comment; optional linked cashflow | Селектор валюты только инвестиции; USD-операция сохраняется с курсом USD; недостаток средств оставляет обе записи |
| TransferForm | TransferFormViewModel: from/to accounts/rates | Amount, destinationAmount, date, comment | Разные валюты, две ноги, ни одной cashflow |
| TransactionDetails | TransactionDetailsViewModel: tx + linked entry + revisions | Исходная/RUB/base, edit/delete, audit | Transfer edit ведёт по transferId, не одиночной ноге |
| CashflowForm | CashflowFormViewModel: category/account/property/rate | Kind, category, amount/date, affectsBalance | Off→on создаёт новую tx, старая остаётся deleted |
| CashflowDetails | CashflowDetailsViewModel: entry + linked tx | Edit/delete, category/property/account, audit | Удаление пары атомарно |
| GoalsScreen | GoalsViewModel: watchAll + progress | Active/achieved/closed, add | Автоматический achieved, архивный asset помечен |
| GoalForm | GoalFormViewModel: eligible assets | Name/category/target/date/multi-select | Property и несоответствующий kind недоступны |
| GoalDetails | GoalDetailsViewModel: progress | Progress/deficit/surplus/monthly contribution | Нулевые месяцы → null, не infinity |
| MoreScreen | MoreViewModel: локальная навигация | Аналитика, справочники, настройки, аудит, о приложении | Все tiles ведут по named route |
| AnalyticsScreen | AnalyticsViewModel: net worth/cashflow queries | Period, kind/category filters, charts + accessible values, итоги по категориям с табами «Расходы»/«Доходы», ссылка «Детализация за месяц» | Пустой период/нет курса имеет отдельные состояния; таб следует за фильтром типа |
| AnalyticsDetails | CashflowDetailsViewModel (inline в builder): cashflowSeries/cashflow + period/kind/category из query | Чипы периода, список дата/доход/расход/итог, empty month/period | Нулевые бакеты скрыты, newest-first; ошибка курса + ручной ввод |
| CategoriesScreen | CategoriesViewModel | Income/expense tabs, add/edit/archive | Использованная категория предлагает archive или move |
| CategoryForm | CategoryFormViewModel | Kind/name/colorKey/iconKey | Duplicate внутри kind отклонён, другое kind разрешено |
| SubgroupsScreen | SubgroupsViewModel | Bank/broker tabs, CRUD/move | Move+delete атомарны |
| CurrenciesScreen | CurrenciesViewModel: currencies/rates | Enable/custom/edit/delete, base route | RUB и используемая валюта защищены |
| CurrencyForm | CurrencyFormViewModel | Code/name/fractionDigits | `usd` нормализуется USD, дубликат отклонён |
| BaseCurrencyScreen | BaseCurrencyViewModel: enabled currencies | Radio list, save | Итоги пересчитаны, audit RUB не изменился |
| SettingsScreen | SettingsViewModel + BackupViewModel + UpdateCheckViewModel | Base currency shortcut; Export/Share/Save/Import; version/check update | Все busy/error/cancel состояния, destructive import confirm |
| AuditScreen | AuditViewModel: filters и revision lists | Asset tx/cashflow tabs, deleted included | Delete revision виден, current list его скрывает |
| AuditEntryDetails | AuditEntryDetailsViewModel: revisions/diff | Хронология, полный snapshot/diff | Revision 1 и delete неизменны; restore отсутствует до P2 |
| AboutScreen | AboutViewModel: version + static app info | Назначение, offline/backup disclaimer, update shortcut | Длинный текст, font scale 1.3 |
| NotFoundScreen | NotFoundViewModel: malformed route info без sensitive data | Сообщение и «На главную» | `/assets/abc`, unknown id не падают |

`Operations` — shell с `AppSegmentedControl`, а не шестой navigation destination.
`SubgroupsScreen`, `NotFoundScreen` и соответствующие VM добавляются в target file tree;
отдельные routes для bank/broker не нужны.

## 6. Настройки: резервная копия и обновление

Порядок секций SettingsScreen:

1. «Отчёты» — выбранная базовая валюта, переход BaseCurrencyScreen.
2. «Резервная копия» — пояснение локального полного снимка, три равноправных действия:
   «Поделиться», «Сохранить файл», «Импортировать». Облачная синхронизация не обещается.
3. «О приложении» — установленная версия, «Проверить обновление», статус; ссылка About.

Backup UX:

- Export создаёт SQLite snapshot, затем share sheet или Android SAF create-document.
  Отмена picker/save — нейтральный статус, не ошибка.
- Import до открытия picker показывает destructive confirmation: текущие локальные данные
  будут заменены; рекомендуется сначала экспортировать копию. Confirm не является успехом.
- После выбора файла busy блокирует все backup actions. Ошибка magic bytes/integrity/
  schema оставляет старую БД открытой и показывает конкретную локализованную причину.
- После успешной замены показывается nondismissible dialog «Импорт завершён, приложение
  будет перезапущено». Единственная кнопка вызывает полное пересоздание DI/router/app tree.
- Не копируются workout checkpoints, звуки, напоминания и другие donor-specific сервисы.

Update UX:

- Проверка только по явной кнопке, не при каждом запуске. `noReleases`, offline, HTTP и
  malformed response — разные статусы без краха.
- Если latest semantic version <= installed — «Установлена актуальная версия».
- Если новее — dialog с версией и «Скачать»/«Позже». Download открывает HTTPS APK через
  внешнее приложение; установка выполняется Android, приложение не запрашивает silent install.
- При ошибке APK пытается открыться release page. Ошибка обеих ссылок видима пользователю.

Подробные сервисные контракты и безопасная замена файла — `backup_and_updates.md`.

## 7. Единые form rules

- Amount field принимает русскую запятую; пустое, ноль, отрицательное, слишком точное и
  переполняющее minor units значения имеют разные field errors.
- Дата по умолчанию today, future запрещена для операции/оценки; targetDate цели может
  быть будущей или прошлой с пояснением расчёта monthly contribution.
- Currency lock после появления связей объясняется inline, а не просто disabled без причины.
- Select archived values видны только как текущее historical value; новые выборы их исключают.
- Delete всегда confirm с названием и последствиями. Для связанного объекта предлагаются
  только разрешённые BR варианты, нет ложной кнопки physical delete.
- SnackBar не заменяет inline field errors и не является единственным каналом ошибки.

## 8. Навигационные тесты

- Для каждого named route: корректный builder, back, unknown id, wrong type и direct deep link.
- Static `/assets/new/account` не захватывается `/assets/:id`; аналогично transfer/new и
  categories/new. Порядок проверяется тестом реального `buildRouter`.
- Shell сохраняет tab state, Android back не покидает приложение с secondary page.
- Prefill создаёт правильный initial draft; malformed query не приводит к FormatException.
- Settings: после успешного import router и все repository создаются заново; failed import
  не пересоздаёт DI. Update никогда не блокирует offline Dashboard.
