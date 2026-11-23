import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/audit/ui/audit_asset_transaction_screen.dart';
import 'package:finanseapp/core/features/audit/ui/audit_asset_transaction_view_model.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry_revision.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_filter.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_details_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_details_view_model.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final class FakeAssets implements AssetRepository {
  FakeAssets(this.accounts);

  final List<Asset> accounts;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value([
        for (final asset in accounts)
          AssetSnapshot(asset: asset, currentValue: asset.openingValue),
      ]);

  @override
  Stream<AssetSnapshot?> watchById(int id) => const Stream.empty();

  @override
  Future<AssetSnapshot> getById(int id) async {
    final asset = accounts.firstWhere((item) => item.id == id);
    return AssetSnapshot(asset: asset, currentValue: asset.openingValue);
  }

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

  FakeTransactions(this.transactions, {this.deleted = false, this.deleteError});

  final List<AssetTransaction> transactions;
  final bool deleted;
  final DomainException? deleteError;
  final List<TransactionFilter> filters = [];
  int deletes = 0;
  int transferDeletes = 0;

  @override
  Stream<List<AssetTransaction>> watch(TransactionFilter filter) {
    filters.add(filter);
    final value = transactions
        .where((item) => filter.kind == null || item.kind == filter.kind)
        .toList();
    return Stream.value(value);
  }

  @override
  Future<AssetTransaction> getById(int id) async => transactions.firstWhere(
    (item) => item.id == id,
    orElse: () => transactions.first,
  );

  @override
  Future<int> create(AssetTransactionDraft draft) => throw UnimplementedError();

  @override
  Future<void> revise(int id, AssetTransactionDraft draft) async {}

  @override
  Future<void> softDelete(int id) async {
    final error = deleteError;
    if (error != null) throw error;
    deletes++;
  }

  @override
  Future<void> restore(int id) async {}

  @override
  Future<int> transfer(TransferDraft draft) => throw UnimplementedError();

  @override
  Future<void> reviseTransfer(int transferId, TransferDraft draft) async {}

  @override
  Future<void> softDeleteTransfer(int transferId) async {
    transferDeletes++;
  }

  @override
  Future<void> restoreTransfer(int transferId) async {}
}

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

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

final class FakeSettings implements SettingsRepository {
  @override
  Stream<Currency> watchBaseCurrency() => Stream.value(_rub);

  @override
  Future<Currency> getBaseCurrency() async => _rub;

  @override
  Future<void> setBaseCurrency(String code) async {}
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

final class FakeAudit implements AuditRepository {
  FakeAudit(this.revisions);

  final List<AssetTransactionRevision> revisions;

  @override
  Stream<List<AssetTransactionRevision>> watchAssetTransactionRevisions(
    int id,
  ) => Stream.value(revisions);

  @override
  Stream<List<CashflowEntryRevision>> watchCashflowRevisions(int id) =>
      const Stream.empty();
}

AccountAsset _account(int id, String name) => AccountAsset(
  id: id,
  name: name,
  currencyCode: 'RUB',
  openingValue: const Money(minorUnits: 1000000, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  bankId: 1,
  annualRate: Decimal.zero,
  startDate: LocalDate(2026, 1, 1),
);

AssetTransaction _transaction({
  int id = 1,
  int assetId = 1,
  AssetTransactionKind kind = AssetTransactionKind.deposit,
  int amount = 10000,
  LocalDate? date,
  String? comment,
  DateTime? deletedAt,
}) => AssetTransaction(
  id: id,
  assetId: assetId,
  kind: kind,
  amount: Money(minorUnits: amount, currencyCode: 'RUB'),
  occurredOn: date ?? LocalDate(2026, 1, 2),
  rateToRub: Decimal.one,
  amountRub: Money(minorUnits: amount, currencyCode: 'RUB'),
  revisionNo: 1,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  comment: comment,
  deletedAt: deletedAt,
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1000, 1800);
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
      home: child,
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

  testWidgets('журнал группирует по дате и применяет фильтры', (tester) async {
    final repository = FakeTransactions([
      _transaction(id: 1, comment: 'Первая'),
      _transaction(
        id: 2,
        kind: AssetTransactionKind.withdrawal,
        date: LocalDate(2026, 1, 1),
        comment: 'Вторая',
      ),
    ]);
    final vm = TransactionsViewModel(
      repository: repository,
      assetRepository: FakeAssets([_account(1, 'Счёт')]),
      today: LocalDate(2026, 1, 3),
    );
    await _pump(
      tester,
      TransactionsScreen(viewModel: vm, onTabChanged: (_) {}),
    );

    expect(find.text('02.01.2026'), findsOneWidget);
    expect(find.text('01.01.2026'), findsOneWidget);
    expect(find.textContaining('Счёт'), findsWidgets);

    await tester.tap(find.text(l10n.transactionsFilterDeposit));
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.filters.last.kind, AssetTransactionKind.deposit);
    expect(find.textContaining('Первая'), findsNothing);
    expect(find.textContaining('Пополнение'), findsOneWidget);
  });

