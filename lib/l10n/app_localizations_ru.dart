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
  String get assetsEmptyMessage => 'Добавьте счёт, инвестицию или квартиру.';

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
}
