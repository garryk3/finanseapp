import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';

/// Реализация справочника валют поверх `CurrenciesDao`.
final class CurrencyRepositoryImpl implements CurrencyRepository {
  const CurrencyRepositoryImpl(this._dao);

  final CurrenciesDao _dao;

  @override
  Stream<List<Currency>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_map).toList(growable: false));

  @override
  Future<List<Currency>> getEnabled() async =>
      (await _dao.getEnabled()).map(_map).toList(growable: false);

  @override
  Future<int> countReferences(String code) =>
      _dao.countReferences(code, includeRates: false);

  @override
  Future<void> createCustom(String code, String name, int fractionDigits) =>
      _dao.createCustom(code.trim().toUpperCase(), name, fractionDigits);

  @override
  Future<void> rename(String code, String name) => _dao.rename(code, name);

  @override
  Future<void> setEnabled(String code, bool value) =>
      _dao.setEnabled(code, value);

  @override
  Future<void> deleteIfUnused(String code) => _dao.deleteIfUnused(code);

  static Currency _map(CurrencyRow row) => Currency(
    code: row.code,
    name: row.name,
    fractionDigits: row.fractionDigits,
    isPreset: row.isPreset,
    isEnabled: row.isEnabled,
  );
}
