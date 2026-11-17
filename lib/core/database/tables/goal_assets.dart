import 'package:drift/drift.dart';
import 'package:finanseapp/core/database/tables/assets.dart';
import 'package:finanseapp/core/database/tables/goals.dart';

/// Явная связь цели с активами (data_schema §6).
@DataClassName('GoalAssetRow')
@TableIndex(name: 'goal_assets_asset_goal', columns: {#assetId, #goalId})
class GoalAssets extends Table {
  IntColumn get goalId => integer().references(
    Goals,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get assetId => integer().references(
    Assets,
    #id,
    onUpdate: KeyAction.restrict,
    onDelete: KeyAction.restrict,
  )();

  @override
  Set<Column> get primaryKey => {goalId, assetId};
}
