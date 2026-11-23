// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'FinanseApp';

  @override
  String get appLockTitle => 'Защита приложения';

  @override
  String get appLockStatusOn => 'Защита включена';

  @override
  String get appLockStatusOff => 'Защита выключена';

  @override
  String get appLockEnable => 'Включить защиту';

  @override
  String get appLockChange => 'Сменить PIN-код';

  @override
  String get appLockDisable => 'Отключить защиту';

  @override
  String get appLockLockTitle => 'Введите PIN-код';

  @override
  String get appLockEnterCurrent => 'Введите текущий PIN-код';

  @override
  String get appLockEnterNew => 'Придумайте PIN-код: 4–6 цифр';

  @override
  String get appLockConfirmNew => 'Повторите PIN-код';

  @override
  String get appLockContinue => 'Продолжить';

  @override
  String get appLockCancel => 'Отмена';

  @override
  String get appLockWrongPin => 'Неверный PIN-код';

  @override
  String get appLockPinsMismatch => 'PIN-коды не совпадают';

  @override
  String appLockLockedOut(int seconds) {
    return 'Слишком много попыток. Повторите через $seconds с';
  }

  @override
  String get appLockBiometricUnlock => 'Разблокировать по отпечатку или лицу';

  @override
  String get appLockBiometricReason =>
      'Подтвердите личность для входа в FinanseApp';

  @override
  String get appLockBiometricSwitch => 'Разблокировка по отпечатку или лицу';

  @override
  String get appLockBiometricUnavailable =>
      'Биометрия недоступна на этом устройстве';

  @override
  String get appLockAutoLock => 'Блокировка при сворачивании';

  @override
  String get appLockAutoLockImmediate => 'Сразу';

  @override
  String appLockAutoLockAfterMinutes(int minutes) {
    return 'Через $minutes мин';
  }

  @override
  String get appLockBackspace => 'Стереть';

  @override
  String appLockDotsSemantics(int filled, int length) {
    return 'Введено $filled из $length';
  }

  @override
  String get navDashboard => 'Главная';

  @override
  String get navOperations => 'Операции';

  @override
  String get navAssets => 'Активы';

  @override
  String get navGoals => 'Цели';

  @override
  String get navMore => 'Ещё';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get errorStateTitle => 'Не удалось загрузить';

  @override
  String get errorStateMessage =>
      'Не удалось загрузить данные. Попробуйте позже.';

  @override
  String get retry => 'Повторить';

  @override
  String get errorLabel => 'Ошибка';

  @override
  String get dashboardEmptyTitle => 'Пока пусто';

  @override
  String get dashboardEmptyMessage =>
      'Добавьте счёт или операцию, чтобы увидеть итоги.';

  @override
  String get cashflowEmptyTitle => 'Нет операций';

  @override
  String get cashflowEmptyMessage => 'Доходы и расходы появятся здесь.';

  @override
  String get transactionsEmptyTitle => 'Нет операций по активам';

  @override
  String get transactionsEmptyMessage =>
      'Пополнения, снятия и переводы появятся здесь.';

  @override
  String get assetsEmptyTitle => 'Нет активов';

  @override
  String get assetsEmptyMessage =>
      'Добавьте счёт, инвестицию или недвижимость.';

  @override
  String get goalsEmptyTitle => 'Нет целей';

  @override
  String get goalsEmptyMessage => 'Создайте цель и привяжите активы.';

  @override
  String get operationsCashflowTab => 'Доходы и расходы';

  @override
  String get operationsTransactionsTab => 'Операции по активам';

  @override
  String get moreSecuritySection => 'Безопасность';

  @override
  String get notFoundTitle => 'Страница не найдена';

  @override
  String get notFoundMessage => 'Такой страницы нет. Вернитесь на главную.';

  @override
  String get notFoundHome => 'На главную';

  @override
  String get comingSoonTitle => 'Раздел в разработке';

  @override
  String get comingSoonMessage => 'Раздел появится в одном из обновлений.';

  @override
  String get subgroupsTitle => 'Банки и брокеры';

  @override
  String get subgroupsBankTab => 'Банки';

  @override
  String get subgroupsBrokerTab => 'Брокеры';

  @override
  String get subgroupAdd => 'Добавить';

  @override
  String get subgroupEmptyTitle => 'Пока нет';

  @override
  String get subgroupNameLabel => 'Название';

  @override
  String get subgroupEditTooltip => 'Переименовать';

  @override
  String get subgroupDeleteTooltip => 'Удалить';

  @override
  String get subgroupInUseTitle => 'Справочник используется';

  @override
  String get subgroupMoveTarget => 'Куда перенести';

  @override
  String get subgroupMoveAction => 'Перенести и удалить';

  @override
  String get subgroupErrorDuplicate => 'Такое название уже есть.';

  @override
  String get subgroupErrorKind =>
      'Можно перенести только в справочник того же типа.';

  @override
  String get subgroupErrorSame => 'Выберите другой справочник.';

  @override
  String get subgroupErrorInUse => 'Сначала перенесите активы.';

  @override
  String subgroupAssetsCount(int count) {
    return 'Активов: $count';
  }

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String subgroupInUseMessageCount(int count) {
    return 'Активов: $count. Перенесите их в другой справочник того же типа.';
  }

  @override
  String subgroupDeleteConfirmTitleNamed(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get subgroupDeleteConfirmMessageNamed =>
      'Справочник не привязан к активам и будет удалён.';

  @override
  String get subgroupNoTargetTitle => 'Некуда перенести';

  @override
  String subgroupNoTargetMessage(String name) {
    return 'Активы привязаны к «$name», а других справочников этого типа нет. Создайте ещё один и повторите перенос.';
  }

  @override
  String get subgroupNewBank => 'Новый банк';

  @override
  String get subgroupNewBroker => 'Новый брокер';

  @override
  String subgroupRenameTitleNamed(String name) {
    return 'Переименовать «$name»';
  }

  @override
  String get subgroupEmptyMessageBank =>
      'Добавьте банк, чтобы привязать к нему счёт.';

  @override
  String get subgroupEmptyMessageBroker =>
      'Добавьте брокера, чтобы привязать к нему инвестицию.';

  @override
  String get subgroupActionsTooltip => 'Действия со справочником';

  @override
  String get commonSaved => 'Сохранено';

  @override
  String get subgroupDeleted => 'Справочник удалён.';

  @override
  String subgroupMovedAndDeleted(String target) {
    return 'Активы перенесены в «$target», справочник удалён.';
  }

  @override
  String get currenciesTitle => 'Валюты';

  @override
  String get currenciesBaseAction => 'Базовая валюта';

  @override
  String get currencyAdd => 'Новая валюта';

  @override
  String get currencyCodeLabel => 'Код (три заглавные буквы)';

  @override
  String get currencyNameLabel => 'Название';

  @override
  String get currencyFractionLabel => 'Знаков после запятой';

  @override
  String currencyFractionValue(int count) {
    return 'Знаков: $count';
  }

  @override
  String get currencyToggleEnable => 'Включить';

  @override
  String get currencyToggleDisable => 'Отключить';

  @override
  String get currencyRename => 'Переименовать';

  @override
  String get currencyDelete => 'Удалить';

  @override
  String currencyDeleteConfirmTitle(String code) {
    return 'Удалить валюту «$code»?';
  }

  @override
  String get currencyDeleteConfirmMessage =>
      'Валюта не используется и будет удалена.';

  @override
  String get currencyErrorDuplicate => 'Валюта с таким названием уже есть.';

  @override
  String get currencyErrorCode => 'Код должен состоять из трёх заглавных букв.';

  @override
  String get currencyErrorInUse => 'Валюта используется или выбрана базовой.';

  @override
  String get currencyErrorRub => 'RUB нельзя отключить или удалить.';

  @override
  String get baseCurrencyTitle => 'Базовая валюта';

  @override
  String get baseCurrencySave => 'Сохранить базовую валюту';

  @override
  String get baseCurrencyCurrent => 'Текущая базовая';

  @override
  String get manualRateTitle => 'Ручной курс';

  @override
  String get manualRateLabel => 'Курс к рублю';

  @override
  String get manualRateHint => 'Например, 93,4567';

  @override
  String get manualRateInvalid => 'Введите положительный курс.';

  @override
  String get currencySaved => 'Валюта сохранена.';

  @override
  String get baseCurrencySaved => 'Базовая валюта изменена.';

  @override
  String get currencyFractionError => 'Введите число от 0 до 8.';

  @override
  String get currenciesEmptyTitle => 'Нет валют';

  @override
  String get currenciesEmptyMessage => 'Добавьте валюту или проверьте фильтры.';

  @override
  String get currencyActionsTooltip => 'Действия с валютой';

  @override
  String get currencyNameRequired => 'Введите название валюты.';

  @override
  String get currencyCodeDuplicate => 'Валюта с таким кодом уже есть.';

  @override
  String get currencyDisabledLabel => 'Отключена';

  @override
  String get currencyDeleted => 'Валюта удалена.';

  @override
  String get currencyToggled => 'Настройки валюты обновлены.';

  @override
  String get baseCurrencyHint =>
      'Итоги и дашборд будут пересчитаны в выбранной валюте; сохранённые суммы в RUB не меняются.';

  @override
  String get baseCurrencyEmpty => 'Нет включённых валют для выбора.';

  @override
  String currencyRenameNamed(String code) {
    return 'Переименовать валюту «$code»';
  }

  @override
  String get currencyFractionRangeHint => 'От 0 до 8';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get categoriesIncomeTab => 'Доходы';

  @override
  String get categoriesExpenseTab => 'Расходы';

  @override
  String get categoryAdd => 'Новая категория';

  @override
  String get categoryEmptyTitle => 'Нет категорий';

  @override
  String get categoryEmptyMessage =>
      'Добавьте категорию для доходов или расходов.';

  @override
  String get categoryArchivedBadge => 'Архивная';

  @override
  String get categoryPresetBadge => 'Предустановленная';

  @override
  String get categoryActionsTooltip => 'Действия с категорией';

  @override
  String categoryRenameNamed(String name) {
    return 'Переименовать «$name»';
  }

  @override
  String categoryDeleteNamed(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get categoryDeleteMessage =>
      'Категория не используется и будет удалена.';

  @override
  String categoryInUseTitle(String name) {
    return 'Категория «$name» используется';
  }

  @override
  String categoryInUseMessage(int count) {
    return 'Записей: $count. Архивируйте категорию или перенесите записи в другую категорию того же типа.';
  }

  @override
  String get categoryArchiveAction => 'Архивировать';

  @override
  String get categoryMoveAction => 'Перенести и удалить';

  @override
  String get categoryMoveTarget => 'Куда перенести записи';

  @override
  String get categoryErrorDuplicate => 'Категория с таким названием уже есть.';

  @override
  String get categoryErrorKind =>
      'Перенести можно только в категорию того же типа.';

  @override
  String get categoryErrorArchived =>
      'Категория архивирована и недоступна для новых записей.';

  @override
  String get categoryErrorName => 'Введите название категории.';

  @override
  String get categorySaved => 'Категория сохранена.';

  @override
  String get categoryDeleted => 'Категория удалена.';

  @override
  String get categoryArchived => 'Категория архивирована.';

  @override
  String get categoryNewTitle => 'Новая категория';

  @override
  String get commonRename => 'Переименовать';

  @override
  String get commonNameLabel => 'Название';

  @override
  String get assetsAddAccount => 'Добавить счёт';

  @override
  String get accountFormNew => 'Новый счёт';

  @override
  String get accountFormEdit => 'Изменить счёт';

  @override
  String get accountNameLabel => 'Название счёта';

  @override
  String get accountBankLabel => 'Банк';

  @override
  String get accountOpeningLabel => 'Начальный баланс';

  @override
  String get accountRateLabel => 'Ставка, % годовых';

  @override
  String get accountRateHint => '0';

  @override
  String get accountStartDate => 'Дата начала';

  @override
  String get accountEndDate => 'Дата окончания';

  @override
  String get accountBalanceLabel => 'Текущий баланс';

  @override
  String get accountForecastLabel => 'Прогноз';

  @override
  String get accountForecastHint =>
      'Оценка с ежемесячной капитализацией, не входит в чистый капитал.';

  @override
  String get accountArchive => 'Архивировать';

  @override
  String get accountDelete => 'Удалить';

  @override
  String accountDeleteTitle(String name) {
    return 'Удалить счёт «$name»?';
  }

  @override
  String get accountDeleteMessage => 'Счёт не используется и будет удалён.';

  @override
  String get accountArchivedBadge => 'Архивный';

  @override
  String get accountSaved => 'Счёт сохранён.';

  @override
  String get accountArchived => 'Счёт архивирован.';

  @override
  String get accountDeleted => 'Счёт удалён.';

  @override
  String get accountErrorName => 'Введите название счёта.';

  @override
  String get accountErrorRate => 'Ставка должна быть от 0 до 100.';

  @override
  String get accountErrorDates => 'Дата окончания не раньше даты начала.';

  @override
  String get accountErrorCurrencyLocked =>
      'Валюту нельзя менять после операций.';

  @override
  String get accountNoBanks => 'Сначала добавьте банк в справочнике.';

  @override
  String get accountDetailsTitle => 'Счёт';

  @override
  String get assetsEmptyCta => 'Добавить счёт';

  @override
  String get accountErrorAmount =>
      'Введите неотрицательную сумму в основных единицах.';

  @override
  String get accountErrorBank => 'Выберите банк.';

  @override
  String get accountEdit => 'Изменить';

  @override
  String get assetBaseEquivalent => 'В базовой валюте';

  @override
  String get assetBaseUnavailable => 'Курс недоступен';

  @override
  String get assetInUseTitle => 'Актив используется';

  @override
  String assetInUseMessage(
    int transactions,
    int valuations,
    int goals,
    int cashflow,
    int recurring,
  ) {
    return 'Операций: $transactions, оценок: $valuations, целей: $goals, записей: $cashflow, правил: $recurring. Удаление недоступно — архивируйте актив.';
  }

  @override
  String get accountCurrencyLabel => 'Валюта счёта';

  @override
  String get accountCurrencyLocked => 'Валюту нельзя менять после операций.';

  @override
  String get accountAddEndDate => 'Добавить дату окончания';

  @override
  String get accountRemoveEndDate => 'Убрать дату окончания';

  @override
  String get assetsAddAsset => 'Добавить актив';

  @override
  String get assetsAddInvestment => 'Добавить инвестицию';

  @override
  String get assetsAddTitle => 'Новый актив';

  @override
  String get investmentFormNew => 'Новая инвестиция';

  @override
  String get investmentFormEdit => 'Изменить инвестицию';

  @override
  String get investmentNameLabel => 'Название инвестиции';

  @override
  String get investmentBrokerLabel => 'Брокер';

  @override
  String get investmentNoBrokers => 'Сначала добавьте брокера в справочнике.';

  @override
  String get investmentCurrencyLabel => 'Валюта инвестиции';

  @override
  String get investmentDetailsTitle => 'Инвестиция';

  @override
  String get investmentCurrentValue => 'Текущая стоимость';

  @override
  String get investmentBreakdownTitle => 'Состав по валютам';

  @override
  String get investmentTotalBase => 'Итого в базовой валюте';

  @override
  String get investmentValuationHint =>
      'Оценка задаётся на конец дня: операции этой даты применяются после неё.';

  @override
  String get investmentErrorName => 'Введите название инвестиции.';

  @override
  String get investmentErrorBroker => 'Выберите брокера.';

  @override
  String get investmentAddValuation => 'Добавить оценку';

  @override
  String get lockedAssetsTitle => 'Заблокированные активы';

  @override
  String lockedAmountSubtitle(String amount) {
    return 'Заблокировано: $amount';
  }

  @override
  String get lockedNotMarked => 'Не отмечено';

  @override
  String get lockedEditTitle => 'Заблокированная сумма';

  @override
  String lockedAvailableHint(String amount) {
    return 'Доступно: $amount';
  }

  @override
  String get lockedEditAction => 'Изменить заблокированную сумму';

  @override
  String lockedEditActionFor(String currency) {
    return 'Изменить заблокированную сумму: $currency';
  }

  @override
  String lockedErrorExceeds(String available) {
    return 'Сумма превышает остаток: доступно $available.';
  }

  @override
  String get lockedErrorAmount => 'Введите сумму блокировки.';

  @override
  String get lockedSaveError =>
      'Не удалось сохранить отметку. Попробуйте позже.';

  @override
  String get lockedClearHint =>
      'Очистите поле или введите 0, чтобы снять отметку.';

  @override
  String get lockedSaved => 'Заблокированная сумма сохранена.';

  @override
  String get lockedRemoved => 'Отметка о блокировке снята.';

  @override
  String get valuationTitle => 'Новая оценка';

  @override
  String get valuationValueLabel => 'Стоимость';

  @override
  String get valuationCurrencyLabel => 'Валюта оценки';

  @override
  String get valuationDateLabel => 'Дата оценки';

  @override
  String get valuationRateLabel => 'Курс к рублю';

  @override
  String get valuationRateOptional => 'Пусто — возьмём курс ЦБ на дату.';

  @override
  String get valuationErrorValue =>
      'Введите стоимость. Стоимость не может быть отрицательной.';

  @override
  String get valuationErrorRate =>
      'Не удалось получить курс. Введите курс вручную.';

  @override
  String get valuationHistory => 'История оценок';

  @override
  String get valuationHistoryEmpty =>
      'Оценок пока нет. Стоимость считается по операциям от начального баланса.';

  @override
  String get valuationSaved => 'Оценка сохранена.';

  @override
  String get assetDetailsTitle => 'Актив';

  @override
  String get assetArchived => 'Актив архивирован.';

  @override
  String get assetDeleted => 'Актив удалён.';

  @override
  String assetDeleteTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get assetDeleteMessage => 'Актив не используется и будет удалён.';

  @override
  String get assetErrorInUse => 'Актив используется и не может быть удалён.';

  @override
  String get valuationErrorDate => 'Дата оценки не может быть в будущем.';

  @override
  String get assetKindAccount => 'Счёт';

  @override
  String get assetKindInvestment => 'Инвестиция';

  @override
  String get assetKindProperty => 'Недвижимость';

  @override
  String get assetActions => 'Действия с активом';

  @override
  String get assetArchiveFailed => 'Не удалось архивировать актив.';

  @override
  String get valuationCurrent => 'Текущая';

  @override
  String valuationRubLine(String value) {
    return 'В рублях: $value';
  }

  @override
  String get investmentSectionTitle => 'Инвестиция';

  @override
  String get brokerAddAction => 'Добавить брокера';

  @override
  String get assetsSearchLabel => 'Поиск активов';

  @override
  String get assetsSearchHint => 'Название';

  @override
  String get assetsSearchClear => 'Очистить поиск';

  @override
  String get assetsFilterAll => 'Все';

  @override
  String get assetsFilterArchived => 'Показывать архивные';

  @override
  String get assetsFilteredEmptyTitle => 'Ничего не найдено';

  @override
  String get assetsFilteredEmptyMessage =>
      'Измените условия фильтра или сбросьте его.';

  @override
  String get assetsResetFilters => 'Сбросить фильтры';

  @override
  String get assetsAllArchivedTitle => 'Все активы в архиве';

  @override
  String get assetsAllArchivedMessage =>
      'Показываются только активные. Откройте архив, чтобы увидеть остальные.';

  @override
  String get assetsShowArchivedAction => 'Показать архивные';

  @override
  String get transactionFormNew => 'Новая операция';

  @override
  String get transactionAssetLabel => 'Актив';

  @override
  String get transactionCurrencyLabel => 'Валюта операции';

  @override
  String get transactionKindDeposit => 'Пополнение';

  @override
  String get transactionKindWithdrawal => 'Снятие';

  @override
  String get transactionAmountLabel => 'Сумма';

  @override
  String get transactionDateLabel => 'Дата операции';

  @override
  String get transactionCommentLabel => 'Комментарий';

  @override
  String get transactionClassifyLabel => 'Учесть как доход или расход';

  @override
  String get transactionCategoryLabel => 'Категория';

  @override
  String get transactionAddDeposit => 'Пополнить';

  @override
  String get transactionAddWithdrawal => 'Снять';

  @override
  String get transactionSaved => 'Операция сохранена.';

  @override
  String get transactionErrorAsset => 'Выберите актив.';

  @override
  String get transactionErrorAmount =>
      'Введите положительную сумму в основных единицах.';

  @override
  String get transactionErrorCategory => 'Выберите категорию.';

  @override
  String get transactionErrorDate => 'Дата операции не может быть в будущем.';

  @override
  String get transactionErrorNegativeBalance =>
      'Недостаточно средств на активе.';

  @override
  String get transactionErrorKindMismatch =>
      'Категория не соответствует виду операции.';

  @override
  String get transactionNoAssets => 'Сначала добавьте счёт или инвестицию.';

  @override
  String get transactionNoCategories => 'Нет категорий для этого вида.';

  @override
  String get transferFormTitle => 'Перевод между счетами';

  @override
  String get transferFromLabel => 'Со счёта';

  @override
  String get transferToLabel => 'На счёт';

  @override
  String get transferAmountLabel => 'Сумма списания';

  @override
  String get transferDestinationAmountLabel => 'Сумма зачисления';

  @override
  String get transferCommentLabel => 'Комментарий';

  @override
  String get transferSaved => 'Перевод сохранён.';

  @override
  String get transferAction => 'Перевести';

  @override
  String get transferErrorFrom => 'Выберите счёт списания.';

  @override
  String get transferErrorTo => 'Выберите счёт зачисления.';

  @override
  String get transferErrorSameAccount => 'Счета должны различаться.';

  @override
  String get transferErrorAmount => 'Введите положительную сумму перевода.';

  @override
  String get transferErrorNegativeBalance =>
      'Недостаточно средств на счёте списания.';

  @override
  String get transferNoAccounts => 'Нужно минимум два счёта.';

  @override
  String transferRateHint(String fromUnit, String toAmount) {
    return '$fromUnit ≈ $toAmount';
  }

  @override
  String get transferNeedAccountsMessage =>
      'Добавьте второй счёт, чтобы переводить между счетами.';

  @override
  String get transferErrorDestination =>
      'Введите положительную сумму зачисления.';

  @override
  String get transactionsSearchLabel => 'Поиск операций';

  @override
  String get transactionsSearchHint => 'Комментарий';

  @override
  String get transactionsSearchClear => 'Очистить поиск';

  @override
  String get transactionsFilterAll => 'Все';

  @override
  String get transactionsFilterDeposit => 'Пополнения';

  @override
  String get transactionsFilterWithdrawal => 'Снятия';

  @override
  String get transactionsFilterTransferOut => 'Исходящие';

  @override
  String get transactionsFilterTransferIn => 'Входящие';

  @override
  String get transactionsFilterMonth => 'Этот месяц';

  @override
  String get transactionsFilteredEmptyTitle => 'Операций не найдено';

  @override
  String get transactionsFilteredEmptyMessage =>
      'Измените фильтры или сбросьте их.';

  @override
  String get transactionsResetFilters => 'Сбросить фильтры';

  @override
  String get transactionsAdd => 'Новая операция';

  @override
  String get transactionsLoading => 'Загрузка операций';

  @override
  String get transactionKindTransferOut => 'Перевод (исходящий)';

  @override
  String get transactionKindTransferIn => 'Перевод (входящий)';

  @override
  String get transactionDetailsTitle => 'Операция';

  @override
  String get transactionRevisionsTitle => 'История изменений';

  @override
  String get transactionDeleteTitle => 'Удалить операцию?';

  @override
  String get transactionDeleteMessage =>
      'Операция будет скрыта из журнала; история останется в аудите.';

  @override
  String get transactionDeleted => 'Операция удалена.';

  @override
  String get transactionDeleteBlocked =>
      'Связанную операцию перевода нельзя удалить отдельно.';

  @override
  String get transactionAmountRub => 'В рублях';

  @override
  String get transactionLinkedCashflow => 'Связана с денежным потоком';

  @override
  String get transactionCommentEmpty => 'Без комментария';

  @override
  String revisionLabel(int number) {
    return 'Ревизия $number';
  }

  @override
  String get revisionActionCreate => 'Создана';

  @override
  String get revisionActionEdit => 'Изменена';

  @override
  String get revisionActionDelete => 'Удалена';

  @override
  String get revisionFieldAmount => 'Сумма';

  @override
  String get revisionFieldDate => 'Дата';

  @override
  String get revisionFieldKind => 'Вид операции';

  @override
  String get revisionFieldRate => 'Курс';

  @override
  String get revisionFieldComment => 'Комментарий';

  @override
  String get auditAssetTransactionTitle => 'Аудит операции';

  @override
  String revisionDiffLine(String field, String oldValue, String newValue) {
    return '$field: было $oldValue, стало $newValue';
  }

  @override
  String get revisionEmpty => 'Изменений пока нет.';

  @override
  String get transactionAuditAction => 'Открыть аудит';

  @override
  String get cashflowIncome => 'Доход';

  @override
  String get cashflowExpense => 'Расход';

  @override
  String get cashflowAdd => 'Добавить доход или расход';

  @override
  String get cashflowFormNew => 'Новая запись';

  @override
  String get cashflowFormEdit => 'Изменить запись';

  @override
  String get cashflowCategoryLabel => 'Категория';

  @override
  String get cashflowAmountLabel => 'Сумма';

  @override
  String get cashflowSaved => 'Запись сохранена.';

  @override
  String get cashflowDeleted => 'Запись удалена.';

  @override
  String get cashflowDeleteTitle => 'Удалить запись?';

  @override
  String get cashflowDeleteMessage =>
      'Запись будет скрыта из журнала; история останется в аудите.';

  @override
  String get cashflowDetailsTitle => 'Доход или расход';

  @override
  String get cashflowErrorAmount => 'Введите положительную сумму.';

  @override
  String get cashflowErrorCategory => 'Выберите категорию.';

  @override
  String get cashflowErrorKindMismatch =>
      'Категория не соответствует типу записи.';

  @override
  String get cashflowNoCategories => 'Нет категорий для этого типа.';

  @override
  String get cashflowTotalsIncome => 'Доходы';

  @override
  String get cashflowTotalsExpense => 'Расходы';

  @override
  String get cashflowTotalsNet => 'Итого';

  @override
  String get cashflowPeriodAll => 'Всё время';

  @override
  String get cashflowCurrencyLabel => 'Валюта';

  @override
  String get cashflowDeleteError => 'Не удалось удалить запись.';

  @override
  String get cashflowErrorCategoryArchived =>
      'Категория в архиве. Выберите активную.';

  @override
  String get propertyFormNew => 'Новая недвижимость';

  @override
  String get propertyFormEdit => 'Изменить недвижимость';

  @override
  String get propertyNameLabel => 'Название недвижимости';

  @override
  String get propertyAddressLabel => 'Адрес';

  @override
  String get propertyPurchasePriceLabel => 'Цена покупки';

  @override
  String get propertyValueLabel => 'Начальная стоимость';

  @override
  String get propertyCurrencyLabel => 'Валюта недвижимости';

  @override
  String get propertySectionTitle => 'Недвижимость';

  @override
  String get propertyErrorName => 'Введите название недвижимости.';

  @override
  String get propertyCashflowTitle => 'Денежный поток по недвижимости';

  @override
  String get propertyCashflowEmpty => 'Записей за период нет.';

  @override
  String get propertyAddIncome => 'Добавить доход';

  @override
  String get propertyAddExpense => 'Добавить расход';

  @override
  String get cashflowPeriodMonth => 'Месяц';

  @override
  String get cashflowPeriodYear => 'Год';

  @override
  String get assetsAddProperty => 'Добавить недвижимость';

  @override
  String get cashflowAccountLabel => 'Счёт';

  @override
  String get cashflowAffectsBalance => 'Влияет на баланс счёта';

  @override
  String get operationsRecurringTab => 'Регулярные';

  @override
  String get recurringTitle => 'Ежемесячные платежи';

  @override
  String get recurringEmpty => 'Пока нет ежемесячных платежей.';

  @override
  String get recurringEmptyHint =>
      'Создайте правило из формы дохода/расхода или кнопкой «Добавить платёж».';

  @override
  String get recurringRuleDeletedTitle => 'Правило удалено';

  @override
  String get recurringRuleDeletedMessage =>
      'Созданные операции сохранились, новые платежи не начисляются.';

  @override
  String get recurringAdd => 'Добавить платёж';

  @override
  String get recurringNew => 'Новый ежемесячный платёж';

  @override
  String get recurringEdit => 'Ежемесячный платёж';

  @override
  String get recurringMonthly => 'Повторять ежемесячно';

  @override
  String get recurringStartDate => 'Дата начала';

  @override
  String get recurringEndDate => 'Дата окончания';

  @override
  String get recurringEndDateOptional => 'Дата окончания (необязательно)';

  @override
  String get recurringEndClear => 'Убрать дату окончания';

  @override
  String get recurringEndNotSet => 'Бессрочно';

  @override
  String recurringScheduleFrom(String from) {
    return 'Ежемесячно с $from';
  }

  @override
  String recurringNextLabel(String date) {
    return 'Следующий: $date';
  }

  @override
  String recurringOverdueLabel(String date) {
    return 'Просрочен: $date';
  }

  @override
  String get recurringCompleted => 'Завершено';

  @override
  String get recurringAutoInterestTitle => 'Проценты по вкладу';

  @override
  String recurringAutoInterestMeta(String rate) {
    return '$rate% годовых · капитализация ежемесячно';
  }

  @override
  String recurringNextAccrual(String date) {
    return 'Следующее начисление: $date';
  }

  @override
  String recurringOverdueAccrual(String date) {
    return 'Просрочено: $date';
  }

  @override
  String get recurringAccrualStoppedArchive =>
      'Начисления остановлены: счёт в архиве';

  @override
  String get recurringAccrualUnavailable =>
      'Начисления не выполняются: проверьте категорию';

  @override
  String get recurringLastAccrualLabel => 'Последнее начисление';

  @override
  String get recurringAutoChip => 'Авто';

  @override
  String get accountRateAutoHint =>
      'Проценты начисляются автоматически в то же число месяца, что и дата начала (для 31-го — последний день месяца). Прошедшие месяцы будут начислены при сохранении.';

  @override
  String get recurringTargetHint => 'Цель — только счёт или недвижимость';

  @override
  String get recurringNoTargets => 'Сначала добавьте счёт или недвижимость.';

  @override
  String recurringScheduleUntil(String to) {
    return 'по $to';
  }

  @override
  String recurringNextPayment(String date) {
    return 'Следующий платёж: $date';
  }

  @override
  String get recurringNextPaymentNone => 'Дата не определена';

  @override
  String get recurringPendingRate => 'Ожидает курс';

  @override
  String get recurringAutoBadge => 'Автоплатёж';

  @override
  String get recurringRuleLink => 'Изменить правило';

  @override
  String get recurringDeleteTitle => 'Удалить правило?';

  @override
  String get recurringDeleteMessage =>
      'Правило будет удалено. Созданные операции останутся.';

  @override
  String get recurringDeleted => 'Правило удалено';

  @override
  String get recurringSaved => 'Правило сохранено';

  @override
  String get recurringDeleteAction => 'Удалить правило';

  @override
  String get recurringTargetAccount => 'Счёт';

  @override
  String get recurringTargetProperty => 'Недвижимость';

  @override
  String get recurringNoTarget => 'Не выбран';

  @override
  String get recurringErrorDates =>
      'Дата окончания не может быть раньше даты начала';

  @override
  String get recurringReadOnlyInterest =>
      'Проценты по вкладу начисляются автоматически и настраиваются в счёте.';

  @override
  String get recurringOpenAccount => 'Открыть счёт';

  @override
  String get recurringRateHint =>
      'Курс берётся из сохранённого курса на дату платежа.';

  @override
  String get recurringSectionEmpty => 'Нет ежемесячных платежей.';

  @override
  String get recurringNoTargetHint => 'Без привязки к активу';

  @override
  String get cashflowErrorAccount =>
      'Выберите счёт или отключите влияние на баланс.';

  @override
  String get cashflowNoAccounts => 'Сначала добавьте счёт.';

  @override
  String get cashflowCurrencyFromAccount => 'Валюта берётся из счёта';

  @override
  String get cashflowAccountHint => 'Выберите счёт';

  @override
  String get cashflowErrorCurrencyMismatch =>
      'Валюта записи не совпадает с валютой счёта.';

  @override
  String get cashflowSearchLabel => 'Поиск по комментарию';

  @override
  String get cashflowSearchHint => 'Комментарий';

  @override
  String get cashflowSearchClear => 'Очистить поиск';

  @override
  String get cashflowFilterAll => 'Все';

  @override
  String get cashflowFilteredEmptyTitle => 'Записей не найдено';

  @override
  String get cashflowFilteredEmptyMessage =>
      'Измените фильтры или сбросьте их.';

  @override
  String get cashflowResetFilters => 'Сбросить фильтры';

  @override
  String get cashflowFilters => 'Фильтры';

  @override
  String get cashflowAllCategories => 'Все категории';

  @override
  String get cashflowAllAccounts => 'Все счета';

  @override
  String get cashflowAllCurrencies => 'Все валюты';

  @override
  String get cashflowAuditTitle => 'Аудит записи';

  @override
  String get commonDone => 'Готово';

  @override
  String get cashflowSummaryInRub => 'Итоги в ₽';

  @override
  String get cashflowAllProperties => 'Вся недвижимость';

  @override
  String get cashflowPropertyLabel => 'Недвижимость';

  @override
  String cashflowFiltersWithCount(int count) {
    return 'Фильтры · $count';
  }

  @override
  String cashflowPropertyContext(String name) {
    return 'Недвижимость: $name';
  }

  @override
  String get cashflowPropertyNoAccount => 'Не влияет на баланс счёта';

  @override
  String get goalsAdd => 'Добавить цель';

  @override
  String get goalFormNew => 'Новая цель';

  @override
  String get goalFormEdit => 'Изменить цель';

  @override
  String get goalDetailsTitle => 'Цель';

  @override
  String get goalNameLabel => 'Название цели';

  @override
  String get goalTargetAmountLabel => 'Целевая сумма';

  @override
  String get goalTargetDateLabel => 'Дата цели';

  @override
  String get goalCategoryLabel => 'Категория цели';

  @override
  String get goalCategoryAccounts => 'Счета';

  @override
  String get goalCategoryInvestments => 'Инвестиции';

  @override
  String get goalAssetsLabel => 'Активы цели';

  @override
  String get goalNoAssets => 'Нет подходящих активов.';

  @override
  String get goalErrorName => 'Введите название цели.';

  @override
  String get goalErrorAmount => 'Введите положительную целевую сумму.';

  @override
  String get goalErrorAssets => 'Выберите хотя бы один актив.';

  @override
  String get goalStatusActive => 'Активна';

  @override
  String get goalStatusAchieved => 'Достигнута';

  @override
  String get goalStatusClosed => 'Закрыта';

  @override
  String get goalDeleted => 'Цель удалена.';

  @override
  String get goalDeleteTitle => 'Удалить цель?';

  @override
  String get goalDeleteMessage =>
      'Цель будет скрыта; связи с активами сохранятся в истории.';

  @override
  String get goalClose => 'Закрыть цель';

  @override
  String get goalActivate => 'Вернуть в работу';

  @override
  String get goalSectionTitle => 'Параметры цели';

  @override
  String get goalCurrencyLabel => 'Валюта цели';

  @override
  String get goalDateToggle => 'Указать дату цели';

  @override
  String get goalErrorDate => 'Дата цели не может быть в прошлом.';

  @override
  String get goalNoLinkedAssets => 'Активы не привязаны.';

  @override
  String get goalProgressSectionTitle => 'Прогресс цели';

  @override
  String get goalProgressLabel => 'Накоплено';

  @override
  String get goalDeficitLabel => 'Осталось';

  @override
  String get goalSurplusLabel => 'Сверх цели';

  @override
  String get goalMonthlyLabel => 'В месяц';

  @override
  String get goalDeadlineExpired => 'Срок истёк';

  @override
  String goalDeficit(String amount) {
    return 'Осталось: $amount';
  }

  @override
  String goalSurplus(String amount) {
    return 'Сверх цели: $amount';
  }

  @override
  String goalDeadline(String date) {
    return 'До $date';
  }

  @override
  String get goalGroupActive => 'Активные';

  @override
  String get goalGroupAchieved => 'Достигнутые';

  @override
  String get goalGroupClosed => 'Закрытые';

  @override
  String goalProgressSemantics(String progress, String target) {
    return 'Накоплено $progress из $target';
  }

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsNetWorthTitle => 'Чистый капитал';

  @override
  String get analyticsPeriodMonth => 'Месяц';

  @override
  String get analyticsPeriodThreeMonths => '3 месяца';

  @override
  String get analyticsPeriodSixMonths => '6 месяцев';

  @override
  String get analyticsPeriodYear => 'Год';

  @override
  String get analyticsPeriodAll => 'Всё время';

  @override
  String get analyticsKindAll => 'Все активы';

  @override
  String get analyticsEmptyTitle => 'Нет данных за период';

  @override
  String get analyticsEmptyMessage => 'Измените период или вид активов.';

  @override
  String get analyticsPointsTitle => 'Значения по датам';

  @override
  String get analyticsTrendUp => 'Рост';

  @override
  String get analyticsTrendDown => 'Снижение';

  @override
  String get analyticsTrendFlat => 'Без изменений';

  @override
  String analyticsChartSummary(
    String period,
    String last,
    String min,
    String max,
    String trend,
  ) {
    return 'Период: $period. Последнее: $last. Минимум: $min. Максимум: $max. $trend.';
  }

  @override
  String get moreOverviewSection => 'Обзор';

  @override
  String get analyticsRateErrorTitle => 'Нет курса валюты';

  @override
  String analyticsRateErrorMessage(String currency, String date) {
    return 'Курс $currency на $date не найден. Введите его вручную, чтобы построить график.';
  }

  @override
  String get analyticsEnterRate => 'Ввести курс';

  @override
  String get analyticsNoAssetsTitle => 'Нет активов';

  @override
  String get analyticsNoAssetsMessage =>
      'Добавьте счёт, инвестицию или недвижимость, чтобы увидеть динамику.';

  @override
  String get analyticsMinLabel => 'Минимум';

  @override
  String get analyticsMaxLabel => 'Максимум';

  @override
  String get analyticsNoChangesTitle => 'Нет изменений за период';

  @override
  String get analyticsNoChangesMessage =>
      'За выбранный период стоимость не менялась.';

  @override
  String analyticsShowAllPoints(int count) {
    return 'Показать все точки ($count)';
  }

  @override
  String get analyticsCollapsePoints => 'Свернуть точки';

  @override
  String get analyticsDynamicsTitle => 'Динамика за период';

  @override
  String get analyticsKindEmptyMessage => 'Нет активов выбранного вида.';

  @override
  String get analyticsCashflowTitle => 'Денежный поток';

  @override
  String get analyticsDetailsTitle => 'Детализация за месяц';

  @override
  String analyticsCashflowChartSummary(
    String period,
    String income,
    String expense,
    String net,
  ) {
    return 'Период: $period. Доход: $income. Расход: $expense. Итог: $net.';
  }

  @override
  String get analyticsCashflowEmptyTitle => 'Нет операций за период';

  @override
  String get analyticsCashflowEmptyMessage =>
      'Измените период или добавьте операцию.';

  @override
  String get analyticsCashflowEmptyMonthTitle => 'Нет операций за месяц';

  @override
  String get analyticsCashflowEmptyMonthMessage =>
      'Добавьте операцию или измените период.';

  @override
  String get analyticsCashflowKindAll => 'Все операции';

  @override
  String get analyticsCashflowIncome => 'Доходы';

  @override
  String get analyticsCashflowExpense => 'Расходы';

  @override
  String get analyticsCategoryFilterLabel => 'Категория';

  @override
  String get analyticsCategoriesTitle => 'Итоги по категориям';

  @override
  String get analyticsUnknownCategory => 'Без категории';

  @override
  String get dashboardNetWorthTitle => 'Чистый капитал';

  @override
  String get dashboardNetWorthAccounts => 'Счета';

  @override
  String get dashboardNetWorthInvestments => 'Инвестиции';

  @override
  String get dashboardNetWorthProperty => 'Недвижимость';

  @override
  String get dashboardSafetyTitle => 'Подушка безопасности';

  @override
  String get dashboardSafetyRunway => 'При текущих тратах хватит на';

  @override
  String dashboardSafetyMonths(int count) {
    return '$count мес';
  }

  @override
  String get dashboardSafetyNoReserve => 'Запаса нет';

  @override
  String get dashboardSafetyLessThanMonth => 'Меньше чем на месяц';

  @override
  String get dashboardSafetyMoreThan100Years => '100+ лет';

  @override
  String dashboardSafetyYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return '$_temp0';
  }

  @override
  String dashboardSafetyYearsMonths(String years, int months) {
    return '$years $months мес';
  }

  @override
  String get dashboardSafetyPeriod =>
      'Деньги на всех счетах · средние расходы за 3 полных месяца';

  @override
  String dashboardSafetyTarget(String amount) {
    return 'Цель — 6 месяцев расходов ($amount)';
  }

  @override
  String dashboardSafetyEta(int months, String profit) {
    return 'До цели — $months мес, если откладывать $profit/мес';
  }

  @override
  String dashboardSafetyEtaMoreThan10Years(String profit) {
    return 'До цели — больше 10 лет, если откладывать $profit/мес';
  }

  @override
  String get dashboardSafetyReached => 'Цель достигнута';

  @override
  String get dashboardSafetyNoProfit =>
      'Доходы не превышают расходы — цель не приближается';

  @override
  String get dashboardQuickActions => 'Быстрые действия';

  @override
  String get dashboardGoalsEmpty => 'Целей пока нет';

  @override
  String get dashboardAllGoals => 'Все цели';

  @override
  String get dashboardRecentTitle => 'Операции по активам';

  @override
  String get dashboardRecentEmpty => 'Операций по активам пока нет.';

  @override
  String get dashboardAllOperations => 'Все операции';

  @override
  String get dashboardOverview => 'Обзор';

  @override
  String get dashboardOverdueTitle => 'Просроченные счета';

  @override
  String dashboardOverdueEnded(String date) {
    return 'Срок истёк $date';
  }

  @override
  String dashboardOverdueMore(int count) {
    return 'Ещё $count';
  }

  @override
  String get dashboardGoalsTitle => 'Цели';

  @override
  String get dashboardUnknownAsset => 'Актив';

  @override
  String get dashboardNetWorthUnavailable => 'Не удалось рассчитать';

  @override
  String get dashboardLockedTitle => 'Заблокированные активы';

  @override
  String dashboardLockedShare(String percent) {
    return '$percent% от инвестиций';
  }

  @override
  String get dashboardLockedTooltip =>
      'Заблокированные суммы не уменьшают стоимость инвестиций и чистый капитал. Показаны в базовой валюте; процент — от общей стоимости инвестиций.';

  @override
  String get dashboardLockedInfoLabel => 'О заблокированных активах';

  @override
  String get dashboardCashflowTitle => 'Денежный поток';

  @override
  String get dashboardCashflowEmpty => 'В этом месяце нет операций';

  @override
  String get dashboardAddExpense => 'Добавить расход';

  @override
  String get dashboardCashflowDynamics => 'По неделям';

  @override
  String get moreReferencesSection => 'Справочники';

  @override
  String get moreAppSection => 'Приложение';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsReportsSection => 'Отчёты';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutDescription =>
      'Локальный учёт финансов. Данные хранятся на устройстве.';

  @override
  String get settingsAboutSection => 'О приложении';

  @override
  String get settingsAboutDetails => 'Подробнее';

  @override
  String get settingsBackupSection => 'Резервная копия';

  @override
  String get settingsBackupWarning =>
      'Файл не зашифрован и содержит финансовые данные. Храните и передавайте его только доверенным способом.';

  @override
  String get backupShare => 'Поделиться';

  @override
  String get backupSave => 'Сохранить файл';

  @override
  String get backupImport => 'Импортировать';

  @override
  String get backupImportConfirmTitle => 'Заменить данные?';

  @override
  String get backupImportConfirmMessage =>
      'Текущие локальные данные будут заменены. Рекомендуется сначала сохранить резервную копию.';

  @override
  String get backupImportConfirm => 'Заменить';

  @override
  String get backupExportShared => 'Файл передан системе.';

  @override
  String get backupExportSaved => 'Резервная копия сохранена.';

  @override
  String get backupShareCancelled => 'Отправка отменена.';

  @override
  String get backupShareUnknown =>
      'Файл подготовлен. Результат отправки неизвестен.';

  @override
  String get backupSaveCancelled => 'Сохранение отменено.';

  @override
  String get backupImportDone =>
      'Импорт завершён. Приложение будет перезапущено.';

  @override
  String get backupExportFailed => 'Не удалось создать резервную копию.';

  @override
  String get backupImportFailed =>
      'Импорт не выполнен, прежние данные восстановлены.';

  @override
  String get backupRestoreFailed =>
      'Не удалось автоматически восстановить прежние данные. Не вводите новые данные и не повторяйте импорт. Rollback-файл сохранён на устройстве.';

  @override
  String get backupValidationNotDatabase => 'Файл не является базой SQLite.';

  @override
  String get backupValidationCorrupted => 'Файл повреждён.';

  @override
  String get backupValidationOtherApp => 'Это не база FinanseApp.';

  @override
  String backupValidationNewerSchema(int schema, int installed) {
    return 'База создана более новой версией приложения (schema $schema, установлено $installed).';
  }

  @override
  String get backupValidationReferences => 'База содержит некорректные ссылки.';

  @override
  String get backupRestartTitle => 'Требуется перезапуск';

  @override
  String get backupRestartMessage =>
      'Импорт завершён. Приложение будет перезапущено.';

  @override
  String get backupRestartOk => 'Перезапустить';

  @override
  String settingsUpdateVersion(String version) {
    return 'Установленная версия: $version';
  }

  @override
  String get updateCheck => 'Проверить обновление';

  @override
  String get updateChecking => 'Проверка обновлений…';

  @override
  String get updateUpToDate => 'Установлена последняя версия.';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version.';
  }

  @override
  String get updateOpen => 'Открыть обновление';

  @override
  String get updateOpenFailed => 'Не удалось открыть страницу обновления.';

  @override
  String get updateNoReleases => 'Релизы не найдены.';

  @override
  String get updateCheckError => 'Не удалось проверить обновления.';

  @override
  String get updateNetworkError => 'Нет соединения или сервер недоступен.';

  @override
  String get updateInvalidResponse => 'Некорректный ответ сервера обновлений.';

  @override
  String get updateVersionUnavailable => 'Версия недоступна';

  @override
  String get updateAvailableSimple => 'Доступно обновление.';

  @override
  String get dashboardCashflowRateUnavailable =>
      'Итоги месяца недоступны без курса.';

  @override
  String get dashboardCashflowUnavailable =>
      'Не удалось рассчитать итоги месяца.';

  @override
  String get journalLoadMore => 'Показать ещё';

  @override
  String get revisionActionRestore => 'Восстановлена';

  @override
  String get auditRestore => 'Восстановить';

  @override
  String get auditRestoreFailed => 'Не удалось восстановить запись.';

  @override
  String get comparisonTitle => 'Сравнение активов';

  @override
  String get comparisonSelectHint => 'Выберите от 2 до 5 активов.';

  @override
  String get comparisonModeAbsolute => 'Суммы';

  @override
  String get comparisonModeNormalized => 'Индекс (100)';

  @override
  String get comparisonNoAssets => 'Недостаточно активов для сравнения.';

  @override
  String get comparisonEmpty => 'Нет данных за выбранный период.';

  @override
  String get comparisonTableTitle => 'Активы';

  @override
  String get comparisonSelectTitle => 'Активы для сравнения';

  @override
  String get comparisonChartTitle => 'Динамика стоимости';

  @override
  String get comparisonChartBase => 'База: 100% на старте';

  @override
  String comparisonSummaryLine(
    String name,
    String last,
    String min,
    String max,
  ) {
    return '$name: последнее $last, минимум $min, максимум $max';
  }

  @override
  String get comparisonGoAssets => 'Перейти к активам';

  @override
  String get propertyYieldTitle => 'Доходность за 12 месяцев';

  @override
  String get propertyYieldGross => 'Валовая доходность';

  @override
  String get propertyYieldNet => 'Чистая доходность';

  @override
  String get propertyYieldHint =>
      'Оценочно: все доходы и расходы объекта за последние 12 месяцев к текущей стоимости. Валовая — без расходов, чистая — за вычетом расходов.';

  @override
  String get propertyYieldUnavailable => 'Недостаточно данных для расчёта.';

  @override
  String get propertyYieldNoOperations =>
      'Нет операций за последние 12 месяцев.';

  @override
  String get propertyYieldError => 'Не удалось рассчитать доходность.';

  @override
  String get onboardingTitle => 'Добро пожаловать';

  @override
  String get onboardingIntro =>
      'FinanseApp — локальный учёт финансов: данные хранятся только на устройстве.';

  @override
  String get onboardingPrivacy =>
      'Резервная копия не шифруется — храните файл безопасно.';

  @override
  String get onboardingBaseCurrency =>
      'Используется для отчётов и итогов; можно изменить позже в настройках.';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingSkip => 'Не менять валюту';

  @override
  String get onboardingCurrencyLabel => 'Базовая валюта';

  @override
  String get onboardingSetupTitle => 'Начало работы';

  @override
  String get onboardingSaveError =>
      'Не удалось сохранить настройки. Попробуйте ещё раз.';

  @override
  String get auditTitle => 'Удалённые операции';

  @override
  String get auditTabAssets => 'Операции по активам';

  @override
  String get auditTabCashflow => 'Доходы и расходы';

  @override
  String get auditDeletedLabel => 'Удалено';

  @override
  String get auditDeletedOn => 'удалено';

  @override
  String get auditEmptyTitle => 'Удалённых операций нет';

  @override
  String get auditEmptyMessage =>
      'Удалённые операции и записи попадут сюда, их можно будет восстановить.';

  @override
  String get bankAddAction => 'Добавить банк';

  @override
  String get transactionDeleteBalanceBlocked =>
      'Нельзя удалить: после этой операции остаток счёта станет отрицательным.';

  @override
  String get transferDeleteTitle => 'Удалить перевод?';

  @override
  String get transferDeleteMessage =>
      'Обе операции перевода будут скрыты из журнала, балансы обоих счетов вернутся к прежним значениям. Восстановить можно в «Удалённых операциях».';

  @override
  String get transferDeleteAction => 'Удалить перевод';

  @override
  String get transferDeleted => 'Перевод удалён.';

  @override
  String get transferDeleteBalanceBlocked =>
      'Нельзя удалить перевод: на одном из двух счетов остаток станет отрицательным. Сначала удалите или измените более поздние операции.';

  @override
  String get transferDeleteConflict =>
      'Перевод уже удалён или повреждён. Обновите журнал.';
}
