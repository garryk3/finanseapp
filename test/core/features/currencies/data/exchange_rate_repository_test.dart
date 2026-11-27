import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/currencies/logic/exchange_rate_events.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../database/database_fixtures.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  late AppDatabase db;
  late ExchangeRateRepository repository;
  final date = LocalDate(2026, 11, 18);
  var requests = 0;

  CbrExchangeRateClient client({http.Response? response}) =>
      CbrExchangeRateClient(
        client: MockClient((_) async {
          requests++;
          return response ??
              http.Response.bytes(utf8.encode(fixture('cbr_daily.xml')), 200);
        }),
      );

  setUp(() {
    db = openTestDatabase();
    requests = 0;
    repository = ExchangeRateRepositoryImpl(db.currenciesDao, client());
  });

  tearDown(() async {
    await db.close();
  });

  test('сохранение курса инкрементирует revision', () async {
    final before = exchangeRateRevision.value;
    await repository.saveManual('USD', date, Decimal.parse('90.5'));
    expect(exchangeRateRevision.value, before + 1);

    final afterManual = exchangeRateRevision.value;
    await repository.fetchFromCbr('HKD', date);
    expect(exchangeRateRevision.value, afterManual + 1);
  });

  test('find возвращает null до сохранения', () async {
    expect(await repository.find('USD', date), isNull);
  });

  test(
    'findLatestOnOrBefore берёт последний курс не позже даты (BR-C-9)',
    () async {
      await repository.saveManual(
        'USD',
        LocalDate(2026, 11, 15),
        Decimal.parse('90'),
      );
      await repository.saveManual(
        'USD',
        LocalDate(2026, 11, 17),
        Decimal.parse('91'),
      );
      await repository.saveManual(
        'USD',
        LocalDate(2026, 11, 20),
        Decimal.parse('92'),
      );

      final onDate = await repository.findLatestOnOrBefore(
        'USD',
        LocalDate(2026, 11, 18),
      );
      expect(onDate!.rateToRub, Decimal.parse('91'));
      expect(onDate.date, LocalDate(2026, 11, 17));

      // Граница `<=`: точная дата тоже подходит.
      final exact = await repository.findLatestOnOrBefore(
        'USD',
        LocalDate(2026, 11, 17),
      );
      expect(exact!.rateToRub, Decimal.parse('91'));
    },
  );

  test('findLatestOnOrBefore null, если курсов не позже даты нет', () async {
    await repository.saveManual(
      'USD',
      LocalDate(2026, 11, 20),
      Decimal.parse('92'),
    );
    expect(
      await repository.findLatestOnOrBefore('USD', LocalDate(2026, 11, 18)),
      isNull,
    );
  });

  test('ручной курс сохраняется и читается', () async {
    final rate = await repository.saveManual(
      'USD',
      date,
      Decimal.parse('90.5'),
    );

    expect(rate.rateToRub, Decimal.parse('90.5'));
    expect(rate.source, ExchangeRateSource.manual);
    final found = await repository.find('USD', date);
    expect(found!.rateToRub, Decimal.parse('90.5'));
  });

  test('ручной курс не перезаписывается ответом ЦБ (BR-C-3)', () async {
    await repository.saveManual('USD', date, Decimal.parse('90'));
    final fetched = await repository.fetchFromCbr('USD', date);

    expect(fetched.rateToRub, Decimal.parse('90'));
    expect(fetched.source, ExchangeRateSource.manual);
    expect(requests, 0);
  });

  test('курс ЦБ кэшируется на точную дату', () async {
    final first = await repository.fetchFromCbr('USD', date);
    expect(first.rateToRub, Decimal.parse('93.4567'));
    expect(requests, 1);

    final second = await repository.fetchFromCbr('USD', date);
    expect(second.rateToRub, first.rateToRub);
    expect(requests, 1);
  });

  test('сеть недоступна и кэша нет → networkUnavailable', () async {
    final offline = ExchangeRateRepositoryImpl(
      db.currenciesDao,
      CbrExchangeRateClient(
        client: MockClient((_) async => throw const SocketException('offline')),
      ),
    );

    await expectLater(
      offline.fetchFromCbr('EUR', LocalDate(2026, 11, 19)),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.networkUnavailable,
        ),
      ),
    );
  });

  test('RUB не запрашивается у ЦБ', () async {
    await expectLater(
      repository.fetchFromCbr('RUB', date),
      throwsA(isA<DomainException>()),
    );
    expect(requests, 0);
  });

  test(
    'валюта операции/оценки инвестиции учитывается в ссылках (BR-C-3/4)',
    () async {
      final investmentId = await createInvestment(db);
      final usedDate = LocalDate(2026, 11, 17);
      await repository.saveManual('USD', usedDate, Decimal.parse('90'));
      await db.transactionsDao.create(
        AssetTransactionInput(
          assetId: investmentId,
          kind: AssetTransactionKind.deposit,
          amountMinor: 10000,
          currencyCode: 'USD',
          occurredOn: usedDate,
          rateToRub: Decimal.parse('90'),
          amountRubMinor: 900000,
        ),
      );
      await db.valuationsDao.create(
        assetId: investmentId,
        effectiveOn: usedDate,
        valueMinor: 12000,
        currencyCode: 'EUR',
        rateToRub: Decimal.parse('100'),
        valueRubMinor: 1200000,
      );

      expect(
        await db.currenciesDao.countReferences('USD', includeRates: false),
        1,
      );
      expect(await db.currenciesDao.countReferences('EUR'), 1);
      expect(await db.currenciesDao.countRateReferences('USD', usedDate), 1);
      expect(await db.currenciesDao.countRateReferences('EUR', usedDate), 1);
      await expectLater(
        repository.saveManual('USD', usedDate, Decimal.parse('91')),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.conflict,
          ),
        ),
      );
    },
  );

  test('использованный курс изменить нельзя (BR-C-3)', () async {
    final usedDate = LocalDate(2026, 1, 10);
    await repository.saveManual('USD', usedDate, Decimal.parse('90'));
    final category = await (db.select(db.categories)..limit(1)).getSingle();
    await db.cashflowDao.create(
      CashflowEntryInput(
        kind: category.kind,
        categoryId: category.id,
        amountMinor: 100,
        currencyCode: 'USD',
        occurredOn: usedDate,
        rateToRub: Decimal.parse('90'),
        amountRubMinor: 9000,
        affectsBalance: false,
      ),
    );

    expect(await db.currenciesDao.countRateReferences('USD', usedDate), 1);
    await expectLater(
      repository.saveManual('USD', usedDate, Decimal.parse('91')),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.conflict,
        ),
      ),
    );
  });
}
