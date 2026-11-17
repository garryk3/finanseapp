import 'package:finanseapp/core/domain/common/currency.dart';

/// Repository валют (domain_model §9).
abstract interface class CurrencyRepository {
  Stream<List<Currency>> watchAll();

  Future<List<Currency>> getEnabled();

  Future<int> countReferences(String code);

  Future<void> createCustom(String code, String name, int fractionDigits);

  Future<void> rename(String code, String name);

  Future<void> setEnabled(String code, bool value);

  Future<void> deleteIfUnused(String code);
}
