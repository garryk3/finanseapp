import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/currency_converter.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// Детали операции: сумма, актив, ревизии и удаление (6.3).
class TransactionDetailsViewModel {
  TransactionDetailsViewModel({
    required this.repository,
    required this.assetRepository,
    required this.auditRepository,
    required this.settingsRepository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.today,
    required this.transactionId,
  });

  final AssetTransactionRepository repository;
  final AssetRepository assetRepository;
  final AuditRepository auditRepository;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate today;
  final int transactionId;

  final Signal<ViewState<void>> state = signal(const ViewLoading());
  final Signal<AssetTransaction?> transaction = signal(null);
  final Signal<Asset?> asset = signal(null);
  final Signal<List<AssetTransactionRevision>> revisions = signal(const []);
  final Signal<bool> busy = signal(false);
  final Signal<Money?> baseAmount = signal(null);
  final Signal<Currency?> baseCurrency = signal(null);
  final Signal<bool> baseUnavailable = signal(false);

  Future<void> load() async {
    try {
      final current = await repository.getById(transactionId);
      if (current.deletedAt != null) {
        state.value = const ViewError(DomainErrorCode.notFound);
        return;
      }
      transaction.value = current;
      asset.value = (await assetRepository.getById(current.assetId)).asset;
      revisions.value = await auditRepository
          .watchAssetTransactionRevisions(transactionId)
          .first;
      await _loadBase(current);
      state.value = const ViewData(null);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<void> _loadBase(AssetTransaction current) async {
    try {
      final base = await settingsRepository.getBaseCurrency();
      baseCurrency.value = base;
      if (base.code == current.amount.currencyCode) return;
      final source = await _currencyOf(current.amount.currencyCode);
      final sourceRate = current.amount.currencyCode == 'RUB'
          ? Decimal.one
          : (await rateRepository.find(
              current.amount.currencyCode,
              today,
            ))?.rateToRub;
      final baseRate = base.code == 'RUB'
          ? Decimal.one
          : (await rateRepository.find(base.code, today))?.rateToRub;
      if (sourceRate == null || baseRate == null) {
        baseUnavailable.value = true;
        return;
      }
      baseAmount.value = CurrencyConverter.convertWithRates(
        value: current.amount,
        source: source,
        target: base,
        sourceRateToRub: sourceRate,
        targetRateToRub: baseRate,
      );
    } on Exception {
      baseUnavailable.value = true;
    }
  }

  Future<Currency> _currencyOf(String code) async {
    final list = await currencyRepository.watchAll().first;
    return list.firstWhere(
      (currency) => currency.code == code,
      orElse: () => Currency(
        code: code,
        name: code,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      ),
    );
  }

  Future<Result<void>> delete() async {
    busy.value = true;
    try {
      await repository.softDelete(transactionId);
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
