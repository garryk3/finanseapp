import 'package:drift/drift.dart';
import 'package:finanseapp/core/domain/common/exchange_rate.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/references/domain/subgroup.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';

/// Стабильные TEXT-значения enum (data_schema §2).
///
/// Явные конвертеры вместо `EnumIndexConverter`: вставка значения в середину
/// enum не сдвигает хранимые данные. Неизвестное значение — `FormatException`,
/// а не молчаливый default.

const _assetKindError = 'Неизвестный вид актива';

final class AssetKindConverter extends TypeConverter<AssetKind, String> {
  const AssetKindConverter();

  @override
  AssetKind fromSql(String fromDb) => switch (fromDb) {
    'account' => AssetKind.account,
    'investment' => AssetKind.investment,
    'property' => AssetKind.property,
    _ => throw FormatException('$_assetKindError: $fromDb'),
  };

  @override
  String toSql(AssetKind value) => switch (value) {
    AssetKind.account => 'account',
    AssetKind.investment => 'investment',
    AssetKind.property => 'property',
  };
}

final class SubgroupKindConverter extends TypeConverter<SubgroupKind, String> {
  const SubgroupKindConverter();

  @override
  SubgroupKind fromSql(String fromDb) => switch (fromDb) {
    'bank' => SubgroupKind.bank,
    'broker' => SubgroupKind.broker,
    _ => throw FormatException('Неизвестный вид справочника: $fromDb'),
  };

  @override
  String toSql(SubgroupKind value) => switch (value) {
    SubgroupKind.bank => 'bank',
    SubgroupKind.broker => 'broker',
  };
}

final class CashflowKindConverter extends TypeConverter<CashflowKind, String> {
  const CashflowKindConverter();

  @override
  CashflowKind fromSql(String fromDb) => switch (fromDb) {
    'income' => CashflowKind.income,
    'expense' => CashflowKind.expense,
    _ => throw FormatException('Неизвестный тип денежного потока: $fromDb'),
  };

  @override
  String toSql(CashflowKind value) => switch (value) {
    CashflowKind.income => 'income',
    CashflowKind.expense => 'expense',
  };
}

final class AssetTransactionKindConverter
    extends TypeConverter<AssetTransactionKind, String> {
  const AssetTransactionKindConverter();

  @override
  AssetTransactionKind fromSql(String fromDb) => switch (fromDb) {
    'deposit' => AssetTransactionKind.deposit,
    'withdrawal' => AssetTransactionKind.withdrawal,
    'transferOut' => AssetTransactionKind.transferOut,
    'transferIn' => AssetTransactionKind.transferIn,
    _ => throw FormatException('Неизвестный вид транзакции: $fromDb'),
  };

  @override
  String toSql(AssetTransactionKind value) => switch (value) {
    AssetTransactionKind.deposit => 'deposit',
    AssetTransactionKind.withdrawal => 'withdrawal',
    AssetTransactionKind.transferOut => 'transferOut',
    AssetTransactionKind.transferIn => 'transferIn',
  };
}

final class RevisionActionConverter
    extends TypeConverter<RevisionAction, String> {
  const RevisionActionConverter();

  @override
  RevisionAction fromSql(String fromDb) => switch (fromDb) {
    'create' => RevisionAction.create,
    'edit' => RevisionAction.edit,
    'delete' => RevisionAction.delete,
    'restore' => RevisionAction.restore,
    _ => throw FormatException('Неизвестное действие ревизии: $fromDb'),
  };

  @override
  String toSql(RevisionAction value) => switch (value) {
    RevisionAction.create => 'create',
    RevisionAction.edit => 'edit',
    RevisionAction.delete => 'delete',
    RevisionAction.restore => 'restore',
  };
}

final class ExchangeRateSourceConverter
    extends TypeConverter<ExchangeRateSource, String> {
  const ExchangeRateSourceConverter();

  @override
  ExchangeRateSource fromSql(String fromDb) => switch (fromDb) {
    'cbr' => ExchangeRateSource.cbr,
    'manual' => ExchangeRateSource.manual,
    _ => throw FormatException('Неизвестный источник курса: $fromDb'),
  };

  @override
  String toSql(ExchangeRateSource value) => switch (value) {
    ExchangeRateSource.cbr => 'cbr',
    ExchangeRateSource.manual => 'manual',
  };
}

final class GoalCategoryConverter extends TypeConverter<GoalCategory, String> {
  const GoalCategoryConverter();

  @override
  GoalCategory fromSql(String fromDb) => switch (fromDb) {
    'accounts' => GoalCategory.accounts,
    'investments' => GoalCategory.investments,
    _ => throw FormatException('Неизвестная категория цели: $fromDb'),
  };

  @override
  String toSql(GoalCategory value) => switch (value) {
    GoalCategory.accounts => 'accounts',
    GoalCategory.investments => 'investments',
  };
}

final class GoalStatusConverter extends TypeConverter<GoalStatus, String> {
  const GoalStatusConverter();

  @override
  GoalStatus fromSql(String fromDb) => switch (fromDb) {
    'active' => GoalStatus.active,
    'achieved' => GoalStatus.achieved,
    'closed' => GoalStatus.closed,
    _ => throw FormatException('Неизвестный статус цели: $fromDb'),
  };

  @override
  String toSql(GoalStatus value) => switch (value) {
    GoalStatus.active => 'active',
    GoalStatus.achieved => 'achieved',
    GoalStatus.closed => 'closed',
  };
}
