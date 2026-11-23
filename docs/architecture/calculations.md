# Формулы, точность и эталонные расчёты

Все тесты из этого документа входят в задачи 3.1, 5.2, 8.2, 9.1–9.4 и 11.1.
Ожидаемые суммы указаны в основных денежных единицах только для читаемости; в коде
ожидание сравнивается через `Money.minorUnits`.

## 1. Денежное представление и округление

- `Money.minorUnits = roundHalfUp(decimalAmount × 10^fractionDigits)`.
- Для отрицательной расчётной разницы half-up означает half away from zero: `-1,005 →
  -1,01`. Пользовательские суммы операций всегда положительны.
- Промежуточные результаты конвертации и суммирования остаются `Decimal`; округление до
  minor units выполняется один раз на границе результата.
- Хранимый `amountRubMinor` вычисляется при создании каждой ревизии и становится частью
  неизменяемого snapshot.
- В UI используется `NumberFormat.decimalPattern('ru_RU')` с `minimumFractionDigits` и
  `maximumFractionDigits`, равными `Currency.fractionDigits`. Символ/код валюты не
  заменяет код в аналитических данных.
- `Decimal.parse` получает нормализованную строку с `.`; UI заменяет запятую на точку,
  удаляет пробелы и не принимает экспоненциальную запись.

Примеры: `1 234,56 RUB → 123456 minorUnits`; `0,005 USD → 1 minorUnit`;
`0,004 USD → 0`, но нулевой итог пользовательского ввода отклоняется BR-T-5/BR-IE-10.

## 2. Курсы и конвертация

`rateToRub` — количество RUB за одну единицу исходной валюты.

```text
amountRub = amountOriginal × sourceRateToRub

amountTarget = amountOriginal × sourceRateToRub / targetRateToRub
```

Для RUB курс 1. Для `RUB → target` sourceRate = 1. Для `source → RUB` деление не
выполняется. Курсы source и target обязаны относиться к одной дате. Отсутствие любого
нужного курса — `rateUnavailable`, а не приближение текущим курсом.

ЦБ РФ возвращает `Value` и `Nominal`; сохраняется `Decimal Value / Decimal Nominal`.
Дата документа XML должна совпадать с запрошенной, иначе курс считается недоступным.

## 3. Текущая стоимость активов

### Счёт

```text
signed(deposit, transferIn)   = +amount
signed(withdrawal, transferOut) = -amount
balance = openingBalance + Σ signed(activeTransactions)
```

Перед commit withdrawal/transferOut/связанного расхода рассчитывается баланс с учётом
всех остальных активных операций. Если результат <0, вся команда откатывается. При
редактировании старой записи её предыдущая current-версия исключается, новая добавляется.

### Инвестиция

Стоимость считается по каждой валюте `C` отдельно (M3):

```text
base_C = latestValuation_C.value, если effectiveOn <= asOf
         иначе openingValue для валюты актива, иначе 0
current_C = base_C + Σ signed(transactions в C с occurredOn >= baseDate_C)
breakdown = [current_assetCurrency, ...ненулевые current_C по алфавиту кода]
current = breakdown.first
```

Для валюты актива без оценки базой служит `openingValue`, для остальных валют — 0.
Если оценки в `C` нет, применяются все операции в `C`. Оценка и операция одной даты:
операция считается после абсолютной оценки (`occurredOn >= baseDate_C`). Удалённые
операции не учитываются. Основная валюта присутствует в `breakdown` всегда, даже с
нулём; остальные — по алфавиту кода и только с ненулевым балансом (M4).

Итоги конвертируют каждую позицию `breakdown` отдельно exact A→RUB→base, округление —
один раз на итог (M5); нехватка курса любой позиции даёт `rateUnavailable`, частичная
сумма не показывается. Это правило детерминированности; UI формы оценки поясняет, что
значение задаётся на конец выбранного дня до операций того же дня.

### Квартира

```text
current = latestValuation.value <= asOf
          иначе openingValue
```

Денежный поток квартиры не входит в эту формулу.

### Архивирование

Для `asOf < archivedOn` актив участвует по истории. Для текущего итога и `asOf >=
archivedOn` архивный актив исключается. Если архивирование выполнено без явной даты,
`archivedOn = LocalDate.fromDateTime(archivedAt.toLocal())`.

## 4. Прогноз вклада

Ежемесячная капитализация:

