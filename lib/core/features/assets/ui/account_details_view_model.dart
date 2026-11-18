import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/logic/account_forecast_calculator.dart';
import 'package:signals/signals.dart';

/// Детали счёта: баланс, прогноз и действия.
class AccountDetailsViewModel {
  AccountDetailsViewModel({
    required this.repository,
    required this.assetId,
    required this.today,
  });

  final AssetRepository repository;
  final int assetId;
  final LocalDate today;

  final Signal<AccountAsset?> account = signal(null);
  final Signal<Money?> balance = signal(null);
  final Signal<Money?> forecast = signal(null);
  final Signal<bool> busy = signal(false);
  final Signal<String?> error = signal(null);

  Future<void> load() async {
    try {
      final snapshot = await repository.getById(assetId);
      final asset = snapshot.asset;
      if (asset is! AccountAsset) {
        error.value = 'validationAssetKindUnsupported';
        return;
      }
      account.value = asset;
      balance.value = snapshot.currentValue;
      forecast.value = AccountForecastCalculator.call(
        account: asset,
        currentBalance: snapshot.currentValue,
        asOf: today,
      );
    } on DomainException catch (exception) {
      error.value = exception.code.name;
    } on Exception {
      error.value = 'storageFailure';
    }
  }

  Future<Result<void>> archive() async {
    busy.value = true;
    try {
      await repository.archive(assetId);
      await load();
      return const Success(null);
    } on DomainException catch (error) {
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      busy.value = false;
    }
  }

  Future<Result<void>> delete() async {
    busy.value = true;
    try {
      await repository.deleteIfUnused(assetId);
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
