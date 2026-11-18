import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/resolve_exchange_rate.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel формы абсолютной оценки (5.2).
class ValuationFormViewModel {
  ValuationFormViewModel({
    required this.repository,
    required this.rateRepository,
    required this.currencyRepository,
    required this.assetId,
    required this.today,
  });

  final AssetRepository repository;
  final ExchangeRateRepository rateRepository;
  final CurrencyRepository currencyRepository;
  final int assetId;
  final LocalDate today;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<Asset?> asset = signal(null);
  final Signal<Currency?> currency = signal(null);
  final Signal<bool> busy = signal(false);

  Future<void> load() async {
    try {
      final snapshot = await repository.getById(assetId);
      asset.value = snapshot.asset;
      final currencies = await currencyRepository.watchAll().first;
      currency.value = currencies.firstWhere(
        (item) => item.code == snapshot.asset.currencyCode,
        orElse: () => Currency(
          code: snapshot.asset.currencyCode,
          name: snapshot.asset.currencyCode,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        ),
      );
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<Result<void>> save({
    required Money value,
    required LocalDate effectiveOn,
    Decimal? manualRate,
  }) async {
    final code = asset.value?.currencyCode;
    if (code == null) {
      return const Failure(DomainException(DomainErrorCode.notFound));
    }
    if (effectiveOn.compareTo(today) > 0) {
      return const Failure(
        DomainException(
          DomainErrorCode.validation,
          fieldErrors: {'effectiveOn': 'validationDateInFuture'},
        ),
      );
    }
    if (value.isNegative) {
      return const Failure(DomainException(DomainErrorCode.validation));
    }
    busy.value = true;
    try {
      final rate = await ResolveExchangeRate.call(
        rateRepository,
        code,
        effectiveOn,
        manualRate: manualRate,
      );
      await repository.recordValuation(
        AssetValuationDraft(
          assetId: assetId,
          effectiveOn: effectiveOn,
          value: value,
          rateToRub: rate.rateToRub,
          fractionDigits: currency.value?.fractionDigits ?? 2,
        ),
      );
      return const Success(null);
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
