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

  /// Ссылки на валюту; кэш курсов не считается использованием (BR-C-4),
  /// поэтому для disable/delete передаётся `includeRates: false`.
  Future<int> countReferences(String code, {bool includeRates = true}) async {
    final ratesSql = includeRates
        ? '(SELECT COUNT(*) FROM exchange_rates WHERE currency_code = ?1) + '
        : '';
    final result = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM assets WHERE currency_code = ?1) + '
      '(SELECT COUNT(*) FROM cashflow_entries WHERE currency_code = ?1) + '
      '(SELECT COUNT(*) FROM asset_transactions t '
      'JOIN assets a ON a.id = t.asset_id '
      'WHERE COALESCE(t.currency_code, a.currency_code) = ?1) + '
      '(SELECT COUNT(*) FROM asset_valuations v '
      'JOIN assets a ON a.id = v.asset_id '
      'WHERE COALESCE(v.currency_code, a.currency_code) = ?1) + '
      '(SELECT COUNT(*) FROM investment_locked_amounts '
      'WHERE currency_code = ?1) + '
      '(SELECT COUNT(*) FROM goals WHERE currency_code = ?1) + '
      '$ratesSql'
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
        if (await find(code) != null) {
          throw const DomainException(
            DomainErrorCode.conflict,
            fieldErrors: {'code': 'validationCurrencyDuplicate'},
          );
        }
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
    if (!value && await countReferences(code, includeRates: false) > 0) {
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
    if (await countReferences(code, includeRates: false) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'code': 'validationCurrencyInUse'},
      );
    }
    // Кэш курсов не блокирует удаление: чистим его в той же транзакции.
    await (delete(
      exchangeRates,
    )..where((r) => r.currencyCode.equals(code))).go();
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

  /// Сохранённый/ручной курс, связанный с операцией или оценкой, неизменяем
  /// (BR-C-3); ручной курс не перезаписывается ответом ЦБ.
  Future<ExchangeRateRow> saveRate({
    required String currencyCode,
    required LocalDate date,
    required Decimal rateToRub,
    required ExchangeRateSource source,
  }) => transaction(() async {
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
    if (existing != null) {
      if (existing.source == ExchangeRateSource.manual &&
          source == ExchangeRateSource.cbr) {
        return existing;
      }
      if (await countRateReferences(currencyCode, date) > 0) {
        throw const DomainException(
          DomainErrorCode.conflict,
          fieldErrors: {'rate': 'validationRateImmutable'},
        );
      }
      await (update(
        exchangeRates,
      )..where((r) => r.id.equals(existing.id))).write(
        ExchangeRatesCompanion(
          rateToRub: Value(rateToRub),
          source: Value(source),
          fetchedAt: Value(attachedDatabase.clock()),
        ),
      );
      return (select(
        exchangeRates,
      )..where((r) => r.id.equals(existing.id))).getSingle();
    }

    final id = await into(exchangeRates).insert(
      ExchangeRatesCompanion.insert(
        currencyCode: currencyCode,
        date: date,
        rateToRub: rateToRub,
        source: source,
        fetchedAt: attachedDatabase.clock(),
      ),
    );
    return (select(exchangeRates)..where((r) => r.id.equals(id))).getSingle();
  });

  /// Сколько операций/оценок используют курс валюты на дату.
  Future<int> countRateReferences(String currencyCode, LocalDate date) async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM asset_transactions t '
      'JOIN assets a ON a.id = t.asset_id '
      'WHERE COALESCE(t.currency_code, a.currency_code) = ?1 '
      'AND t.occurred_on = ?2) + '
      '(SELECT COUNT(*) FROM cashflow_entries '
      'WHERE currency_code = ?1 AND occurred_on = ?2) + '
      '(SELECT COUNT(*) FROM asset_valuations v '
      'JOIN assets a ON a.id = v.asset_id '
      'WHERE COALESCE(v.currency_code, a.currency_code) = ?1 '
      'AND v.effective_on = ?2) AS total',
      variables: [
        Variable<String>(currencyCode),
        Variable<String>(date.toIsoString()),
      ],
    ).getSingle();
    return row.read<int>('total');
  }

  /// Ручной ввод курса: RUB не кэшируется, курс должен быть положительным.
  Future<ExchangeRateRow> saveManualRate(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => saveRate(
    currencyCode: currencyCode,
    date: date,
    rateToRub: rateToRub,
    source: ExchangeRateSource.manual,
  );

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
