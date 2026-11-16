# Доменная модель и публичные контракты

Все сигнатуры ниже — обязательные контракты для реализации. Тела методов намеренно не
создаются на этапе проектирования. Domain не импортирует Flutter, Drift или `dart:ui`.

## 1. Общие value objects

```dart
import 'package:decimal/decimal.dart';

final class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;

  factory LocalDate.fromDateTime(DateTime value);
  factory LocalDate.parse(String isoDate); // строго yyyy-MM-dd
  String toIsoString();
  DateTime toUtcDateTime();
}

final class Money {
  const Money({required this.minorUnits, required this.currencyCode});
  final int minorUnits;
  final String currencyCode;
}

final class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.fractionDigits,
    required this.isPreset,
    required this.isEnabled,
  });
  final String code;
  final String name;
  final int fractionDigits;
  final bool isPreset;
  final bool isEnabled;
}

enum ExchangeRateSource { cbr, manual }

final class ExchangeRate {
  const ExchangeRate({
    required this.id,
    required this.currencyCode,
    required this.date,
    required this.rateToRub,
    required this.source,
    required this.fetchedAt,
  });
  final int id;
  final String currencyCode;
  final LocalDate date;
  final Decimal rateToRub;
  final ExchangeRateSource source;
  final DateTime fetchedAt;
}

final class DateRange {
  const DateRange({required this.start, required this.end}); // включительно
  final LocalDate start;
  final LocalDate end;
}
```

`LocalDate` валидирует реальную календарную дату. `Money.minorUnits` может быть
отрицательным только для вычисленной разницы; пользовательские суммы операций положительны.
`Money` с разными валютами нельзя складывать без `CurrencyConverter`.

```dart
abstract final class MoneyMath {
  static Money fromDecimal(Decimal value, Currency currency);
  static Decimal toDecimal(Money value, Currency currency);
  static Money add(Money left, Money right);
  static Money subtract(Money left, Money right);
}

abstract final class CurrencyConverter {
  static Money convertWithRates({
    required Money value,
    required Currency source,
    required Currency target,
    required Decimal sourceRateToRub,
    Decimal? targetRateToRub,
  });
}
```

Для RUB курс равен 1. `targetRateToRub` обязателен, если target не RUB. Промежуточные
значения не округляются; округление выполняется один раз в `MoneyMath.fromDecimal`.

## 2. Ошибки и результаты команд

```dart
enum DomainErrorCode {
  validation,
  notFound,
  conflict,
  negativeBalance,
  rateUnavailable,
  networkUnavailable,
  storageFailure,
}

final class DomainException implements Exception {
  const DomainException(this.code, {this.fieldErrors = const {}});
  final DomainErrorCode code;
  final Map<String, String> fieldErrors; // значения — стабильные l10n keys
}

sealed class Result<T> {
  const Result();
}
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}
final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final DomainException error;
}
```

UI не показывает `Exception.toString()`. ViewModel преобразует `DomainErrorCode` и
`fieldErrors` в русские строки через `AppLocalizations`.

## 3. Справочники

```dart
enum SubgroupKind { bank, broker }

final class Subgroup {
  const Subgroup({required this.id, required this.kind, required this.name});
  final int id;
  final SubgroupKind kind;
  final String name;
}

enum CashflowKind { income, expense }

final class CashflowCategory {
  const CashflowCategory({
    required this.id,
    required this.kind,
    required this.name,
    required this.isPreset,
    this.colorKey,
    this.iconKey,
    this.archivedAt,
  });
  final int id;
  final CashflowKind kind;
  final String name;
  final bool isPreset;
  final String? colorKey;
  final String? iconKey;
  final DateTime? archivedAt;
}

final class CashflowCategoryDraft {
  const CashflowCategoryDraft({
    required this.kind,
    required this.name,
    this.colorKey,
    this.iconKey,
  });
  final CashflowKind kind;
  final String name;
  final String? colorKey;
  final String? iconKey;
}
```

