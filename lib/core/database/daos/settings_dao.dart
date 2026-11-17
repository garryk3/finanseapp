import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/app_settings.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';
import 'package:finanseapp/core/database/seed/seed_data.dart';
import 'package:finanseapp/core/domain/common/result.dart';

part 'settings_dao.g.dart';

/// Настройки приложения и выбранная базовая валюта.
@DriftAccessor(tables: [AppSettings, Currencies])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<CurrencyRow> watchBaseCurrency() {
    final query = select(currencies).join([
      innerJoin(appSettings, appSettings.value.equalsExp(currencies.code)),
    ])..where(appSettings.key.equals(baseCurrencySettingKey));
    return query.watchSingle().map((row) => row.readTable(currencies));
  }

  Future<CurrencyRow> getBaseCurrency() async {
    final query = select(currencies).join([
      innerJoin(appSettings, appSettings.value.equalsExp(currencies.code)),
    ])..where(appSettings.key.equals(baseCurrencySettingKey));
    final row = await query.getSingleOrNull();
    if (row == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'baseCurrencyCode': 'validationBaseCurrencyMissing'},
      );
    }
    return row.readTable(currencies);
  }

  Future<void> setBaseCurrency(String code) => transaction(() async {
    final currency = await (select(
      currencies,
    )..where((c) => c.code.equals(code))).getSingleOrNull();
    if (currency == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'baseCurrencyCode': 'validationCurrencyNotFound'},
      );
    }
    if (!currency.isEnabled) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'baseCurrencyCode': 'validationCurrencyDisabled'},
      );
    }
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: baseCurrencySettingKey,
        value: code,
        updatedAt: attachedDatabase.clock(),
      ),
    );
  });
}
