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
  /// **'Добавьте счёт, инвестицию или недвижимость.'**
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

  /// Ошибка суммы счёта.
  ///
  /// In ru, this message translates to:
  /// **'Введите неотрицательную сумму в основных единицах.'**
  String get accountErrorAmount;

  /// Ошибка выбора банка.
  ///
  /// In ru, this message translates to:
  /// **'Выберите банк.'**
  String get accountErrorBank;

  /// Действие редактирования счёта.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get accountEdit;

  /// Подпись эквивалента в базовой валюте.
  ///
  /// In ru, this message translates to:
  /// **'В базовой валюте'**
  String get assetBaseEquivalent;

  /// Нет курса для пересчёта в базовую валюту.
  ///
  /// In ru, this message translates to:
  /// **'Курс недоступен'**
  String get assetBaseUnavailable;

  /// Заголовок диалога занятого актива.
  ///
  /// In ru, this message translates to:
  /// **'Актив используется'**
  String get assetInUseTitle;

  /// Разбивка ссылок на актив.
  ///
  /// In ru, this message translates to:
  /// **'Операций: {transactions}, оценок: {valuations}, целей: {goals}, записей: {cashflow}, правил: {recurring}. Удаление недоступно — архивируйте актив.'**
  String assetInUseMessage(
    int transactions,
    int valuations,
    int goals,
    int cashflow,
    int recurring,
  );

  /// Поле выбора валюты счёта.
  ///
  /// In ru, this message translates to:
  /// **'Валюта счёта'**
  String get accountCurrencyLabel;

  /// Причина блокировки валюты счёта.
  ///
  /// In ru, this message translates to:
  /// **'Валюту нельзя менять после операций.'**
  String get accountCurrencyLocked;

  /// Включить дату окончания вклада.
  ///
  /// In ru, this message translates to:
  /// **'Добавить дату окончания'**
  String get accountAddEndDate;

  /// Снять дату окончания вклада.
  ///
  /// In ru, this message translates to:
  /// **'Убрать дату окончания'**
  String get accountRemoveEndDate;

  /// Действие создания любого актива.
  ///
  /// In ru, this message translates to:
  /// **'Добавить актив'**
  String get assetsAddAsset;

  /// Действие создания инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Добавить инвестицию'**
  String get assetsAddInvestment;

  /// Заголовок выбора вида актива.
  ///
  /// In ru, this message translates to:
  /// **'Новый актив'**
  String get assetsAddTitle;

  /// Заголовок формы новой инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Новая инвестиция'**
  String get investmentFormNew;

  /// Заголовок формы редактирования инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Изменить инвестицию'**
  String get investmentFormEdit;

  /// Поле названия инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Название инвестиции'**
  String get investmentNameLabel;

  /// Поле выбора брокера.
  ///
  /// In ru, this message translates to:
  /// **'Брокер'**
  String get investmentBrokerLabel;

  /// Пустой список брокеров.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте брокера в справочнике.'**
  String get investmentNoBrokers;

  /// Поле валюты инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Валюта инвестиции'**
  String get investmentCurrencyLabel;

  /// Заголовок деталей инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Инвестиция'**
  String get investmentDetailsTitle;

  /// Подпись текущей стоимости инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Текущая стоимость'**
  String get investmentCurrentValue;

  /// Пояснение к абсолютной оценке.
  ///
  /// In ru, this message translates to:
  /// **'Оценка задаётся на конец дня: операции этой даты применяются после неё.'**
  String get investmentValuationHint;

  /// Ошибка названия инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Введите название инвестиции.'**
  String get investmentErrorName;

  /// Ошибка выбора брокера.
  ///
  /// In ru, this message translates to:
  /// **'Выберите брокера.'**
  String get investmentErrorBroker;

  /// Действие добавления оценки.
  ///
  /// In ru, this message translates to:
  /// **'Добавить оценку'**
  String get investmentAddValuation;

  /// Заголовок формы оценки.
  ///
  /// In ru, this message translates to:
  /// **'Новая оценка'**
  String get valuationTitle;

  /// Поле абсолютной стоимости.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость'**
  String get valuationValueLabel;

  /// Поле даты оценки.
  ///
  /// In ru, this message translates to:
  /// **'Дата оценки'**
  String get valuationDateLabel;

  /// Поле ручного курса для оценки.
  ///
  /// In ru, this message translates to:
  /// **'Курс к рублю'**
  String get valuationRateLabel;

  /// Пояснение к необязательному курсу.
  ///
  /// In ru, this message translates to:
  /// **'Пусто — возьмём курс ЦБ на дату.'**
  String get valuationRateOptional;

  /// Ошибка стоимости оценки.
  ///
  /// In ru, this message translates to:
  /// **'Введите стоимость. Стоимость не может быть отрицательной.'**
  String get valuationErrorValue;

  /// Ошибка получения курса.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить курс. Введите курс вручную.'**
  String get valuationErrorRate;

  /// Заголовок истории оценок.
  ///
  /// In ru, this message translates to:
  /// **'История оценок'**
  String get valuationHistory;

  /// Пустая история оценок.
  ///
  /// In ru, this message translates to:
  /// **'Оценок пока нет. Стоимость считается по операциям от начального баланса.'**
  String get valuationHistoryEmpty;

  /// Подтверждение сохранения оценки.
  ///
  /// In ru, this message translates to:
  /// **'Оценка сохранена.'**
  String get valuationSaved;

  /// Заголовок деталей неизвестного вида актива.
  ///
  /// In ru, this message translates to:
  /// **'Актив'**
  String get assetDetailsTitle;

  /// Подтверждение архивации актива.
  ///
  /// In ru, this message translates to:
  /// **'Актив архивирован.'**
  String get assetArchived;

  /// Подтверждение удаления актива.
  ///
  /// In ru, this message translates to:
  /// **'Актив удалён.'**
  String get assetDeleted;

  /// Подтверждение удаления актива.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{name}»?'**
  String assetDeleteTitle(String name);

  /// Пояснение удаления актива.
  ///
  /// In ru, this message translates to:
  /// **'Актив не используется и будет удалён.'**
  String get assetDeleteMessage;

  /// Ошибка удаления используемого актива.
  ///
  /// In ru, this message translates to:
  /// **'Актив используется и не может быть удалён.'**
  String get assetErrorInUse;

  /// Ошибка будущей даты оценки.
  ///
  /// In ru, this message translates to:
  /// **'Дата оценки не может быть в будущем.'**
  String get valuationErrorDate;

  /// Вид актива: счёт.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get assetKindAccount;

  /// Вид актива: инвестиция.
  ///
  /// In ru, this message translates to:
  /// **'Инвестиция'**
  String get assetKindInvestment;

  /// Вид актива: недвижимость.
  ///
  /// In ru, this message translates to:
  /// **'Недвижимость'**
  String get assetKindProperty;

  /// Меню редких действий на деталях актива.
  ///
  /// In ru, this message translates to:
  /// **'Действия с активом'**
  String get assetActions;

  /// Ошибка архивации актива.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось архивировать актив.'**
  String get assetArchiveFailed;

  /// Метка актуальной оценки.
  ///
  /// In ru, this message translates to:
  /// **'Текущая'**
  String get valuationCurrent;

  /// Рублёвый эквивалент оценки.
  ///
  /// In ru, this message translates to:
  /// **'В рублях: {value}'**
  String valuationRubLine(String value);

  /// Заголовок секции формы инвестиции.
  ///
  /// In ru, this message translates to:
  /// **'Инвестиция'**
  String get investmentSectionTitle;

  /// Действие перехода к справочнику брокеров.
  ///
  /// In ru, this message translates to:
  /// **'Добавить брокера'**
  String get brokerAddAction;

  /// Поле поиска по названию актива.
  ///
  /// In ru, this message translates to:
  /// **'Поиск активов'**
  String get assetsSearchLabel;

  /// Подсказка поиска активов.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get assetsSearchHint;

  /// Очистка поля поиска.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get assetsSearchClear;

  /// Фильтр всех видов активов.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get assetsFilterAll;

  /// Тумблер показа архивных активов.
  ///
  /// In ru, this message translates to:
  /// **'Показывать архивные'**
  String get assetsFilterArchived;

  /// Заголовок пустого результата фильтра.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get assetsFilteredEmptyTitle;

  /// Пояснение пустого результата фильтра.
  ///
  /// In ru, this message translates to:
  /// **'Измените условия фильтра или сбросьте его.'**
  String get assetsFilteredEmptyMessage;

  /// Сброс фильтров списка активов.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get assetsResetFilters;

  /// Заголовок каталога, где все активы архивные.
  ///
  /// In ru, this message translates to:
  /// **'Все активы в архиве'**
  String get assetsAllArchivedTitle;

  /// Пояснение каталога только из архивных активов.
  ///
  /// In ru, this message translates to:
  /// **'Показываются только активные. Откройте архив, чтобы увидеть остальные.'**
  String get assetsAllArchivedMessage;

  /// Действие показа архивных из пустого состояния.
  ///
  /// In ru, this message translates to:
  /// **'Показать архивные'**
  String get assetsShowArchivedAction;

  /// Заголовок формы операции по активу.
  ///
  /// In ru, this message translates to:
  /// **'Новая операция'**
  String get transactionFormNew;

  /// Поле выбора актива.
  ///
  /// In ru, this message translates to:
  /// **'Актив'**
  String get transactionAssetLabel;

  /// Вид операции: пополнение.
  ///
  /// In ru, this message translates to:
  /// **'Пополнение'**
  String get transactionKindDeposit;

  /// Вид операции: снятие.
  ///
  /// In ru, this message translates to:
  /// **'Снятие'**
  String get transactionKindWithdrawal;

  /// Сумма операции.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get transactionAmountLabel;

  /// Дата операции.
  ///
  /// In ru, this message translates to:
  /// **'Дата операции'**
  String get transactionDateLabel;

  /// Комментарий к операции.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get transactionCommentLabel;

  /// Связать операцию с денежным потоком.
  ///
  /// In ru, this message translates to:
  /// **'Учесть как доход или расход'**
  String get transactionClassifyLabel;

  /// Категория дохода или расхода.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get transactionCategoryLabel;

  /// Действие пополнения актива.
  ///
  /// In ru, this message translates to:
  /// **'Пополнить'**
  String get transactionAddDeposit;

  /// Действие снятия с актива.
  ///
  /// In ru, this message translates to:
  /// **'Снять'**
  String get transactionAddWithdrawal;

  /// Подтверждение сохранения операции.
  ///
  /// In ru, this message translates to:
  /// **'Операция сохранена.'**
  String get transactionSaved;

  /// Ошибка выбора актива.
  ///
  /// In ru, this message translates to:
  /// **'Выберите актив.'**
  String get transactionErrorAsset;

  /// Ошибка суммы операции.
  ///
  /// In ru, this message translates to:
  /// **'Введите положительную сумму в основных единицах.'**
  String get transactionErrorAmount;

  /// Ошибка выбора категории.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию.'**
  String get transactionErrorCategory;

  /// Ошибка будущей даты операции.
  ///
  /// In ru, this message translates to:
  /// **'Дата операции не может быть в будущем.'**
  String get transactionErrorDate;

  /// Ошибка отрицательного баланса.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно средств на активе.'**
  String get transactionErrorNegativeBalance;

  /// Ошибка несовпадения вида.
  ///
  /// In ru, this message translates to:
  /// **'Категория не соответствует виду операции.'**
  String get transactionErrorKindMismatch;

  /// Пустой список активов для операции.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте счёт или инвестицию.'**
  String get transactionNoAssets;

  /// Пустой список категорий.
  ///
  /// In ru, this message translates to:
  /// **'Нет категорий для этого вида.'**
  String get transactionNoCategories;

  /// Заголовок формы перевода.
  ///
  /// In ru, this message translates to:
  /// **'Перевод между счетами'**
  String get transferFormTitle;

  /// Счёт-источник перевода.
  ///
  /// In ru, this message translates to:
  /// **'Со счёта'**
  String get transferFromLabel;

  /// Счёт назначения перевода.
  ///
  /// In ru, this message translates to:
  /// **'На счёт'**
  String get transferToLabel;

  /// Сумма перевода со счёта-источника.
  ///
  /// In ru, this message translates to:
  /// **'Сумма списания'**
  String get transferAmountLabel;

  /// Сумма перевода на счёт назначения.
  ///
  /// In ru, this message translates to:
  /// **'Сумма зачисления'**
  String get transferDestinationAmountLabel;

  /// Комментарий к переводу.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get transferCommentLabel;

  /// Подтверждение перевода.
  ///
  /// In ru, this message translates to:
  /// **'Перевод сохранён.'**
  String get transferSaved;

  /// Действие перевода между счетами.
  ///
  /// In ru, this message translates to:
  /// **'Перевести'**
  String get transferAction;

  /// Ошибка счёта-источника.
  ///
  /// In ru, this message translates to:
  /// **'Выберите счёт списания.'**
  String get transferErrorFrom;

  /// Ошибка счёта назначения.
  ///
  /// In ru, this message translates to:
  /// **'Выберите счёт зачисления.'**
  String get transferErrorTo;

  /// Ошибка одинаковых счетов.
  ///
  /// In ru, this message translates to:
  /// **'Счета должны различаться.'**
  String get transferErrorSameAccount;

  /// Ошибка суммы перевода.
  ///
  /// In ru, this message translates to:
  /// **'Введите положительную сумму перевода.'**
  String get transferErrorAmount;

  /// Ошибка баланса перевода.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно средств на счёте списания.'**
  String get transferErrorNegativeBalance;

  /// Пустое состояние выбора счетов.
  ///
  /// In ru, this message translates to:
  /// **'Нужно минимум два счёта.'**
  String get transferNoAccounts;

  /// Курс по введённым суммам перевода.
  ///
  /// In ru, this message translates to:
  /// **'{fromUnit} ≈ {toAmount}'**
  String transferRateHint(String fromUnit, String toAmount);

  /// Пояснение состояния с одним счётом.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте второй счёт, чтобы переводить между счетами.'**
  String get transferNeedAccountsMessage;

  /// Ошибка суммы зачисления.
  ///
  /// In ru, this message translates to:
  /// **'Введите положительную сумму зачисления.'**
  String get transferErrorDestination;

  /// Поле поиска по комментарию.
  ///
  /// In ru, this message translates to:
  /// **'Поиск операций'**
  String get transactionsSearchLabel;

  /// Подсказка поиска операций.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get transactionsSearchHint;

  /// Очистка поиска операций.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get transactionsSearchClear;

  /// Все виды операций.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get transactionsFilterAll;

  /// Фильтр пополнений.
  ///
  /// In ru, this message translates to:
  /// **'Пополнения'**
  String get transactionsFilterDeposit;

  /// Фильтр снятий.
  ///
  /// In ru, this message translates to:
  /// **'Снятия'**
  String get transactionsFilterWithdrawal;

  /// Фильтр исходящих переводов.
  ///
  /// In ru, this message translates to:
  /// **'Исходящие'**
  String get transactionsFilterTransferOut;

  /// Фильтр входящих переводов.
  ///
  /// In ru, this message translates to:
  /// **'Входящие'**
  String get transactionsFilterTransferIn;

  /// Фильтр текущего месяца.
  ///
  /// In ru, this message translates to:
  /// **'Этот месяц'**
  String get transactionsFilterMonth;

  /// Заголовок пустого фильтра журнала.
  ///
  /// In ru, this message translates to:
  /// **'Операций не найдено'**
  String get transactionsFilteredEmptyTitle;

  /// Пояснение пустого фильтра журнала.
  ///
  /// In ru, this message translates to:
  /// **'Измените фильтры или сбросьте их.'**
  String get transactionsFilteredEmptyMessage;

  /// Сброс фильтров журнала.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get transactionsResetFilters;

  /// Создание операции из журнала.
  ///
  /// In ru, this message translates to:
  /// **'Новая операция'**
  String get transactionsAdd;

  /// Семантика загрузки журнала.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка операций'**
  String get transactionsLoading;

  /// Вид операции: исходящий перевод.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (исходящий)'**
  String get transactionKindTransferOut;

  /// Вид операции: входящий перевод.
  ///
  /// In ru, this message translates to:
  /// **'Перевод (входящий)'**
  String get transactionKindTransferIn;

  /// Заголовок деталей операции.
  ///
  /// In ru, this message translates to:
  /// **'Операция'**
  String get transactionDetailsTitle;

  /// Заголовок ревизий операции.
  ///
  /// In ru, this message translates to:
  /// **'История изменений'**
  String get transactionRevisionsTitle;

  /// Подтверждение удаления операции.
  ///
  /// In ru, this message translates to:
  /// **'Удалить операцию?'**
  String get transactionDeleteTitle;

  /// Пояснение удаления операции.
  ///
  /// In ru, this message translates to:
  /// **'Операция будет скрыта из журнала; история останется в аудите.'**
  String get transactionDeleteMessage;

  /// Подтверждение удаления операции.
  ///
  /// In ru, this message translates to:
  /// **'Операция удалена.'**
  String get transactionDeleted;

  /// Ошибка удаления ноги перевода.
  ///
  /// In ru, this message translates to:
  /// **'Связанную операцию перевода нельзя удалить отдельно.'**
  String get transactionDeleteBlocked;

  /// Рублёвый snapshot операции.
  ///
  /// In ru, this message translates to:
  /// **'В рублях'**
  String get transactionAmountRub;

  /// Метка связанной классификации.
  ///
  /// In ru, this message translates to:
  /// **'Связана с денежным потоком'**
  String get transactionLinkedCashflow;

  /// Пустой комментарий операции.
  ///
  /// In ru, this message translates to:
  /// **'Без комментария'**
  String get transactionCommentEmpty;

  /// Заголовок ревизии.
  ///
  /// In ru, this message translates to:
  /// **'Ревизия {number}'**
  String revisionLabel(int number);

  /// Действие ревизии: создание.
  ///
  /// In ru, this message translates to:
  /// **'Создана'**
  String get revisionActionCreate;

  /// Действие ревизии: изменение.
  ///
  /// In ru, this message translates to:
  /// **'Изменена'**
  String get revisionActionEdit;

  /// Действие ревизии: удаление.
  ///
  /// In ru, this message translates to:
  /// **'Удалена'**
  String get revisionActionDelete;

  /// Поле diff: сумма.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get revisionFieldAmount;

  /// Поле diff: дата.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get revisionFieldDate;

  /// Поле diff: вид.
  ///
  /// In ru, this message translates to:
  /// **'Вид операции'**
  String get revisionFieldKind;

  /// Поле diff: курс.
  ///
  /// In ru, this message translates to:
  /// **'Курс'**
  String get revisionFieldRate;

  /// Поле diff: комментарий.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get revisionFieldComment;

  /// Заголовок аудита операции.
  ///
  /// In ru, this message translates to:
  /// **'Аудит операции'**
  String get auditAssetTransactionTitle;

  /// Строка diff ревизии.
  ///
  /// In ru, this message translates to:
  /// **'{field}: было {oldValue}, стало {newValue}'**
  String revisionDiffLine(String field, String oldValue, String newValue);

  /// Пустая история ревизий.
  ///
  /// In ru, this message translates to:
  /// **'Изменений пока нет.'**
  String get revisionEmpty;

  /// Переход к истории ревизий операции.
  ///
  /// In ru, this message translates to:
  /// **'Открыть аудит'**
  String get transactionAuditAction;

  /// Тип записи: доход.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get cashflowIncome;

  /// Тип записи: расход.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get cashflowExpense;

  /// Создание записи денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Добавить доход или расход'**
  String get cashflowAdd;

  /// Заголовок новой записи денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Новая запись'**
  String get cashflowFormNew;

  /// Заголовок редактирования записи.
  ///
  /// In ru, this message translates to:
  /// **'Изменить запись'**
  String get cashflowFormEdit;

  /// Поле категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get cashflowCategoryLabel;

  /// Поле суммы дохода/расхода.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get cashflowAmountLabel;

  /// Подтверждение сохранения.
  ///
  /// In ru, this message translates to:
  /// **'Запись сохранена.'**
  String get cashflowSaved;

  /// Подтверждение удаления.
  ///
  /// In ru, this message translates to:
  /// **'Запись удалена.'**
  String get cashflowDeleted;

  /// Подтверждение удаления записи.
  ///
  /// In ru, this message translates to:
  /// **'Удалить запись?'**
  String get cashflowDeleteTitle;

  /// Пояснение удаления записи.
  ///
  /// In ru, this message translates to:
  /// **'Запись будет скрыта из журнала; история останется в аудите.'**
  String get cashflowDeleteMessage;

  /// Заголовок деталей записи.
  ///
  /// In ru, this message translates to:
  /// **'Доход или расход'**
  String get cashflowDetailsTitle;

  /// Ошибка суммы.
  ///
  /// In ru, this message translates to:
  /// **'Введите положительную сумму.'**
  String get cashflowErrorAmount;

  /// Ошибка категории.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию.'**
  String get cashflowErrorCategory;

  /// Ошибка несовпадения типа.
  ///
  /// In ru, this message translates to:
  /// **'Категория не соответствует типу записи.'**
  String get cashflowErrorKindMismatch;

  /// Пустой список категорий.
  ///
  /// In ru, this message translates to:
  /// **'Нет категорий для этого типа.'**
  String get cashflowNoCategories;

  /// Итог доходов.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get cashflowTotalsIncome;

  /// Итог расходов.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get cashflowTotalsExpense;

  /// Итог денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get cashflowTotalsNet;

  /// Период: все время.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get cashflowPeriodAll;

  /// Поле валюты дохода/расхода.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get cashflowCurrencyLabel;

  /// Ошибка удаления записи.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить запись.'**
  String get cashflowDeleteError;

  /// Ошибка архивной категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория в архиве. Выберите активную.'**
  String get cashflowErrorCategoryArchived;

  /// Заголовок формы новой недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Новая недвижимость'**
  String get propertyFormNew;

  /// Заголовок редактирования недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Изменить недвижимость'**
  String get propertyFormEdit;

  /// Поле названия недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Название недвижимости'**
  String get propertyNameLabel;

  /// Необязательный адрес.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get propertyAddressLabel;

  /// Необязательная цена покупки.
  ///
  /// In ru, this message translates to:
  /// **'Цена покупки'**
  String get propertyPurchasePriceLabel;

  /// Начальная стоимость недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Начальная стоимость'**
  String get propertyValueLabel;

  /// Валюта стоимости недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Валюта недвижимости'**
  String get propertyCurrencyLabel;

  /// Заголовок секции формы недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Недвижимость'**
  String get propertySectionTitle;

  /// Ошибка названия недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Введите название недвижимости.'**
  String get propertyErrorName;

  /// Секция cashflow недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Денежный поток по недвижимости'**
  String get propertyCashflowTitle;

  /// Пустой поток недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Записей за период нет.'**
  String get propertyCashflowEmpty;

  /// Добавить доход по недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Добавить доход'**
  String get propertyAddIncome;

  /// Добавить расход по недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Добавить расход'**
  String get propertyAddExpense;

  /// Период: месяц.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get cashflowPeriodMonth;

  /// Период: год.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get cashflowPeriodYear;

  /// Действие создания недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Добавить недвижимость'**
  String get assetsAddProperty;

  /// Необязательный счёт для дохода/расхода.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get cashflowAccountLabel;

  /// Создать связанную операцию по счёту.
  ///
  /// In ru, this message translates to:
  /// **'Влияет на баланс счёта'**
  String get cashflowAffectsBalance;

  /// Вкладка журнала операций с правилами ежемесячных платежей.
  ///
  /// In ru, this message translates to:
  /// **'Регулярные'**
  String get operationsRecurringTab;

  /// Заголовок списка и секции регулярных платежей.
  ///
  /// In ru, this message translates to:
  /// **'Ежемесячные платежи'**
  String get recurringTitle;

  /// Пустое состояние списка регулярных платежей.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет ежемесячных платежей.'**
  String get recurringEmpty;

  /// Как появится первое правило.
  ///
  /// In ru, this message translates to:
  /// **'Создайте правило из формы дохода/расхода или кнопкой «Добавить платёж».'**
  String get recurringEmptyHint;

  /// Ссылка из истории ведёт на удалённое правило.
  ///
  /// In ru, this message translates to:
  /// **'Правило удалено'**
  String get recurringRuleDeletedTitle;

  /// Пояснение к удалённому правилу.
  ///
  /// In ru, this message translates to:
  /// **'Созданные операции сохранились, новые платежи не начисляются.'**
  String get recurringRuleDeletedMessage;

  /// Кнопка создания ежемесячного платежа.
  ///
  /// In ru, this message translates to:
  /// **'Добавить платёж'**
  String get recurringAdd;

  /// Заголовок формы создания правила.
  ///
  /// In ru, this message translates to:
  /// **'Новый ежемесячный платёж'**
  String get recurringNew;

  /// Заголовок формы редактирования правила.
  ///
  /// In ru, this message translates to:
  /// **'Ежемесячный платёж'**
  String get recurringEdit;

  /// Чекбокс создания правила из формы дохода/расхода.
  ///
  /// In ru, this message translates to:
  /// **'Повторять ежемесячно'**
  String get recurringMonthly;

  /// Дата первого платежа правила.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get recurringStartDate;

  /// Необязательная дата последнего платежа.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get recurringEndDate;

  /// Поле необязательной даты окончания.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания (необязательно)'**
  String get recurringEndDateOptional;

  /// Очистка необязательной даты окончания.
  ///
  /// In ru, this message translates to:
  /// **'Убрать дату окончания'**
  String get recurringEndClear;

  /// Дата окончания не задана.
  ///
  /// In ru, this message translates to:
  /// **'Бессрочно'**
  String get recurringEndNotSet;

  /// Расписание правила: from — дата начала.
  ///
  /// In ru, this message translates to:
  /// **'Ежемесячно с {from}'**
  String recurringScheduleFrom(String from);

  /// Ближайший платёж правила.
  ///
  /// In ru, this message translates to:
  /// **'Следующий: {date}'**
  String recurringNextLabel(String date);

  /// Платёж правила не выполнен в срок.
  ///
  /// In ru, this message translates to:
  /// **'Просрочен: {date}'**
  String recurringOverdueLabel(String date);

  /// Правило дошло до даты окончания.
  ///
  /// In ru, this message translates to:
  /// **'Завершено'**
  String get recurringCompleted;

  /// Название автоправила процентов в списке.
  ///
  /// In ru, this message translates to:
  /// **'Проценты по вкладу'**
  String get recurringAutoInterestTitle;

  /// Параметры автоправила процентов.
  ///
  /// In ru, this message translates to:
  /// **'{rate}% годовых · капитализация ежемесячно'**
  String recurringAutoInterestMeta(String rate);

  /// Ближайшее начисление процентов.
  ///
  /// In ru, this message translates to:
  /// **'Следующее начисление: {date}'**
  String recurringNextAccrual(String date);

  /// Начисление процентов не выполнено в срок.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено: {date}'**
  String recurringOverdueAccrual(String date);

  /// Архивный вклад не капитализируется.
  ///
  /// In ru, this message translates to:
  /// **'Начисления остановлены: счёт в архиве'**
  String get recurringAccrualStoppedArchive;

  /// Автоправило процентов не создано или недоступно.
  ///
  /// In ru, this message translates to:
  /// **'Начисления не выполняются: проверьте категорию'**
  String get recurringAccrualUnavailable;

  /// Подпись суммы последнего начисления.
  ///
  /// In ru, this message translates to:
  /// **'Последнее начисление'**
  String get recurringLastAccrualLabel;

  /// Метка автоматического правила в карточке процентов.
  ///
  /// In ru, this message translates to:
  /// **'Авто'**
  String get recurringAutoChip;

  /// Подсказка в форме счёта при ставке больше нуля.
  ///
  /// In ru, this message translates to:
  /// **'Проценты начисляются автоматически в то же число месяца, что и дата начала (для 31-го — последний день месяца). Прошедшие месяцы будут начислены при сохранении.'**
  String get accountRateAutoHint;

  /// Пояснение взаимоисключающего выбора цели.
  ///
  /// In ru, this message translates to:
  /// **'Цель — только счёт или недвижимость'**
  String get recurringTargetHint;

  /// Нет активов для цели правила.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте счёт или недвижимость.'**
  String get recurringNoTargets;

  /// Дата окончания правила.
  ///
  /// In ru, this message translates to:
  /// **'по {to}'**
  String recurringScheduleUntil(String to);

  /// Ближайшая дата платежа правила.
  ///
  /// In ru, this message translates to:
  /// **'Следующий платёж: {date}'**
  String recurringNextPayment(String date);

  /// Следующий платёж не вычисляется (нет даты начала).
  ///
  /// In ru, this message translates to:
  /// **'Дата не определена'**
  String get recurringNextPaymentNone;

  /// Платёж отложен: нет курса на дату.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает курс'**
  String get recurringPendingRate;

  /// Метка операции, созданной правилом.
  ///
  /// In ru, this message translates to:
  /// **'Автоплатёж'**
  String get recurringAutoBadge;

  /// Переход от автооперации к её правилу.
  ///
  /// In ru, this message translates to:
  /// **'Изменить правило'**
  String get recurringRuleLink;

  /// Заголовок подтверждения удаления правила.
  ///
  /// In ru, this message translates to:
  /// **'Удалить правило?'**
  String get recurringDeleteTitle;

  /// Пояснение удаления правила без удаления истории.
  ///
  /// In ru, this message translates to:
  /// **'Правило будет удалено. Созданные операции останутся.'**
  String get recurringDeleteMessage;

  /// Уведомление после удаления правила.
  ///
  /// In ru, this message translates to:
  /// **'Правило удалено'**
  String get recurringDeleted;

  /// Уведомление после сохранения правила.
  ///
  /// In ru, this message translates to:
  /// **'Правило сохранено'**
  String get recurringSaved;

  /// Кнопка удаления правила в форме.
  ///
  /// In ru, this message translates to:
  /// **'Удалить правило'**
  String get recurringDeleteAction;

  /// Выбор счёта как цели правила.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get recurringTargetAccount;

  /// Выбор недвижимости как цели правила.
  ///
  /// In ru, this message translates to:
  /// **'Недвижимость'**
  String get recurringTargetProperty;

  /// Правило без привязки к активу.
  ///
  /// In ru, this message translates to:
  /// **'Не выбран'**
  String get recurringNoTarget;

  /// Ошибка диапазона дат правила.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания не может быть раньше даты начала'**
  String get recurringErrorDates;

  /// Автоправило процентов нельзя править вручную.
  ///
  /// In ru, this message translates to:
  /// **'Проценты по вкладу начисляются автоматически и настраиваются в счёте.'**
  String get recurringReadOnlyInterest;

  /// Переход из автоправила процентов к счёту.
  ///
  /// In ru, this message translates to:
  /// **'Открыть счёт'**
  String get recurringOpenAccount;

  /// Какой курс использует автогенерация.
  ///
  /// In ru, this message translates to:
  /// **'Курс берётся из сохранённого курса на дату платежа.'**
  String get recurringRateHint;

  /// Пустая секция на экране актива.
  ///
  /// In ru, this message translates to:
  /// **'Нет ежемесячных платежей.'**
  String get recurringSectionEmpty;

  /// Правило без счёта и недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Без привязки к активу'**
  String get recurringNoTargetHint;

  /// Ошибка счёта при affectsBalance.
  ///
  /// In ru, this message translates to:
  /// **'Выберите счёт или отключите влияние на баланс.'**
  String get cashflowErrorAccount;

  /// Нет счетов для связи.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте счёт.'**
  String get cashflowNoAccounts;

  /// Причина блокировки валюты.
  ///
  /// In ru, this message translates to:
  /// **'Валюта берётся из счёта'**
  String get cashflowCurrencyFromAccount;

  /// Подсказка выбора счёта.
  ///
  /// In ru, this message translates to:
  /// **'Выберите счёт'**
  String get cashflowAccountHint;

  /// Ошибка валюты при связи со счётом.
  ///
  /// In ru, this message translates to:
  /// **'Валюта записи не совпадает с валютой счёта.'**
  String get cashflowErrorCurrencyMismatch;

  /// Поиск по комментарию cashflow.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по комментарию'**
  String get cashflowSearchLabel;

  /// Подсказка поиска.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get cashflowSearchHint;

  /// Очистка поиска.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get cashflowSearchClear;

  /// Все виды записей.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get cashflowFilterAll;

  /// Пустой фильтр.
  ///
  /// In ru, this message translates to:
  /// **'Записей не найдено'**
  String get cashflowFilteredEmptyTitle;

  /// Пояснение пустого фильтра.
  ///
  /// In ru, this message translates to:
  /// **'Измените фильтры или сбросьте их.'**
  String get cashflowFilteredEmptyMessage;

  /// Сброс фильтров.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get cashflowResetFilters;

  /// Открыть дополнительные фильтры.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get cashflowFilters;

  /// Сброс фильтра категории.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get cashflowAllCategories;

  /// Сброс фильтра счёта.
  ///
  /// In ru, this message translates to:
  /// **'Все счета'**
  String get cashflowAllAccounts;

  /// Сброс фильтра валюты.
  ///
  /// In ru, this message translates to:
  /// **'Все валюты'**
  String get cashflowAllCurrencies;

  /// Заголовок аудита денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Аудит записи'**
  String get cashflowAuditTitle;

  /// Закрыть диалог.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get commonDone;

  /// Пометка рублёвых итогов.
  ///
  /// In ru, this message translates to:
  /// **'Итоги в ₽'**
  String get cashflowSummaryInRub;

  /// Сброс фильтра недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Вся недвижимость'**
  String get cashflowAllProperties;

  /// Поле фильтра по недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Недвижимость'**
  String get cashflowPropertyLabel;

  /// Кнопка фильтров со счётчиком.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры · {count}'**
  String cashflowFiltersWithCount(int count);

  /// Контекст недвижимости в форме.
  ///
  /// In ru, this message translates to:
  /// **'Недвижимость: {name}'**
  String cashflowPropertyContext(String name);

  /// Пояснение отсутствия счёта.
  ///
  /// In ru, this message translates to:
  /// **'Не влияет на баланс счёта'**
  String get cashflowPropertyNoAccount;

  /// Создание цели.
  ///
  /// In ru, this message translates to:
  /// **'Добавить цель'**
  String get goalsAdd;

  /// Заголовок новой цели.
  ///
  /// In ru, this message translates to:
  /// **'Новая цель'**
  String get goalFormNew;

  /// Заголовок редактирования цели.
  ///
  /// In ru, this message translates to:
  /// **'Изменить цель'**
  String get goalFormEdit;

  /// Заголовок деталей цели.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get goalDetailsTitle;

  /// Поле названия.
  ///
  /// In ru, this message translates to:
  /// **'Название цели'**
  String get goalNameLabel;

  /// Поле целевой суммы.
  ///
  /// In ru, this message translates to:
  /// **'Целевая сумма'**
  String get goalTargetAmountLabel;

  /// Необязательная дата цели.
  ///
  /// In ru, this message translates to:
  /// **'Дата цели'**
  String get goalTargetDateLabel;

  /// Категория цели.
  ///
  /// In ru, this message translates to:
  /// **'Категория цели'**
  String get goalCategoryLabel;

  /// Цель по счетам.
  ///
  /// In ru, this message translates to:
  /// **'Счета'**
  String get goalCategoryAccounts;

  /// Цель по инвестициям.
  ///
  /// In ru, this message translates to:
  /// **'Инвестиции'**
  String get goalCategoryInvestments;

  /// Список привязанных активов.
  ///
  /// In ru, this message translates to:
  /// **'Активы цели'**
  String get goalAssetsLabel;

  /// Пустой список активов.
  ///
  /// In ru, this message translates to:
  /// **'Нет подходящих активов.'**
  String get goalNoAssets;

  /// Ошибка названия.
  ///
  /// In ru, this message translates to:
  /// **'Введите название цели.'**
  String get goalErrorName;

  /// Ошибка суммы.
  ///
  /// In ru, this message translates to:
  /// **'Введите положительную целевую сумму.'**
  String get goalErrorAmount;

  /// Ошибка активов.
  ///
  /// In ru, this message translates to:
  /// **'Выберите хотя бы один актив.'**
  String get goalErrorAssets;

  /// Статус цели.
  ///
  /// In ru, this message translates to:
  /// **'Активна'**
  String get goalStatusActive;

  /// Статус цели.
  ///
  /// In ru, this message translates to:
  /// **'Достигнута'**
  String get goalStatusAchieved;

  /// Статус цели.
  ///
  /// In ru, this message translates to:
  /// **'Закрыта'**
  String get goalStatusClosed;

  /// Подтверждение удаления.
  ///
  /// In ru, this message translates to:
  /// **'Цель удалена.'**
  String get goalDeleted;

  /// Подтверждение удаления.
  ///
  /// In ru, this message translates to:
  /// **'Удалить цель?'**
  String get goalDeleteTitle;

  /// Пояснение удаления.
  ///
  /// In ru, this message translates to:
  /// **'Цель будет скрыта; связи с активами сохранятся в истории.'**
  String get goalDeleteMessage;

  /// Действие статуса.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть цель'**
  String get goalClose;

  /// Действие статуса.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть в работу'**
  String get goalActivate;

  /// Заголовок секции формы цели.
  ///
  /// In ru, this message translates to:
  /// **'Параметры цели'**
  String get goalSectionTitle;

  /// Поле валюты целевой суммы.
  ///
  /// In ru, this message translates to:
  /// **'Валюта цели'**
  String get goalCurrencyLabel;

  /// Включить дату цели.
  ///
  /// In ru, this message translates to:
  /// **'Указать дату цели'**
  String get goalDateToggle;

  /// Ошибка даты цели.
  ///
  /// In ru, this message translates to:
  /// **'Дата цели не может быть в прошлом.'**
  String get goalErrorDate;

  /// Пустой список активов в деталях цели.
  ///
  /// In ru, this message translates to:
  /// **'Активы не привязаны.'**
  String get goalNoLinkedAssets;

  /// Заголовок секции прогресса в деталях цели.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс цели'**
  String get goalProgressSectionTitle;

  /// Текущий прогресс цели.
  ///
  /// In ru, this message translates to:
  /// **'Накоплено'**
  String get goalProgressLabel;

  /// Сколько осталось до цели.
  ///
  /// In ru, this message translates to:
  /// **'Осталось'**
  String get goalDeficitLabel;

  /// Насколько прогресс превышает цель.
  ///
  /// In ru, this message translates to:
  /// **'Сверх цели'**
  String get goalSurplusLabel;

  /// Рекомендуемый месячный взнос.
  ///
  /// In ru, this message translates to:
  /// **'В месяц'**
  String get goalMonthlyLabel;

  /// Дата цели в прошлом при дефиците.
  ///
  /// In ru, this message translates to:
  /// **'Срок истёк'**
  String get goalDeadlineExpired;

  /// Строка дефицита в карточке цели.
  ///
  /// In ru, this message translates to:
  /// **'Осталось: {amount}'**
  String goalDeficit(String amount);

  /// Строка превышения в карточке цели.
  ///
  /// In ru, this message translates to:
  /// **'Сверх цели: {amount}'**
  String goalSurplus(String amount);

  /// Срок цели в карточке.
  ///
  /// In ru, this message translates to:
  /// **'До {date}'**
  String goalDeadline(String date);

  /// Заголовок группы активных целей.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get goalGroupActive;

  /// Заголовок группы достигнутых целей.
  ///
  /// In ru, this message translates to:
  /// **'Достигнутые'**
  String get goalGroupAchieved;

  /// Заголовок группы закрытых целей.
  ///
  /// In ru, this message translates to:
  /// **'Закрытые'**
  String get goalGroupClosed;

  /// Доступное описание прогресса цели.
  ///
  /// In ru, this message translates to:
  /// **'Накоплено {progress} из {target}'**
  String goalProgressSemantics(String progress, String target);

  /// Заголовок экрана аналитики.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get analyticsTitle;

  /// Заголовок графика net worth.
  ///
  /// In ru, this message translates to:
  /// **'Чистый капитал'**
  String get analyticsNetWorthTitle;

  /// Период аналитики — текущий месяц.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get analyticsPeriodMonth;

  /// Период аналитики — 3 месяца.
  ///
  /// In ru, this message translates to:
  /// **'3 месяца'**
  String get analyticsPeriodThreeMonths;

  /// Период аналитики — 6 месяцев.
  ///
  /// In ru, this message translates to:
  /// **'6 месяцев'**
  String get analyticsPeriodSixMonths;

  /// Период аналитики — текущий год.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get analyticsPeriodYear;

  /// Период аналитики — всё время.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get analyticsPeriodAll;

  /// Фильтр видов активов — все.
  ///
  /// In ru, this message translates to:
  /// **'Все активы'**
  String get analyticsKindAll;

  /// Пустая серия net worth.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных за период'**
  String get analyticsEmptyTitle;

  /// Пояснение пустой серии.
  ///
  /// In ru, this message translates to:
  /// **'Измените период или вид активов.'**
  String get analyticsEmptyMessage;

  /// Доступный список точек графика.
  ///
  /// In ru, this message translates to:
  /// **'Значения по датам'**
  String get analyticsPointsTitle;

  /// Направление серии.
  ///
  /// In ru, this message translates to:
  /// **'Рост'**
  String get analyticsTrendUp;

  /// Направление серии.
  ///
  /// In ru, this message translates to:
  /// **'Снижение'**
  String get analyticsTrendDown;

  /// Направление серии.
  ///
  /// In ru, this message translates to:
  /// **'Без изменений'**
  String get analyticsTrendFlat;

  /// Доступное описание графика.
  ///
  /// In ru, this message translates to:
  /// **'Период: {period}. Последнее: {last}. Минимум: {min}. Максимум: {max}. {trend}.'**
  String analyticsChartSummary(
    String period,
    String last,
    String min,
    String max,
    String trend,
  );

  /// Секция «Ещё» с обзорными экранами.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get moreOverviewSection;

  /// Ошибка отсутствующего курса в аналитике.
  ///
  /// In ru, this message translates to:
  /// **'Нет курса валюты'**
  String get analyticsRateErrorTitle;

  /// Ошибка отсутствующего курса с датой.
  ///
  /// In ru, this message translates to:
  /// **'Курс {currency} на {date} не найден. Введите его вручную, чтобы построить график.'**
  String analyticsRateErrorMessage(String currency, String date);

  /// Действие ручного ввода курса.
  ///
  /// In ru, this message translates to:
  /// **'Ввести курс'**
  String get analyticsEnterRate;

  /// Пустая аналитика без активов.
  ///
  /// In ru, this message translates to:
  /// **'Нет активов'**
  String get analyticsNoAssetsTitle;

  /// Пояснение пустой аналитики без активов.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте счёт, инвестицию или недвижимость, чтобы увидеть динамику.'**
  String get analyticsNoAssetsMessage;

  /// Минимум серии net worth.
  ///
  /// In ru, this message translates to:
  /// **'Минимум'**
  String get analyticsMinLabel;

  /// Максимум серии net worth.
  ///
  /// In ru, this message translates to:
  /// **'Максимум'**
  String get analyticsMaxLabel;

  /// Серия из одной точки.
  ///
  /// In ru, this message translates to:
  /// **'Нет изменений за период'**
  String get analyticsNoChangesTitle;

  /// Пояснение к одной точке.
  ///
  /// In ru, this message translates to:
  /// **'За выбранный период стоимость не менялась.'**
  String get analyticsNoChangesMessage;

  /// Развернуть доступный список точек.
  ///
  /// In ru, this message translates to:
  /// **'Показать все точки ({count})'**
  String analyticsShowAllPoints(int count);

  /// Свернуть доступный список точек.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть точки'**
  String get analyticsCollapsePoints;

  /// Короткий заголовок графика net worth.
  ///
  /// In ru, this message translates to:
  /// **'Динамика за период'**
  String get analyticsDynamicsTitle;

  /// Пустая аналитика по фильтру вида.
  ///
  /// In ru, this message translates to:
  /// **'Нет активов выбранного вида.'**
  String get analyticsKindEmptyMessage;

  /// Заголовок cashflow-секции аналитики.
  ///
  /// In ru, this message translates to:
  /// **'Денежный поток'**
  String get analyticsCashflowTitle;

  /// Доступный список cashflow-серии.
  ///
  /// In ru, this message translates to:
  /// **'Значения по периодам'**
  String get analyticsPeriodsTitle;

  /// Доступное описание cashflow-графика.
  ///
  /// In ru, this message translates to:
  /// **'Период: {period}. Доход: {income}. Расход: {expense}. Итог: {net}.'**
  String analyticsCashflowChartSummary(
    String period,
    String income,
    String expense,
    String net,
  );

  /// Пустая cashflow-серия.
  ///
  /// In ru, this message translates to:
  /// **'Нет операций за период'**
  String get analyticsCashflowEmptyTitle;

  /// Пояснение пустой cashflow-серии.
  ///
  /// In ru, this message translates to:
  /// **'Измените период или добавьте операцию.'**
  String get analyticsCashflowEmptyMessage;

  /// Развернуть cashflow-список периодов.
  ///
  /// In ru, this message translates to:
  /// **'Показать все периоды ({count})'**
  String analyticsShowAllPeriods(int count);

  /// Свернуть cashflow-список периодов.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть периоды'**
  String get analyticsCollapsePeriods;

  /// Фильтр cashflow-аналитики по типу.
  ///
  /// In ru, this message translates to:
  /// **'Все операции'**
  String get analyticsCashflowKindAll;

  /// Фильтр cashflow — доходы.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get analyticsCashflowIncome;

  /// Фильтр cashflow — расходы.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get analyticsCashflowExpense;

  /// Фильтр аналитики по категории.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get analyticsCategoryFilterLabel;

  /// Секция итогов по категориям.
  ///
  /// In ru, this message translates to:
  /// **'Итоги по категориям'**
  String get analyticsCategoriesTitle;

  /// Фоллбэк имени категории в аналитике.
  ///
  /// In ru, this message translates to:
  /// **'Без категории'**
  String get analyticsUnknownCategory;

  /// Заголовок net worth на главной.
  ///
  /// In ru, this message translates to:
  /// **'Чистый капитал'**
  String get dashboardNetWorthTitle;

  /// Секция быстрых действий.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые действия'**
  String get dashboardQuickActions;

  /// Пустой блок целей на главной.
  ///
  /// In ru, this message translates to:
  /// **'Целей пока нет'**
  String get dashboardGoalsEmpty;

  /// Переход к списку целей.
  ///
  /// In ru, this message translates to:
  /// **'Все цели'**
  String get dashboardAllGoals;

  /// Секция последних операций.
  ///
  /// In ru, this message translates to:
  /// **'Операции по активам'**
  String get dashboardRecentTitle;

  /// Пустой блок операций на главной.
  ///
  /// In ru, this message translates to:
  /// **'Операций по активам пока нет.'**
  String get dashboardRecentEmpty;

  /// Переход в журнал операций с главной.
  ///
  /// In ru, this message translates to:
  /// **'Все операции'**
  String get dashboardAllOperations;

  /// Заголовок секции net worth.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get dashboardOverview;

  /// Заголовок секции целей на главной.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get dashboardGoalsTitle;

  /// Фоллбэк имени актива на главной.
  ///
  /// In ru, this message translates to:
  /// **'Актив'**
  String get dashboardUnknownAsset;

  /// Нейтральная ошибка расчёта net worth.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось рассчитать'**
  String get dashboardNetWorthUnavailable;

  /// Секция cashflow месяца на главной.
  ///
  /// In ru, this message translates to:
  /// **'Денежный поток'**
  String get dashboardCashflowTitle;

  /// Пустой cashflow месяца.
  ///
  /// In ru, this message translates to:
  /// **'В этом месяце нет операций'**
  String get dashboardCashflowEmpty;

  /// CTA пустого cashflow месяца.
  ///
  /// In ru, this message translates to:
  /// **'Добавить расход'**
  String get dashboardAddExpense;

  /// Подзаголовок недельного графика cashflow на главной.
  ///
  /// In ru, this message translates to:
  /// **'По неделям'**
  String get dashboardCashflowDynamics;

  /// Секция справочников в «Ещё».
  ///
  /// In ru, this message translates to:
  /// **'Справочники'**
  String get moreReferencesSection;

  /// Секция приложения в «Ещё».
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get moreAppSection;

  /// Заголовок экрана настроек.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// Секция отчётов в настройках.
  ///
  /// In ru, this message translates to:
  /// **'Отчёты'**
  String get settingsReportsSection;

  /// Заголовок экрана о приложении.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutTitle;

  /// Описание приложения.
  ///
  /// In ru, this message translates to:
  /// **'Локальный учёт финансов. Данные хранятся на устройстве.'**
  String get aboutDescription;

  /// Секция «О приложении» в настройках.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAboutSection;

  /// Переход на экран About из настроек.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get settingsAboutDetails;

  /// Секция backup в настройках.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия'**
  String get settingsBackupSection;

  /// Предупреждение backup.
  ///
  /// In ru, this message translates to:
  /// **'Файл не зашифрован и содержит финансовые данные. Храните и передавайте его только доверенным способом.'**
  String get settingsBackupWarning;

  /// Действие share backup.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get backupShare;

  /// Действие save backup.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить файл'**
  String get backupSave;

  /// Действие import backup.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать'**
  String get backupImport;

  /// Подтверждение импорта.
  ///
  /// In ru, this message translates to:
  /// **'Заменить данные?'**
  String get backupImportConfirmTitle;

  /// Пояснение импорта.
  ///
  /// In ru, this message translates to:
  /// **'Текущие локальные данные будут заменены. Рекомендуется сначала сохранить резервную копию.'**
  String get backupImportConfirmMessage;

  /// Подтвердить импорт.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get backupImportConfirm;

  /// Share success.
  ///
  /// In ru, this message translates to:
  /// **'Файл передан системе.'**
  String get backupExportShared;

  /// Save success.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия сохранена.'**
  String get backupExportSaved;

  /// Share cancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отправка отменена.'**
  String get backupShareCancelled;

  /// Share unavailable.
  ///
  /// In ru, this message translates to:
  /// **'Файл подготовлен. Результат отправки неизвестен.'**
  String get backupShareUnknown;

  /// Save cancelled.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение отменено.'**
  String get backupSaveCancelled;

  /// Import success.
  ///
  /// In ru, this message translates to:
  /// **'Импорт завершён. Приложение будет перезапущено.'**
  String get backupImportDone;

  /// Export error.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать резервную копию.'**
  String get backupExportFailed;

  /// Import rollback.
  ///
  /// In ru, this message translates to:
  /// **'Импорт не выполнен, прежние данные восстановлены.'**
  String get backupImportFailed;

  /// Blocking rollback failure.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось автоматически восстановить прежние данные. Не вводите новые данные и не повторяйте импорт. Rollback-файл сохранён на устройстве.'**
  String get backupRestoreFailed;

  /// Validation error.
  ///
  /// In ru, this message translates to:
  /// **'Файл не является базой SQLite.'**
  String get backupValidationNotDatabase;

  /// Validation error.
  ///
  /// In ru, this message translates to:
  /// **'Файл повреждён.'**
  String get backupValidationCorrupted;

  /// Validation error.
  ///
  /// In ru, this message translates to:
  /// **'Это не база FinanseApp.'**
  String get backupValidationOtherApp;

  /// Validation error new schema.
  ///
  /// In ru, this message translates to:
  /// **'База создана более новой версией приложения (schema {schema}, установлено {installed}).'**
  String backupValidationNewerSchema(int schema, int installed);

  /// Validation error FK.
  ///
  /// In ru, this message translates to:
  /// **'База содержит некорректные ссылки.'**
  String get backupValidationReferences;

  /// Restart dialog title.
  ///
  /// In ru, this message translates to:
  /// **'Требуется перезапуск'**
  String get backupRestartTitle;

  /// Restart dialog.
  ///
  /// In ru, this message translates to:
  /// **'Импорт завершён. Приложение будет перезапущено.'**
  String get backupRestartMessage;

  /// Restart action.
  ///
  /// In ru, this message translates to:
  /// **'Перезапустить'**
  String get backupRestartOk;

  /// Версия приложения.
  ///
  /// In ru, this message translates to:
  /// **'Установленная версия: {version}'**
  String settingsUpdateVersion(String version);

  /// Кнопка проверки обновлений.
  ///
  /// In ru, this message translates to:
  /// **'Проверить обновление'**
  String get updateCheck;

  /// Статус проверки.
  ///
  /// In ru, this message translates to:
  /// **'Проверка обновлений…'**
  String get updateChecking;

  /// Статус up-to-date.
  ///
  /// In ru, this message translates to:
  /// **'Установлена последняя версия.'**
  String get updateUpToDate;

  /// Статус доступного обновления.
  ///
  /// In ru, this message translates to:
  /// **'Доступна версия {version}.'**
  String updateAvailable(String version);

  /// Открыть APK/release page.
  ///
  /// In ru, this message translates to:
  /// **'Открыть обновление'**
  String get updateOpen;

  /// Ошибка запуска ссылки.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть страницу обновления.'**
  String get updateOpenFailed;

  /// 404 latest release.
  ///
  /// In ru, this message translates to:
  /// **'Релизы не найдены.'**
  String get updateNoReleases;

  /// Сетевая/форматная ошибка.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить обновления.'**
  String get updateCheckError;

  /// Offline/HTTP ошибка обновлений.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения или сервер недоступен.'**
  String get updateNetworkError;

  /// Malformed release.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный ответ сервера обновлений.'**
  String get updateInvalidResponse;

  /// Не удалось получить версию.
  ///
  /// In ru, this message translates to:
  /// **'Версия недоступна'**
  String get updateVersionUnavailable;

  /// Обновление без тега версии.
  ///
  /// In ru, this message translates to:
  /// **'Доступно обновление.'**
  String get updateAvailableSimple;

  /// Ошибка курса в блоке денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Итоги месяца недоступны без курса.'**
  String get dashboardCashflowRateUnavailable;

  /// Ошибка расчёта денежного потока.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось рассчитать итоги месяца.'**
  String get dashboardCashflowUnavailable;

  /// Пагинация журналов.
  ///
  /// In ru, this message translates to:
  /// **'Показать ещё'**
  String get journalLoadMore;

  /// Действие ревизии restore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановлена'**
  String get revisionActionRestore;

  /// Кнопка восстановления удалённой записи.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get auditRestore;

  /// Ошибка restore.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось восстановить запись.'**
  String get auditRestoreFailed;

  /// Экран сравнения активов.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение активов'**
  String get comparisonTitle;

  /// Подсказка выбора.
  ///
  /// In ru, this message translates to:
  /// **'Выберите от 2 до 5 активов.'**
  String get comparisonSelectHint;

  /// Режим absolute.
  ///
  /// In ru, this message translates to:
  /// **'Суммы'**
  String get comparisonModeAbsolute;

  /// Режим normalized.
  ///
  /// In ru, this message translates to:
  /// **'Индекс (100)'**
  String get comparisonModeNormalized;

  /// Меньше 2 активов.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно активов для сравнения.'**
  String get comparisonNoAssets;

  /// Пустые серии.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных за выбранный период.'**
  String get comparisonEmpty;

  /// Таблица сравнения.
  ///
  /// In ru, this message translates to:
  /// **'Активы'**
  String get comparisonTableTitle;

  /// Заголовок выбора активов.
  ///
  /// In ru, this message translates to:
  /// **'Активы для сравнения'**
  String get comparisonSelectTitle;

  /// Заголовок графика сравнения.
  ///
  /// In ru, this message translates to:
  /// **'Динамика стоимости'**
  String get comparisonChartTitle;

  /// Короткое пояснение normalized.
  ///
  /// In ru, this message translates to:
  /// **'База: 100% на старте'**
  String get comparisonChartBase;

  /// Строка summary сравнения.
  ///
  /// In ru, this message translates to:
  /// **'{name}: последнее {last}, минимум {min}, максимум {max}'**
  String comparisonSummaryLine(
    String name,
    String last,
    String min,
    String max,
  );

  /// CTA пустого сравнения.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к активам'**
  String get comparisonGoAssets;

  /// Секция доходности недвижимости.
  ///
  /// In ru, this message translates to:
  /// **'Доходность за 12 месяцев'**
  String get propertyYieldTitle;

  /// Gross yield.
  ///
  /// In ru, this message translates to:
  /// **'Валовая доходность'**
  String get propertyYieldGross;

  /// Net yield.
  ///
  /// In ru, this message translates to:
  /// **'Чистая доходность'**
  String get propertyYieldNet;

  /// Пояснение доходности.
  ///
  /// In ru, this message translates to:
  /// **'Оценочно: все доходы и расходы объекта за последние 12 месяцев к текущей стоимости. Валовая — без расходов, чистая — за вычетом расходов.'**
  String get propertyYieldHint;

  /// Нет стоимости/дохода.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно данных для расчёта.'**
  String get propertyYieldUnavailable;

  /// Нет cashflow для доходности.
  ///
  /// In ru, this message translates to:
  /// **'Нет операций за последние 12 месяцев.'**
  String get propertyYieldNoOperations;

  /// Ошибка расчёта доходности.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось рассчитать доходность.'**
  String get propertyYieldError;

  /// Заголовок онбординга.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать'**
  String get onboardingTitle;

  /// Вступление.
  ///
  /// In ru, this message translates to:
  /// **'FinanseApp — локальный учёт финансов: данные хранятся только на устройстве.'**
  String get onboardingIntro;

  /// Приватность.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия не шифруется — храните файл безопасно.'**
  String get onboardingPrivacy;

  /// Валюта.
  ///
  /// In ru, this message translates to:
  /// **'Используется для отчётов и итогов; можно изменить позже в настройках.'**
  String get onboardingBaseCurrency;

  /// CTA старт.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onboardingStart;

  /// Вторая CTA: завершить онбординг, не меняя базовую валюту.
  ///
  /// In ru, this message translates to:
  /// **'Не менять валюту'**
  String get onboardingSkip;

  /// Короткий label выбора валюты.
  ///
  /// In ru, this message translates to:
  /// **'Базовая валюта'**
  String get onboardingCurrencyLabel;

  /// Заголовок вводной секции онбординга.
  ///
  /// In ru, this message translates to:
  /// **'Начало работы'**
  String get onboardingSetupTitle;

  /// Ошибка сохранения настроек онбординга.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить настройки. Попробуйте ещё раз.'**
  String get onboardingSaveError;

  /// Заголовок аудита удалённых записей.
  ///
  /// In ru, this message translates to:
  /// **'Удалённые операции'**
  String get auditTitle;

  /// Таб операций по активам.
  ///
  /// In ru, this message translates to:
  /// **'Операции по активам'**
  String get auditTabAssets;

  /// Таб доходов и расходов.
  ///
  /// In ru, this message translates to:
  /// **'Доходы и расходы'**
  String get auditTabCashflow;

  /// Бейдж удалённой записи.
  ///
  /// In ru, this message translates to:
  /// **'Удалено'**
  String get auditDeletedLabel;

  /// Метка даты удаления в аудите.
  ///
  /// In ru, this message translates to:
  /// **'удалено'**
  String get auditDeletedOn;

  /// Заголовок пустого аудита.
  ///
  /// In ru, this message translates to:
  /// **'Удалённых операций нет'**
  String get auditEmptyTitle;

  /// Пояснение пустого аудита.
  ///
  /// In ru, this message translates to:
  /// **'Удалённые операции и записи попадут сюда, их можно будет восстановить.'**
  String get auditEmptyMessage;

  /// CTA создания банка из формы счёта.
  ///
  /// In ru, this message translates to:
  /// **'Добавить банк'**
  String get bankAddAction;

  /// Удаление нарушает историю баланса.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить: после этой операции остаток счёта станет отрицательным.'**
  String get transactionDeleteBalanceBlocked;

  /// Подтверждение удаления перевода.
  ///
  /// In ru, this message translates to:
  /// **'Удалить перевод?'**
  String get transferDeleteTitle;

  /// Пояснение удаления перевода.
  ///
  /// In ru, this message translates to:
  /// **'Обе операции перевода будут скрыты из журнала, балансы обоих счетов вернутся к прежним значениям. Восстановить можно в «Удалённых операциях».'**
  String get transferDeleteMessage;

  /// Кнопка удаления перевода в деталях.
  ///
  /// In ru, this message translates to:
  /// **'Удалить перевод'**
  String get transferDeleteAction;

  /// Успешное удаление перевода.
  ///
  /// In ru, this message translates to:
  /// **'Перевод удалён.'**
  String get transferDeleted;

  /// Удаление перевода нарушает историю баланса.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить перевод: на одном из двух счетов остаток станет отрицательным. Сначала удалите или измените более поздние операции.'**
  String get transferDeleteBalanceBlocked;

  /// Конфликт при удалении перевода.
  ///
  /// In ru, this message translates to:
  /// **'Перевод уже удалён или повреждён. Обновите журнал.'**
  String get transferDeleteConflict;
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
