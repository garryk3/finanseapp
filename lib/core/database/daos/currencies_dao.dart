import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/tables/currencies.dart';
import 'package:finanseapp/core/database/tables/exchange_rates.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/cashflow_entries.dart';
import 'package:finanseapp/core/database/tables/goals.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/domain/common/validation.dart';

part 'currencies_dao.g.dart';

/// Валюты и кэш курсов к рублю (data_schema §6).
@DriftAccessor(
  tables: [Currencies, ExchangeRates, Assets, CashflowEntries, Goals],
)
class CurrenciesDao extends DatabaseAccessor<AppDatabase>
    with _$CurrenciesDaoMixin {
  CurrenciesDao(super.db);

  Stream<List<CurrencyRow>> watchAll() =>
      (select(currencies)..orderBy([(c) => OrderingTerm.asc(c.code)])).watch();

  Future<List<CurrencyRow>> getEnabled() =>
      (select(currencies)
            ..where((c) => c.isEnabled.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.code)]))
          .get();

  Future<CurrencyRow?> find(String code) =>
      (select(currencies)..where((c) => c.code.equals(code))).getSingleOrNull();

  Future<int> countReferences(String code) async {
    final result = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM assets WHERE currency_code = ?1) + '
      '(SELECT COUNT(*) FROM cashflow_entries WHERE currency_code = ?1) + '
      '(SELECT COUNT(*) FROM goals WHERE currency_code = ?1) + '
      '(SELECT COUNT(*) FROM exchange_rates WHERE currency_code = ?1) + '
      '(SELECT COUNT(*) FROM app_settings '
      "WHERE key = 'baseCurrencyCode' AND value = ?1) "
      'AS total',
      variables: [Variable<String>(code)],
    ).getSingle();
    return result.read<int>('total');
  }

  /// Создаёт пользовательскую валюту (BR-C-8): код — три заглавные буквы.
  Future<void> createCustom(String code, String name, int fractionDigits) =>
      transaction(() async {
        if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'code': 'validationCurrencyCodeFormat'},
          );
        }
        final trimmed = _requireName(name);
        await _requireCurrencyUnique(trimmed.normalized);
        if (fractionDigits < 0 || fractionDigits > 8) {
          throw const DomainException(
            DomainErrorCode.validation,
            fieldErrors: {'fractionDigits': 'validationFractionDigitsRange'},
          );
        }
        await into(currencies).insert(
          CurrenciesCompanion.insert(
            code: code,
            name: trimmed.display,
            normalizedName: trimmed.normalized,
            fractionDigits: fractionDigits,
            isPreset: const Value(false),
            isEnabled: const Value(true),
          ),
        );
      });

  Future<void> rename(String code, String name) => transaction(() async {
    final trimmed = _requireName(name);
    await _requireCurrencyUnique(trimmed.normalized, exceptCode: code);
    final updated =
        await (update(currencies)..where((c) => c.code.equals(code))).write(
          CurrenciesCompanion(
            name: Value(trimmed.display),
            normalizedName: Value(trimmed.normalized),
          ),
        );
    if (updated == 0) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'code': 'validationCurrencyNotFound'},
      );
    }
  });

  Future<void> setEnabled(String code, bool value) => transaction(() async {
    if (code == 'RUB' && !value) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'code': 'validationRubProtected'},
      );
    }
    if (!value && await countReferences(code) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'code': 'validationCurrencyInUse'},
      );
    }
    final updated =
        await (update(currencies)..where((c) => c.code.equals(code))).write(
          CurrenciesCompanion(isEnabled: Value(value)),
        );
    if (updated == 0) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'code': 'validationCurrencyNotFound'},
      );
    }
  });

  Future<void> deleteIfUnused(String code) => transaction(() async {
    if (code == 'RUB') {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'code': 'validationRubProtected'},
      );
    }
    if (await countReferences(code) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'code': 'validationCurrencyInUse'},
      );
    }
    final deleted = await (delete(
      currencies,
    )..where((c) => c.code.equals(code))).go();
    if (deleted == 0) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'code': 'validationCurrencyNotFound'},
      );
    }
  });

  Future<ExchangeRateRow?> findRate(String currencyCode, LocalDate date) =>
      (select(exchangeRates)..where(
            (r) =>
                r.currencyCode.equals(currencyCode) & r.date.equalsValue(date),
          ))
          .getSingleOrNull();

  /// Ручной ввод курса: RUB не кэшируется, курс должен быть положительным.
  Future<ExchangeRateRow> saveManualRate(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => transaction(() async {
    if (currencyCode == 'RUB') {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'currencyCode': 'validationRubRateFixed'},
      );
    }
    if (rateToRub <= Decimal.zero) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'rate': 'validationRatePositive'},
      );
    }
    if (await find(currencyCode) == null) {
      throw const DomainException(
        DomainErrorCode.notFound,
        fieldErrors: {'currencyCode': 'validationCurrencyNotFound'},
      );
    }
    final existing = await findRate(currencyCode, date);
    final now = attachedDatabase.clock();
    if (existing == null) {
      final id = await into(exchangeRates).insert(
        ExchangeRatesCompanion.insert(
          currencyCode: currencyCode,
          date: date,
          rateToRub: rateToRub,
          source: ExchangeRateSource.manual,
          fetchedAt: now,
        ),
      );
      return (select(exchangeRates)..where((r) => r.id.equals(id))).getSingle();
    }
    await (update(exchangeRates)..where((r) => r.id.equals(existing.id))).write(
      ExchangeRatesCompanion(
        rateToRub: Value(rateToRub),
        source: const Value(ExchangeRateSource.manual),
        fetchedAt: Value(now),
      ),
    );
    return (select(
      exchangeRates,
    )..where((r) => r.id.equals(existing.id))).getSingle();
  });

  static ({String display, String normalized}) _requireName(String name) {
    final display = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (display.isEmpty) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'name': 'validationNameRequired'},
      );
    }
    return (display: display, normalized: normalizeEntityName(display));
  }

  /// Unique normalizedName среди активных валют (BR-C-8).
  Future<void> _requireCurrencyUnique(
    String normalized, {
    String? exceptCode,
  }) async {
    final query = select(currencies)
      ..where(
        (c) =>
            c.normalizedName.equals(normalized) &
            c.isEnabled.equals(true) &
            (exceptCode == null
                ? const Constant(true)
                : c.code.equals(exceptCode).not()),
      )
      ..limit(1);
    if (await query.getSingleOrNull() != null) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'name': 'validationCurrencyDuplicate'},
      );
    }
  }
}
