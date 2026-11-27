import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:flutter_test/flutter_test.dart';

/// BR-G-1: категория цели — производное значение от видов активов (21.1).
void main() {
  test('пустой набор → null', () {
    expect(GoalCategory.forAssets(const <AssetKind>[]), isNull);
  });

  test('только счета → accounts', () {
    expect(
      GoalCategory.forAssets(const [AssetKind.account, AssetKind.account]),
      GoalCategory.accounts,
    );
  });

  test('только инвестиции → investments', () {
    expect(
      GoalCategory.forAssets(const [AssetKind.investment]),
      GoalCategory.investments,
    );
  });

  test('счета и инвестиции вместе → mixed', () {
    expect(
      GoalCategory.forAssets(const [AssetKind.account, AssetKind.investment]),
      GoalCategory.mixed,
    );
  });

  test('недвижимость не образует категорию', () {
    expect(GoalCategory.forAssets(const [AssetKind.property]), isNull);
  });
}
