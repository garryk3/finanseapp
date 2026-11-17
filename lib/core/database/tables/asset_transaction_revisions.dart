import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/asset_transactions.dart';

/// Append-only журнал ревизий операции (data_schema §4).
///
/// UPDATE/DELETE запрещены триггерами в `AppDatabase`; snapshot — состояние
/// current projection после действия.
@DataClassName('AssetTransactionRevisionRow')
@TableIndex(
  name: 'asset_transaction_revisions_tx_changed',
  columns: {#transactionId, #changedAt, #id},
)
class AssetTransactionRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get transactionId => integer().references(
    AssetTransactions,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get revisionNo =>
      integer().customConstraint('NOT NULL CHECK (revision_no >= 1)')();

  TextColumn get action => text().map(const RevisionActionConverter())();

  TextColumn get snapshotJson => text()();

  TextColumn get changedAt => text().map(const UtcTimestampConverter())();

  @override
  List<Set<Column>> get uniqueKeys => [
    {transactionId, revisionNo},
  ];
}
