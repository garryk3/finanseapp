import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class FakeCashflow implements CashflowRepository {
  @override
  Stream<List<CashflowEntry>> watchDeleted() => const Stream.empty();

  FakeCashflow(this.entries);

  final List<CashflowEntry> entries;

  @override
  Stream<List<CashflowEntry>> watch(CashflowFilter filter) {
    final search = filter.query.toLowerCase();
    return Stream.value([
      for (final entry in entries)
        if ((filter.kind == null || entry.kind == filter.kind) &&
            (filter.categoryId == null ||
                entry.categoryId == filter.categoryId) &&
            (search.isEmpty ||
                (entry.comment ?? '').toLowerCase().contains(search)))
          entry,
    ]);
  }

  @override
  Future<CashflowEntry> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(CashflowEntryDraft draft) async => 1;

  @override
  Future<int> createLinked(
    CashflowEntryDraft draft, {
    required int assetTransactionId,
  }) async => 1;

  @override
  Future<void> revise(int id, CashflowEntryDraft draft) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> restore(int id) async {}
}

final class FakeCategories implements CategoryRepository {
  @override
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  }) => Stream.value([
    CashflowCategory(
      id: kind == CashflowKind.income ? 10 : 20,
      kind: kind,
      name: kind == CashflowKind.income ? 'Зарплата' : 'Продукты',
      isPreset: true,
    ),
  ]);

  @override
  Future<int> create(CashflowCategoryDraft draft) async => 1;

  @override
  Future<void> update(CashflowCategory category) async {}

  @override
  Future<int> countEntries(int id) async => 0;

  @override
  Future<void> archive(int id) async {}

  @override
  Future<void> moveEntriesAndDelete(int id, int targetId) async {}

  @override
  Future<void> deleteIfUnused(int id) async {}
}

final class FakeCurrencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub];

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(
    String code,
    String name,
    int fractionDigits,
  ) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class FakeAssets implements AssetRepository {
  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value(const []);

  @override
  Stream<AssetSnapshot?> watchById(int id) => const Stream.empty();

  @override
  Future<AssetSnapshot> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(AssetDraft draft) async => 1;

  @override
  Future<void> update(int id, AssetDraft draft) async {}

  @override
  Future<void> deleteIfUnused(int id) async {}

  @override
  Future<void> archive(int id) async {}

  @override
  Future<void> recordValuation(AssetValuationDraft draft) async {}

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) =>
      throw UnimplementedError();

  @override
  Future<List<AssetValuation>> valuations(int id) async => const [];
}

void main() {
  testWidgets('пустой фильтр даёт reset и восстанавливает журнал', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final vm = CashflowViewModel(
      repository: FakeCashflow([
        CashflowEntry(
          id: 1,
          kind: CashflowKind.expense,
          categoryId: 20,
          amount: const Money(minorUnits: 10000, currencyCode: 'RUB'),
          occurredOn: LocalDate(2026, 1, 2),
          rateToRub: Decimal.one,
          amountRub: const Money(minorUnits: 10000, currencyCode: 'RUB'),
          affectsBalance: false,
          revisionNo: 1,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ]),
      categoryRepository: FakeCategories(),
      currencyRepository: FakeCurrencies(),
      assetRepository: FakeAssets(),
      today: LocalDate(2026, 1, 3),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: CashflowScreen(viewModel: vm, onTabChanged: (_) {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Продукты'), findsOneWidget);

    await tester.tap(find.text(l10n.cashflowIncome));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.cashflowFilteredEmptyTitle), findsOneWidget);
    expect(find.text(l10n.cashflowEmptyTitle), findsNothing);

    await tester.tap(find.text(l10n.cashflowResetFilters).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Продукты'), findsOneWidget);
  });
}