`colorKey` и `iconKey` — закрытые ключи из UIKit, не hex и не произвольные code points.

## 4. Активы

```dart
enum AssetKind { account, investment, property }

sealed class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.openingValue,
    required this.createdAt,
    this.archivedAt,
  });
  final int id;
  final String name;
  final String currencyCode;
  final Money openingValue;
  final DateTime createdAt;
  final DateTime? archivedAt;
  AssetKind get kind;
}

final class AccountAsset extends Asset {
  const AccountAsset({
    required super.id,
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required super.createdAt,
    super.archivedAt,
    required this.bankId,
    required this.annualRate,
    required this.startDate,
    this.endDate,
  });
  final int bankId;
  final Decimal annualRate;
  final LocalDate startDate;
  final LocalDate? endDate;
}

final class InvestmentAsset extends Asset {
  const InvestmentAsset({
    required super.id,
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required super.createdAt,
    super.archivedAt,
    required this.brokerId,
  });
  final int brokerId;
}

final class PropertyAsset extends Asset {
  const PropertyAsset({
    required super.id,
    required super.name,
    required super.currencyCode,
    required super.openingValue,
    required super.createdAt,
    super.archivedAt,
    this.address,
    this.purchasePrice,
  });
  final String? address;
  final Money? purchasePrice;
}

final class AssetSnapshot {
  const AssetSnapshot({required this.asset, required this.currentValue});
  final Asset asset;
  final Money currentValue;
}

final class AssetValuation {
  const AssetValuation({
    required this.id,
    required this.assetId,
    required this.effectiveOn,
    required this.value,
    required this.rateToRub,
    required this.valueRub,
    required this.createdAt,
  });
  final int id;
  final int assetId;
  final LocalDate effectiveOn;
  final Money value;
  final Decimal rateToRub;
  final Money valueRub;
  final DateTime createdAt;
}
```

Draft-типы имеют те же обязательные поля, но без `id`, `createdAt`, `archivedAt`:
`AccountDraft`, `InvestmentDraft`, `PropertyDraft`, объединённые `sealed class AssetDraft`.
`AssetValuationDraft` содержит `assetId`, `effectiveOn`, `value` и уже разрешённый
`rateToRub`; repository вычисляет `valueRub` перед записью.

## 5. Транзакции активов и переводы

```dart
enum AssetTransactionKind { deposit, withdrawal, transferOut, transferIn }

final class AssetTransaction {
  const AssetTransaction({
    required this.id,
    required this.assetId,
    required this.kind,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRub,
    required this.revisionNo,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
    this.transferId,
    this.cashflowEntryId,
    this.deletedAt,
  });
  final int id;
  final int assetId;
  final AssetTransactionKind kind;
  final Money amount; // всегда >0
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final Money amountRub; // абсолютное значение >0
  final int revisionNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comment;
  final int? transferId;
  final int? cashflowEntryId; // derived join, не второй источник связи
  final DateTime? deletedAt;
}

final class AssetTransactionDraft {
  const AssetTransactionDraft({
    required this.assetId,
    required this.kind,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    this.comment,
  });
  final int assetId;
  final AssetTransactionKind kind;
  final Money amount;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final String? comment;
}

final class TransferDraft {
  const TransferDraft({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.destinationAmount,
    required this.occurredOn,
    required this.fromRateToRub,
    required this.toRateToRub,
    this.comment,
  });
  final int fromAccountId;
  final int toAccountId;
  final Money amount; // валюта исходного счёта
  final Money destinationAmount; // валюта счёта зачисления
  final LocalDate occurredOn;
  final Decimal fromRateToRub;
  final Decimal toRateToRub;
  final String? comment;
}
```

Для одновалютного перевода `amount == destinationAmount`. Обе суммы >0, счета различны,
виды ног фиксированы. Сумма RUB каждой ноги считается независимо по своему курсу.

