import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';

/// Ошибка обновления курса одной валюты; остальные валюты не страдают (D21.3).
final class RateRefreshFailure {
  const RateRefreshFailure(this.currencyCode, this.error);

  final String currencyCode;
  final DomainException error;
}

/// Итог обновления курсов на сегодня: сколько загружено из сети, сколько уже
/// было в кэше и по каким валютам сеть не ответила (D21.3).
final class RateRefreshReport {
  const RateRefreshReport({
    this.refreshed = 0,
    this.skipped = 0,
    this.failures = const <RateRefreshFailure>[],
    this.noOp = false,
  });

  /// Пропущен in-memory guard'ом: сегодня уже обновляли и `force` не задан.
  const RateRefreshReport.noOp()
    : refreshed = 0,
      skipped = 0,
      failures = const <RateRefreshFailure>[],
      noOp = true;

  final int refreshed;
  final int skipped;
  final List<RateRefreshFailure> failures;
  final bool noOp;

  bool get hasFailures => failures.isNotEmpty;
}

/// Автообновление курсов на «сегодня» (D21.3/R1–R2).
///
/// Берёт включённые валюты, пропускает RUB и уже закэшированный курс, для
/// остальных запрашивает ЦБ. Ошибка по валюте изолируется и попадает в отчёт;
/// успешная запись курса сама инкрементит [exchangeRateRevision] через
/// репозиторий, поэтому дашборд пересчитывается без явного сигнала.
///
/// Повторный вызов в тот же календарный день без `force` — no-op: приложение
/// дёргает обновление на cold start и `resumed`, и без guard'а это било бы по
/// сети на каждом возврате. Ручное обновление передаёт `force: true`.
final class RateRefreshService {
  RateRefreshService({
    required this.currencyRepository,
    required this.rateRepository,
    LocalDate Function()? today,
  }) : _today = today ?? (() => LocalDate.fromDateTime(DateTime.now()));

  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final LocalDate Function() _today;

  LocalDate? _lastRefreshDate;

  Future<RateRefreshReport> refreshToday({bool force = false}) async {
    final today = _today();
    if (!force && _lastRefreshDate == today) {
      return const RateRefreshReport.noOp();
    }
    _lastRefreshDate = today;

    final currencies = await currencyRepository.getEnabled();
    var refreshed = 0;
    var skipped = 0;
    final failures = <RateRefreshFailure>[];

    for (final currency in currencies) {
      if (currency.isRub) continue;
      try {
        final cached = await rateRepository.find(currency.code, today);
        if (cached != null) {
          skipped++;
          continue;
        }
        await rateRepository.fetchFromCbr(currency.code, today);
        refreshed++;
      } on DomainException catch (error) {
        failures.add(RateRefreshFailure(currency.code, error));
      }
    }

    return RateRefreshReport(
      refreshed: refreshed,
      skipped: skipped,
      failures: failures,
    );
  }
}
