import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/settings_dao.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/settings/domain/display_settings_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';

/// Реализация настроек: базовая валюта (BR-C-5) и отображение (D21.4).
final class SettingsRepositoryImpl
    implements SettingsRepository, DisplaySettingsRepository {
  const SettingsRepositoryImpl(this._dao);

  final SettingsDao _dao;

  @override
  Stream<Currency> watchBaseCurrency() => _dao.watchBaseCurrency().map(_map);

  @override
  Future<Currency> getBaseCurrency() async =>
      _map(await _dao.getBaseCurrency());

  @override
  Future<void> setBaseCurrency(String code) => _dao.setBaseCurrency(code);

  @override
  Stream<bool> watchAmountsHidden() => _dao.watchAmountsHidden();

  @override
  Future<bool> getAmountsHidden() => _dao.getAmountsHidden();

  @override
  Future<void> setAmountsHidden(bool hidden) => _dao.setAmountsHidden(hidden);

  static Currency _map(CurrencyRow row) => Currency(
    code: row.code,
    name: row.name,
    fractionDigits: row.fractionDigits,
    isPreset: row.isPreset,
    isEnabled: row.isEnabled,
  );
}
