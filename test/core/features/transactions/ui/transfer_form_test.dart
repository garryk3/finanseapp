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
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/core/features/transactions/ui/transfer_form_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transfer_form_view_model.dart';
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

AccountAsset _account(int id, String code, {int opening = 1000000}) =>
    AccountAsset(
      id: id,
      name: 'Счёт $id',
      currencyCode: code,
      openingValue: Money(minorUnits: opening, currencyCode: code),
      createdAt: DateTime.utc(2026),
      bankId: 1,
      annualRate: Decimal.zero,
      startDate: LocalDate(2026, 1, 1),
    );

final class FakeAssets implements AssetRepository {
  FakeAssets(this.accounts);

  final List<AccountAsset> accounts;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([
        for (final account in accounts)
          AssetSnapshot(asset: account, currentValue: account.openingValue),
      ]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => const Stream.empty();

  @override
  Future<AssetSnapshot> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(AssetDraft draft) => throw UnimplementedError();

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

final class FakeTransactions implements AssetTransactionRepository {
  FakeTransactions({this.failure});

  final DomainException? failure;
  final List<TransferDraft> transfers = [];

  @override
  Future<int> transfer(TransferDraft draft) async {
    if (failure != null) throw failure!;
    transfers.add(draft);
    return 1;
  }

  @override
  Stream<List<AssetTransaction>> watch(TransactionFilter filter) =>
      const Stream.empty();

  @override
  Future<AssetTransaction> getById(int id) => throw UnimplementedError();

  @override
  Future<int> create(AssetTransactionDraft draft) => throw UnimplementedError();

  @override
  Future<void> revise(int id, AssetTransactionDraft draft) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> reviseTransfer(int transferId, TransferDraft draft) async {}

  @override
  Future<void> softDeleteTransfer(int transferId) async {}
}

final class FakeCurrencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub, _usd]);

  @override
  Future<List<Currency>> getEnabled() async => const [_rub, _usd];

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
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async {
    if (currencyCode != 'USD') return null;
    return ExchangeRate(
      id: 1,
      currencyCode: 'USD',
      date: date,
      rateToRub: Decimal.fromInt(90),
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
  ) => throw const DomainException(DomainErrorCode.validation);
}

TransferFormViewModel _viewModel(
  FakeTransactions transactions, {
  List<AccountAsset>? accounts,
}) => TransferFormViewModel(
  assetRepository: FakeAssets(
    accounts ?? [_account(1, 'RUB'), _account(2, 'RUB')],
  ),
  transactionRepository: transactions,
  currencyRepository: FakeCurrencies(),
  rateRepository: FakeRates(),
  today: LocalDate(2026, 1, 3),
  initialFromId: 1,
);

Future<void> _pump(WidgetTester tester, TransferFormViewModel vm) async {
  tester.view.physicalSize = const Size(1000, 2000);
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
      home: TransferFormScreen(viewModel: vm),
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

  test('same-currency перевод: суммы и курс совпадают', () async {
    final transactions = FakeTransactions();
    final vm = _viewModel(transactions);
    await vm.load();

    final result = await vm.save(
      fromId: 1,
      toId: 2,
      amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 3),
    );

    expect(result, isA<Success<int>>());
    final draft = transactions.transfers.single;
    expect(draft.destinationAmount.minorUnits, 100000);
    expect(draft.fromRateToRub, Decimal.one);
    expect(draft.toRateToRub, Decimal.one);
  });

  test('cross-currency перевод берёт курс валюты назначения', () async {
    final transactions = FakeTransactions();
    final vm = _viewModel(
      transactions,
      accounts: [_account(1, 'RUB'), _account(2, 'USD')],
    );
    await vm.load();

    final result = await vm.save(
      fromId: 1,
      toId: 2,
      amount: const Money(minorUnits: 900000, currencyCode: 'RUB'),
      destinationAmount: const Money(minorUnits: 10000, currencyCode: 'USD'),
      occurredOn: LocalDate(2026, 1, 3),
    );

    expect(result, isA<Success<int>>());
    final draft = transactions.transfers.single;
    expect(draft.fromRateToRub, Decimal.one);
    expect(draft.toRateToRub, Decimal.fromInt(90));
    expect(draft.destinationAmount.minorUnits, 10000);
  });

  test('одинаковые счета и отрицательный баланс отклоняются', () async {
    final vm = _viewModel(FakeTransactions());
    await vm.load();

    final same = await vm.save(
      fromId: 1,
      toId: 1,
      amount: const Money(minorUnits: 1000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 3),
    );
    expect(same, isA<Failure<int>>());

    final failing = _viewModel(
      FakeTransactions(
        failure: const DomainException(DomainErrorCode.negativeBalance),
      ),
    );
    await failing.load();
    final result = await failing.save(
      fromId: 1,
      toId: 2,
      amount: const Money(minorUnits: 100000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 3),
    );
    expect(result, isA<Failure<int>>());
    expect(
      (result as Failure<int>).error.code,
      DomainErrorCode.negativeBalance,
    );
  });

  testWidgets('форма перевода сохраняет сумму и счета', (tester) async {
    final transactions = FakeTransactions();
    await _pump(tester, _viewModel(transactions));

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(transactions.transfers, hasLength(1));
    expect(transactions.transfers.single.fromAccountId, 1);
    expect(transactions.transfers.single.toAccountId, 2);
    expect(transactions.transfers.single.amount.minorUnits, 100000);
  });
}
