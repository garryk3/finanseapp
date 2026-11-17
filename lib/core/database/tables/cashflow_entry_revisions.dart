import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/converters/enum_converters.dart';
import 'package:finanseapp/core/database/converters/utc_timestamp_converter.dart';
import 'package:finanseapp/core/database/tables/cashflow_entries.dart';

/// Append-only журнал ревизий денежного потока (data_schema §5).
@DataClassName('CashflowEntryRevisionRow')
@TableIndex(
  name: 'cashflow_revisions_entry_changed',
  columns: {#entryId, #changedAt, #id},
)
class CashflowEntryRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get entryId => integer().references(
    CashflowEntries,
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
    {entryId, revisionNo},
  ];
}