```text
future = currentBalance × (1 + annualRate / 1200)^m
```

`annualRate` задана в процентах. `m` вычисляется от `asOf` до `endDate`:

1. Если `endDate == null`, результат `null`.
2. Если `endDate <= asOf` или `annualRate == 0`, результат `currentBalance`.
3. Последовательно строятся anniversary-даты от исходного `asOf`: тот же день следующего
   месяца, а при отсутствии дня — последний день месяца (31 января → 28/29 февраля).
4. `fullMonths` — максимальное число anniversary-дат, которые <= `endDate`.
5. `lastAnniversary = addMonthsClamped(asOf, fullMonths)`, `nextAnniversary =
   addMonthsClamped(asOf, fullMonths + 1)`.
6. `remainingDays = endDate - lastAnniversary` в днях; `monthDays = nextAnniversary -
   lastAnniversary` в днях.
7. `m = fullMonths + remainingDays / monthDays` как `Decimal`; `remainingDays < monthDays`.

Возведение в дробную степень допускается через `double` только для оценочного прогноза;
входные деньги и итоговое округление остаются `Decimal`/minor units. Этот расчёт не
создаёт транзакцию, доход или бухгалтерский итог. UI подписывает прогноз как оценку с
ежемесячной капитализацией и не учитывает его в чистом капитале.

## 4a. Расписание регулярных платежей

```text
date(k) = startDate.plusMonthsClamped(k)
```

`plusMonthsClamped` сохраняет день месяца и при отсутствии дня берёт последний день
месяца (31.01 + 1 мес → 28/29.02; 31.03 + 1 мес → 30.04).

- `fixed`: k = 0, 1, 2, … — первый платёж в `startDate`.
- `deposit_interest`: k = 1, 2, … — первая годовщина через месяц после открытия вклада.
- Платёж включается, если `date <= today` и (`endDate == null` или `date <= endDate`).
- Периоды с `periodKey(date) <= lastGeneratedPeriod` уже закрыты и пропускаются;
  `periodKey` = `YYYY-MM`.
- `nextPayment` возвращает первую дату после маркера без фильтра `today` (для UI) и
  `null`, если она выходит за `endDate`.
- Страховка: не более 12000 месяцев; долгое отсутствие пользователя не создаёт
  неограниченную работу.

Catch-up обрабатывает пары `(правило, дата)` по возрастанию `(date, strategy, ruleId)`
(сначала `fixed`, затем `deposit_interest`), поэтому проценты видят все операции дня.

## 4b. Фактическое начисление процентов по вкладу

```text
interest = balance(account, accrualDate) × annualRate / 1200
```

`balance` — opening value плюс все активные операции с `occurredOn <= accrualDate`
(включая предыдущие капитализации). Округление до minor units — одно, half away from
zero через `MoneyMath`. Даты — месячные годовщины `startDate` вклада, k ≥ 1, не позже
`min(today, endDate)`. Если процент после округления ≤ 0, период закрывается без
операции (маркер двигается). Начисление создаёт связанную пару `deposit + income`
и увеличивает баланс (капитализация), категория — «Проценты по вкладу», комментарий —
«Капитализация процентов».

Отличие от §4: прогноз — оценка с дробной степенью, факт — ежемесячные операции,
записанные в БД. Правка ставки/дат счёта влияет только на будущие начисления;
при паузе (ставка 0/архив) автоправило soft-deleted, при возобновлении
восстанавливается с сохранённым маркером, поэтому прошлые проценты не дублируются.

## 5. Чистый капитал и исторические точки

```text
netWorth(onDate) = Σ assetValue(asset, onDate) в базовой валюте
```

Для каждого актива используются только записи с `effectiveOn/occurredOn <= onDate`.
Конвертация выполняется по курсам `onDate`. Итог по категории считается из тех же
`assetValue`, затем сумма категорий должна равняться общему итогу до округления. Все
составляющие суммируются в Decimal, округляется общий итог; допустимая разница
отображаемых категорий на 1 minor unit устраняется распределением остатка в категорию с
наибольшим абсолютным значением и покрывается тестом.

Серия содержит точку на начало периода и каждую дату, где есть операция, оценка,
создание/архивирование актива. Фильтр месяц/3/6/год/всё время строит календарный диапазон
с включёнными границами. Отсутствие курса на конкретную дату показывает ошибку с датой и
валютой и действием ручного ввода; точка не заменяется нулём.

