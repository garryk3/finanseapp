import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_form_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_form_view_model.dart';
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

AccountAsset _account() => AccountAsset(
  id: 1,
  name: 'Счёт',
  currencyCode: 'RUB',
  openingValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  bankId: 1,
  annualRate: Decimal.zero,
  startDate: LocalDate(2026, 1, 1),
);

final class FakeAssets implements AssetRepository {
  FakeAssets(this.asset);

  final Asset asset;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([
        AssetSnapshot(asset: asset, currentValue: asset.openingValue),
      ]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => Stream.value(
    AssetSnapshot(asset: asset, currentValue: asset.openingValue),
  );

  @override
  Future<AssetSnapshot> getById(int id) async =>
      AssetSnapshot(asset: asset, currentValue: asset.openingValue);

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
  Future<AssetReferenceCounts> referenceCounts(int id) async =>
      const AssetReferenceCounts(
        transactions: 0,
        valuations: 0,
        goals: 0,
        cashflow: 0,
      );

  @override
  Future<List<AssetValuation>> valuations(int id) async => const [];
}

final class FakeTransactions implements AssetTransactionRepository {
  @override
  Stream<List<AssetTransaction>> watchDeleted() => const Stream.empty();

  FakeTransactions({this.failure, this.gate});

  final DomainException? failure;
  final Completer<void>? gate;
  final List<AssetTransactionDraft> created = [];

  @override
  Future<int> create(AssetTransactionDraft draft) async {
    created.add(draft);
    if (gate != null) await gate!.future;
    if (failure != null) throw failure!;
    return created.length;
  }

  @override
  Stream<List<AssetTransaction>> watch(TransactionFilter filter) =>
      const Stream.empty();

  @override
  Future<AssetTransaction> getById(int id) => throw UnimplementedError();

  @override
  Future<void> revise(int id, AssetTransactionDraft draft) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> restore(int id) async {}

  @override
  Future<int> transfer(TransferDraft draft) => throw UnimplementedError();

  @override
  Future<void> reviseTransfer(int transferId, TransferDraft draft) async {}

  @override
  Future<void> softDeleteTransfer(int transferId) async {}

  @override
  Future<void> restoreTransfer(int transferId) async {}
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

final class FakeRates implements ExchangeRateRepository {
  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async => null;

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw const DomainException(DomainErrorCode.rateUnavailable);

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) => throw const DomainException(DomainErrorCode.validation);
}

TransactionFormViewModel _viewModel(
  FakeTransactions transactions, {
  AssetKind kind = AssetKind.account,
}) => TransactionFormViewModel(
  assetRepository: FakeAssets(
    kind == AssetKind.account
        ? _account()
        : InvestmentAsset(
            id: 1,
            name: 'Инвестиция',
            currencyCode: 'RUB',
            openingValue: const Money(minorUnits: 100000, currencyCode: 'RUB'),
            createdAt: DateTime.utc(2026),
            brokerId: 1,
          ),
  ),
  transactionRepository: transactions,
  categoryRepository: FakeCategories(),
  currencyRepository: FakeCurrencies(),
  rateRepository: FakeRates(),
  today: LocalDate(2026, 1, 3),
  initialAssetId: 1,
);

Future<void> _pump(
  WidgetTester tester,
  TransactionFormViewModel viewModel,
) async {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru')],
      home: TransactionFormScreen(viewModel: viewModel),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  testWidgets('пополнение сохраняет сумму, дату и RUB-курс', (tester) async {
    final transactions = FakeTransactions();
    await _pump(tester, _viewModel(transactions));

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(transactions.created, hasLength(1));
    final draft = transactions.created.single;
    expect(draft.kind, AssetTransactionKind.deposit);
    expect(draft.amount.minorUnits, 100000);
    expect(draft.rateToRub, Decimal.one);
    expect(draft.occurredOn, LocalDate(2026, 1, 3));
    expect(draft.classification, isNull);
  });

  test('пополнение счёта классифицируется как доход', () async {
    final transactions = FakeTransactions();
    final vm = _viewModel(transactions);
    await vm.load();

    final result = await vm.save(
      assetId: 1,
      kind: AssetTransactionKind.deposit,
      amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 3),
      categoryId: 10,
    );

    expect(result, isA<Success<int>>());
    final classification = transactions.created.single.classification;
    expect(classification, isNotNull);
    expect(classification!.kind, CashflowKind.income);
    expect(classification.categoryId, 10);
  });

  testWidgets('повторный тап Save не создаёт вторую операцию', (tester) async {
    final gate = Completer<void>();
    final transactions = FakeTransactions(gate: gate);
    await _pump(tester, _viewModel(transactions));

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump();
    expect(transactions.created, hasLength(1));

    gate.complete();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('отрицательный баланс показывается сообщением', (tester) async {
    final transactions = FakeTransactions(
      failure: const DomainException(DomainErrorCode.negativeBalance),
    );
    await _pump(tester, _viewModel(transactions));

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.transactionErrorNegativeBalance), findsOneWidget);
  });
}
