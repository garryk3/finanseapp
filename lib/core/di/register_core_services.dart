import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/app_database_path.dart';
import 'package:finanseapp/core/database/daos/assets_dao.dart';
import 'package:finanseapp/core/database/daos/audit_dao.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/database/daos/goals_dao.dart';
import 'package:finanseapp/core/database/daos/references_dao.dart';
import 'package:finanseapp/core/database/daos/settings_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/database/daos/valuations_dao.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';

/// Регистрирует БД, DAO и общие presentation-сервисы.
///
/// Feature-repositories регистрируются в своих задачах вместе с реализациями
/// (3.3 создаёт только контракты). [database] подменяется в тестах.
Future<ServiceLocator> registerCoreServices(
  ServiceLocator locator, {
  AppDatabase? database,
}) async {
  final db = database ?? openAppDatabase();

  locator.register<AppDatabase>(db, dispose: (value) => value.close());
  locator.register<AssetsDao>(db.assetsDao);
  locator.register<ValuationsDao>(db.valuationsDao);
  locator.register<TransactionsDao>(db.transactionsDao);
  locator.register<CashflowDao>(db.cashflowDao);
  locator.register<ReferencesDao>(db.referencesDao);
  locator.register<CurrenciesDao>(db.currenciesDao);
  locator.register<GoalsDao>(db.goalsDao);
  locator.register<SettingsDao>(db.settingsDao);
  locator.register<AuditDao>(db.auditDao);

  locator.register<MoneyFormatter>(const MoneyFormatter());
  locator.register<DateFormatter>(const DateFormatter());

  return locator;
}
