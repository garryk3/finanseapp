import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/ui/property_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/property_form_view_model.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
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

final class FakeAssets implements AssetRepository {
  FakeAssets([this.snapshot]);

  final AssetSnapshot? snapshot;
  AssetDraft? savedDraft;

  @override
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false}) =>
      const Stream.empty();

  @override
  Stream<AssetSnapshot?> watchById(int id) => const Stream.empty();

  @override
  Future<AssetSnapshot> getById(int id) async => snapshot!;

  @override
  Future<int> create(AssetDraft draft) async => 1;

  @override
  Future<void> update(int id, AssetDraft draft) async {
    savedDraft = draft;
  }

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

void main() {
  testWidgets('форма квартиры помещается на 320dp при textScale 1.3', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final vm = PropertyFormViewModel(
      repository: FakeAssets(),
      currencyRepository: FakeCurrencies(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
        home: PropertyFormScreen(viewModel: vm),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.propertyFormNew), findsOneWidget);
    expect(find.text(l10n.propertyAddressLabel), findsOneWidget);
  });

  testWidgets('редактирование: нулевые стоимость и цена показаны пустыми', (
    tester,
  ) async {
    await _pumpEdit(tester, _property(opening: 0, purchase: 0));

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, isEmpty);
    expect(tester.widget<TextField>(fields.at(3)).controller!.text, isEmpty);
  });

  testWidgets('редактирование: ненулевые стоимость и цена показаны как есть', (
    tester,
  ) async {
    await _pumpEdit(tester, _property(opening: 100000, purchase: 5000000));

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, '1000');
    expect(tester.widget<TextField>(fields.at(3)).controller!.text, '50000');
  });

  testWidgets('сохранённый нулевой purchasePrice не превращается в null', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final assets = await _pumpEdit(tester, _property(opening: 0, purchase: 0));

    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final draft = assets.savedDraft! as PropertyDraft;
    expect(draft.purchasePrice?.minorUnits, 0);
  });

  testWidgets('пустая цена покупки сохраняется как null', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final assets = await _pumpEdit(tester, _property(opening: 0));

    expect(
      tester.widget<TextField>(find.byType(TextField).at(3)).controller!.text,
      isEmpty,
    );
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final draft = assets.savedDraft! as PropertyDraft;
    expect(draft.purchasePrice, isNull);
  });

  testWidgets('очистка ненулевой цены покупки сохраняется как null', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    final assets = await _pumpEdit(
      tester,
      _property(opening: 0, purchase: 5000000),
    );

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(3)).controller!.text, '50000');
    await tester.enterText(fields.at(3), '');
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pump(const Duration(milliseconds: 300));

    final draft = assets.savedDraft! as PropertyDraft;
    expect(draft.purchasePrice, isNull);
  });
}

PropertyAsset _property({required int opening, int? purchase}) => PropertyAsset(
  id: 1,
  name: 'Квартира',
  currencyCode: 'RUB',
  openingValue: Money(minorUnits: opening, currencyCode: 'RUB'),
  createdAt: DateTime.utc(2026),
  purchasePrice: purchase == null
      ? null
      : Money(minorUnits: purchase, currencyCode: 'RUB'),
);

Future<FakeAssets> _pumpEdit(
  WidgetTester tester,
  PropertyAsset property,
) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final assets = FakeAssets(
    AssetSnapshot(
      asset: property,
      currentValue: const Money(minorUnits: 0, currencyCode: 'RUB'),
    ),
  );
  final vm = PropertyFormViewModel(
    repository: assets,
    currencyRepository: FakeCurrencies(),
    editingId: 1,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru')],
      home: PropertyFormScreen(viewModel: vm),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return assets;
}
