import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/references/domain/subgroup.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/database/converters/decimal_converter.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/local_date_converter.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/daos/assets_dao.dart';
import 'package:finanseapp/core/database/daos/audit_dao.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/database/daos/goals_dao.dart';
import 'package:finanseapp/core/database/daos/references_dao.dart';
import 'package:finanseapp/core/database/daos/settings_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/database/daos/valuations_dao.dart';
import 'package:finanseapp/core/database/seed/seed_data.dart';
import 'package:finanseapp/core/database/tables/app_settings.dart';
import 'package:finanseapp/core/database/tables/asset_details.dart';
import 'package:finanseapp/core/database/tables/asset_transaction_revisions.dart';
import 'package:finanseapp/core/database/tables/asset_transactions.dart';
import 'package:finanseapp/core/database/tables/asset_transfers.dart';
import 'package:finanseapp/core/database/tables/asset_valuations.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/cashflow_entries.dart';
import 'package:finanseapp/core/database/tables/cashflow_entry_revisions.dart';
import 'package:finanseapp/core/database/tables/categories.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';
import 'package:finanseapp/core/database/tables/exchange_rates.dart';
import 'package:finanseapp/core/database/tables/goal_assets.dart';
import 'package:finanseapp/core/database/tables/goals.dart';
import 'package:finanseapp/core/database/tables/subgroups.dart';

part 'app_database.g.dart';

/// Идентификатор формата файла FinanseApp (`FNAP`) для `PRAGMA application_id`.
const appDatabaseApplicationId = 0x464E4150;

/// Схема v1 FinanseApp (data_schema).
///
/// `createdAt`/`updatedAt` берутся из [clock] в UTC, чтобы тесты были
/// детерминированными. Production-путь открывается `openAppDatabase`.
@DriftDatabase(
  tables: [
    Assets,
    AccountDetails,
    InvestmentDetails,
    PropertyDetails,
    AssetValuations,
    AssetTransfers,
    AssetTransactions,
    AssetTransactionRevisions,
    CashflowEntries,
    CashflowEntryRevisions,
    Subgroups,
    Currencies,
    ExchangeRates,
    Categories,
    Goals,
    GoalAssets,
    AppSettings,
  ],
  daos: [
    AssetsDao,
    ValuationsDao,
    TransactionsDao,
    CashflowDao,
    ReferencesDao,
    CurrenciesDao,
    GoalsDao,
    SettingsDao,
    AuditDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({required QueryExecutor executor, DateTime Function()? now})
    : _now = now ?? _utcNow,
      super(executor);

  final DateTime Function() _now;

  /// Текущий UTC-момент для timestamps записи.
  DateTime clock() => _now().toUtc();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final statement in schemaObjectsV1) {
        await customStatement(statement);
      }
      await customStatement(
        'PRAGMA application_id = $appDatabaseApplicationId',
      );
      await ReferenceSeeder.seed(this);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static DateTime _utcNow() => DateTime.now().toUtc();
}

/// Объекты, которые нельзя объявить в Drift-таблицах: частичные unique-индексы
/// и триггеры. `schema dump` их не видит, поэтому тесты проверяют `sqlite_master`.
const schemaObjectsV1 = <String>[
  // Одна активная нога каждого вида на группу перевода.
  'CREATE UNIQUE INDEX asset_transactions_active_transfer_leg '
      'ON asset_transactions (transfer_id, kind) '
      'WHERE deleted_at IS NULL AND transfer_id IS NOT NULL',
  // Одна активная запись денежного потока на операцию актива.
  'CREATE UNIQUE INDEX cashflow_active_asset_link '
      'ON cashflow_entries (asset_transaction_id) '
      'WHERE asset_transaction_id IS NOT NULL AND deleted_at IS NULL',
  // Имя категории уникально внутри вида среди неархивных.
  'CREATE UNIQUE INDEX categories_active_name '
      'ON categories (kind, normalized_name) WHERE archived_at IS NULL',
  // Ревизии append-only.
  'CREATE TRIGGER asset_transaction_revisions_no_update '
      'BEFORE UPDATE ON asset_transaction_revisions BEGIN '
      "SELECT RAISE(ABORT, 'asset transaction revisions are append-only'); END",
  'CREATE TRIGGER asset_transaction_revisions_no_delete '
      'BEFORE DELETE ON asset_transaction_revisions BEGIN '
      "SELECT RAISE(ABORT, 'asset transaction revisions are append-only'); END",
  'CREATE TRIGGER cashflow_entry_revisions_no_update '
      'BEFORE UPDATE ON cashflow_entry_revisions BEGIN '
      "SELECT RAISE(ABORT, 'cashflow revisions are append-only'); END",
  'CREATE TRIGGER cashflow_entry_revisions_no_delete '
      'BEFORE DELETE ON cashflow_entry_revisions BEGIN '
      "SELECT RAISE(ABORT, 'cashflow revisions are append-only'); END",
  // RUB нельзя отключить или удалить (BR-C-4).
  'CREATE TRIGGER currencies_rub_no_disable '
      'BEFORE UPDATE OF is_enabled ON currencies '
      "WHEN OLD.code = 'RUB' AND NEW.is_enabled = 0 BEGIN "
      "SELECT RAISE(ABORT, 'RUB cannot be disabled'); END",
  'CREATE TRIGGER currencies_rub_no_delete '
      'BEFORE DELETE ON currencies '
      "WHEN OLD.code = 'RUB' BEGIN "
      "SELECT RAISE(ABORT, 'RUB cannot be deleted'); END",
  // Дата окончания счёта не раньше даты начала (BR-VAL-6).
  'CREATE TRIGGER account_details_dates_on_insert '
      'BEFORE INSERT ON account_details '
      'WHEN NEW.end_date IS NOT NULL AND NEW.start_date > NEW.end_date BEGIN '
      "SELECT RAISE(ABORT, 'account end date before start date'); END",
  'CREATE TRIGGER account_details_dates_on_update '
      'BEFORE UPDATE ON account_details '
      'WHEN NEW.end_date IS NOT NULL AND NEW.start_date > NEW.end_date BEGIN '
      "SELECT RAISE(ABORT, 'account end date before start date'); END",
];