```dart
enum RevisionAction { create, edit, delete, restore }

final class AssetTransactionRevision {
  const AssetTransactionRevision({
    required this.id,
    required this.transactionId,
    required this.revisionNo,
    required this.action,
    required this.snapshot,
    required this.changedAt,
  });
  final int id;
  final int transactionId;
  final int revisionNo;
  final RevisionAction action;
  final AssetTransaction snapshot;
  final DateTime changedAt;
}
```

## 6. Доходы и расходы

```dart
final class CashflowEntry {
  const CashflowEntry({
    required this.id,
    required this.kind,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRub,
    required this.affectsBalance,
    required this.revisionNo,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
    this.propertyId,
    this.accountId,
    this.assetTransactionId,
    this.deletedAt,
  });
  final int id;
  final CashflowKind kind;
  final int categoryId;
  final Money amount;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final Money amountRub;
  final bool affectsBalance;
  final int revisionNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comment;
  final int? propertyId;
  final int? accountId;
  final int? assetTransactionId;
  final DateTime? deletedAt;
}

final class CashflowEntryDraft {
  const CashflowEntryDraft({
    required this.kind,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    required this.rateToRub,
    required this.affectsBalance,
    this.comment,
    this.propertyId,
    this.accountId,
  });
  final CashflowKind kind;
  final int categoryId;
  final Money amount;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final bool affectsBalance;
  final String? comment;
  final int? propertyId;
  final int? accountId;
}

final class CashflowEntryRevision {
  const CashflowEntryRevision({
    required this.id,
    required this.entryId,
    required this.revisionNo,
    required this.action,
    required this.snapshot,
    required this.changedAt,
  });
  final int id;
  final int entryId;
  final int revisionNo;
  final RevisionAction action;
  final CashflowEntry snapshot;
  final DateTime changedAt;
}
```

Инварианты: категория имеет тот же `kind`; `propertyId` ссылается только на property;
`accountId` только на account; `affectsBalance` требует account; `assetTransactionId`
уникален среди активных связей. Удалённая связь сохраняет ID для аудита.

## 7. Цели

```dart
enum GoalCategory { accounts, investments }
enum GoalStatus { active, achieved, closed }

final class FinancialGoal {
  const FinancialGoal({
    required this.id,
    required this.name,
    required this.category,
    required this.targetAmount,
    required this.status,
    required this.assetIds,
    required this.createdAt,
    required this.updatedAt,
    this.targetDate,
    this.deletedAt,
  });
  final int id;
  final String name;
  final GoalCategory category;
  final Money targetAmount;
  final GoalStatus status;
  final Set<int> assetIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LocalDate? targetDate;
  final DateTime? deletedAt;
}

final class GoalDraft {
  const GoalDraft({
    required this.name,
    required this.category,
    required this.targetAmount,
    required this.assetIds,
    this.targetDate,
  });
  final String name;
  final GoalCategory category;
  final Money targetAmount;
  final Set<int> assetIds;
  final LocalDate? targetDate;
}

final class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.progress,
    required this.deficit,
    required this.surplus,
    required this.completionRatio,
    this.monthlyContribution,
  });
  final FinancialGoal goal;
  final Money progress;
  final Money deficit;
  final Money surplus;
  final Decimal completionRatio;
  final Money? monthlyContribution;
}
```

## 8. Фильтры и аналитические модели