## 6. Денежный поток

Для неудалённых записей, отфильтрованных по `occurredOn`:

```text
totalIncome = Σ income.amountRub
totalExpense = Σ expense.amountRub
netCashflow = totalIncome - totalExpense
categoryShare = categoryTotal / totalAbs × 100%
propertyNet = propertyIncome - propertyExpense
```

Если базовая валюта не RUB, каждая запись конвертируется из исходной валюты в базовую по
курсам `occurredOn`; сохранённый `amountRub` остаётся доступен для аудита. Сначала
суммируются Decimal-значения записей, округление — на итоге. `total = 0` даёт долю
категории 0%, а не NaN.

График группирует по календарным месяцам для периодов >62 дней и по дням иначе. Все
периоды заполняются нулевыми точками, чтобы отсутствие операций отличалось от пропуска
данных. Столбцы доходов/расходов и линия net используют один и тот же summary dataset.

## 7. Цели

```text
progress = Σ currentValue(связанные активы) в валюте цели на today
rawDeficit = target - progress
deficit = max(0, rawDeficit)
surplus = max(0, -rawDeficit)
completionRatio = max(0, progress / target) // для бара UI min(1, ratio)
```

`target >0`, поэтому деления на ноль нет. Статус `achieved` при `progress >= target`;
при снижении прогресса `achieved → active`, если цель не `closed`.

Число месяцев взносов — календарное, включая текущий и месяц цели:

```text
calendarMonthsRemaining =
  (targetYear - todayYear) × 12 + targetMonth - todayMonth + 1
monthlyContribution = deficit / calendarMonthsRemaining
```

Если `targetDate == null` или дефицит 0 — рекомендация `null` и 0 соответственно. Если
дата в прошлом и дефицит >0 — статус «Срок истёк», рекомендация `null`. Если дата сегодня
или позже, знаменатель минимум 1. Статус «В графике» в MVP означает только отсутствие
просроченной даты; отдельной исторической модели опережения графика нет.

## 8. Доходность недвижимости (P2)

```text
grossYield = annualIncome / currentMarketValue × 100%
netYield = (annualIncome - annualExpense) / currentMarketValue × 100%
```

Период — последние 12 календарных месяцев, включая today. В numerator входят все доходы
объекта (propertyId), в net — все доходы минус все расходы. При `currentMarketValue <=0`
результат `null`. Показатели оценочные и не меняют стоимость; не инвестиционная рекомендация.

## 9. Эталонные кейсы

