# Резервное копирование, восстановление и обновления

Контракт переноса функций из FitnessAppAI в FinanseApp. Переносится поведение, а не
пакетные импорты или donor-specific состояние. UI находится на `/more/settings`.

## 1. Скоуп и ограничения

- Полный локальный SQLite snapshot всех таблиц, revisions, справочников и настроек.
- Три действия: «Поделиться», «Сохранить файл», «Импортировать». Облака и автоматического
  фонового backup нет.
- Backup не шифруется: UI предупреждает, что файл содержит финансовые данные и его нужно
  хранить/передавать только доверенным способом.
- Android 12+ — основной сценарий: SAF не требует `MANAGE_EXTERNAL_STORAGE`,
  `READ/WRITE_EXTERNAL_STORAGE` или `REQUEST_INSTALL_PACKAGES`.
- Обновление только по кнопке: GitHub latest release → сравнение версий → внешний browser
  для APK; установка и подтверждение неизвестных источников выполняет Android.
- Тренировки, checkpoint, sounds, notifications, reminders и exercises donor-проекта не
  копируются ни в код, ни в план.

## 2. Зависимости реализационной задачи

Добавить в `pubspec.yaml` версиями, совместимыми с текущим lockfile resolver:

```yaml
path_provider: ^2.1.6
path: ^1.9.1
file_picker: ^10.3.10
share_plus: ^12.0.0
cross_file: ^0.3.5
sqlite3: ^3.5.1
package_info_plus: ^9.0.1
url_launcher: ^6.3.2
```

`url_launcher_platform_interface` и `path_provider_platform_interface` добавляются в
dev_dependencies только если выбранные тестовые doubles используют их platform API.
Прямой импорт `sqlite3` требует прямой production dependency, даже если Drift уже
подтягивает пакет транзитивно. Для GitHub используется `dart:io`, как в donor; отдельный
`http` для этого сервиса не нужен.

## 3. Файлы и границы

```text
lib/app/app_restart.dart
lib/core/database/app_database_path.dart
lib/core/features/backup/domain/backup_service.dart
lib/core/features/backup/domain/backup_exception.dart
lib/core/features/backup/data/local_database_backup_service.dart
lib/core/features/backup/data/backup_file_gateway.dart
lib/core/features/backup/data/platform_backup_file_gateway.dart
lib/core/features/backup/logic/backup_view_model.dart
lib/core/features/settings/domain/update_service.dart
lib/core/features/settings/domain/app_version.dart
lib/core/features/settings/data/github_update_service.dart
lib/core/features/settings/logic/update_check_view_model.dart
lib/core/features/settings/ui/settings_screen.dart
lib/core/features/settings/ui/widgets/backup_section.dart
lib/core/features/settings/ui/widgets/update_section.dart
android/app/src/main/kotlin/com/example/finanseapp/MainActivity.kt
android/app/src/main/AndroidManifest.xml
```

Backup не находится внутри SettingsRepository: это отдельная feature с собственным
жизненным циклом БД. View не импортирует `dart:io`, FilePicker, SharePlus, SQLite или
MethodChannel. Domain не импортирует Flutter/Drift.

## 4. Публичные контракты

```dart
final class BackupFile {
  const BackupFile({required this.path, required this.fileName});
  final String path;
  final String fileName;
}

abstract interface class BackupService {
  Future<BackupFile> exportDatabase();
  Future<void> importDatabase(String sourcePath);
}

enum BackupValidationError {
  notADatabase,
  corrupted,
  schemaNewer,
  notFinanseApp,
  invalidReferences,
}

final class BackupValidationException implements Exception {
  const BackupValidationException(
    this.reason, {
    this.schemaVersion,
    this.installedVersion,
  });
  final BackupValidationError reason;
  final int? schemaVersion;
  final int? installedVersion;
}

enum BackupStorageOperation { export, stage, replace, rollback, reopen }

final class BackupStorageException implements Exception {
  const BackupStorageException(this.operation);
  final BackupStorageOperation operation;
}

enum BackupShareOutcome { shared, cancelled, unavailable }

abstract interface class BackupFileGateway {
  Future<String?> pickDatabase();
  Future<BackupShareOutcome> share(BackupFile file);
  Future<bool> save(BackupFile file, {required String dialogTitle});
}
```

`BackupStorageException.operation` — enum, который UI сопоставляет русским сообщениям.
Пути, SQL и platform exception details не показываются пользователю. Platform gateway
маппит SharePlus result: success→shared, dismissed→cancelled, unavailable→unavailable;
unknown result не считается успешной отправкой.

