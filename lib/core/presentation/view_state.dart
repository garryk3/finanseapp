import 'package:finanseapp/core/domain/common/result.dart';

/// Состояние экрана, единое для всех ViewModel (domain_model §11).
sealed class ViewState<T> {
  const ViewState();
}

final class ViewLoading<T> extends ViewState<T> {
  const ViewLoading();
}

final class ViewData<T> extends ViewState<T> {
  const ViewData(this.value);

  final T value;
}

final class ViewError<T> extends ViewState<T> {
  const ViewError(this.errorCode);

  /// Код ошибки переводится в русскую строку View'ом через `AppLocalizations`.
  final DomainErrorCode errorCode;
}
