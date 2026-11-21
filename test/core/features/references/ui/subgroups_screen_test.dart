import 'dart:async';

import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';
import 'package:finanseapp/core/features/references/ui/subgroups_screen.dart';
import 'package:finanseapp/core/features/references/ui/subgroups_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// In-memory repository без Drift-стримов (widget-тест не должен ждать
/// zero-timer'ы отмены drift-подписок).
final class FakeSubgroupRepository implements SubgroupRepository {
  final Map<int, Subgroup> _byId = {};
  final Map<int, int> _assetCounts = {};
  final Map<SubgroupKind, StreamController<List<Subgroup>>> _controllers = {
    SubgroupKind.bank: StreamController.broadcast(sync: true),
    SubgroupKind.broker: StreamController.broadcast(sync: true),
  };
  int _nextId = 1;

  void addSubgroup(SubgroupKind kind, String name, {int assetCount = 0}) {
    final id = _nextId++;
    _byId[id] = Subgroup(id: id, kind: kind, name: name);
    _assetCounts[id] = assetCount;
    _emit(kind);
  }

  void _emit(SubgroupKind kind) {
    final controller = _controllers[kind]!;
    if (controller.hasListener) {
      controller.add(_byId.values.where((s) => s.kind == kind).toList());
    }
  }

  void emit(SubgroupKind kind) {
    _controllers[kind]!.add(_byId.values.where((s) => s.kind == kind).toList());
  }

  @override
  Future<List<Subgroup>> getByKind(SubgroupKind kind) async =>
      (_byId.values.where((item) => item.kind == kind).toList()
        ..sort((a, b) => a.name.compareTo(b.name)));

  @override
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind) =>
      _controllers[kind]!.stream;

  @override
  Future<int> create(SubgroupKind kind, String name) async {
    final trimmed = name.trim();
    final normalized = trimmed.toLowerCase();
    if (_byId.values.any(
      (s) => s.kind == kind && s.name.toLowerCase() == normalized,
    )) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'name': 'validationSubgroupDuplicate'},
      );
    }
    final id = _nextId++;
    _byId[id] = Subgroup(id: id, kind: kind, name: trimmed);
    _assetCounts[id] = 0;
    _emit(kind);
    return id;
  }

  @override
  Future<void> rename(int id, String name) async {
    final current = _byId[id]!;
    _byId[id] = Subgroup(id: id, kind: current.kind, name: name.trim());
    _emit(current.kind);
  }

  @override
  Future<int> countAssets(int id) async => _assetCounts[id] ?? 0;

  @override
  Future<void> deleteIfUnused(int id) async {
    final subgroup = _byId[id]!;
    if ((_assetCounts[id] ?? 0) > 0) {
      throw const DomainException(
        DomainErrorCode.conflict,
        fieldErrors: {'subgroupId': 'validationSubgroupInUse'},
      );
    }
    _byId.remove(id);
    _assetCounts.remove(id);
    _emit(subgroup.kind);
  }

  @override
  Future<void> moveAssetsAndDelete(int id, int targetId) async {
    final source = _byId[id]!;
    final target = _byId[targetId]!;
    if (source.kind != target.kind) {
      throw const DomainException(
        DomainErrorCode.validation,
        fieldErrors: {'targetId': 'validationSubgroupKindMismatch'},
      );
    }
    _assetCounts[targetId] =
        (_assetCounts[targetId] ?? 0) + (_assetCounts[id] ?? 0);
    _byId.remove(id);
    _assetCounts.remove(id);
    _emit(source.kind);
  }
}

