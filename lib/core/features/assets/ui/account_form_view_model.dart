import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_draft.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel формы счёта: справочники, редактирование и валидация.
class AccountFormViewModel {
  AccountFormViewModel({
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
  final Signal<List<Subgroup>> banks = signal(const []);
  final Signal<List<Currency>> currencies = signal(const []);
  final Signal<AccountAsset?> account = signal(null);
  final Signal<AssetReferenceCounts?> referenceCounts = signal(null);
  final Signal<bool> busy = signal(false);

  bool get isEditing => editingId != null;

  Future<void> load() async {
    try {
      final bankList = await subgroupRepository.getByKind(SubgroupKind.bank);
      final currencyList = await currencyRepository.getEnabled();
      banks.value = bankList;
      currencies.value = currencyList;
      if (editingId != null) {
        final snapshot = await repository.getById(editingId!);
        final asset = snapshot.asset;
        if (asset is AccountAsset) account.value = asset;
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
    required int bankId,
    required String currencyCode,
    required Money openingValue,
    required Decimal annualRate,
    required LocalDate startDate,
    LocalDate? endDate,
  }) async {
    busy.value = true;
    try {
      final draft = AccountDraft(
        name: name,
        currencyCode: currencyCode,
        openingValue: openingValue,
        bankId: bankId,
        annualRate: annualRate,
        startDate: startDate,
        endDate: endDate,
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

/// Ввод начального баланса — в основных единицах (BR-VAL-1).
Money? parseOpeningAmount(String raw, Currency currency) {
  final normalized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final decimal = Decimal.tryParse(normalized);
  if (decimal == null || decimal < Decimal.zero) return null;
  try {
    return MoneyMath.fromDecimal(decimal, currency);
  } on DomainException {
    return null;
  }
}
