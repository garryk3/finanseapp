/// Код доменной ошибки (domain_model §2).
enum DomainErrorCode {
  validation,
  notFound,
  conflict,
  negativeBalance,
  rateUnavailable,
  networkUnavailable,
  storageFailure,
}

/// Доменная ошибка с машинным кодом и стабильными l10n-ключами по полям.
///
/// UI не показывает исключение пользователю: ViewModel переводит [code] и
/// [fieldErrors] в русские строки через `AppLocalizations`.
final class DomainException implements Exception {
  const DomainException(this.code, {this.fieldErrors = const {}});

  final DomainErrorCode code;

  /// Поле формы → ключ локализации (не готовая строка).
  final Map<String, String> fieldErrors;

  @override
  String toString() => 'DomainException(${code.name}, $fieldErrors)';
}

/// Результат доменной команды: успех со значением либо доменная ошибка.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final DomainException error;
}
