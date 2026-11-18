import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/data/subgroup_repository_impl.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../database/database_fixtures.dart';

void main() {
  late AppDatabase db;
  late SubgroupRepositoryImpl repository;

  setUp(() {
    db = openTestDatabase();
    repository = SubgroupRepositoryImpl(db.referencesDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('создание тримит имя, дубликат по нормализации отклоняется', () async {
    final id = await repository.create(SubgroupKind.bank, '  Банк   Раз  ');
    final list = await repository.watchByKind(SubgroupKind.bank).first;

    expect(
      list.single,
      Subgroup(id: id, kind: SubgroupKind.bank, name: 'Банк Раз'),
    );

    await expectLater(
      repository.create(SubgroupKind.bank, 'банк раз'),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.conflict,
        ),
      ),
    );
    // Другой вид с тем же именем разрешён (BR-P-1…2).
    await expectLater(
      repository.create(SubgroupKind.broker, 'Банк Раз'),
      completes,
    );
  });

  test('rename сохраняет id и имя в активах не меняется', () async {
    final id = await repository.create(SubgroupKind.bank, 'Старый');
    final accountId = await db.assetsDao.create(
      name: 'Счёт',
      kind: AssetKind.account,
      currencyCode: 'RUB',
      openingValueMinor: 0,
      account: AccountDetailsCompanion.insert(
        bankId: id,
        annualRate: Decimal.zero,
        startDate: LocalDate(2026, 1, 1),
      ),
    );

    await repository.rename(id, 'Новый');

    final list = await repository.watchByKind(SubgroupKind.bank).first;
    expect(list.single.id, id);
    expect(list.single.name, 'Новый');
    expect(await repository.countAssets(id), 1);

    final account = await db.assetsDao.getById(accountId);
    final accountDetail = await (db.select(
      db.accountDetails,
    )..where((d) => d.assetId.equals(account.id))).getSingle();
    expect(accountDetail.bankId, id);
  });

  test('занятый справочник нельзя удалить, свободный удаляется', () async {
    final used = await repository.create(SubgroupKind.bank, 'Занятый');
    final free = await repository.create(SubgroupKind.bank, 'Свободный');
    await db.assetsDao.create(
      name: 'Счёт',
      kind: AssetKind.account,
      currencyCode: 'RUB',
      openingValueMinor: 0,
      account: AccountDetailsCompanion.insert(
        bankId: used,
        annualRate: Decimal.zero,
        startDate: LocalDate(2026, 1, 1),
      ),
    );

    await expectLater(
      repository.deleteIfUnused(used),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.conflict,
        ),
      ),
    );
    await expectLater(repository.deleteIfUnused(free), completes);
    expect(
      (await repository.watchByKind(SubgroupKind.bank).first).map((s) => s.id),
      [used],
    );
  });

  test('перенос активов и удаление одной транзакцией', () async {
    final source = await repository.create(SubgroupKind.bank, 'Источник');
    final target = await repository.create(SubgroupKind.bank, 'Цель');
    final first = await _createAccount(db, source);
    final second = await _createAccount(db, source);

    await repository.moveAssetsAndDelete(source, target);

    final details = await (db.select(
      db.accountDetails,
    )..where((d) => d.assetId.isIn([first, second]))).get();
    expect(details.map((d) => d.bankId), everyElement(target));
    expect(
      (await repository.watchByKind(SubgroupKind.bank).first).map((s) => s.id),
      [target],
    );
  });

  test('cross-kind и same-target переносы отклоняются', () async {
    final bank = await repository.create(SubgroupKind.bank, 'Банк');
    final broker = await repository.create(SubgroupKind.broker, 'Брокер');

    await expectLater(
      repository.moveAssetsAndDelete(bank, broker),
      throwsA(
        isA<DomainException>().having(
          (error) => error.code,
          'code',
          DomainErrorCode.validation,
        ),
      ),
    );
    await expectLater(
      repository.moveAssetsAndDelete(bank, bank),
      throwsA(isA<DomainException>()),
    );
  });

  test('сбой удаления откатывает перенос активов', () async {
    final source = await repository.create(SubgroupKind.bank, 'Источник');
    final target = await repository.create(SubgroupKind.bank, 'Цель');
    final accountId = await _createAccount(db, source);
    await db.customStatement(
      'CREATE TRIGGER test_blocks_delete BEFORE DELETE ON subgroups '
      "BEGIN SELECT RAISE(ABORT, 'blocked'); END",
    );

    await expectLater(
      repository.moveAssetsAndDelete(source, target),
      throwsA(isA<Exception>()),
    );
    await db.customStatement('DROP TRIGGER test_blocks_delete');

    final detail = await (db.select(
      db.accountDetails,
    )..where((d) => d.assetId.equals(accountId))).getSingle();
    expect(detail.bankId, source);
    expect(await db.referencesDao.countAssets(source), 1);
  });
}

Future<int> _createAccount(AppDatabase db, int bankId) => db.assetsDao.create(
  name: 'Счёт',
  kind: AssetKind.account,
  currencyCode: 'RUB',
  openingValueMinor: 0,
  account: AccountDetailsCompanion.insert(
    bankId: bankId,
    annualRate: Decimal.zero,
    startDate: LocalDate(2026, 1, 1),
  ),
);