```dart
final class ReleaseInfo {
  const ReleaseInfo({required this.tagName, this.htmlUrl, this.apkUrl});
  final String tagName;
  final String? htmlUrl;
  final String? apkUrl;
}

abstract interface class UpdateService {
  Future<ReleaseInfo?> fetchLatestRelease();
}

final class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);
  final int major;
  final int minor;
  final int patch;
  factory AppVersion.parse(String value);
}
```

`AppVersion.parse` принимает `1.2.3`, `v1.2.3`, суффикс `-beta`; отсутствующие minor/patch
дополняет нулями. Более трёх numeric components, пустые и отрицательные части —
`FormatException`. Build metadata после `+` отбрасывается. Prerelease precedence не
выдумывается: numeric core сравнивается так же, как в donor.

## 5. Экспорт

1. BackupViewModel атомарно проверяет/устанавливает `isBusy`.
2. Production database path — `<applicationDocuments>/finanseapp.sqlite`.
3. Export file создаётся во временном каталоге с уникальным именем
   `finanseapp_backup_<UTC yyyyMMdd_HHmmss>_<nonce>.sqlite`; существующий файл не
   перезаписывается.
4. На активном Drift connection выполняется `VACUUM INTO` с safely quoted path. Это
   создаёт consistent snapshot и учитывает WAL; рабочая БД остаётся открытой.
5. `share` вызывает `SharePlus.instance.share(ShareParams(files: [XFile(path)]))`.
   shared → exportShared; dismissed → shareCancelled без ошибки; unavailable → shareResultUnknown без ошибки.
   Успех означает только подтверждённый системой результат, не доставку получателю.
6. `save` на Android вызывает channel `com.example.finanseapp/file_saver`, method
   `saveFile(sourcePath, fileName)`. Kotlin открывает `ACTION_CREATE_DOCUMENT` с MIME
   `application/octet-stream`, копирует stream в content URI и возвращает bool.
7. Desktop save использует `FilePicker.platform.saveFile` + `File.copy`. Отмена возвращает
   false. Share unsupported на desktop — локализованная ошибка, а не ложный success.
8. Temporary export cleanup выполняется при следующем запуске/новом export по возрасту,
   но немедленно удалять файл после системного share нельзя: consumer может читать его
   асинхронно. Никогда не удаляется выбранный пользователем destination.

## 6. Импорт и безопасная замена

### 6.1 До закрытия рабочей БД

1. Пользователь подтверждает замену и выбирает `.sqlite`, `.db` или `.sqlite3`.
   При PlatformException повторяется picker `FileType.any`, как в donor.
2. Source копируется в уникальный staging file во временном каталоге; source никогда не
   изменяется. Пустой file и wrong 16-byte `SQLite format 3\0` → notADatabase.
3. Read-only sqlite probe выполняет `PRAGMA integrity_check` (ровно `ok`),
   `PRAGMA application_id`, `PRAGMA user_version`, `PRAGMA foreign_key_check`.
4. FinanseApp задаёт `PRAGMA application_id = 0x464E4150` (`FNAP`) при создании и
   проверяет в `beforeOpen`. Другое значение/0 → notFinanseApp. Это исключает импорт
   FitnessAppAI или произвольной SQLite БД с совпавшим user_version.
5. `user_version < 1` → notFinanseApp; `> installed schemaVersion` → schemaNewer с обеими
   версиями. Более старая поддерживаемая версия допускается к upgrade.
6. Любые rows foreign_key_check → invalidReferences. SqliteException → notADatabase,
   если magic valid, но структура не читается; failed integrity → corrupted.

### 6.2 Candidate, backup и rollback

1. Валидный source копируется в candidate **в каталоге рабочей БД**, чтобы final rename
   был на одной файловой системе. Candidate открывается отдельным AppDatabase, выполняет
   последовательные migrations, integrity/foreign key checks и закрывается.
2. Перед закрытием текущей БД создаётся rollback snapshot через `VACUUM INTO` в том же
   каталоге. Если snapshot не создан, рабочая БД остаётся открытой и импорт прекращается.
3. Текущая БД закрывается через lifecycle owner; streams/ViewModels больше не используются.
4. Current file переименовывается в `.pre-import`; candidate переименовывается в
   `finanseapp.sqlite`. `-wal`/`-shm` старой БД не копируются; после корректного close
   sidecars обрабатываются SQLite. Ни один шаг сначала не удаляет единственную рабочую копию.
