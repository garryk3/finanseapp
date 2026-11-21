import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_form_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_commands.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_category_select.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

final _expense = CashflowCategory(
  id: 1,
  kind: CashflowKind.expense,
  name: 'Питание',
  isPreset: true,
);

final _income = CashflowCategory(
  id: 2,
  kind: CashflowKind.income,
  name: 'Зарплата',
  isPreset: true,
);

final class _FakeCategories implements CategoryRepository {
  @override
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  }) => Stream.value([kind == CashflowKind.income ? _income : _expense]);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _FakeCurrencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _FakeAssets implements AssetRepository {
  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _FakeRates implements ExchangeRateRepository {
  @override
  Future<ExchangeRate?> find(String currencyCode, LocalDate date) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _FakeCashflowRepository implements CashflowRepository {
  int createCalls = 0;

  @override
  Future<int> create(CashflowEntryDraft draft) async {
    createCalls++;
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _FakeRecurringRepository implements RecurringRepository {
  RecurringRuleDraft? createdDraft;

  @override
  Future<int> create(RecurringRuleDraft draft) async {
    createdDraft = draft;
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late AppLocalizations l10n;
  late RecurringCommands recurringCommands;
  late CashflowCommands cashflowCommands;
  late _FakeCashflowRepository cashflowRepository;
  late _FakeRecurringRepository recurringRepository;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    recurringRepository = _FakeRecurringRepository();
    cashflowRepository = _FakeCashflowRepository();
    recurringCommands = RecurringCommands(
      repository: recurringRepository,
      catchup: () async {},
      today: LocalDate(2026, 11, 17),
    );
    cashflowCommands = CashflowCommands(
      repository: cashflowRepository,
      currencyRepository: _FakeCurrencies(),
      rateRepository: _FakeRates(),
      today: LocalDate(2026, 11, 17),
    );
  });

  CashflowFormViewModel viewModel({bool withRecurring = true}) =>
      CashflowFormViewModel(
        repository: cashflowRepository,
        categoryRepository: _FakeCategories(),
        currencyRepository: _FakeCurrencies(),
        commands: cashflowCommands,
        assetRepository: _FakeAssets(),
        recurringCommands: withRecurring ? recurringCommands : null,
        initialKind: CashflowKind.expense,
      );

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(900, 2000);
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
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 20));
    });
  }

  testWidgets('чекбокс ежемесячного платежа скрыт без команды', (tester) async {
    await pump(
      tester,
      CashflowFormScreen(viewModel: viewModel(withRecurring: false)),
    );

    expect(find.text(l10n.recurringMonthly), findsNothing);
    expect(find.byType(AppSpinner), findsNothing);
    expect(find.text(l10n.transactionDateLabel), findsOneWidget);
  });

  testWidgets('чекбокс открывает дату начала и окончания', (tester) async {
    await pump(tester, CashflowFormScreen(viewModel: viewModel()));

    expect(find.text(l10n.recurringMonthly), findsOneWidget);
    await tester.tap(find.text(l10n.recurringMonthly));
    await tester.pumpAndSettle();

    expect(find.text(l10n.recurringStartDate), findsOneWidget);
    expect(find.text(l10n.recurringEndDateOptional), findsOneWidget);
    expect(find.text(l10n.recurringEndNotSet), findsOneWidget);
    expect(find.text(l10n.recurringEndClear), findsNothing);
  });

  testWidgets('пустая сумма не создаёт правило', (tester) async {
    await pump(tester, CashflowFormScreen(viewModel: viewModel()));

    await tester.tap(find.text(l10n.recurringMonthly));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(find.text(l10n.cashflowErrorAmount), findsOneWidget);
    expect(recurringRepository.createdDraft, isNull);
  });

  testWidgets('сохранение создаёт правило, а не разовую операцию', (
    tester,
  ) async {
    await pump(tester, CashflowFormScreen(viewModel: viewModel()));

    final categorySelect = find.byType(AppCategorySelect);
    await tester.tap(
      find.descendant(of: categorySelect, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Питание').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.text(l10n.recurringMonthly));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(recurringRepository.createdDraft, isNotNull);
    expect(recurringRepository.createdDraft?.amount?.minorUnits, 100000);
    expect(cashflowRepository.createCalls, 0);
  });

  test('canRepeat выключен при редактировании записи', () {
    final vm = CashflowFormViewModel(
      repository: _FakeCashflowRepository(),
      categoryRepository: _FakeCategories(),
      currencyRepository: _FakeCurrencies(),
      commands: cashflowCommands,
      assetRepository: _FakeAssets(),
      recurringCommands: recurringCommands,
      editingId: 1,
    );

    expect(vm.canRepeat, isFalse);
    vm.dispose();
  });
}
