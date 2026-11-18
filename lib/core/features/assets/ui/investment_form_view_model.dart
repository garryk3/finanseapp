import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel формы инвестиции: брокеры, валюты, редактирование (5.2).
class InvestmentFormViewModel {
  InvestmentFormViewModel({
    required this.repository,
    required this.subgroupRepository,
    required this.currencyRepository,
    this.editingId,
  });

  final AssetRepository repository;
  final SubgroupRepository subgroupRepository;
  final CurrencyRepository currencyRepository;
  final int? editingId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<Subgroup>> brokers = signal(const []);
  final Signal<List<Currency>> currencies = signal(const []);
  final Signal<InvestmentAsset?> investment = signal(null);
  final Signal<AssetReferenceCounts?> referenceCounts = signal(null);
  final Signal<bool> busy = signal(false);

  bool get isEditing => editingId != null;

  Future<void> load() async {
    try {
      brokers.value = await subgroupRepository
          .watchByKind(SubgroupKind.broker)
          .first;
      currencies.value = await currencyRepository.getEnabled();
      if (editingId != null) {
        final snapshot = await repository.getById(editingId!);
        final asset = snapshot.asset;
        if (asset is InvestmentAsset) investment.value = asset;
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
    required int brokerId,
    required String currencyCode,
    required Money openingValue,
  }) async {
    busy.value = true;
    try {
      final draft = InvestmentDraft(
        name: name,
        currencyCode: currencyCode,
        openingValue: openingValue,
        brokerId: brokerId,
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