  test('месячный фильтр ограничивает период текущим месяцем', () async {
    final repository = FakeTransactions([]);
    final vm = TransactionsViewModel(
      repository: repository,
      assetRepository: FakeAssets([_account(1, 'Счёт')]),
      today: LocalDate(2026, 1, 3),
    );
    vm.init();
    vm.setMonthOnly(true);
    await pumpEventQueue();

    final period = repository.filters.last.period;
    expect(period, isNotNull);
    expect(period!.start, LocalDate(2026, 1, 1));
    expect(period.end, LocalDate(2026, 1, 31));
  });

  testWidgets('удалённая операция в деталях даёт NotFound', (tester) async {
    final transaction = _transaction(deletedAt: DateTime.utc(2026, 1, 3));
    final vm = TransactionDetailsViewModel(
      repository: FakeTransactions([transaction], deleted: true),
      assetRepository: FakeAssets([_account(1, 'Счёт')]),
      auditRepository: FakeAudit([]),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
      today: LocalDate(2026, 1, 3),
      transactionId: 1,
    );
    await _pump(tester, TransactionDetailsScreen(viewModel: vm));

    expect(find.text(l10n.notFoundTitle), findsOneWidget);
    expect(find.text(l10n.transactionDetailsTitle), findsOneWidget);
    expect(find.text(l10n.transactionAuditAction), findsOneWidget);
  });

  testWidgets('аудит показывает ревизии удалённой операции', (tester) async {
    final deleted = _transaction(deletedAt: DateTime.utc(2026, 1, 3));
    final vm = AuditAssetTransactionViewModel(
      auditRepository: FakeAudit([
        AssetTransactionRevision(
          id: 2,
          transactionId: 1,
          revisionNo: 2,
          action: RevisionAction.delete,
          snapshot: deleted,
          changedAt: DateTime.utc(2026, 1, 3),
        ),
      ]),
      assetRepository: FakeAssets([_account(1, 'Счёт')]),
      transactionRepository: FakeTransactions(const []),
      transactionId: 1,
    );
    await _pump(tester, AuditAssetTransactionScreen(viewModel: vm));

    expect(find.text(l10n.auditAssetTransactionTitle), findsOneWidget);
    expect(find.textContaining(l10n.revisionActionDelete), findsOneWidget);
    expect(find.text(l10n.auditRestore), findsOneWidget);
  });

