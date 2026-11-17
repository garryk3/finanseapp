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

  /// Заголовок секции демо-счётчика на домашнем экране.
  ///
  /// In ru, this message translates to:
  /// **'Демо состояния'**
  String get homeDemoSection;

  /// Подпись значения демо-счётчика.
  ///
  /// In ru, this message translates to:
  /// **'Счётчик'**
  String get counterLabel;

  /// Кнопка увеличения демо-счётчика.
  ///
  /// In ru, this message translates to:
  /// **'Увеличить'**
  String get increment;

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
