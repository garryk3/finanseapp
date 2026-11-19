import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel формы квартиры (5.4).
class PropertyFormViewModel {
  PropertyFormViewModel({
    required this.repository,
    required this.currencyRepository,
    this.editingId,
  });

  final AssetRepository repository;
  final CurrencyRepository currencyRepository;
  final int? editingId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<Currency>> currencies = signal(const []);
  final Signal<PropertyAsset?> property = signal(null);
  final Signal<AssetReferenceCounts?> referenceCounts = signal(null);
  final Signal<bool> busy = signal(false);

  bool get isEditing => editingId != null;

  Future<void> load() async {
    try {
      currencies.value = await currencyRepository.getEnabled();
      if (editingId != null) {
        final snapshot = await repository.getById(editingId!);
        final asset = snapshot.asset;
        if (asset is PropertyAsset) property.value = asset;
        referenceCounts.value = await repository.referenceCounts(editingId!);
      }
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<Result<int>> save({
    required String name,
    required String currencyCode,
    required Money openingValue,
    String? address,
    Money? purchasePrice,
  }) async {
    busy.value = true;
    try {
      final draft = PropertyDraft(
        name: name,
        currencyCode: currencyCode,
        openingValue: openingValue,
        address: address,
        purchasePrice: purchasePrice,
      );
      if (editingId == null) return Success(await repository.create(draft));
      await repository.update(editingId!, draft);
      return const Success(0);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }

  void dispose() {}
}