  testWidgets('нога перевода удаляется вместе с парой', (tester) async {
    final transaction = AssetTransaction(
      id: 1,
      assetId: 1,
      kind: AssetTransactionKind.transferOut,
      amount: const Money(minorUnits: 10000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
      rateToRub: Decimal.one,
      amountRub: const Money(minorUnits: 10000, currencyCode: 'RUB'),
      revisionNo: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      transferId: 5,
    );
    final repository = FakeTransactions([transaction]);
    final vm = TransactionDetailsViewModel(
      repository: repository,
      assetRepository: FakeAssets([_account(1, 'Счёт')]),
      auditRepository: FakeAudit([]),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
      today: LocalDate(2026, 1, 3),
      transactionId: 1,
    );
    await _pump(tester, TransactionDetailsScreen(viewModel: vm));

    expect(find.text(l10n.transferDeleteAction), findsOneWidget);
    await tester.tap(find.text(l10n.transferDeleteAction));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.transferDeleteTitle), findsOneWidget);
    expect(find.text(l10n.transferDeleteMessage), findsOneWidget);
    await tester.tap(find.text(l10n.commonDelete).last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.transferDeletes, 1);
    expect(repository.deletes, 0);
    expect(find.text(l10n.transferDeleted), findsOneWidget);
  });

  testWidgets('удаление с нарушением истории баланса объясняет причину', (
    tester,
  ) async {
    final transaction = _transaction();
    final vm = TransactionDetailsViewModel(
      repository: FakeTransactions([
        transaction,
      ], deleteError: const DomainException(DomainErrorCode.negativeBalance)),
      assetRepository: FakeAssets([_account(1, 'Счёт')]),
      auditRepository: FakeAudit([]),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
      today: LocalDate(2026, 1, 3),
      transactionId: 1,
    );
    await _pump(tester, TransactionDetailsScreen(viewModel: vm));

    await tester.tap(find.text(l10n.accountDelete));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.commonDelete).last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.transactionDeleteBalanceBlocked), findsOneWidget);
  });

  testWidgets('детали операции окрашивают карточку по типу', (tester) async {
    const expected = <AssetTransactionKind, AppMoneyTone>{
      AssetTransactionKind.deposit: AppMoneyTone.income,
      AssetTransactionKind.withdrawal: AppMoneyTone.expense,
      AssetTransactionKind.transferOut: AppMoneyTone.transfer,
      AssetTransactionKind.transferIn: AppMoneyTone.transfer,
    };
    for (final kind in expected.keys) {
      final vm = TransactionDetailsViewModel(
        repository: FakeTransactions([_transaction(kind: kind)]),
        assetRepository: FakeAssets([_account(1, 'Счёт')]),
        auditRepository: FakeAudit([]),
        settingsRepository: FakeSettings(),
        currencyRepository: FakeCurrencies(),
        rateRepository: FakeRates(),
        today: LocalDate(2026, 1, 3),
        transactionId: 1,
      );
      await _pump(tester, TransactionDetailsScreen(viewModel: vm));

      final card = tester.widget<AppSummaryCard>(find.byType(AppSummaryCard));
      final context = tester.element(find.byType(AppSummaryCard));
      expect(card.tone, expected[kind], reason: kind.name);
      final amount = tester.widget<Text>(find.text(card.value));
      expect(
        amount.style?.color,
        resolveMoneyToneColor(context, expected[kind]!),
        reason: '${kind.name}: тон должен доходить до текста',
      );
    }
  });

  testWidgets('детали показывают ревизии и удаляют операцию', (tester) async {
    final transaction = _transaction(comment: 'Комментарий');
    final revisions = [
      AssetTransactionRevision(
        id: 1,
        transactionId: 1,
        revisionNo: 1,
        action: RevisionAction.create,
        snapshot: transaction,
        changedAt: DateTime.utc(2026, 1, 2),
      ),
    ];
    final repository = FakeTransactions([transaction]);
    final vm = TransactionDetailsViewModel(
      repository: repository,
      assetRepository: FakeAssets([_account(1, 'Счёт')]),
      auditRepository: FakeAudit(revisions),
      settingsRepository: FakeSettings(),
      currencyRepository: FakeCurrencies(),
      rateRepository: FakeRates(),
      today: LocalDate(2026, 1, 3),
      transactionId: 1,
    );
    await _pump(tester, TransactionDetailsScreen(viewModel: vm));

    expect(find.text(l10n.transactionRevisionsTitle), findsOneWidget);
    expect(find.textContaining(l10n.revisionActionCreate), findsOneWidget);

    await tester.tap(find.text(l10n.accountDelete));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.commonDelete).last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.deletes, 1);
  });
}
