import 'dart:async';

import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/categories/ui/categories_screen.dart';
import 'package:finanseapp/core/features/categories/ui/categories_view_model.dart';
import 'package:finanseapp/core/features/categories/ui/category_form_screen.dart';
import 'package:finanseapp/core/features/categories/ui/category_form_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final class FakeCategoryRepository implements CategoryRepository {
  final StreamController<List<CashflowCategory>> _controller =
      StreamController.broadcast(sync: true);
  final List<CashflowCategory> categories = [];
  final Map<int, int> counts = {};
  int _nextId = 1;

  void seed(
    CashflowKind kind,
    String name, {
    bool preset = false,
    bool archived = false,
    int entries = 0,
  }) {
    final id = _nextId++;
    categories.add(
      CashflowCategory(
        id: id,
        kind: kind,
        name: name,
        isPreset: preset,
        archivedAt: archived ? DateTime.utc(2026, 1, 1) : null,
      ),
    );
    counts[id] = entries;
  }

  void emit(CashflowKind kind) => _controller.add(
    categories.where((category) => category.kind == kind).toList(),
  );

  @override
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  }) => _controller.stream;

  @override
  Future<int> create(CashflowCategoryDraft draft) async {
    if (categories.any(
      (category) =>
          category.kind == draft.kind &&
          category.name.toLowerCase() == draft.name.trim().toLowerCase() &&
          category.archivedAt == null,
    )) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'name': 'validationCategoryDuplicate'},
      );
    }
    final id = _nextId++;
    categories.add(
      CashflowCategory(
        id: id,
        kind: draft.kind,
        name: draft.name.trim(),
        isPreset: false,
      ),
    );
    counts[id] = 0;
    return id;
  }

  @override
  Future<void> update(CashflowCategory category) async {
    final index = categories.indexWhere((item) => item.id == category.id);
    categories[index] = category;
  }

  @override
  Future<int> countEntries(int id) async => counts[id] ?? 0;

  @override
  Future<void> archive(int id) async {
    final index = categories.indexWhere((item) => item.id == id);
    final current = categories[index];
    categories[index] = CashflowCategory(
      id: current.id,
      kind: current.kind,
      name: current.name,
      isPreset: current.isPreset,
      archivedAt: DateTime.utc(2026, 1, 2),
    );
  }

  @override
  Future<void> moveEntriesAndDelete(int id, int targetId) async {
    counts[targetId] = (counts[targetId] ?? 0) + (counts[id] ?? 0);
    counts.remove(id);
    categories.removeWhere((category) => category.id == id);
  }

  @override
  Future<void> deleteIfUnused(int id) async {
    if ((counts[id] ?? 0) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'categoryId': 'validationCategoryInUse'},
      );
    }
    categories.removeWhere((category) => category.id == id);
  }

  @override
  Future<int?> findActiveIdByName(String name, CashflowKind kind) async => null;
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
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
  }

  testWidgets('список показывает архивацию и пометки', (tester) async {
    final repository = FakeCategoryRepository()
      ..seed(CashflowKind.expense, 'Питание', preset: true)
      ..seed(CashflowKind.expense, 'Старое', archived: true)
      ..seed(CashflowKind.income, 'Зарплата');
    final vm = CategoriesViewModel(repository: repository);

    await pump(
      tester,
      CategoriesScreen(
        viewModel: vm,
        initialKind: CashflowKind.expense,
        onKindChanged: (_) {},
      ),
    );
    repository.emit(CashflowKind.expense);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Питание'), findsOneWidget);
    expect(find.textContaining(l10n.categoryPresetBadge), findsOneWidget);
    expect(find.textContaining(l10n.categoryArchivedBadge), findsOneWidget);
  });

  testWidgets('дубликат в форме показывается inline', (tester) async {
    final repository = FakeCategoryRepository()
      ..seed(CashflowKind.expense, 'Питание');
    final vm = CategoryFormViewModel(
      repository: repository,
      kind: CashflowKind.expense,
    );

    await pump(tester, CategoryFormScreen(viewModel: vm));
    await tester.enterText(find.byType(TextField), 'питание');
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.categoryErrorDuplicate), findsOneWidget);
  });

  testWidgets('переключение income/expense не оставляет loading', (
    tester,
  ) async {
    final repository = FakeCategoryRepository()
      ..seed(CashflowKind.expense, 'Питание')
      ..seed(CashflowKind.income, 'Зарплата');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: _KindHost(repository: repository),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    repository.emit(CashflowKind.expense);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Питание'), findsOneWidget);

    await tester.tap(find.text(l10n.categoriesIncomeTab));
    await tester.pump(const Duration(milliseconds: 300));
    repository.emit(CashflowKind.income);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Зарплата'), findsOneWidget);
    expect(find.text(l10n.commonLoading), findsNothing);
  });

  testWidgets('занятая категория предлагает архив/перенос', (tester) async {
    final repository = FakeCategoryRepository()
      ..seed(CashflowKind.expense, 'Питание', entries: 3)
      ..seed(CashflowKind.expense, 'Цель');
    final vm = CategoriesViewModel(repository: repository);

    await pump(
      tester,
      CategoriesScreen(
        viewModel: vm,
        initialKind: CashflowKind.expense,
        onKindChanged: (_) {},
      ),
    );
    repository.emit(CashflowKind.expense);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip(l10n.categoryActionsTooltip).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonDelete).last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Питание'), findsWidgets);
    expect(find.text(l10n.categoryArchiveAction), findsWidgets);
    expect(find.text(l10n.categoryMoveAction), findsWidgets);
  });
}

/// Повторяет поведение роутера: новый VM на каждую вкладку.
class _KindHost extends StatefulWidget {
  const _KindHost({required this.repository});

  final FakeCategoryRepository repository;

  @override
  State<_KindHost> createState() => _KindHostState();
}

class _KindHostState extends State<_KindHost> {
  late CategoriesViewModel _viewModel = CategoriesViewModel(
    repository: widget.repository,
  );
  CashflowKind _kind = CashflowKind.expense;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CategoriesScreen(
    viewModel: _viewModel,
    initialKind: _kind,
    onKindChanged: (next) {
      final old = _viewModel;
      setState(() {
        _kind = next;
        _viewModel = CategoriesViewModel(repository: widget.repository);
      });
      old.dispose();
    },
  );
}
