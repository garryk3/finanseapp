# Finance components

Все денежные строки уже округлены и локализованы feature presentation layer. Компоненты
не выполняют exchange, forecast, sum или goal progress calculations.

## 1. Деньги и метрики

```dart
class AppMoneyText extends StatelessWidget {
  const AppMoneyText(
    this.formattedAmount, {
    super.key, this.tone = AppMoneyTone.neutral, this.style,
    this.textAlign, this.maxLines, this.semanticsLabel,
  });
  final String formattedAmount;
  final AppMoneyTone tone;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final String? semanticsLabel;
}

class AppMoneyDelta extends StatelessWidget {
  const AppMoneyDelta({
    super.key, required this.formattedDelta, required this.directionLabel,
    this.tone = AppMoneyTone.neutral, this.showIcon = true,
  });
  final String formattedDelta;
  final String directionLabel; // «увеличение», «уменьшение», «без изменений»
  final AppMoneyTone tone;
  final bool showIcon;
}

class AppExchangeRateText extends StatelessWidget {
  const AppExchangeRateText({
    super.key, required this.formattedRate, required this.sourceLabel,
    required this.dateText, this.manual = false,
  });
  final String formattedRate, sourceLabel, dateText;
  final bool manual;
}

class AppMetric extends StatelessWidget {
  const AppMetric({
    super.key, required this.label, required this.value,
    this.caption, this.icon, this.tone = AppMoneyTone.neutral,
  });
  final String label, value;
  final String? caption;
  final IconData? icon;
  final AppMoneyTone tone;
}

class AppSummaryCard extends StatelessWidget {
  const AppSummaryCard({
    super.key, required this.title, required this.value,
    this.subtitle, this.leading, this.trailing, this.onTap,
    this.tone = AppMoneyTone.neutral,
  });
  final String title, value;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onTap;
  final AppMoneyTone tone;
}

class AppCashflowSummary extends StatelessWidget {
  const AppCashflowSummary({
    super.key, required this.incomeText, required this.expenseText,
    required this.netText, required this.periodLabel,
  });
  final String incomeText, expenseText, netText, periodLabel;
}
```

Знак `−` и directionLabel обязательны при уменьшении, цвет не единственный канал. Expense
использует tertiary, error не выбирается. Summary на compact — вертикальные metrics;
expanded — три равных column, значения не обрезаются.

## 2. Активы и операции

```dart
class AppAssetListTile extends StatelessWidget {
  const AppAssetListTile({
    super.key, required this.name, required this.kindLabel,
    required this.amountText, this.subtitle, this.baseAmountText,
    this.icon, this.archived = false, this.archivedLabel, this.onTap,
  }) : assert(!archived || archivedLabel != null);
  final String name, kindLabel, amountText;
  final String? subtitle, baseAmountText;
  final IconData? icon;
  final bool archived;
  final String? archivedLabel;
  final VoidCallback? onTap;
}

class AppOperationListTile extends StatelessWidget {
  const AppOperationListTile({
    super.key, required this.title, required this.typeLabel,
    required this.icon, required this.amountText,
    required this.dateText, required this.tone,
    this.categoryLabel, this.accountLabel, this.comment,
    this.linkedLabel, this.deleted = false, this.deletedLabel, this.onTap,
  }) : assert(!deleted || deletedLabel != null);
  final String title, typeLabel;
  final IconData icon;
  final String amountText, dateText;
  final AppMoneyTone tone;
  final String? categoryLabel, accountLabel, comment, linkedLabel;
  final bool deleted;
  final String? deletedLabel;
  final VoidCallback? onTap;
}

class AppDateHeader extends StatelessWidget {
  const AppDateHeader(this.text, {super.key, this.totalText});
  final String text;
  final String? totalText;
}

class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    super.key, required this.label, this.icon, this.colorKey,
    this.selected = false, this.onSelected, this.archived = false,
    this.archivedLabel,
  }) : assert(!archived || archivedLabel != null);
  final String label;
  final IconData? icon;
  final String? colorKey;
  final bool selected, archived;
  final String? archivedLabel;
  final ValueChanged<bool>? onSelected;
}
```

`colorKey` принимает только allowlisted semantic key (`primary|secondary|tertiary|
surfaceContainerHighest`), resolver находится в UIKit theme layer. Произвольный key даёт
neutral fallback, не Color.parse. `iconKey` из domain заранее преобразован View в IconData
через закрытый mapper feature presentation; arbitrary code point запрещён.

Operation tile обязательно содержит `typeLabel` + `icon` и включает их в Semantics;
пустые части meta-строки (`dateText`, category/account) опускаются перед `join(' · ')`:
«Доход», «Расход», «Пополнение», «Снятие», «Перевод»; знак суммы также сохраняется.
Archived/deleted labels (`showDeletedBadge: false` скрывает бейдж там, где контекст
задаёт экран, — аудит удалённых) приходят из feature View и показываются визуально + в Semantics.
Linked label поясняет «Влияет на баланс»/«Связано со счётом», но не создаёт вторую сумму
в aggregate.

## 3. Цели

```dart
class AppGoalCard extends StatelessWidget {
  const AppGoalCard({
    super.key, required this.name, required this.progressText,
    required this.targetText, required this.ratio,
    this.statusLabel, this.deadlineText, this.deficitText,
    this.onTap,
  });
  final String name, progressText, targetText;
  final double ratio;
  final String? statusLabel, deadlineText, deficitText;
  final VoidCallback? onTap;
}
```

Ratio clamp 0…1 для indicator; фактический процент >100 приходит в status/progress text
и не обрезается. Статусы active/achieved/closed различаются label/icon, не только цветом.
При completed ratio=1 semantics содержит target и actual, а не только «100%».

## 4. Общие finance states

- Empty amount не заменяется автоматически на `0`: View передаёт formatted zero или `—`
  с semantics «Нет данных» осознанно.
- Base equivalent скрывается, если равен original currency и не нужен; unavailable курс
  отображается текстом «Курс недоступен», не нулём.
- Архивный/удалённый стиль использует onSurfaceVariant + badge; disabled != deleted.
- Touchable tile целиком ≥56dp, trailing popup имеет отдельный 48dp target и label.

## 5. Finance tests

- Income/expense/deposit/withdrawal/transfer имеют обязательные typeLabel+icon и разные
  semantics даже в monochrome; expense не error.
- Очень большая сумма `−123 456 789 012,34 ₽` не overflow при 320dp и 1.3.
- Goal 0%, 75%, 125%, achieved/closed; ratio и semantics корректны.
- Archived asset/category и deleted operation показывают переданные labels визуально и в
  Semantics; missing label при соответствующем flag ловится constructor assertion.
- CashflowSummary stacked/expanded layouts и AppOperationListTile linked/deleted states
  проходят light/dark и длинный русский текст.
