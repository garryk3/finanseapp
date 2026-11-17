import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/references/domain/subgroup.dart';

/// Фиксированный UTC-clock для детерминированных timestamps в тестах.
DateTime testNow() => DateTime.utc(2026, 11, 17, 12, 0, 0);

/// Открывает in-memory БД с production-миграцией и seed.
AppDatabase openTestDatabase() =>
    AppDatabase(executor: NativeDatabase.memory(), now: testNow);

Future<int> _ensureSubgroup(
  AppDatabase db,
  SubgroupKind kind,
  String name,
) async {
  final normalized = name.toLowerCase();
  final existing =
      await (db.select(db.subgroups)..where(
            (s) =>
                s.kind.equalsValue(kind) & s.normalizedName.equals(normalized),
          ))
          .getSingleOrNull();
  return existing?.id ?? await db.referencesDao.createSubgroup(kind, name);
}

Future<int> createAccount(
  AppDatabase db, {
  String name = 'Счёт',
  String currencyCode = 'RUB',
  int openingValueMinor = 0,
  int? bankId,
}) async {
  final bank = bankId ?? await _ensureSubgroup(db, SubgroupKind.bank, 'Банк');
  return db.assetsDao.create(
    name: name,
    kind: AssetKind.account,
    currencyCode: currencyCode,
    openingValueMinor: openingValueMinor,
    account: AccountDetailsCompanion.insert(
      bankId: bank,
      annualRate: Decimal.zero,
      startDate: LocalDate(2026, 1, 1),
    ),
  );
}

Future<int> createInvestment(
  AppDatabase db, {
  String name = 'Инвестиция',
  String currencyCode = 'RUB',
  int openingValueMinor = 0,
}) async {
  final broker = await _ensureSubgroup(db, SubgroupKind.broker, 'Брокер');
  return db.assetsDao.create(
    name: name,
    kind: AssetKind.investment,
    currencyCode: currencyCode,
    openingValueMinor: openingValueMinor,
    investment: InvestmentDetailsCompanion.insert(brokerId: broker),
  );
}

Future<int> createProperty(
  AppDatabase db, {
  String name = 'Квартира',
  String currencyCode = 'RUB',
  int openingValueMinor = 0,
}) => db.assetsDao.create(
  name: name,
  kind: AssetKind.property,
  currencyCode: currencyCode,
  openingValueMinor: openingValueMinor,
  property: const PropertyDetailsCompanion(),
);

Future<int> categoryId(AppDatabase db, CashflowKind kind) async {
  final row =
      await (db.select(db.categories)
            ..where((c) => c.kind.equalsValue(kind))
            ..limit(1))
          .getSingle();
  return row.id;
}
