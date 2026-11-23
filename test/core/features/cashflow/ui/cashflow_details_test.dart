import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry_revision.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_details_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_details_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
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

final class FakeCashflow implements CashflowRepository {
  @override
  Stream<List<CashflowEntry>> watchDeleted() => const Stream.empty();

  FakeCashflow(this.entry);

  final CashflowEntry entry;

  @override
  Stream<List<CashflowEntry>> watch(CashflowFilter filter) =>
      Stream.value([entry]);

  @override
  Future<CashflowEntry> getById(int id) async => entry;

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
  }) => Stream.value(const []);

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

final class FakeAudit implements AuditRepository {
  @override
  Stream<List<AssetTransactionRevision>> watchAssetTransactionRevisions(
    int id,
  ) => const Stream.empty();

  @override
  Stream<List<CashflowEntryRevision>> watchCashflowRevisions(int id) =>
      Stream.value(const []);
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

void main() {
  testWidgets('детали валютной записи показывают original и RUB', (
    tester,
  ) async {
    final entry = CashflowEntry(
      id: 1,
      kind: CashflowKind.expense,
      categoryId: 10,
      amount: const Money(minorUnits: 1000, currencyCode: 'USD'),
      occurredOn: LocalDate(2026, 1, 2),
      rateToRub: Decimal.fromInt(90),
      amountRub: const Money(minorUnits: 90000, currencyCode: 'RUB'),
      affectsBalance: false,
      revisionNo: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final repository = FakeCashflow(entry);
    final currencies = FakeCurrencies();
    final vm = CashflowDetailsViewModel(
      repository: repository,
      categoryRepository: FakeCategories(),
      auditRepository: FakeAudit(),
      currencyRepository: currencies,
      commands: CashflowCommands(
        repository: repository,
        currencyRepository: currencies,
        rateRepository: FakeRates(),
        today: LocalDate(2026, 1, 3),
      ),
      entryId: 1,
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: CashflowDetailsScreen(viewModel: vm),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('10,00'), findsWidgets);
    expect(find.textContaining(l10n.transactionAmountRub), findsOneWidget);
    expect(find.textContaining('900,00'), findsWidgets);
    expect(find.text(l10n.recurringAutoBadge), findsNothing);
  });

  testWidgets('автооперация показывает бейдж и ссылку на правило', (
    tester,
  ) async {
    final entry = CashflowEntry(
      id: 1,
      kind: CashflowKind.expense,
      categoryId: 10,
      amount: const Money(minorUnits: 1000, currencyCode: 'RUB'),
      occurredOn: LocalDate(2026, 1, 2),
      rateToRub: Decimal.one,
      amountRub: const Money(minorUnits: 1000, currencyCode: 'RUB'),
      affectsBalance: false,
      revisionNo: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      recurringRuleId: 7,
    );
    final repository = FakeCashflow(entry);
    final currencies = FakeCurrencies();
    final vm = CashflowDetailsViewModel(
      repository: repository,
      categoryRepository: FakeCategories(),
      auditRepository: FakeAudit(),
      currencyRepository: currencies,
      commands: CashflowCommands(
        repository: repository,
        currencyRepository: currencies,
        rateRepository: FakeRates(),
        today: LocalDate(2026, 1, 3),
      ),
      entryId: 1,
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: CashflowDetailsScreen(viewModel: vm),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.recurringAutoBadge), findsOneWidget);
    expect(find.text(l10n.recurringRuleLink), findsOneWidget);
  });

  testWidgets('детали дохода и расхода окрашивают карточку тоном', (
    tester,
  ) async {
    const expected = <CashflowKind, AppMoneyTone>{
      CashflowKind.income: AppMoneyTone.income,
      CashflowKind.expense: AppMoneyTone.expense,
    };
    for (final kind in expected.keys) {
      final entry = CashflowEntry(
        id: 1,
        kind: kind,
        categoryId: 10,
        amount: const Money(minorUnits: 1000, currencyCode: 'RUB'),
        occurredOn: LocalDate(2026, 1, 2),
        rateToRub: Decimal.one,
        amountRub: const Money(minorUnits: 1000, currencyCode: 'RUB'),
        affectsBalance: false,
        revisionNo: 1,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      final repository = FakeCashflow(entry);
      final currencies = FakeCurrencies();
      final vm = CashflowDetailsViewModel(
        repository: repository,
        categoryRepository: FakeCategories(),
        auditRepository: FakeAudit(),
        currencyRepository: currencies,
        commands: CashflowCommands(
          repository: repository,
          currencyRepository: currencies,
          rateRepository: FakeRates(),
          today: LocalDate(2026, 1, 3),
        ),
        entryId: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: const [
            ...GlobalMaterialLocalizations.delegates,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ru')],
          home: CashflowDetailsScreen(viewModel: vm),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

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
}