5. `onImported` пересоздаёт ServiceLocator, AppDatabase, DAO/repositories/router factories
   и запускает seed только через обычный non-destructive `onCreate`. Пользовательские
   данные импортированной БД не затираются повторным seed.
6. Если rename/reopen/rebuild падает, новый файл закрывается, `.pre-import` либо rollback
   snapshot возвращается на production path, `onRollback` пересоздаёт DI со старой БД.
   Успешный rollback → `importFailed`, прежние данные восстановлены. Если сам rollback или
   последующее открытие прежней БД падает → `restoreFailed`; активность и целостность прежней
   БД не считаются подтверждёнными, backup actions блокируются.
7. После успешного rebuild `.pre-import` и staging удаляются; rollback snapshot можно
   удалить только после подтверждённого открытия. Сбой cleanup не отменяет успешный import.
8. Успех возвращается в старый BackupViewModel только для показа restart dialog. Дальнейшие
   действия выполняются уже против нового DI; factory service берётся заново на действие.

Это намеренное усиление donor-алгоритма `delete → copy`: текущая база не может быть потеряна
между удалением и копированием. Тест обязан инжектировать сбой именно на final replace и
на reopen, а не проверять только happy path.

## 7. BackupViewModel

```dart
enum BackupStatusKind {
  exportShared,
  exportSaved,
  shareCancelled,
  shareResultUnknown,
  saveCancelled,
  importDone,
  exportFailed,
  importFailed,
  restoreFailed,
}

final class BackupState {
  const BackupState({
    this.isBusy = false,
    this.status,
    this.validationError,
    this.storageError,
  });
  final bool isBusy;
  final BackupStatusKind? status;
  final BackupValidationException? validationError;
  final BackupStorageException? storageError;
}

final class BackupViewModel {
  BackupViewModel({
    required BackupService Function() serviceFactory,
    required BackupFileGateway files,
  });
  Signal<BackupState> get state;
  Future<bool> exportShared();
  Future<bool> exportSaved({required String dialogTitle});
  Future<bool> importSelected();
  void dispose();
}
```

- Все методы при busy немедленно возвращают false и не вызывают gateway.
- Отмена pick оставляет status null; save cancel → saveCancelled, share dismissed →
  shareCancelled, unavailable → shareResultUnknown с сообщением «Файл подготовлен. Результат
  отправки неизвестен»; все три состояния нейтральны и не имеют error semantics.
  Exception или unsupported platform → exportFailed.
- Validation exception сохраняется typed. Storage exception сохраняется в storageError:
  replace/reopen с успешным rollback → importFailed и сообщение «Импорт не выполнен,
  прежние данные восстановлены»; rollback failure → restoreFailed.
- `restoreFailed` — blocking critical state, а не обычная import error: «Не удалось
  автоматически восстановить прежние данные. Не вводите новые данные и не повторяйте
  импорт. Rollback-файл сохранён на устройстве». Backup actions disabled; безопасное
  действие — закрыть приложение системными средствами и выполнить техническое восстановление
  сохранённого rollback-файла. UI не утверждает, что прежняя БД активна.
- `isBusy` сбрасывается в finally, включая picker/share/save exceptions. Состояние
  restoreFailed не очищается автоматически следующим tap.
- FinanseApp не имеет checkpoint clearing; после успешного import только полный app restart.

## 8. Перезапуск после импорта

`app/app_restart.dart` содержит `ValueNotifier<int> appRestartTick` и `restartApp()`.
Root Stateful owner слушает tick, пересоздаёт `FinanseApp` с `ValueKey(tick)` и новым
router, не переиспользуя старые ViewModel/Streams. ServiceLocator имеет явные
`reset/rebuild` с ожиданием `close` и unregister старых синглтонов; простой `map.clear()`
без close запрещён.

После успешного import показывается один nondismissible dialog. Кнопка OK вызывает
`restartApp`, переход на `/`, после чего Dashboard читает импортированные данные. Авто-
restart в середине DB transaction и повторный restart по rebuild запрещены.

## 9. GitHub Updates

```text
API: https://api.github.com/repos/garryk3/finanseapp/releases/latest
APK: https://github.com/garryk3/finanseapp/releases/latest/download/app-release.apk
```

- Accept `application/vnd.github+json`, User-Agent `FinanseApp-Update-Check`; connect и
  response timeout по 10 секунд. Тело ограничивается разумным HTTP response handling и
  декодируется UTF-8 JSON.
