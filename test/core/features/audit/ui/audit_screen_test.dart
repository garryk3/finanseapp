import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/audit/ui/audit_screen.dart';
import 'package:finanseapp/core/features/audit/ui/audit_view_model.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final class _Currencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub];

  @override
  Future<int> countReferences(String code) async => 0;

  @override
  Future<void> createCustom(String code, String name, int digits) async {}

  @override
  Future<void> rename(String code, String name) async {}

  @override
  Future<void> setEnabled(String code, bool value) async {}

  @override
  Future<void> deleteIfUnused(String code) async {}
}

final class _Transactions implements AssetTransactionRepository {
  _Transactions(this.items);

  final List<AssetTransaction> items;

  @override
  Stream<List<AssetTransaction>> watchDeleted() => Stream.value(items);

  @override
  Stream<List<AssetTransaction>> watch(TransactionFilter filter) =>
      const Stream.empty();

  @override
  Future<AssetTransaction> getById(int id) async => items.first;

  @override
  Future<int> create(AssetTransactionDraft draft) async => 0;

  @override
  Future<void> revise(int id, AssetTransactionDraft draft) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> restore(int id) async {}

  @override
  Future<void> restoreTransfer(int transferId) async {}

  @override
  Future<int> transfer(TransferDraft draft) async => 0;

  @override
  Future<void> reviseTransfer(int transferId, TransferDraft draft) async {}

  @override
  Future<void> softDeleteTransfer(int transferId) async {}
}

final class _Cashflow implements CashflowRepository {
  _Cashflow(this.items);

  final List<CashflowEntry> items;

  @override
  Stream<List<CashflowEntry>> watchDeleted() => Stream.value(items);

  @override
  Stream<List<CashflowEntry>> watch(CashflowFilter filter) =>
      const Stream.empty();

  @override
  Future<CashflowEntry> getById(int id) async => items.first;

  @override
  Future<int> create(CashflowEntryDraft draft) async => 0;

  @override
  Future<int> createLinked(
    CashflowEntryDraft draft, {
    required int assetTransactionId,
  }) async => 0;

  @override
  Future<void> revise(int id, CashflowEntryDraft draft) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> restore(int id) async {}
}

final class _Assets implements AssetRepository {
  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([
        AssetSnapshot(
          asset: AccountAsset(
            id: 1,
            name: 'Счёт',
            currencyCode: 'RUB',
            openingValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
            bankId: 0,
            annualRate: Decimal.zero,
            startDate: LocalDate(2026, 1, 1),
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
        ),
      ]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => const Stream.empty();

  @override
  Future<AssetSnapshot> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(AssetDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(int id, AssetDraft draft) => throw UnimplementedError();

  @override
  Future<void> deleteIfUnused(int id) => throw UnimplementedError();

  @override
  Future<void> archive(int id) => throw UnimplementedError();

  @override
  Future<void> recordValuation(AssetValuationDraft draft) =>
      throw UnimplementedError();

  @override
  Future<AssetReferenceCounts> referenceCounts(int id) =>
      throw UnimplementedError();

  @override
  Future<List<AssetValuation>> valuations(int id) => throw UnimplementedError();
}

final class _Categories implements CategoryRepository {
  @override
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  }) => Stream.value([
    CashflowCategory(id: 1, kind: kind, name: 'Коммуналка', isPreset: true),
  ]);

  @override
  Future<int> create(CashflowCategoryDraft draft) => throw UnimplementedError();

  @override
  Future<void> update(CashflowCategory category) => throw UnimplementedError();

  @override
  Future<int> countEntries(int id) => throw UnimplementedError();

  @override
  Future<void> archive(int id) => throw UnimplementedError();

  @override
  Future<void> moveEntriesAndDelete(int id, int targetId) =>
      throw UnimplementedError();

  @override
  Future<void> deleteIfUnused(int id) => throw UnimplementedError();
}

AssetTransaction _transaction({
  int id = 1,
  AssetTransactionKind kind = AssetTransactionKind.deposit,
  String? comment,
}) => AssetTransaction(
  id: id,
  assetId: 1,
  kind: kind,
  amount: const Money(minorUnits: 50000, currencyCode: 'RUB'),
  occurredOn: LocalDate(2026, 11, 20),
  rateToRub: Decimal.one,
  amountRub: const Money(minorUnits: 50000, currencyCode: 'RUB'),
  revisionNo: 2,
  createdAt: DateTime.utc(2026, 11, 20),
  updatedAt: DateTime.utc(2026, 11, 21),
  comment: comment,
  deletedAt: DateTime.utc(2026, 11, 21),
);

CashflowEntry _entry({int id = 1, String? comment, int? assetTransactionId}) =>
    CashflowEntry(
      id: id,
      kind: CashflowKind.expense,
      categoryId: 1,
      amount: const Money(minorUnits: 120000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 11, 19),
      rateToRub: Decimal.one,
      amountRub: const Money(minorUnits: 120000, currencyCode: 'RUB'),
      affectsBalance: true,
      revisionNo: 2,
      createdAt: DateTime.utc(2026, 11, 19),
      updatedAt: DateTime.utc(2026, 11, 21),
      comment: comment,
      assetTransactionId: assetTransactionId,
      deletedAt: DateTime.utc(2026, 11, 21),
    );

Widget _app(AuditViewModel viewModel) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => AuditScreen(viewModel: viewModel),
      ),
      GoRoute(
        path: '/more/audit/asset-transactions/:id',
        builder: (context, state) =>
            const MaterialApp(home: AppText('аудит операции')),
      ),
      GoRoute(
        path: '/more/audit/cashflow/:id',
        builder: (context, state) =>
            const MaterialApp(home: AppText('аудит записи')),
      ),
    ],
  );
  return MaterialApp.router(
    theme: AppTheme.light(),
    routerConfig: router,
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      AppLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ru')],
  );
}

