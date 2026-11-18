import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/settings_dao.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';

/// Реализация настроек: базовая валюта (BR-C-5); расширяется задачей 10.3.
final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dao);

  final SettingsDao _dao;

  @override
  Stream<Currency> watchBaseCurrency() => _dao.watchBaseCurrency().map(_map);

  @override
  Future<Currency> getBaseCurrency() async =>
      _map(await _dao.getBaseCurrency());

  @override
  Future<void> setBaseCurrency(String code) => _dao.setBaseCurrency(code);

  static Currency _map(CurrencyRow row) => Currency(
    code: row.code,
    name: row.name,
    fractionDigits: row.fractionDigits,
    isPreset: row.isPreset,
    isEnabled: row.isEnabled,
  );
}