```dart
final class TransactionFilter {
  const TransactionFilter({
    this.period,
    this.assetId,
    this.assetKind,
    this.currencyCode,
    this.query = '',
  });
  final DateRange? period;
  final int? assetId;
  final AssetKind? assetKind;
  final String? currencyCode;
  final String query;
}

final class CashflowFilter {
  const CashflowFilter({
    this.period,
    this.kind,
    this.categoryId,
    this.currencyCode,
    this.propertyId,
    this.accountId,
    this.query = '',
  });
  final DateRange? period;
  final CashflowKind? kind;
  final int? categoryId;
  final String? currencyCode;
  final int? propertyId;
  final int? accountId;
  final String query;
}

final class CashflowSummary {
  const CashflowSummary({
    required this.income,
    required this.expense,
    required this.net,
    required this.currencyCode,
  });
  final Money income;
  final Money expense;
  final Money net;
  final String currencyCode;
}

final class CategoryTotal {
  const CategoryTotal({required this.categoryId, required this.total});
  final int categoryId;
  final Money total;
}

final class NetWorthSummary {
  const NetWorthSummary({required this.total, required this.byAssetKind});
  final Money total;
  final Map<AssetKind, Money> byAssetKind;
}

final class NetWorthPoint {
  const NetWorthPoint({required this.date, required this.value});
  final LocalDate date;
  final Money value;
}

final class CashflowPeriodPoint {
  const CashflowPeriodPoint({
    required this.periodStart,
    required this.summary,
  });
  final LocalDate periodStart;
  final CashflowSummary summary;
}
```

## 9. Repository contracts

Все `watch*` исключают soft-deleted/archived по умолчанию и эмитят новый immutable
snapshot после commit. Методы записи выбрасывают `DomainException`; UI не вызывает DAO.

```dart
abstract interface class AssetRepository {
  Stream<List<AssetSnapshot>> watchAll({bool includeArchived = false});
  Stream<AssetSnapshot?> watchById(int id);
  Future<AssetSnapshot> getById(int id);
  Future<int> create(AssetDraft draft);
  Future<void> update(int id, AssetDraft draft);
  Future<void> deleteIfUnused(int id);
  Future<void> archive(int id);
  Future<void> recordValuation(AssetValuationDraft draft);
}

abstract interface class SubgroupRepository {
  Stream<List<Subgroup>> watchByKind(SubgroupKind kind);
  Future<int> create(SubgroupKind kind, String name);
  Future<void> rename(int id, String name);
  Future<int> countAssets(int id);
  Future<void> deleteIfUnused(int id);
  Future<void> moveAssetsAndDelete(int id, int targetId);
}

abstract interface class CurrencyRepository {
  Stream<List<Currency>> watchAll();
  Future<List<Currency>> getEnabled();
  Future<int> countReferences(String code);
  Future<void> createCustom(String code, String name, int fractionDigits);
  Future<void> rename(String code, String name);
  Future<void> setEnabled(String code, bool value);
  Future<void> deleteIfUnused(String code);
}

abstract interface class ExchangeRateRepository {
  Future<ExchangeRate?> find(String currencyCode, LocalDate date);
  Future<ExchangeRate> fetchFromCbr(String currencyCode, LocalDate date);
  Future<ExchangeRate> saveManual(
    String currencyCode,
    LocalDate date,
    Decimal rateToRub,
  );
}

abstract interface class CategoryRepository {
  Stream<List<CashflowCategory>> watchByKind(
    CashflowKind kind, {
    bool includeArchived = false,
  });
  Future<int> create(CashflowCategoryDraft draft);
  Future<void> update(CashflowCategory category);
  Future<int> countEntries(int id);
  Future<void> archive(int id);
  Future<void> moveEntriesAndDelete(int id, int targetId);
  Future<void> deleteIfUnused(int id);
}

abstract interface class AssetTransactionRepository {
  Stream<List<AssetTransaction>> watch(TransactionFilter filter);
  Future<AssetTransaction> getById(int id);
  Future<int> create(AssetTransactionDraft draft);
  Future<void> revise(int id, AssetTransactionDraft draft);
  Future<void> softDelete(int id);
  Future<int> transfer(TransferDraft draft);
  Future<void> reviseTransfer(int transferId, TransferDraft draft);
  Future<void> softDeleteTransfer(int transferId);
}

abstract interface class CashflowRepository {
  Stream<List<CashflowEntry>> watch(CashflowFilter filter);
  Future<CashflowEntry> getById(int id);
  Future<int> create(CashflowEntryDraft draft);
  Future<int> createLinked(
    CashflowEntryDraft draft, {
    required int assetTransactionId,
  });
  Future<void> revise(int id, CashflowEntryDraft draft);
  Future<void> softDelete(int id);
}

abstract interface class GoalRepository {
  Stream<List<FinancialGoal>> watchAll();
  Future<FinancialGoal> getById(int id);
  Future<int> create(GoalDraft draft);
  Future<void> update(int id, GoalDraft draft);
  Future<void> setStatus(int id, GoalStatus status);
  Future<void> softDelete(int id);
}

abstract interface class SettingsRepository {
  Stream<Currency> watchBaseCurrency();
  Future<Currency> getBaseCurrency();
  Future<void> setBaseCurrency(String code);
}

abstract interface class AuditRepository {
  Stream<List<AssetTransactionRevision>> watchAssetTransactionRevisions(int id);
  Stream<List<CashflowEntryRevision>> watchCashflowRevisions(int id);
}
```

