import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// Заголовок приложения.
  ///
  /// In ru, this message translates to:
  /// **'FinanseApp'**
  String get appTitle;

  /// Заголовок экрана управления защитой (PIN-код, биометрия).
  ///
  /// In ru, this message translates to:
  /// **'Защита приложения'**
  String get appLockTitle;

  /// Статус: защита приложения включена.
  ///
  /// In ru, this message translates to:
  /// **'Защита включена'**
  String get appLockStatusOn;

  /// Статус: защита приложения выключена.
  ///
  /// In ru, this message translates to:
  /// **'Защита выключена'**
  String get appLockStatusOff;

  /// Кнопка включения защиты PIN-кодом.
  ///
  /// In ru, this message translates to:
  /// **'Включить защиту'**
  String get appLockEnable;

  /// Кнопка смены PIN-кода.
  ///
  /// In ru, this message translates to:
  /// **'Сменить PIN-код'**
  String get appLockChange;

  /// Кнопка отключения защиты PIN-кодом.
  ///
  /// In ru, this message translates to:
  /// **'Отключить защиту'**
  String get appLockDisable;

  /// Заголовок экрана блокировки.
  ///
  /// In ru, this message translates to:
  /// **'Введите PIN-код'**
  String get appLockLockTitle;

  /// Подсказка ввода текущего PIN при смене или отключении.
  ///
  /// In ru, this message translates to:
  /// **'Введите текущий PIN-код'**
  String get appLockEnterCurrent;

  /// Подсказка придумывания нового PIN-кода.
  ///
  /// In ru, this message translates to:
  /// **'Придумайте PIN-код: 4–6 цифр'**
  String get appLockEnterNew;

  /// Подсказка повторного ввода нового PIN-кода.
  ///
  /// In ru, this message translates to:
  /// **'Повторите PIN-код'**
  String get appLockConfirmNew;

  /// Кнопка перехода к повторному вводу PIN-кода.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get appLockContinue;

  /// Кнопка отмены ввода PIN-кода.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get appLockCancel;

  /// Ошибка при неверном PIN-коде.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN-код'**
  String get appLockWrongPin;

  /// Ошибка при расхождении повторного ввода нового PIN.
  ///
  /// In ru, this message translates to:
  /// **'PIN-коды не совпадают'**
  String get appLockPinsMismatch;

  /// Сообщение о блокировке ввода после неудачных попыток.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Повторите через {seconds} с'**
  String appLockLockedOut(int seconds);

  /// Кнопка разблокировки биометрией на экране блокировки.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать по отпечатку или лицу'**
  String get appLockBiometricUnlock;

  /// Причина, показываемая системной биометрией.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите личность для входа в FinanseApp'**
  String get appLockBiometricReason;

  /// Подпись переключателя биометрии в управлении защитой.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировка по отпечатку или лицу'**
  String get appLockBiometricSwitch;

  /// Ошибка при попытке включить недоступную биометрию.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия недоступна на этом устройстве'**
  String get appLockBiometricUnavailable;

  /// Подпись настройки auto-lock.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка при сворачивании'**
  String get appLockAutoLock;

  /// Вариант auto-lock: блокировать сразу при сворачивании.
  ///
  /// In ru, this message translates to:
  /// **'Сразу'**
  String get appLockAutoLockImmediate;

  /// Вариант auto-lock: блокировать через N минут в фоне.
  ///
  /// In ru, this message translates to:
  /// **'Через {minutes} мин'**
  String appLockAutoLockAfterMinutes(int minutes);

  /// Семантическая подпись кнопки стирания цифры PIN.
  ///
  /// In ru, this message translates to:
  /// **'Стереть'**
  String get appLockBackspace;

  /// Семантическая подпись индикатора ввода PIN.
  ///
  /// In ru, this message translates to:
  /// **'Введено {filled} из {length}'**
  String appLockDotsSemantics(int filled, int length);

  /// Пункт навигации: главная.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navDashboard;

  /// Пункт навигации: журнал операций.
  ///
  /// In ru, this message translates to:
  /// **'Операции'**
  String get navOperations;

  /// Пункт навигации: активы.
  ///
  /// In ru, this message translates to:
  /// **'Активы'**
  String get navAssets;

  /// Пункт навигации: финансовые цели.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get navGoals;

  /// Пункт навигации: дополнительные разделы.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get navMore;

  /// Нейтральный текст первичной загрузки.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка…'**
  String get commonLoading;

  /// Заголовок состояния ошибки.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить'**
  String get errorStateTitle;

  /// Пояснение состояния ошибки.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные. Попробуйте позже.'**
  String get errorStateMessage;

  /// Кнопка повтора после ошибки.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// Семантический ярлык ошибки.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get errorLabel;

  /// Заголовок пустой главной.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто'**
  String get dashboardEmptyTitle;

  /// Пояснение пустой главной.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте счёт или операцию, чтобы увидеть итоги.'**
  String get dashboardEmptyMessage;

  /// Заголовок пустого денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Нет операций'**
  String get cashflowEmptyTitle;

  /// Пояснение пустого денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Доходы и расходы появятся здесь.'**
  String get cashflowEmptyMessage;

  /// Заголовок пустых операций по активам.
  ///
  /// In ru, this message translates to:
  /// **'Нет операций по активам'**
  String get transactionsEmptyTitle;

  /// Пояснение пустых операций по активам.
  ///
  /// In ru, this message translates to:
  /// **'Пополнения, снятия и переводы появятся здесь.'**
  String get transactionsEmptyMessage;

  /// Заголовок пустого списка активов.
  ///
  /// In ru, this message translates to:
  /// **'Нет активов'**
  String get assetsEmptyTitle;

  /// Пояснение пустого списка активов.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте счёт, инвестицию или квартиру.'**
  String get assetsEmptyMessage;

  /// Заголовок пустого списка целей.
  ///
  /// In ru, this message translates to:
  /// **'Нет целей'**
  String get goalsEmptyTitle;

  /// Пояснение пустого списка целей.
  ///
  /// In ru, this message translates to:
  /// **'Создайте цель и привяжите активы.'**
  String get goalsEmptyMessage;

  /// Вкладка денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Доходы и расходы'**
  String get operationsCashflowTab;

  /// Вкладка операций по активам.
  ///
  /// In ru, this message translates to:
  /// **'Операции по активам'**
  String get operationsTransactionsTab;

  /// Секция экрана «Ещё».
  ///
  /// In ru, this message translates to:
  /// **'Безопасность'**
  String get moreSecuritySection;

  /// Заголовок Not Found.
  ///
  /// In ru, this message translates to:
  /// **'Страница не найдена'**
  String get notFoundTitle;

  /// Пояснение Not Found.
  ///
  /// In ru, this message translates to:
  /// **'Такой страницы нет. Вернитесь на главную.'**
  String get notFoundMessage;

  /// Кнопка возврата на главную.
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get notFoundHome;

  /// Заголовок заглушки раздела.
  ///
  /// In ru, this message translates to:
  /// **'Раздел в разработке'**
  String get comingSoonTitle;

  /// Пояснение заглушки раздела.
  ///
  /// In ru, this message translates to:
  /// **'Раздел появится в одном из обновлений.'**
  String get comingSoonMessage;

  /// Заголовок справочника банков и брокеров.
  ///
  /// In ru, this message translates to:
  /// **'Банки и брокеры'**
  String get subgroupsTitle;

  /// Вкладка банков.
  ///
  /// In ru, this message translates to:
  /// **'Банки'**
  String get subgroupsBankTab;

  /// Вкладка брокеров.
  ///
  /// In ru, this message translates to:
  /// **'Брокеры'**
  String get subgroupsBrokerTab;

  /// Кнопка добавления справочника.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get subgroupAdd;

  /// Заголовок пустого справочника.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет'**
  String get subgroupEmptyTitle;

  /// Поле названия справочника.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get subgroupNameLabel;

  /// Действие переименования.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get subgroupEditTooltip;

  /// Действие удаления.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get subgroupDeleteTooltip;

  /// Заголовок диалога занятого справочника.
  ///
  /// In ru, this message translates to:
  /// **'Справочник используется'**
  String get subgroupInUseTitle;

  /// Поле выбора целевой подгруппы.
  ///
  /// In ru, this message translates to:
  /// **'Куда перенести'**
  String get subgroupMoveTarget;

  /// Подтверждение переноса и удаления.
  ///
  /// In ru, this message translates to:
  /// **'Перенести и удалить'**
  String get subgroupMoveAction;

  /// Ошибка дубликата названия.
  ///
  /// In ru, this message translates to:
  /// **'Такое название уже есть.'**
  String get subgroupErrorDuplicate;

  /// Ошибка несовпадения типа.
  ///
  /// In ru, this message translates to:
  /// **'Можно перенести только в справочник того же типа.'**
  String get subgroupErrorKind;

  /// Ошибка выбора той же подгруппы.
  ///
  /// In ru, this message translates to:
  /// **'Выберите другой справочник.'**
  String get subgroupErrorSame;

  /// Ошибка удаления занятого справочника.
  ///
  /// In ru, this message translates to:
  /// **'Сначала перенесите активы.'**
  String get subgroupErrorInUse;

  /// Число привязанных активов.
  ///
  /// In ru, this message translates to:
  /// **'Активов: {count}'**
  String subgroupAssetsCount(int count);

  /// Кнопка отмены.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// Кнопка сохранения.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// Кнопка удаления.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// Пояснение переноса занятого справочника с числом активов.
  ///
  /// In ru, this message translates to:
  /// **'Активов: {count}. Перенесите их в другой справочник того же типа.'**
  String subgroupInUseMessageCount(int count);

  /// Подтверждение удаления свободного справочника с именем.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{name}»?'**
  String subgroupDeleteConfirmTitleNamed(String name);

  /// Пояснение удаления свободного справочника.
  ///
  /// In ru, this message translates to:
  /// **'Справочник не привязан к активам и будет удалён.'**
  String get subgroupDeleteConfirmMessageNamed;

  /// Заголовок тупика: нет второго справочника того же типа.
  ///
  /// In ru, this message translates to:
  /// **'Некуда перенести'**
  String get subgroupNoTargetTitle;

  /// Пояснение тупика переноса.
  ///
  /// In ru, this message translates to:
  /// **'Активы привязаны к «{name}», а других справочников этого типа нет. Создайте ещё один и повторите перенос.'**
  String subgroupNoTargetMessage(String name);

  /// Заголовок диалога создания банка.
  ///
  /// In ru, this message translates to:
  /// **'Новый банк'**
  String get subgroupNewBank;

  /// Заголовок диалога создания брокера.
  ///
  /// In ru, this message translates to:
  /// **'Новый брокер'**
  String get subgroupNewBroker;

  /// Заголовок переименования с именем.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать «{name}»'**
  String subgroupRenameTitleNamed(String name);

  /// Пояснение пустого списка банков.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте банк, чтобы привязать к нему счёт.'**
  String get subgroupEmptyMessageBank;

  /// Пояснение пустого списка брокеров.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте брокера, чтобы привязать к нему инвестицию.'**
  String get subgroupEmptyMessageBroker;

  /// Подсказка overflow-меню строки справочника.
  ///
  /// In ru, this message translates to:
  /// **'Действия со справочником'**
  String get subgroupActionsTooltip;

  /// Подтверждение успешного сохранения.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get commonSaved;

  /// Подтверждение удаления справочника.
  ///
  /// In ru, this message translates to:
  /// **'Справочник удалён.'**
  String get subgroupDeleted;

  /// Подтверждение переноса активов и удаления справочника.
  ///
  /// In ru, this message translates to:
  /// **'Активы перенесены в «{target}», справочник удалён.'**
  String subgroupMovedAndDeleted(String target);

  /// Заголовок справочника валют.
  ///
  /// In ru, this message translates to:
  /// **'Валюты'**
  String get currenciesTitle;

  /// Кнопка перехода к выбору базовой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Базовая валюта'**
  String get currenciesBaseAction;

  /// Действие создания валюты.
  ///
  /// In ru, this message translates to:
  /// **'Новая валюта'**
  String get currencyAdd;

  /// Поле кода валюты.
  ///
  /// In ru, this message translates to:
  /// **'Код (три заглавные буквы)'**
  String get currencyCodeLabel;

  /// Поле названия валюты.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get currencyNameLabel;

  /// Поле числа дробных знаков.
  ///
  /// In ru, this message translates to:
  /// **'Знаков после запятой'**
  String get currencyFractionLabel;

  /// Подпись числа дробных знаков.
  ///
  /// In ru, this message translates to:
  /// **'Знаков: {count}'**
  String currencyFractionValue(int count);

  /// Действие включения валюты.
  ///
  /// In ru, this message translates to:
  /// **'Включить'**
  String get currencyToggleEnable;

  /// Действие отключения валюты.
  ///
  /// In ru, this message translates to:
  /// **'Отключить'**
  String get currencyToggleDisable;

  /// Действие переименования валюты.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get currencyRename;

  /// Действие удаления валюты.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get currencyDelete;

  /// Подтверждение удаления валюты.
  ///
  /// In ru, this message translates to:
  /// **'Удалить валюту «{code}»?'**
  String currencyDeleteConfirmTitle(String code);

  /// Пояснение удаления валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюта не используется и будет удалена.'**
  String get currencyDeleteConfirmMessage;

  /// Ошибка дубликата валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюта с таким названием уже есть.'**
  String get currencyErrorDuplicate;

  /// Ошибка формата кода.
  ///
  /// In ru, this message translates to:
  /// **'Код должен состоять из трёх заглавных букв.'**
  String get currencyErrorCode;

  /// Ошибка удаления/отключения используемой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюта используется или выбрана базовой.'**
  String get currencyErrorInUse;

  /// Ошибка защиты RUB.
  ///
  /// In ru, this message translates to:
  /// **'RUB нельзя отключить или удалить.'**
  String get currencyErrorRub;

  /// Заголовок выбора базовой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Базовая валюта'**
  String get baseCurrencyTitle;

  /// Кнопка сохранения базовой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить базовую валюту'**
  String get baseCurrencySave;

  /// Подпись текущей базовой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Текущая базовая'**
  String get baseCurrencyCurrent;

  /// Заголовок диалога ручного курса.
  ///
  /// In ru, this message translates to:
  /// **'Ручной курс'**
  String get manualRateTitle;

  /// Поле ручного курса.
  ///
  /// In ru, this message translates to:
  /// **'Курс к рублю'**
  String get manualRateLabel;

  /// Подсказка формата курса.
  ///
  /// In ru, this message translates to:
  /// **'Например, 93,4567'**
  String get manualRateHint;

  /// Ошибка ручного курса.
  ///
  /// In ru, this message translates to:
  /// **'Введите положительный курс.'**
  String get manualRateInvalid;

  /// Подтверждение сохранения валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюта сохранена.'**
  String get currencySaved;

  /// Подтверждение смены базовой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Базовая валюта изменена.'**
  String get baseCurrencySaved;

  /// Ошибка числа дробных знаков валюты.
  ///
  /// In ru, this message translates to:
  /// **'Введите число от 0 до 8.'**
  String get currencyFractionError;

  /// Заголовок пустого списка валют.
  ///
  /// In ru, this message translates to:
  /// **'Нет валют'**
  String get currenciesEmptyTitle;

  /// Пояснение пустого списка валют.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте валюту или проверьте фильтры.'**
  String get currenciesEmptyMessage;

  /// Подсказка меню строки валюты.
  ///
  /// In ru, this message translates to:
  /// **'Действия с валютой'**
  String get currencyActionsTooltip;

  /// Ошибка пустого названия валюты.
  ///
  /// In ru, this message translates to:
  /// **'Введите название валюты.'**
  String get currencyNameRequired;

  /// Ошибка дубликата кода валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюта с таким кодом уже есть.'**
  String get currencyCodeDuplicate;

  /// Статус отключённой валюты в списке.
  ///
  /// In ru, this message translates to:
  /// **'Отключена'**
  String get currencyDisabledLabel;

  /// Подтверждение удаления валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюта удалена.'**
  String get currencyDeleted;

  /// Подтверждение включения/отключения валюты.
  ///
  /// In ru, this message translates to:
  /// **'Настройки валюты обновлены.'**
  String get currencyToggled;

  /// Пояснение смены базовой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Итоги и дашборд будут пересчитаны в выбранной валюте; сохранённые суммы в RUB не меняются.'**
  String get baseCurrencyHint;

  /// Пустое состояние выбора базовой валюты.
  ///
  /// In ru, this message translates to:
  /// **'Нет включённых валют для выбора.'**
  String get baseCurrencyEmpty;

  /// Заголовок переименования валюты с кодом.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать валюту «{code}»'**
  String currencyRenameNamed(String code);

  /// Подсказка диапазона дробных знаков.
  ///
  /// In ru, this message translates to:
  /// **'От 0 до 8'**
  String get currencyFractionRangeHint;

  /// Заголовок справочника категорий.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categoriesTitle;

  /// Вкладка доходных категорий.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get categoriesIncomeTab;

  /// Вкладка расходных категорий.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get categoriesExpenseTab;

  /// Действие создания категории.
  ///
  /// In ru, this message translates to:
  /// **'Новая категория'**
  String get categoryAdd;

  /// Заголовок пустого списка категорий.
  ///
  /// In ru, this message translates to:
  /// **'Нет категорий'**
  String get categoryEmptyTitle;

  /// Пояснение пустого списка категорий.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте категорию для доходов или расходов.'**
  String get categoryEmptyMessage;

  /// Пометка архивной категории.
  ///
  /// In ru, this message translates to:
  /// **'Архивная'**
  String get categoryArchivedBadge;

  /// Пометка предустановленной категории.
  ///
  /// In ru, this message translates to:
  /// **'Предустановленная'**
  String get categoryPresetBadge;

  /// Подсказка меню строки категории.
  ///
  /// In ru, this message translates to:
  /// **'Действия с категорией'**
  String get categoryActionsTooltip;

  /// Заголовок переименования категории.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать «{name}»'**
  String categoryRenameNamed(String name);

  /// Подтверждение удаления категории.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{name}»?'**
  String categoryDeleteNamed(String name);

  /// Пояснение удаления категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория не используется и будет удалена.'**
  String get categoryDeleteMessage;

  /// Заголовок конфликта удаления категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория «{name}» используется'**
  String categoryInUseTitle(String name);

  /// Пояснение конфликта категории.
  ///
  /// In ru, this message translates to:
  /// **'Записей: {count}. Архивируйте категорию или перенесите записи в другую категорию того же типа.'**
  String categoryInUseMessage(int count);

  /// Действие архивирования категории.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать'**
  String get categoryArchiveAction;

  /// Действие переноса записей и удаления категории.
  ///
  /// In ru, this message translates to:
  /// **'Перенести и удалить'**
  String get categoryMoveAction;

  /// Поле выбора целевой категории.
  ///
  /// In ru, this message translates to:
  /// **'Куда перенести записи'**
  String get categoryMoveTarget;

  /// Ошибка дубликата категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория с таким названием уже есть.'**
  String get categoryErrorDuplicate;

  /// Ошибка несовпадения типа категории.
  ///
  /// In ru, this message translates to:
  /// **'Перенести можно только в категорию того же типа.'**
  String get categoryErrorKind;

  /// Ошибка архивной категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория архивирована и недоступна для новых записей.'**
  String get categoryErrorArchived;

  /// Ошибка пустого названия.
  ///
  /// In ru, this message translates to:
  /// **'Введите название категории.'**
  String get categoryErrorName;

  /// Подтверждение сохранения категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория сохранена.'**
  String get categorySaved;

  /// Подтверждение удаления категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория удалена.'**
  String get categoryDeleted;

  /// Подтверждение архивации категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория архивирована.'**
  String get categoryArchived;

  /// Заголовок формы создания категории.
  ///
  /// In ru, this message translates to:
  /// **'Новая категория'**
  String get categoryNewTitle;

  /// Общее действие переименования.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get commonRename;

  /// Общее поле названия сущности.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get commonNameLabel;

  /// Действие создания счёта.
  ///
  /// In ru, this message translates to:
  /// **'Добавить счёт'**
  String get assetsAddAccount;

  /// Заголовок формы нового счёта.
  ///
  /// In ru, this message translates to:
  /// **'Новый счёт'**
  String get accountFormNew;

  /// Заголовок формы редактирования счёта.
  ///
  /// In ru, this message translates to:
  /// **'Изменить счёт'**
  String get accountFormEdit;

  /// Поле названия счёта.
  ///
  /// In ru, this message translates to:
  /// **'Название счёта'**
  String get accountNameLabel;

  /// Поле выбора банка.
  ///
  /// In ru, this message translates to:
  /// **'Банк'**
  String get accountBankLabel;

  /// Поле начального баланса.
  ///
  /// In ru, this message translates to:
  /// **'Начальный баланс'**
  String get accountOpeningLabel;

  /// Поле годовой ставки.
  ///
  /// In ru, this message translates to:
  /// **'Ставка, % годовых'**
  String get accountRateLabel;

  /// Поле даты начала вклада.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get accountStartDate;

  /// Поле даты окончания вклада.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get accountEndDate;

  /// Подпись текущего баланса.
  ///
  /// In ru, this message translates to:
  /// **'Текущий баланс'**
  String get accountBalanceLabel;

  /// Подпись прогноза вклада.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз'**
  String get accountForecastLabel;

  /// Пояснение прогноза.
  ///
  /// In ru, this message translates to:
  /// **'Оценка с ежемесячной капитализацией, не входит в чистый капитал.'**
  String get accountForecastHint;

  /// Действие архивирования счёта.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать'**
  String get accountArchive;

  /// Действие удаления счёта.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get accountDelete;

  /// Подтверждение удаления счёта.
  ///
  /// In ru, this message translates to:
  /// **'Удалить счёт «{name}»?'**
  String accountDeleteTitle(String name);

  /// Пояснение удаления счёта.
  ///
  /// In ru, this message translates to:
  /// **'Счёт не используется и будет удалён.'**
  String get accountDeleteMessage;

  /// Пометка архивного актива.
  ///
  /// In ru, this message translates to:
  /// **'Архивный'**
  String get accountArchivedBadge;

  /// Подтверждение сохранения счёта.
  ///
  /// In ru, this message translates to:
  /// **'Счёт сохранён.'**
  String get accountSaved;

  /// Подтверждение архивации.
  ///
  /// In ru, this message translates to:
  /// **'Счёт архивирован.'**
  String get accountArchived;

  /// Подтверждение удаления.
  ///
  /// In ru, this message translates to:
  /// **'Счёт удалён.'**
  String get accountDeleted;

  /// Ошибка названия.
  ///
  /// In ru, this message translates to:
  /// **'Введите название счёта.'**
  String get accountErrorName;

  /// Ошибка ставки.
  ///
  /// In ru, this message translates to:
  /// **'Ставка должна быть от 0 до 100.'**
  String get accountErrorRate;

  /// Ошибка дат.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания не раньше даты начала.'**
  String get accountErrorDates;

  /// Ошибка смены валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюту нельзя менять после операций.'**
  String get accountErrorCurrencyLocked;

  /// Ошибка удаления используемого счёта.
  ///
  /// In ru, this message translates to:
  /// **'Счёт используется и не может быть удалён.'**
  String get accountErrorInUse;

  /// Пустое состояние выбора банка.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте банк в справочнике.'**
  String get accountNoBanks;

  /// Заголовок деталей счёта.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get accountDetailsTitle;

  /// CTA пустого списка активов.
  ///
  /// In ru, this message translates to:
  /// **'Добавить счёт'**
  String get assetsEmptyCta;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