- 404 → null/noReleases; не-200 → HttpException; отсутствует nonempty `tag_name` →
  checkFailed, а не актуальная версия. `html_url` принимается только как valid http(s),
  итоговый opener разрешает **только HTTPS**.
- APK URL фиксирован release asset `app-release.apk`; release workflow обязан публиковать
  именно его. Произвольные URLs из JSON не исполняются и не скачиваются в приложение.
- `UpdateCheckViewModel.loadVersion()` использует PackageInfo. `checkForUpdates()` не
  допускает parallel calls, сравнивает `AppVersion`, хранит ReleaseInfo для openUpdate.
- `openUpdate()` сначала APK, при ошибке — html release page. `canLaunchUrl == false`,
  launch false/exception обеих ссылок → openFailed. Отсутствие ReleaseInfo — no-op.
- Statuses: `updateAvailable`, `upToDate`, `noReleases`, `networkError`, `checkFailed`,
  `openFailed`. `noReleases` — информационное состояние, не красная ошибка.
- SocketException/TimeoutException/HttpException → networkError; malformed JSON/version →
  checkFailed. Version loader failure показывает «Версия недоступна», но check может
  повторить загрузку; при неудаче не сравнивает пустую строку как 0.0.0.

## 10. Android configuration

- Manifest: `<uses-permission android:name="android.permission.INTERNET"/>`.
- `<queries>` содержит VIEW intent с `<data android:scheme="https"/>` для url_launcher.
- MainActivity содержит только file_saver channel из FinanseApp; battery channel donor не
  переносится. Один pending save result: повторный save пока pending != null возвращает
  `ALREADY_PENDING`, а не перезаписывает callback.
- `onActivityResult` очищает pending result/source при cancel, error и success; null/closed
  output stream → false/error, не молчаливый hung Future.
- Канал использует package `com.example.finanseapp`; смена applicationId потребует
  синхронного изменения channel namespace и теста.

## 11. Обязательные тесты

### Local service на реальных temp SQLite files

- Export содержит marker asset + revision и оставляет исходную БД открытой.
- Valid import заменяет marker и вызывает onImported один раз.
- Wrong magic/empty JSON с `.sqlite`, corrupt SQLite, other application_id,
  user_version 0/installed+1, FK violation отклоняются до close; исходные данные доступны.
- Older supported schema мигрируется на candidate; production path меняется только после
  успешной миграции.
- Сбой candidate copy/final rename/reopen возвращает прежнюю БД; onRollback вызван,
  onImported success не показан, UI получает `importFailed` и подтверждённое восстановление
  прежних данных. Сбой cleanup не превращает success в failure.
- Injected rollback failure и rollback-reopen failure дают `restoreFailed`: тест не утверждает,
  что прежняя БД активна; rollback-файл сохраняется, backup actions disabled, повторный tap
  не очищает blocking state. Доступное безопасное действие описано как закрытие приложения.
- Export во время записи даёт consistent snapshot; import busy исключает второй import.

### ViewModels и platform doubles

- Save cancel, pick cancel, share dismissed → `shareCancelled` без error semantics,
  share unavailable → `shareResultUnknown` без error semantics и с текстом о неизвестном
  результате, share exception/unsupported platform → `exportFailed`, save/pick exception,
  double tap и typed validation states. Успешный rollback показывает `importFailed` и доступность
  прежних данных; rollback failure показывает `restoreFailed` без такого утверждения.
- Update: `v1.1.0 > 1.0.0`, `1.0.10 > 1.0.9`, same/older/beta/malformed, 404/500,
  timeout/offline, APK fallback и обе ссылки failed, non-HTTPS rejected.
- Settings widget: три backup actions, warning перед picker, restart только после success,
  version/status и pending buttons; Semantics нейтральной отмены share, неизвестного результата
  отправки, успешного rollback и blocking rollback failure различимы; при `restoreFailed`
  все backup actions disabled;
  font scale 1.3, long Russian strings, dark/light.
- Android SAF проверяется instrumented/manual сценарием: save, overwrite existing document,
  cancel, unavailable activity. Browser APK и release fallback — на Android device.

### End-to-end

Создать уникальный актив → export → изменить/удалить marker → import → restart → marker
и revisions восстановлены. Невалидный файл оставляет изменённые данные нетронутыми. Update
network тестируется fake HTTP в unit/widget, production GitHub проверяется отдельным ручным
сценарием без зависимости CI от сети.
