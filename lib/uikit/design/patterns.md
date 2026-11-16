# State patterns и confirm dialogs

## 1. Empty/error

```dart
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key, required this.title, required this.message,
    this.icon = Icons.inbox_outlined, this.actionLabel, this.onAction,
  });
  final String title, message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key, required this.title, required this.message,
    this.retryLabel, this.onRetry, this.compact = false,
  });
  final String title, message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final bool compact;
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key, required this.title, required this.message,
    required this.confirmLabel, required this.cancelLabel,
    required this.onConfirm, required this.onCancel,
    this.destructive = false, this.pending = false,
  });
  final String title, message, confirmLabel, cancelLabel;
  final VoidCallback onConfirm, onCancel;
  final bool destructive, pending;
}
```

Empty/error занимают доступную высоту без unbounded constraints и могут скроллиться с
основным content. Error использует icon+title, не только красный. Retry опционален: если
его нет, предлагается другое реальное действие, а не неработающая кнопка.

Confirm destructive использует error только для подтверждения удаления/импорта заменой.
Pending блокирует оба действия и закрытие по barrier там, где отмена невозможна; обычное
delete pending не блокирует Cancel до начала commit. Dialog не выполняет async команду
сам: View владеет mounted check и последовательностью.

## 2. Стандартные паттерны

### Первичная загрузка

AppSkeleton повторяет структуру summary + 3 list rows. Не показывается одновременно
ложный empty. При refresh текущие данные остаются, AppProgress сверху.

### Пустой справочник/журнал

Title описывает отсутствие данных, message — как появятся записи, один CTA. Для пустого
результата filter CTA «Сбросить фильтры», а не «Создать» по умолчанию.

### Offline network-only

Локальные данные остаются. Inline AppErrorState(compact) содержит «Нет соединения» и
Retry; курсовая форма дополнительно имеет «Ввести вручную». Update не показывает global
offline banner.

### Удаление/архив

Delete confirm называет объект и последствия. Использованный asset/category получает
архив/move choices вместо disabled delete без объяснения. После commit SnackBar и обновлённый
stream; ошибка оставляет dialog/form открытыми.

### Backup

Три action tiles используют AppButton(tonal) или feature BackupActionTile на AppCard/
AppInkWell; каждый имеет icon+label и busy semantics. Import сначала AppConfirmDialog
destructive, затем picker. Успех требует отдельный restart dialog. Cancel нейтрален.

### Long forms

AppFormSection → fields → inline errors → bottom Save. Save остаётся видим после keyboard
и системных insets, но не перекрывает последнее поле. Unsaved back вызывает confirm.

## 3. Обязательная матрица widget-тестов нового экрана

| Состояние | Arrange | Assert |
|---|---|---|
| Loading | VM ViewLoading | skeleton/progress, нет empty/error |
| Data | типичные + длинные данные | значения, actions, один callback |
| Empty initial | пустой repository | title + create CTA |
| Empty filtered | несовпадающий filter | reset CTA, данные не удалены |
| Error | repository throw | локализованное сообщение + retry |
| Offline | network exception | локальные данные + network action status |
| Busy | Completer не завершён | repeat tap не вызывает команду |
| Validation | invalid input | field error, Save не вызывается |
| Conflict | object changed/deleted | conflict message, форма сохраняет ввод |
| Accessibility | dark/light + 1.3 + 320dp | no overflow, labels/targets |

Все async widget-тесты завершают Completer и pump settle; никаких произвольных multi-second
`sleep`. TalkBack manual проверяется для charts, import warning, destructive delete и forms.

## 4. Запрещённые обходы

- Нельзя использовать raw Text/Container/InkWell/GestureDetector «временно» в feature UI.
- Нельзя передавать repository/domain entity в AppCard или делать AppButton async owner.
- Нельзя вводить одноразовый компонент с hex/gradient/shadow вне UIKit.
- Нельзя скрывать ошибку только SnackBar или показывать raw exception.
- Нельзя применять error color для расхода, отрицательного денежного потока или noReleases.