void main() {
  late FakeSubgroupRepository repository;
  late SubgroupsViewModel viewModel;

  setUp(() {
    repository = FakeSubgroupRepository();
    viewModel = SubgroupsViewModel(repository: repository);
  });

  tearDown(() => viewModel.dispose());

  Future<void> pumpScreen(
    WidgetTester tester, {
    SubgroupKind kind = SubgroupKind.bank,
    TextScaler textScaler = TextScaler.noScaling,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: SubgroupsScreen(
          viewModel: viewModel,
          initialKind: kind,
          onKindChanged: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    repository.emit(kind);
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('пустой справочник и создание банка', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    await pumpScreen(tester);
    expect(find.text(l10n.subgroupEmptyTitle), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.subgroupAdd));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), '  Тинькофф  ');
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Тинькофф'), findsOneWidget);
    expect(find.text(l10n.subgroupAssetsCount(0)), findsOneWidget);
  });

  testWidgets('дубликат показывает ошибку', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    repository.addSubgroup(SubgroupKind.bank, 'Банк Раз');
    await pumpScreen(tester);

    await tester.tap(find.byTooltip(l10n.subgroupAdd));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'банк раз');
    await tester.pump();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.subgroupErrorDuplicate), findsOneWidget);
  });

  testWidgets('занятый справочник показывает диалог переноса', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    repository
      ..addSubgroup(SubgroupKind.bank, 'Источник', assetCount: 2)
      ..addSubgroup(SubgroupKind.bank, 'Цель');
    await pumpScreen(tester);

    await tester.tap(find.byTooltip(l10n.subgroupActionsTooltip).first);
    await tester.pumpAndSettle();
    final deleteItem = find.ancestor(
      of: find.text(l10n.subgroupDeleteTooltip),
      matching: find.byWidgetPredicate((widget) => widget is PopupMenuItem),
    );
    await tester.tap(deleteItem);
    await tester.pumpAndSettle();

    expect(find.text(l10n.subgroupInUseTitle), findsOneWidget);
    expect(find.text(l10n.subgroupInUseMessageCount(2)), findsOneWidget);
    expect(find.text(l10n.subgroupMoveTarget), findsOneWidget);
    expect(find.text(l10n.subgroupMoveAction), findsOneWidget);

    // Отмена не меняет справочник; сам перенос проверен repository-тестами.
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Источник'), findsOneWidget);
    expect(find.text(l10n.subgroupAssetsCount(2)), findsOneWidget);
  });

  testWidgets('переключение bank → broker → bank не оставляет loading', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    repository
      ..addSubgroup(SubgroupKind.bank, 'Банк')
      ..addSubgroup(SubgroupKind.broker, 'Брокер');
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
    await tester.pump(const Duration(milliseconds: 400));
    repository.emit(SubgroupKind.bank);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text(l10n.subgroupsBrokerTab));
    await tester.pump(const Duration(milliseconds: 400));
    repository.emit(SubgroupKind.broker);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Брокер'), findsOneWidget);

    await tester.tap(find.text(l10n.subgroupsBankTab));
    await tester.pump(const Duration(milliseconds: 400));
    repository.emit(SubgroupKind.bank);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Банк'), findsOneWidget);
    expect(find.text(l10n.commonLoading), findsNothing);
  });

  testWidgets('320dp, font 1.3 и тёмная тема на непустом списке', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository.addSubgroup(
      SubgroupKind.bank,
      'Московский Кредитный Банк',
      assetCount: 3,
    );
    await pumpScreen(
      tester,
      textScaler: const TextScaler.linear(1.3),
      brightness: Brightness.dark,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Московский Кредитный Банк'), findsOneWidget);
    expect(find.text(l10n.subgroupAssetsCount(3)), findsOneWidget);
  });

  testWidgets('брокеры показываются на своей вкладке', (tester) async {
    repository.addSubgroup(SubgroupKind.broker, 'Брокер');
    await pumpScreen(tester, kind: SubgroupKind.broker);

    expect(find.text('Брокер'), findsOneWidget);
  });
}

/// Повторяет поведение роутера: новый VM на каждый `?kind=`.
class _KindHost extends StatefulWidget {
  const _KindHost({required this.repository});

  final FakeSubgroupRepository repository;

  @override
  State<_KindHost> createState() => _KindHostState();
}

class _KindHostState extends State<_KindHost> {
  late SubgroupsViewModel _viewModel = SubgroupsViewModel(
    repository: widget.repository,
  );
  SubgroupKind _kind = SubgroupKind.bank;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubgroupsScreen(
      viewModel: _viewModel,
      initialKind: _kind,
      onKindChanged: (next) {
        final old = _viewModel;
        setState(() {
          _kind = next;
          _viewModel = SubgroupsViewModel(repository: widget.repository);
        });
        old.dispose();
      },
    );
  }
}
