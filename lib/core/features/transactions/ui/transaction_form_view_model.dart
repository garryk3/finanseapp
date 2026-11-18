import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/resolve_exchange_rate.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/transaction_classification.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel формы операции по активу (6.1): пополнение/снятие и классификация.
class TransactionFormViewModel {
  TransactionFormViewModel({
    required this.assetRepository,
    required this.transactionRepository,
    required this.categoryRepository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.today,
    this.initialAssetId,
    this.initialKind = AssetTransactionKind.deposit,
  });

  final AssetRepository assetRepository;
  final AssetTransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;
  final int? initialAssetId;
  final AssetTransactionKind initialKind;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<List<Asset>> assets = signal(const []);
  final Signal<Map<String, Currency>> currencies = signal(const {});
  final Signal<List<CashflowCategory>> categories = signal(const []);
  final Signal<bool> busy = signal(false);

  Future<void> load() async {
    try {
      final snapshots = await assetRepository.watchAll().first;
      assets.value = [
        for (final snapshot in snapshots)
          if (snapshot.asset.kind != AssetKind.property) snapshot.asset,
      ];
      final currencyList = await currencyRepository.getEnabled();
      currencies.value = {
        for (final currency in currencyList) currency.code: currency,
      };
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<void> loadCategories(CashflowKind kind) async {
    try {
      categories.value = await categoryRepository.watchByKind(kind).first;
    } on Exception {
      categories.value = const [];
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
    required int assetId,
    required AssetTransactionKind kind,
    required Money amount,
    required LocalDate occurredOn,
    Decimal? manualRate,
    String? comment,
    int? categoryId,
  }) async {
    final asset = assetById(assetId);
    if (asset == null) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'assetId': 'validationAssetRequired'},
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
    TransactionClassification? classification;
    if (categoryId != null) {
      if (asset.kind != AssetKind.account) {
        return const Failure(
          DomainException(
            DomainErrorCode.validation,
            fieldErrors: {
              'classification': 'validationClassificationAccountOnly',
            },
          ),
        );
      }
      classification = TransactionClassification(
        kind: kind == AssetTransactionKind.deposit
            ? CashflowKind.income
            : CashflowKind.expense,
        categoryId: categoryId,
      );
    }
    busy.value = true;
    try {
      final rate = await ResolveExchangeRate.call(
        rateRepository,
        asset.currencyCode,
        occurredOn,
        manualRate: manualRate,
      );
      final id = await transactionRepository.create(
        AssetTransactionDraft(
          assetId: assetId,
          kind: kind,
          amount: amount,
          occurredOn: occurredOn,
          rateToRub: rate.rateToRub,
          comment: (comment?.trim().isEmpty ?? true) ? null : comment!.trim(),
          classification: classification,
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
