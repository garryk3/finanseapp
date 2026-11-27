import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';

/// Курс, выбранный для чтения (BR-C-9): значение, фактическая дата и признак
/// резервного курса.
final class ResolvedRate {
  const ResolvedRate({
    required this.rateToRub,
    required this.effectiveDate,
    required this.stale,
  });

  /// Количество RUB за одну единицу валюты.
  final Decimal rateToRub;

  /// Дата, на которую курс действительно известен.
  final LocalDate effectiveDate;

  /// `true`, если точного курса на запрошенную дату не было и взят последний
  /// известный не позже неё.
  final bool stale;
}

/// Резолвер курса для чтения (BR-C-9).
///
/// Точный курс на дату → актуальный (`stale = false`); иначе последний
/// сохранённый не позже даты → резервный (`stale = true`); иначе `null`
/// (читающий путь покажет «Курс недоступен»). Запись операций/оценок не
/// затрагивается: при сохранении нужен точный или ручной курс (BR-C-2).
abstract final class ExchangeRateResolver {
  static Future<ResolvedRate?> resolve(
    ExchangeRateRepository repository,
    String currencyCode,
    LocalDate date,
  ) async {
    if (currencyCode == Currency.rubCode) {
      return ResolvedRate(
        rateToRub: Decimal.one,
        effectiveDate: date,
        stale: false,
      );
    }
    final exact = await repository.find(currencyCode, date);
    if (exact != null) {
      return ResolvedRate(
        rateToRub: exact.rateToRub,
        effectiveDate: exact.date,
        stale: false,
      );
    }
    final latest = await repository.findLatestOnOrBefore(currencyCode, date);
    if (latest == null) return null;
    return ResolvedRate(
      rateToRub: latest.rateToRub,
      effectiveDate: latest.date,
      stale: true,
    );
  }
}
