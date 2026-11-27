import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/resolve_exchange_rate.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transfer_asset_kinds.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel перевода между активами: счетами и инвестициями (6.2, 21.2).
class TransferFormViewModel {
  TransferFormViewModel({
    required this.assetRepository,
    required this.transactionRepository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.today,
    this.initialFromId,
  });

  final AssetRepository assetRepository;
  final AssetTransactionRepository transactionRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;
  final int? initialFromId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<Asset>> assets = signal(const []);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<bool> busy = signal(false);

  Future<void> load() async {
    try {
      final snapshots = await assetRepository.watchAll().first;
      assets.value = [
        for (final snapshot in snapshots)
          if (transferAssetKinds.contains(snapshot.asset.kind) &&
              snapshot.asset.archivedAt == null)
            snapshot.asset,
      ];
      final list = await currencyRepository.getEnabled();
      currencies.value = {for (final currency in list) currency.code: currency};
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Asset? assetById(int id) =>
      assets.value.where((asset) => asset.id == id).firstOrNull;

  Currency currencyOf(String code) =>
      currencies.value[code] ??
      Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      );

  Future<Result<int>> save({
    required int fromId,
    required int toId,
    required Money amount,
    Money? destinationAmount,
    required LocalDate occurredOn,
    String? comment,
  }) async {
    final from = assetById(fromId);
    final to = assetById(toId);
    if (from == null || to == null) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'assetId': 'validationAssetRequired'},
        ),
      );
    }
    if (from.id == to.id) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'toAccountId': 'validationTransferSameAccount'},
        ),
      );
    }
    if (occurredOn.compareTo(today) > 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'occurredOn': 'validationDateInFuture'},
        ),
      );
    }
    if (amount.minorUnits <= 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'amount': 'validationAmountPositive'},
        ),
      );
    }
    if (destinationAmount != null && destinationAmount.minorUnits <= 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {
            'destinationAmount': 'validationDestinationAmountPositive',
          },
        ),
      );
    }
    if (from.currencyCode != to.currencyCode && destinationAmount == null) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {
            'destinationAmount': 'validationDestinationAmountRequired',
          },
        ),
      );
    }
    if (from.currencyCode == to.currencyCode &&
        destinationAmount != null &&
        destinationAmount.minorUnits != amount.minorUnits) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {
            'destinationAmount': 'validationTransferAmountMismatch',
          },
        ),
      );
    }
    busy.value = true;
    try {
      final fromRate = await ResolveExchangeRate.call(
        rateRepository,
        from.currencyCode,
        occurredOn,
      );
      final toRate = from.currencyCode == to.currencyCode
          ? fromRate
          : await ResolveExchangeRate.call(
              rateRepository,
              to.currencyCode,
              occurredOn,
            );
      final destination =
          destinationAmount ??
          Money(minorUnits: amount.minorUnits, currencyCode: from.currencyCode);
      final id = await transactionRepository.transfer(
        TransferDraft(
          fromAccountId: from.id,
          toAccountId: to.id,
          amount: amount,
          destinationAmount: destination,
          occurredOn: occurredOn,
          fromRateToRub: fromRate.rateToRub,
          toRateToRub: toRate.rateToRub,
          comment: (comment?.trim().isEmpty ?? true) ? null : comment!.trim(),
        ),
      );
      return Success(id);
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
