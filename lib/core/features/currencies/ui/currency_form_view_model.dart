import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';

/// ViewModel формы создания валюты (BR-C-8).
class CurrencyFormViewModel {
  CurrencyFormViewModel({required this.repository});

  final CurrencyRepository repository;
  final ValueNotifier<bool> saving = ValueNotifier(false);
  final Signal<String?> codeError = signal(null);
  final Signal<String?> nameError = signal(null);
  final Signal<String?> fractionError = signal(null);

  Future<Result<void>> save({
    required String code,
    required String name,
    required int fractionDigits,
  }) async {
    codeError.value = null;
    nameError.value = null;
    fractionError.value = null;
    saving.value = true;
    try {
      await repository.createCustom(
        code.trim().toUpperCase(),
        name,
        fractionDigits,
      );
      return const Success(null);
    } on DomainException catch (error) {
      _apply(error);
      return Failure(error);
    } on Exception {
      return const Failure(DomainException(DomainErrorCode.storageFailure));
    } finally {
      saving.value = false;
    }
  }

  void _apply(DomainException error) {
    final keys = error.fieldErrors;
    if (keys.containsKey('code')) codeError.value = keys['code'];
    if (keys.containsKey('name')) nameError.value = keys['name'];
    if (keys.containsKey('fractionDigits')) {
      fractionError.value = keys['fractionDigits'];
    }
  }

  void dispose() {
    saving.dispose();
  }
}

/// Парсит целое число знаков из поля формы.
int parseFractionDigits(String raw) => int.tryParse(raw.trim()) ?? -1;

/// Проверяет, что пользовательский ввод кода — три заглавные буквы.
bool isValidCurrencyCode(String raw) =>
    RegExp(r'^[A-Z]{3}$').hasMatch(raw.trim().toUpperCase());

/// Заглушка для проверки положительного ручного курса.
Decimal? parseManualRate(String raw) {
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final value = Decimal.tryParse(normalized);
  if (value == null || value <= Decimal.zero) return null;
  return value;
}
