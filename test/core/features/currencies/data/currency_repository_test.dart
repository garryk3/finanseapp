import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/currency_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('usd нормализуется в USD и дубликат отклоняется', () async {
    final repository = CurrencyRepositoryImpl(db.currenciesDao);

    await expectLater(
      repository.createCustom('usd', 'Доллар США 2', 2),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.conflict,
        ),
      ),
    );
    // Другой код принимается и сохраняется заглавными.
    await repository.createCustom('gbp', 'Фунт', 2);
    final currencies = await repository.watchAll().first;
    expect(currencies.any((currency) => currency.code == 'GBP'), isTrue);
  });

  test('RUB защищён от отключения и удаления', () async {
    final repository = CurrencyRepositoryImpl(db.currenciesDao);

    await expectLater(
      repository.setEnabled('RUB', false),
      throwsA(isA<DomainException>()),
    );
    await expectLater(
      repository.deleteIfUnused('RUB'),
      throwsA(isA<DomainException>()),
    );
  });

  test(
    'используемую и базовую валюту нельзя отключить/удалить (BR-C-4)',
    () async {
      final repository = CurrencyRepositoryImpl(db.currenciesDao);
      await createAccount(db, currencyCode: 'USD');

      await expectLater(
        repository.setEnabled('USD', false),
        throwsA(isA<DomainException>()),
      );

      await db.settingsDao.setBaseCurrency('EUR');
      await expectLater(
        repository.setEnabled('EUR', false),
        throwsA(isA<DomainException>()),
      );
      await expectLater(
        repository.deleteIfUnused('EUR'),
        throwsA(isA<DomainException>()),
      );
    },
  );

  test('кэш курса не мешает отключению и удалению (BR-C-4)', () async {
    final repository = CurrencyRepositoryImpl(db.currenciesDao);
    await db.currenciesDao.saveRate(
      currencyCode: 'EUR',
      date: LocalDate(2026, 1, 10),
      rateToRub: Decimal.parse('100'),
      source: ExchangeRateSource.cbr,
    );

    await expectLater(repository.setEnabled('EUR', false), completes);
    await expectLater(repository.deleteIfUnused('EUR'), completes);
    expect(
      await repository.watchAll().first.then(
        (list) => list.any((c) => c.code == 'EUR'),
      ),
      isFalse,
    );
  });

  test('rename сохраняет код и название обновляется', () async {
    final repository = CurrencyRepositoryImpl(db.currenciesDao);

    await repository.rename('USD', 'Доллар');
    final currencies = await repository.watchAll().first;
    final usd = currencies.firstWhere((currency) => currency.code == 'USD');

    expect(usd.name, 'Доллар');
    expect(usd.fractionDigits, 2);
  });
}
