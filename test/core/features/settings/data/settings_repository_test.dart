import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/settings/data/settings_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repository;

  setUp(() {
    db = openTestDatabase();
    repository = SettingsRepositoryImpl(db.settingsDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('базовая валюта по умолчанию RUB и меняется', () async {
    expect((await repository.getBaseCurrency()).code, 'RUB');

    await repository.setBaseCurrency('USD');

    expect((await repository.getBaseCurrency()).code, 'USD');
    expect((await repository.watchBaseCurrency().first).code, 'USD');
  });

  test('выключенную валюту нельзя выбрать базовой', () async {
    await db.currenciesDao.setEnabled('EUR', false);

    await expectLater(
      repository.setBaseCurrency('EUR'),
      throwsA(isA<DomainException>()),
    );
    expect((await repository.getBaseCurrency()).code, 'RUB');
  });
}