Связанная пара создаётся не последовательными вызовами из ViewModel, а методом
`CashflowCommands.save`, который использует `AppDatabase.transaction` и оба repository.
Для обратного направления из формы транзакции используется тот же command.

## 10. Use-case contracts

```dart
abstract final class ResolveExchangeRate {
  static Future<ExchangeRate> call(
    ExchangeRateRepository repository,
    String currencyCode,
    LocalDate date, {
    Decimal? manualRate,
  });
}

abstract final class AssetValueCalculator {
  static Money account(AccountAsset asset, List<AssetTransaction> transactions);
  static Money investment(
    InvestmentAsset asset,
    List<AssetValuation> valuations,
    List<AssetTransaction> transactions,
  );
  static Money property(PropertyAsset asset, List<AssetValuation> valuations);
}

abstract final class AccountForecastCalculator {
  static Money? call({
    required AccountAsset account,
    required Money currentBalance,
    required LocalDate asOf,
  });
}

abstract final class GoalCalculator {
  static GoalProgress calculate({
    required FinancialGoal goal,
    required List<Money> assetValues,
    required LocalDate today,
  });
}

abstract final class CashflowCalculator {
  static CashflowSummary summarize({
    required List<CashflowEntry> entries,
    required String currencyCode,
  });
}
```

Асинхронные агрегаты, требующие курсов, живут в `AnalyticsQueries`:

```dart
abstract interface class AnalyticsQueries {
  Future<NetWorthSummary> netWorth(LocalDate onDate);
  Future<List<NetWorthPoint>> netWorthSeries({
    required DateRange period,
    AssetKind? assetKind,
  });
  Future<CashflowSummary> cashflow(CashflowFilter filter);
  Future<List<CategoryTotal>> cashflowByCategory(CashflowFilter filter);
  Future<List<CashflowPeriodPoint>> cashflowSeries(CashflowFilter filter);
}
```

`CashflowCommands`:

```dart
abstract interface class CashflowCommands {
  Future<Result<int>> save(CashflowEntryDraft draft, {int? editingId});
  Future<Result<void>> delete(int id);
  Future<Result<int>> saveFromAssetTransaction(
    AssetTransactionDraft draft, {
    required CashflowKind kind,
    required int categoryId,
    int? editingId,
  });
}
```

## 11. ViewState и ViewModel conventions

```dart
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
  final DomainErrorCode errorCode;
}
```

Каждый экран имеет `<Screen>ViewModel`, exposes `Signal<ViewState<State>> state`, methods
для команд и `void dispose()`. ViewModel получает repositories/use cases через конструктор,
не обращается к `ServiceLocator`, `AppLocalizations`, `BuildContext` или `GoRouter`.
ViewModel создаётся factory в DI; Stateful owner вызывает `dispose`. Списки обновляются
по `Stream`, экран использует `SignalBuilder`.

Формы имеют отдельный immutable `<Form>State`: поля ввода, `isSaving`, `fieldErrors`,
`generalErrorCode`, `availableRate`, `isManualRateRequired`. После успешного Save ViewModel
выставляет одноразовое `completed` событие; View выполняет `context.pop()` и SnackBar.