void main() {
  late AppLocalizations l10n;

  test('аудит скрывает записи, связанные с активной операцией', () async {
    final viewModel = AuditViewModel(
      transactionRepository: _Transactions([
        _transaction(id: 1),
        _transaction(id: 2),
      ]),
      cashflowRepository: _Cashflow([
        _entry(id: 1, assetTransactionId: 7),
        _entry(id: 2, assetTransactionId: 1),
        _entry(id: 3),
      ]),
      currencyRepository: _Currencies(),
      assetRepository: _Assets(),
      categoryRepository: _Categories(),
    );
    addTearDown(viewModel.dispose);

    await viewModel.load();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.entries.value, hasLength(3));
    expect(viewModel.restorableEntries.map((entry) => entry.id), [2, 3]);
  });

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('аудит показывает удалённые операции и открывает детали', (
    tester,
  ) async {
    final viewModel = AuditViewModel(
      transactionRepository: _Transactions([_transaction(comment: 'Старая')]),
      cashflowRepository: _Cashflow([_entry()]),
      currencyRepository: _Currencies(),
      assetRepository: _Assets(),
      categoryRepository: _Categories(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();

    expect(find.text('${l10n.auditTabAssets} · 1'), findsOneWidget);
    expect(find.text('Счёт'), findsOneWidget);

    await tester.tap(find.text('Счёт'));
    await tester.pumpAndSettle();
    expect(find.text('аудит операции'), findsOneWidget);
  });

  testWidgets('аудит переключает таб и показывает доходы/расходы', (
    tester,
  ) async {
    final viewModel = AuditViewModel(
      transactionRepository: _Transactions([_transaction()]),
      cashflowRepository: _Cashflow([_entry(comment: 'Коммуналка')]),
      currencyRepository: _Currencies(),
      assetRepository: _Assets(),
      categoryRepository: _Categories(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${l10n.auditTabCashflow} · 1'));
    await tester.pumpAndSettle();

    expect(find.text('Коммуналка'), findsWidgets);
    expect(find.text('Счёт'), findsNothing);
  });

  testWidgets('экран не показывает запись, связанную с активной операцией', (
    tester,
  ) async {
    final viewModel = AuditViewModel(
      transactionRepository: _Transactions([_transaction(id: 1)]),
      cashflowRepository: _Cashflow([
        _entry(id: 1, assetTransactionId: 7, comment: 'Скрытая'),
        _entry(id: 2, assetTransactionId: 1, comment: 'Пара'),
      ]),
      currencyRepository: _Currencies(),
      assetRepository: _Assets(),
      categoryRepository: _Categories(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${l10n.auditTabCashflow} · 1'));
    await tester.pumpAndSettle();

    expect(find.text('Коммуналка'), findsOneWidget);
  });

  testWidgets('пустой аудит показывает empty state', (tester) async {
    final viewModel = AuditViewModel(
      transactionRepository: _Transactions(const []),
      cashflowRepository: _Cashflow(const []),
      currencyRepository: _Currencies(),
      assetRepository: _Assets(),
      categoryRepository: _Categories(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();

    expect(find.text(l10n.auditEmptyTitle), findsOneWidget);
  });
}
