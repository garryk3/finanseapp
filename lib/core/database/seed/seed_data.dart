import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/validation.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';

/// Пять предустановленных валют (BR-C-8, business_rules §13).
const presetCurrencies = <({String code, String name, int fractionDigits})>[
  (code: 'RUB', name: 'Российский рубль', fractionDigits: 2),
  (code: 'CNY', name: 'Китайский юань', fractionDigits: 2),
  (code: 'EUR', name: 'Евро', fractionDigits: 2),
  (code: 'USD', name: 'Доллар США', fractionDigits: 2),
  (code: 'HKD', name: 'Гонконгский доллар', fractionDigits: 2),
];

/// Предустановленные категории доходов.
const presetIncomeCategories = <String>[
  'Зарплата',
  'Аренда',
  'Проценты по вкладу',
  'Дивиденды',
  'Подарки',
  'Прочие доходы',
];

/// Предустановленные категории расходов.
const presetExpenseCategories = <String>[
  'Питание',
  'Аренда жилья',
  'Содержание помещения',
  'Коммунальные платежи',
  'Ремонт',
  'Налоги',
  'Транспорт',
  'Здоровье',
  'Развлечения',
  'Прочие расходы',
];

/// Ключ базовой валюты в `app_settings` (BR-C-5).
const baseCurrencySettingKey = 'baseCurrencyCode';

/// Ключ настройки «скрывать суммы при входе» в `app_settings` (D21.4).
///
/// Значение — `'true'`/`'false'`; отсутствие ключа трактуется как `false`.
const amountsHiddenSettingKey = 'amountsHidden';

/// Ключ ставки налога с процентов по вкладам в `app_settings` (D21.6/X2).
///
/// Значение — целое число `0..100`; отсутствие ключа трактуется как дефолт.
const taxRatePercentSettingKey = 'taxRatePercent';

/// Начальные справочники v1.
///
/// Идемпотентен: повторный запуск не создаёт дублей и не перезаписывает
/// rename/archive категорий и выбранную базовую валюту.
abstract final class ReferenceSeeder {
  static Future<void> seed(AppDatabase db) async {
    final now = db.clock();

    for (final currency in presetCurrencies) {
      await db
          .into(db.currencies)
          .insert(
            CurrenciesCompanion.insert(
              code: currency.code,
              name: currency.name,
              normalizedName: normalizeEntityName(currency.name),
              fractionDigits: currency.fractionDigits,
              isPreset: const Value(true),
              isEnabled: const Value(true),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    // Сид категорий выполняется только на пустой таблице: rename/archive
    // пользователя не воскрешаются и не дублируются.
    final categoriesExist = (await db.select(db.categories).get()).isNotEmpty;
    if (!categoriesExist) {
      for (final name in presetIncomeCategories) {
        await _insertCategory(db, CashflowKind.income, name);
      }
      for (final name in presetExpenseCategories) {
        await _insertCategory(db, CashflowKind.expense, name);
      }
    }

    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            key: baseCurrencySettingKey,
            value: 'RUB',
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  static Future<void> _insertCategory(
    AppDatabase db,
    CashflowKind kind,
    String name,
  ) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          kind: kind,
          name: name,
          normalizedName: normalizeEntityName(name),
          isPreset: const Value(true),
        ),
      );
}
