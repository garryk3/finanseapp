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
  String get homeDemoSection => 'Демо состояния';

  @override
  String get counterLabel => 'Счётчик';

  @override
  String get increment => 'Увеличить';

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
}
