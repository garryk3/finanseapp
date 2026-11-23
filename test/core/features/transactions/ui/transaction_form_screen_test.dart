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

const _usd = Currency(
  code: 'USD',
  name: 'Доллар',
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
  FakeAssets(this.items);

  final List<Asset> items;

  AssetSnapshot _snapshotOf(Asset asset) =>
      AssetSnapshot(asset: asset, currentValue: asset.openingValue);

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([for (final asset in items) _snapshotOf(asset)]);

  @override
  Stream<AssetSnapshot?> watchById(int id) =>
      Stream.value(_snapshotOf(items.firstWhere((asset) => asset.id == id)));

  @override
  Future<AssetSnapshot> getById(int id) async =>
      _snapshotOf(items.firstWhere((asset) => asset.id == id));

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

  @override
  Future<void> setLockedAmount(
    int assetId,
    String currencyCode,
    Money amount,
  ) async {}

  @override
  Future<List<Money>> lockedAmounts(int assetId) async => const [];
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
  FakeCurrencies([List<Currency>? items]) : items = items ?? const [_rub, _usd];

  final List<Currency> items;

  @override
  Stream<List<Currency>> watchAll() => Stream.value(items);

  @override
  Future<List<Currency>> getEnabled() async => items;

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
  FakeRates({this.rate});

  final Decimal? rate;

  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    final value = rate;
    if (value == null) return null;
    return ExchangeRate(
      id: 1,
      currencyCode: currencyCode,
      date: date,
      rateToRub: value,
      source: ExchangeRateSource.cbr,
      fetchedAt: DateTime.utc(2026),
    );
  }

  @override
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date) =>
      throw const DomainException(DomainErrorCode.rateUnavailable);

  @override
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  ) async => ExchangeRate(
    id: 1,
    currencyCode: currencyCode,
    date: date,
    rateToRub: rateToRub,
    source: ExchangeRateSource.manual,
    fetchedAt: DateTime.utc(2026),
  );
}

InvestmentAsset _investmentAsset({
  int id = 1,
  String name = 'Инвестиция',
  String currency = 'RUB',
}) => InvestmentAsset(
  id: id,
  name: name,
  currencyCode: currency,
  openingValue: Money(minorUnits: 100000, currencyCode: currency),
  createdAt: DateTime.utc(2026),
  brokerId: 1,
);

TransactionFormViewModel _viewModel(
  FakeTransactions transactions, {
  AssetKind kind = AssetKind.account,
}) => _viewModelForAssets(transactions, [
  if (kind == AssetKind.account) _account() else _investmentAsset(),
]);

TransactionFormViewModel _viewModelForAssets(
  FakeTransactions transactions,
  List<Asset> assets,
) => TransactionFormViewModel(
  assetRepository: FakeAssets(assets),
  transactionRepository: transactions,
  categoryRepository: FakeCategories(),
  currencyRepository: FakeCurrencies(),
  rateRepository: FakeRates(),
  today: LocalDate(2026, 1, 3),
  initialAssetId: assets.first.id,
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

  testWidgets('инвестиция показывает селектор валюты с валютой актива', (
    tester,
  ) async {
    await _pump(
      tester,
      _viewModel(FakeTransactions(), kind: AssetKind.investment),
    );

    expect(find.text(l10n.transactionCurrencyLabel), findsOneWidget);
    expect(find.text('Рубль (RUB)'), findsOneWidget);
  });

  testWidgets('счёт не показывает селектор валюты операции', (tester) async {
    await _pump(tester, _viewModel(FakeTransactions()));

    expect(find.text(l10n.transactionCurrencyLabel), findsNothing);
  });

  testWidgets('выбор USD меняет суффикс суммы и показывает курс', (
    tester,
  ) async {
    await _pump(
      tester,
      _viewModel(FakeTransactions(), kind: AssetKind.investment),
    );

    await _selectCurrency(tester, from: 'Рубль (RUB)', to: 'Доллар');

    expect(find.text('Доллар (USD)'), findsOneWidget);
    expect(find.text(l10n.valuationRateLabel), findsOneWidget);
    final amount = tester.widget<TextField>(find.byType(TextField).first);
    expect(amount.decoration!.suffixText, 'USD');
  });

  testWidgets(
    'USD-операция инвестиции сохраняется с выбранной валютой и курсом',
    (tester) async {
      final transactions = FakeTransactions();
      await _pump(tester, _viewModel(transactions, kind: AssetKind.investment));

      await _selectCurrency(tester, from: 'Рубль (RUB)', to: 'Доллар');
      await tester.enterText(find.byType(TextField).first, '1000');
      await tester.enterText(find.byType(TextField).at(1), '90');
      await tester.ensureVisible(find.text(l10n.commonSave));
      await tester.tap(find.text(l10n.commonSave));
      await tester.pump(const Duration(milliseconds: 300));

      final draft = transactions.created.single;
      expect(draft.amount.currencyCode, 'USD');
      expect(draft.amount.minorUnits, 100000);
      expect(draft.rateToRub, Decimal.fromInt(90));
    },
  );

  testWidgets('неизменяемый курс показывает понятное сообщение', (
    tester,
  ) async {
    final transactions = FakeTransactions(
      failure: const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'rate': 'validationRateImmutable'},
      ),
    );
    await _pump(tester, _viewModel(transactions, kind: AssetKind.investment));

    await _selectCurrency(tester, from: 'Рубль (RUB)', to: 'Доллар');
    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.enterText(find.byType(TextField).at(1), '90');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.rateErrorImmutable), findsOneWidget);
    expect(find.byType(TransactionFormScreen), findsOneWidget);
  });

  testWidgets('инвестиция в USD по умолчанию выбирает USD', (tester) async {
    await _pump(
      tester,
      _viewModelForAssets(FakeTransactions(), [
        _investmentAsset(id: 1, name: 'Инвестиция USD', currency: 'USD'),
      ]),
    );

    expect(find.text(l10n.transactionCurrencyLabel), findsOneWidget);
    expect(find.text('Доллар (USD)'), findsOneWidget);
  });

  testWidgets('смена актива сбрасывает валюту на валюту нового актива и курс', (
    tester,
  ) async {
    final transactions = FakeTransactions();
    await _pump(
      tester,
      _viewModelForAssets(transactions, [
        _investmentAsset(id: 1, name: 'Инвестиция RUB'),
        _investmentAsset(id: 2, name: 'Инвестиция USD', currency: 'USD'),
        _investmentAsset(id: 3, name: 'Инвестиция RUB 2'),
      ]),
    );

    await _selectCurrency(tester, from: 'Рубль (RUB)', to: 'Доллар');
    await tester.enterText(find.byType(TextField).at(1), '90');

    // Повторный выбор текущего актива не должен сбрасывать выбранную валюту.
    await tester.tap(find.text('Инвестиция RUB').last);
    await tester.pumpAndSettle();
    expect(find.text('Доллар (USD)'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '90',
    );

    // Смена на актив с другой валютой сбрасывает валюту и очищает курс.
    await tester.tap(find.text('Инвестиция RUB 2'));
    await tester.pumpAndSettle();

    expect(find.text('Рубль (RUB)'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      isEmpty,
    );
  });
}

Future<void> _selectCurrency(
  WidgetTester tester, {
  required String from,
  required String to,
}) async {
  await tester.tap(find.text(from));
  await tester.pumpAndSettle();
  await tester.tap(find.text(to));
  await tester.pumpAndSettle();
}
