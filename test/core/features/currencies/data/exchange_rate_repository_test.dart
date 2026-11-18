import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_exchange_rate_client.dart';
import 'package:finanseapp/core/features/currencies/data/exchange_rate_repository_impl.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
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

  test('find возвращает null до сохранения', () async {
    expect(await repository.find('USD', date), isNull);
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
