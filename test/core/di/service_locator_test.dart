import 'package:drift/native.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/database/daos/assets_dao.dart';
import 'package:finanseapp/core/database/daos/valuations_dao.dart';
import 'package:finanseapp/core/database/daos/transactions_dao.dart';
import 'package:finanseapp/core/database/daos/settings_dao.dart';
import 'package:finanseapp/core/database/daos/references_dao.dart';
import 'package:finanseapp/core/database/daos/goals_dao.dart';
import 'package:finanseapp/core/database/daos/currencies_dao.dart';
import 'package:finanseapp/core/database/daos/cashflow_dao.dart';
import 'package:finanseapp/core/database/daos/audit_dao.dart';
import 'package:finanseapp/core/di/register_core_services.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../database/database_fixtures.dart';

final class _Disposable {
  bool closed = false;
  int closeCalls = 0;

  Future<void> close() async {
    await Future<void>.delayed(Duration.zero);
    closeCalls++;
    closed = true;
  }
}

final class _SpyDatabase extends AppDatabase {
  _SpyDatabase() : super(executor: NativeDatabase.memory());

  bool closed = false;

  @override
  Future<void> close() async {
    closed = true;
    await super.close();
  }
}

final class _FakeViewModel {
  const _FakeViewModel(this.id);

  final int id;
}

void main() {
  late ServiceLocator locator;

  setUp(() {
    locator = ServiceLocator();
  });

  test('повторная регистрация даёт понятную ошибку', () {
    final disposable = _Disposable();

    locator.register<_Disposable>(disposable);

    expect(
      () => locator.register<_Disposable>(_Disposable()),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('уже зарегистрирован'),
        ),
      ),
    );
  });

  test('запрос незарегистрированного сервиса даёт понятную ошибку', () {
    expect(
      () => locator.get<MoneyFormatter>(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('не зарегистрирован'),
        ),
      ),
    );
  });

  test('singleton возвращается одним и тем же экземпляром', () {
    final disposable = _Disposable();
    locator.register<_Disposable>(disposable);

    expect(identical(locator.get<_Disposable>(), disposable), isTrue);
    expect(
      identical(locator.get<_Disposable>(), locator.get<_Disposable>()),
      isTrue,
    );
  });

  test('factory возвращает разные экземпляры (ViewModel)', () {
    var nextId = 0;
    locator.registerFactory<_FakeViewModel>(() => _FakeViewModel(nextId++));

    final first = locator.get<_FakeViewModel>();
    final second = locator.get<_FakeViewModel>();

    expect(first.id, 0);
    expect(second.id, 1);
    expect(identical(first, second), isFalse);
  });

  test('reset дожидается dispose и очищает реестр', () async {
    final disposable = _Disposable();
    locator.register<_Disposable>(
      disposable,
      dispose: (value) => value.close(),
    );

    await locator.reset();

    expect(disposable.closed, isTrue);
    expect(disposable.closeCalls, 1);
    expect(locator.isRegistered<_Disposable>(), isFalse);
    expect(() => locator.get<_Disposable>(), throwsA(isA<StateError>()));

    // После reset можно зарегистрировать сервис заново.
    locator.register<_Disposable>(_Disposable());
    expect(locator.get<_Disposable>(), isA<_Disposable>());
  });

  test('повторный reset безопасен и не вызывает dispose дважды', () async {
    final disposable = _Disposable();
    locator.register<_Disposable>(
      disposable,
      dispose: (value) => value.close(),
    );

    await locator.reset();
    await locator.reset();

    expect(disposable.closeCalls, 1);
  });

  test('registerCoreServices регистрирует БД, DAO и форматтеры', () async {
    final db = openTestDatabase();
    addTearDown(() async {
      // БД может быть уже закрыта через reset.
      try {
        await db.close();
      } on Object {
        // повторное закрытие игнорируется
      }
    });

    await registerCoreServices(locator, database: db);

    expect(locator.get<AppDatabase>(), same(db));
    expect(locator.get<AssetsDao>(), same(db.assetsDao));
    expect(locator.get<ValuationsDao>(), same(db.valuationsDao));
    expect(locator.get<TransactionsDao>(), same(db.transactionsDao));
    expect(locator.get<CashflowDao>(), same(db.cashflowDao));
    expect(locator.get<ReferencesDao>(), same(db.referencesDao));
    expect(locator.get<CurrenciesDao>(), same(db.currenciesDao));
    expect(locator.get<GoalsDao>(), same(db.goalsDao));
    expect(locator.get<SettingsDao>(), same(db.settingsDao));
    expect(locator.get<AuditDao>(), same(db.auditDao));
    expect(locator.get<MoneyFormatter>(), same(const MoneyFormatter()));
    expect(locator.get<DateFormatter>(), same(const DateFormatter()));
    expect(locator.isRegistered<AppDatabase>(), isTrue);
  });

  test('reset закрывает БД и не отдаёт disposed singleton', () async {
    final db = _SpyDatabase();
    await registerCoreServices(locator, database: db);

    await locator.reset();

    expect(db.closed, isTrue, reason: 'reset должен вызвать database.close()');
    expect(() => locator.get<AppDatabase>(), throwsA(isA<StateError>()));
  });
}
