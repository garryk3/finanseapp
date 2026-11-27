import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_commands.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rule_form_screen.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rule_form_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
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

final class _FakeCategories implements CategoryRepository {
  @override
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  }) => Stream.value([_expense]);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
  @override
  Future<int?> findActiveIdByName(String name, CashflowKind kind) async => null;
}

final class _FakeCurrencies implements CurrencyRepository {
  @override
  Stream<List<Currency>> watchAll() => Stream.value(const [_rub]);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _FakeAssets implements AssetRepository {
  _FakeAssets(this.snapshots);

  final List<AssetSnapshot> snapshots;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      Stream.value(snapshots);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _FakeRecurringRepository implements RecurringRepository {
  _FakeRecurringRepository();

  RecurringRule? rule;
  bool deleted = false;

  @override
  Stream<List<RecurringRule>> watchActive({RecurringStrategy? strategy}) =>
      Stream.value(rule == null ? const [] : [rule!]);

  @override
  Future<RecurringRule> getById(int id) async => rule!;

  @override
  Future<int> create(RecurringRuleDraft draft) async => 1;

  @override
  Future<void> revise(int id, RecurringRuleDraft draft) async {
    rule = _copy(
      rule!,
      amount: draft.amount,
      categoryId: draft.categoryId,
      startDate: draft.startDate,
      endDate: draft.endDate,
    );
  }

  @override
  Future<void> softDelete(int id) async {
    deleted = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  static RecurringRule _copy(
    RecurringRule source, {
    Money? amount,
    int? categoryId,
    LocalDate? startDate,
    LocalDate? endDate,
  }) => RecurringRule(
    id: source.id,
    strategy: source.strategy,
    kind: source.kind,
    categoryId: categoryId ?? source.categoryId,
    amount: amount ?? source.amount,
    currencyCode: source.currencyCode,
    accountId: source.accountId,
    propertyId: source.propertyId,
    affectsBalance: source.affectsBalance,
    startDate: startDate ?? source.startDate,
    endDate: endDate ?? source.endDate,
    comment: source.comment,
    lastGeneratedPeriod: source.lastGeneratedPeriod,
    createdAt: source.createdAt,
    updatedAt: source.updatedAt,
    deletedAt: source.deletedAt,
  );
}

AccountAsset _account() => AccountAsset(
  id: 1,
  name: 'Вклад',
  currencyCode: 'RUB',
  openingValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  bankId: 1,
  annualRate: Decimal.zero,
  startDate: LocalDate(2026, 1, 1),
);

PropertyAsset _property() => PropertyAsset(
  id: 1,
  name: 'Квартира',
  currencyCode: 'RUB',
  openingValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
);

RecurringRule _rule({
  RecurringStrategy strategy = RecurringStrategy.fixed,
  DateTime? deletedAt,
}) => RecurringRule(
  id: 1,
  strategy: strategy,
  kind: strategy == RecurringStrategy.fixed
      ? CashflowKind.expense
      : CashflowKind.income,
  categoryId: 1,
  amount: strategy == RecurringStrategy.fixed
      ? const Money(minorUnits: 100000, currencyCode: 'RUB')
      : null,
  currencyCode: 'RUB',
  accountId: strategy == RecurringStrategy.fixed ? null : 1,
  propertyId: strategy == RecurringStrategy.fixed ? 1 : null,
  affectsBalance: strategy == RecurringStrategy.depositInterest,
  startDate: LocalDate(2026, 9, 15),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  deletedAt: deletedAt,
);

void main() {
  late AppLocalizations l10n;
  late _FakeRecurringRepository repository;
  late RecurringCommands commands;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    repository = _FakeRecurringRepository();
    commands = RecurringCommands(
      repository: repository,
      catchup: () async {},
      today: LocalDate(2026, 11, 17),
    );
  });

  RecurringRuleFormViewModel viewModel({int? editingId}) =>
      RecurringRuleFormViewModel(
        repository: repository,
        categoryRepository: _FakeCategories(),
        currencyRepository: _FakeCurrencies(),
        assetRepository: _FakeAssets([
          AssetSnapshot(
            asset: _account(),
            currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
          ),
          AssetSnapshot(
            asset: _property(),
            currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
          ),
        ]),
        commands: commands,
        editingId: editingId,
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

  testWidgets('пустая сумма даёт inline-ошибку', (tester) async {
    await pump(tester, RecurringRuleFormScreen(viewModel: viewModel()));

    expect(find.byType(AppSpinner), findsNothing);
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(find.text(l10n.cashflowErrorAmount), findsOneWidget);
  });

  testWidgets('автоправило процентов доступно только для чтения', (
    tester,
  ) async {
    repository.rule = _rule(strategy: RecurringStrategy.depositInterest);

    await pump(
      tester,
      RecurringRuleFormScreen(viewModel: viewModel(editingId: 1)),
    );

    expect(find.text(l10n.recurringReadOnlyInterest), findsOneWidget);
    expect(find.text(l10n.recurringOpenAccount), findsOneWidget);
    expect(find.text(l10n.commonSave), findsNothing);
    expect(find.text(l10n.recurringDeleteAction), findsNothing);
  });

  testWidgets('в режиме правки есть удаление с подтверждением', (tester) async {
    repository.rule = _rule();

    await pump(
      tester,
      RecurringRuleFormScreen(viewModel: viewModel(editingId: 1)),
    );

    await tester.ensureVisible(find.text(l10n.recurringDeleteAction));
    await tester.tap(find.text(l10n.recurringDeleteAction));
    await tester.pumpAndSettle();

    expect(find.text(l10n.recurringDeleteTitle), findsOneWidget);
    expect(find.text(l10n.recurringDeleteMessage), findsOneWidget);
    expect(repository.deleted, isFalse);
  });

  testWidgets('удалённое правило показывает спокойное состояние', (
    tester,
  ) async {
    repository.rule = _rule(deletedAt: DateTime.utc(2026, 2));

    await pump(
      tester,
      RecurringRuleFormScreen(viewModel: viewModel(editingId: 1)),
    );

    expect(find.text(l10n.recurringRuleDeletedTitle), findsOneWidget);
    expect(find.text(l10n.recurringRuleDeletedMessage), findsOneWidget);
    expect(find.text(l10n.commonSave), findsNothing);
    expect(find.text(l10n.recurringDeleteAction), findsNothing);
  });
}