| ID | Вход | Ожидание |
|---|---|---|
| CALC-001 | 100 USD, rateToRub 90,25 | 9 025,00 RUB |
| CALC-002 | 250,50 EUR, rateToRub 100,10 | 25 075,05 RUB |
| CALC-003 | 123,45 RUB, любая дата | 123,45 RUB; сетевой вызов отсутствует |
| CALC-004 | 100 USD; USD→RUB 90; EUR→RUB 100 | 90,00 EUR |
| CALC-005 | 0,01 USD; USD→RUB 90,555 | 0,91 RUB после одного округления |
| CALC-006 | 1,005 USD → RUB | 1,01 RUB |
| CALC-007 | Курс 0, -1 или null | `validation`/`rateUnavailable`, записи нет |
| CALC-008 | Ответ ЦБ с другой датой | `rateUnavailable`, ближайший курс не подставляется |
| CALC-009 | Opening 1 000; +250,50; −100 | Баланс 1 150,50 |
| CALC-010 | Баланс 100; withdrawal 100,01 | `negativeBalance`, balance 100, ревизия не создана |
| CALC-011 | +100 EUR по 95; edit на 110 EUR по той же дате | Current 110 EUR/10 450 RUB; revision 1 остаётся 100/9 500; delta +950 RUB |
| CALC-012 | +100 EUR 01.01 по 95; edit даты 01.02 по 100 | Revision 1 =9 500 RUB; revision 2 =10 000 RUB |
| CALC-013 | Delete +250, затем агрегат | Операция скрыта и исключена; revision delete доступна |
| CALC-014 | Investment opening 1 000; +200; valuation 1 500; затем −100 | До оценки 1 200; после оценки 1 500; текущая 1 400 |
| CALC-015 | Property opening 5 000 000; expense 50 000; valuation 5 100 000 | Стоимость 5 100 000; expense только в cashflow |
| CALC-016 | 100 000, 12%, 01.01.2026→01.01.2027 | 112 682,50 |
| CALC-017 | 100 000, 12%, 01.01.2026→01.07.2026 | 106 152,02 |
| CALC-018 | 100 000, 12%, 15.01.2026→14.02.2026 | 100 967,59 |
| CALC-019 | 100 000, 12%, 31.01.2028→30.03.2028 | 101 977,26 |
| CALC-020 | 50 000, 7,5%, 10.02.2026→10.11.2026 | 52 883,85 |
| CALC-021 | Ставка 0 / endDate null / endDate в прошлом | current / null / current |
| CALC-022 | Account 1 000 RUB + investment 20 USD при 90 + property 1 000 EUR при 100 | Net worth 102 800 RUB |
| CALC-023 | Income 100 000, expense 30 000 | Net 70 000 |
| CALC-024 | Property income 60 000, expense 15 000 | Property net 45 000; те же записи включены один раз в общий итог |
| CALC-025 | Доход 1 000 USD по 90, базовая EUR по 100 | 900 EUR; audit snapshot 90 000 RUB |
| CALC-026 | Goal target 100 000, assets progress 60 000 | Deficit 40 000; ratio 0,60; surplus 0 |
| CALC-027 | Goal target 100 000, progress 120 000 | Deficit 0; surplus 20 000; achieved; bar 100% |
| CALC-028 | Deficit 12 000, 6 календарных месяцев | Monthly 2 000; после прогресса 2 500 и 5 месяцев — 1 900 |
| CALC-029 | Deficit 10 000, дата вчера | Monthly null, «Срок истёк», нет деления на ноль |
| CALC-030 | Transfer 100 USD со счёта A на B | Две ноги, cashflow income=0, expense=0, net worth меняется только при разных курсах |
| CALC-031 | Cash expense 500 с affectsBalance + связанный withdrawal | Expense=500 один раз; account −500; удаление пары откатывает оба влияния |
| CALC-032 | Доход без account/property | Входит в income, не меняет ни один актив |
| CALC-033 | Обычный deposit без классификации | Меняет account, не входит в income |
| CALC-034 | Оценка property +100 000 | Net worth меняется; income не меняется |
| CALC-035 | Категории: 25 000 и 75 000 расходов | Доли 25% и 75%; total=0 → доли 0% |
| CALC-036 | Property value 0, rent 120 000 | Gross/net yield null |
| CALC-037 | 100 000, 12%, 15.01→20.04 | 1 000,00 / 1 010,00 / 1 020,10; баланс 103 030,10 |
| CALC-038 | 10,50, 12% | 0,11 (half away from zero) |
| CALC-039 | 100 000, 12%, endDate 15.03 | февраль + март; баланс 102 010,00 |
| CALC-040 | 100 000, 12%, start 31.01, today 01.05 | даты 28.02 / 31.03 / 30.04 |
| CALC-041 | 100 000, 12%, снятие 50 000 20.01 | 500,00 / 505,00; баланс 51 005,00 |
| CALC-042 | Reg. rule 31.01.2026, today 17.11.2026, marker null | 10 платежей: 31.01, 28.02, 31.03, 30.04, 31.05, 30.06, 31.07, 31.08, 30.09, 31.10 |
| CALC-043 | Reg. rule 15.01, marker `2026-09` | 15.10 и 15.11 |
| CALC-044 | Reg. rule 15.01.2020, today 17.11.2026 | 83 платежа, маркер `2026-11` |
| CALC-045 | Investment opening 100 000 RUB; +100 USD по 90; оценка 120 USD по 92 | Позиции 100 000 RUB и 120 USD; `currentValue` = 100 000 RUB |
| CALC-046 | CALC-045, базовая валюта RUB, курс USD 92 | Вклад инвестиции в net worth = 111 040 RUB |

## 10. Периоды и границы

- `DateRange.start` и `end` включительны; `start <= end`.
- «Текущий месяц» — с первого по последний календарный день локального месяца устройства,
  но хранение даты остаётся `LocalDate`.
- «Всё время» начинается с самой ранней даты актива/операции; пустая БД даёт empty state,
  а не фиктивную нулевую линию.
- Поиск по комментарию: `trim`, case-insensitive, без учёта повторных пробелов; пустой
  запрос не фильтрует. Денежные итоги всегда соответствуют тем же активным фильтрам.


