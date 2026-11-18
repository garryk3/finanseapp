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
  String get assetsEmptyMessage => 'Добавьте счёт или инвестицию.';

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
  ) {
    return 'Операций: $transactions, оценок: $valuations, целей: $goals, записей: $cashflow. Удаление недоступно — архивируйте актив.';
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
  String get investmentValuationHint =>
      'Оценка задаётся на конец дня: операции этой даты применяются после неё.';

  @override
  String get investmentErrorName => 'Введите название инвестиции.';

  @override
  String get investmentErrorBroker => 'Выберите брокера.';

  @override
  String get investmentAddValuation => 'Добавить оценку';

  @override
  String get valuationTitle => 'Новая оценка';

  @override
  String get valuationValueLabel => 'Стоимость';

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
  String get assetKindProperty => 'Квартира';

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
}
