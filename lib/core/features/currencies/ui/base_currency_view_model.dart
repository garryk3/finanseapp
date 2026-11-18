import 'dart:async';

import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:signals/signals.dart';

/// ViewModel выбора базовой валюты (BR-C-5).
class BaseCurrencyViewModel {
  BaseCurrencyViewModel({
    required this.currencyRepository,
    required this.settingsRepository,
  });

  final CurrencyRepository currencyRepository;
  final SettingsRepository settingsRepository;

  final Signal<ViewState<List<Currency>>> state = signal(const ViewLoading());
  final Signal<String?> selected = signal(null);
  final Signal<bool> busy = signal(false);

  Future<void> init() async {
    try {
      final enabled = await currencyRepository.getEnabled();
      final base = await settingsRepository.getBaseCurrency();
      selected.value = base.code;
      state.value = ViewData(enabled);
    } on DomainException catch (error) {
      state.value = ViewError(error.code);
    } on Exception {
      state.value = const ViewError(DomainErrorCode.storageFailure);
    }
  }

  Future<Result<void>> save() async {
    final code = selected.value;
    if (code == null) {
      return const Failure(DomainException(DomainErrorCode.validation));
    }
    busy.value = true;
    try {
      await settingsRepository.setBaseCurrency(code);
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
