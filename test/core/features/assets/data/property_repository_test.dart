import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/data/asset_repository_impl.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/cashflow/data/cashflow_repository_impl.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late AssetRepositoryImpl assets;
  late CashflowRepositoryImpl cashflow;
  late int expenseCategoryId;

  setUp(() async {
    db = openTestDatabase();
    assets = AssetRepositoryImpl(
      db.assetsDao,
      db.transactionsDao,
      db.valuationsDao,
    );
    cashflow = CashflowRepositoryImpl(db.cashflowDao, db.currenciesDao);
    expenseCategoryId = (await db.select(db.categories).get())
        .firstWhere((row) => row.kind == CashflowKind.expense)
        .id;
  });

  tearDown(() async {
    await db.close();
  });

  PropertyDraft draft({String? address, int? purchase}) => PropertyDraft(
    name: 'Квартира',
    currencyCode: 'RUB',
    openingValue: const Money(minorUnits: 500000000, currencyCode: 'RUB'),
    address: address,
    purchasePrice: purchase == null
        ? null
        : Money(minorUnits: purchase, currencyCode: 'RUB'),
  );

  test('квартира хранит адрес и цену покупки', () async {
    final id = await assets.create(
      draft(address: 'ул. Ленина, 1', purchase: 450000000),
    );

    final snapshot = await assets.getById(id);
    final property = snapshot.asset as PropertyAsset;
    expect(property.address, 'ул. Ленина, 1');
    expect(property.purchasePrice?.minorUnits, 450000000);
    expect(snapshot.currentValue.minorUnits, 500000000);
  });

  test('пустой адрес сохраняется как null, update меняет детали', () async {
    final id = await assets.create(draft(address: '   '));
    expect((await assets.getById(id)).asset, isA<PropertyAsset>());
    expect(((await assets.getById(id)).asset as PropertyAsset).address, isNull);

    await assets.update(id, draft(address: 'Новый адрес', purchase: 400000000));
    final property = (await assets.getById(id)).asset as PropertyAsset;
    expect(property.address, 'Новый адрес');
    expect(property.purchasePrice?.minorUnits, 400000000);

    await assets.update(id, draft());
    final cleared = (await assets.getById(id)).asset as PropertyAsset;
    expect(cleared.address, isNull);
    expect(cleared.purchasePrice, isNull);
  });

  test('оценка меняет стоимость, расход не меняет', () async {
    final id = await assets.create(draft());
    await assets.recordValuation(
      AssetValuationDraft(
        assetId: id,
        effectiveOn: LocalDate(2026, 1, 2),
        value: const Money(minorUnits: 550000000, currencyCode: 'RUB'),
        rateToRub: Decimal.one,
        fractionDigits: 2,
      ),
    );
    expect((await assets.getById(id)).currentValue.minorUnits, 550000000);

    await cashflow.create(
      CashflowEntryDraft(
        kind: CashflowKind.expense,
        categoryId: expenseCategoryId,
        amount: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
        occurredOn: LocalDate(2026, 1, 3),
        rateToRub: Decimal.one,
        affectsBalance: false,
        propertyId: id,
      ),
    );
    expect((await assets.getById(id)).currentValue.minorUnits, 550000000);
  });

  test('cashflow с propertyId связывается с квартирой и фильтруется', () async {
    final id = await assets.create(draft());
    final entryId = await cashflow.create(
      CashflowEntryDraft(
        kind: CashflowKind.expense,
        categoryId: expenseCategoryId,
        amount: const Money(minorUnits: 10000000, currencyCode: 'RUB'),
        occurredOn: LocalDate(2026, 1, 2),
        rateToRub: Decimal.one,
        affectsBalance: false,
        propertyId: id,
        comment: 'Ремонт',
      ),
    );
    final entry = await cashflow.getById(entryId);
    expect(entry.propertyId, id);
    expect(entry.amountRub.minorUnits, 10000000);

    final entries = await cashflow
        .watch(
          CashflowFilter(
            propertyId: id,
            period: DateRange(
              start: LocalDate(2026, 1, 1),
              end: LocalDate(2026, 1, 31),
            ),
          ),
        )
        .first;
    expect(entries, hasLength(1));
  });

  test('propertyId не принимает счёт', () async {
    final accountId = await createAccount(db);
    await expectLater(
      cashflow.create(
        CashflowEntryDraft(
          kind: CashflowKind.expense,
          categoryId: expenseCategoryId,
          amount: const Money(minorUnits: 100, currencyCode: 'RUB'),
          occurredOn: LocalDate(2026, 1, 2),
          rateToRub: Decimal.one,
          affectsBalance: false,
          propertyId: accountId,
        ),
      ),
      throwsA(isA<DomainException>()),
    );
  });
}
