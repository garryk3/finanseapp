import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// BR → каталоги тестов (11.1). Каждый BR ID из business_rules.md обязан
/// попасть в группу, а в каталогах группы должен быть хотя бы один тест.
const _brCoverage = <String, List<String>>{
  'BR-VAL': ['test/core/domain/common', 'test/core/features/transactions'],
  'BR-T': ['test/core/features/transactions', 'test/core/features/cashflow'],
  'BR-C': ['test/core/features/currencies', 'test/core/domain/common'],
  'BR-A': ['test/core/features/assets', 'test/core/features/analytics'],
  'BR-P': ['test/core/features/assets', 'test/core/features/references'],
  'BR-G': ['test/core/features/goals'],
  'BR-S': ['test/core/features/analytics', 'test/core/features/dashboard'],
  'BR-IE': ['test/core/features/cashflow', 'test/core/features/transactions'],
  'BR-RC': ['test/core/features/recurring'],
  'BR-RE': ['test/core/features/cashflow', 'test/core/features/assets'],
  'BR-CAT': ['test/core/features/categories', 'test/core/features/references'],
  'BR-BU': ['test/core/features/backup', 'test/core/features/settings'],
  'BR-UP': ['test/core/features/settings'],
  'BR-Sec': ['test/core/features/applock'],
};

/// CALC → конкретные файлы с literal-assertions (11.1).
const _calcCoverage = <String, List<String>>{
  'CALC-001': ['test/core/domain/common/golden_calculations_test.dart'],
  'CALC-002': ['test/core/domain/common/golden_calculations_test.dart'],
  'CALC-003': ['test/core/domain/common/golden_calculations_test.dart'],
  'CALC-004': ['test/core/domain/common/golden_calculations_test.dart'],
  'CALC-005': ['test/core/domain/common/golden_calculations_test.dart'],
  'CALC-006': ['test/core/domain/common/golden_calculations_test.dart'],
  'CALC-007': ['test/core/domain/common/golden_calculations_test.dart'],
  'CALC-008': [
    'test/core/features/currencies/data/cbr_xml_parser_test.dart',
    'test/core/features/currencies/data/cbr_exchange_rate_client_test.dart',
  ],
  'CALC-009': ['test/core/features/assets/data/asset_repository_test.dart'],
  'CALC-010': [
    'test/core/features/transactions/data/asset_transaction_repository_test.dart',
  ],
  'CALC-011': [
    'test/core/features/transactions/data/asset_transaction_repository_test.dart',
  ],
  'CALC-012': [
    'test/core/features/transactions/data/asset_transaction_repository_test.dart',
  ],
  'CALC-013': [
    'test/core/features/cashflow/data/cashflow_repository_test.dart',
  ],
  'CALC-014': [
    'test/core/features/assets/data/investment_repository_test.dart',
  ],
  'CALC-015': ['test/core/features/assets/data/property_repository_test.dart'],
  'CALC-016': [
    'test/core/features/assets/logic/account_forecast_calculator_test.dart',
  ],
  'CALC-017': [
    'test/core/features/assets/logic/account_forecast_calculator_test.dart',
  ],
  'CALC-018': [
    'test/core/features/assets/logic/account_forecast_calculator_test.dart',
  ],
  'CALC-019': [
    'test/core/features/assets/logic/account_forecast_calculator_test.dart',
  ],
  'CALC-020': [
    'test/core/features/assets/logic/account_forecast_calculator_test.dart',
  ],
  'CALC-021': [
    'test/core/features/assets/logic/account_forecast_calculator_test.dart',
  ],
  'CALC-022': ['test/core/features/analytics/data/net_worth_test.dart'],
  'CALC-023': ['test/core/domain/common/golden_calculations_extra_test.dart'],
  'CALC-024': [
    'test/core/domain/common/golden_calculations_extra_test.dart',
    'test/core/features/assets/data/property_repository_test.dart',
  ],
  'CALC-025': [
    'test/core/features/analytics/data/cashflow_analytics_test.dart',
  ],
  'CALC-026': ['test/core/features/goals/logic/goal_calculator_test.dart'],
  'CALC-027': ['test/core/features/goals/logic/goal_calculator_test.dart'],
  'CALC-028': ['test/core/features/goals/logic/goal_calculator_test.dart'],
  'CALC-029': ['test/core/features/goals/logic/goal_calculator_test.dart'],
  'CALC-030': [
    'test/core/features/transactions/data/transfer_repository_test.dart',
  ],
  'CALC-031': ['test/core/features/cashflow/data/linked_pair_test.dart'],
  'CALC-032': [
    'test/core/features/cashflow/data/cashflow_repository_test.dart',
  ],
  'CALC-033': [
    'test/core/features/transactions/data/asset_transaction_repository_test.dart',
  ],
  'CALC-034': ['test/core/features/assets/data/property_repository_test.dart'],
  'CALC-035': [
    'test/core/features/analytics/ui/analytics_view_model_test.dart',
  ],
  'CALC-036': [
    'test/core/features/assets/logic/property_yield_calculator_test.dart',
  ],
  'CALC-037': ['test/core/features/recurring/recurring_interest_test.dart'],
  'CALC-038': ['test/core/features/recurring/recurring_interest_test.dart'],
  'CALC-039': ['test/core/features/recurring/recurring_interest_test.dart'],
  'CALC-040': ['test/core/features/recurring/recurring_interest_test.dart'],
  'CALC-041': ['test/core/features/recurring/recurring_interest_test.dart'],
  'CALC-042': ['test/core/features/recurring/recurring_schedule_test.dart'],
  'CALC-043': ['test/core/features/recurring/recurring_schedule_test.dart'],
  'CALC-044': ['test/core/features/recurring/recurring_schedule_test.dart'],
};

/// Расчёты, которые ещё не реализованы; запись обязана объяснить причину.
const _deferredCalc = <String, String>{};

Set<String> _idsIn(String path, String pattern) {
  final text = File(path).readAsStringSync();
  return RegExp(pattern)
      .allMatches(text)
      .map((match) => match.group(0)!)
      .toSet();
}

/// Раскрывает составные правила (`BR-CAT-1…3`) в отдельные ID.
Set<String> _brIds(String path) {
  final text = File(path).readAsStringSync();
  final ids = <String>{};
  for (final match in RegExp(
    r'BR-([A-Za-z]+)-(\d+)(?:…(\d+))?',
  ).allMatches(text)) {
    final prefix = match.group(1)!;
    final first = int.parse(match.group(2)!);
    final last = int.tryParse(match.group(3) ?? '') ?? first;
    for (var number = first; number <= last; number++) {
      ids.add('BR-$prefix-$number');
    }
  }
  return ids;
}

void _expectFilesExist(Iterable<String> paths, String owner) {
  for (final path in paths) {
    expect(
      File(path).existsSync(),
      isTrue,
      reason: '$owner: отсутствует $path',
    );
  }
}

void _expectTestsInside(Iterable<String> directories, String owner) {
  for (final directory in directories) {
    final entity = Directory(directory);
    expect(entity.existsSync(), isTrue, reason: '$owner: нет $directory');
    final tests = entity
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_test.dart'));
    expect(
      tests,
      isNotEmpty,
      reason: '$owner: в $directory нет ни одного *_test.dart',
    );
  }
}

void main() {
  test('каждый BR из business_rules.md покрыт тестовой группой', () {
    final ids = _brIds('docs/architecture/business_rules.md');
    expect(ids, hasLength(113));
    for (final prefix in _brCoverage.keys) {
      expect(
        ids.any((id) => id.startsWith('$prefix-')),
        isTrue,
        reason: 'устаревшая BR-группа: $prefix',
      );
    }

    for (final id in ids) {
      final group = _brCoverage.keys.firstWhere(
        (prefix) => id.startsWith('$prefix-'),
        orElse: () => '',
      );
      expect(group, isNotEmpty, reason: '$id не имеет BR-карты');
      _expectTestsInside(_brCoverage[group]!, id);
    }
  });

  test('каждая CALC имеет literal-тест или документированный defer', () {
    final ids = _idsIn('docs/architecture/calculations.md', r'CALC-\d{3}');
    expect(ids, hasLength(44));

    final stale = {
      ..._calcCoverage.keys,
      ..._deferredCalc.keys,
    }.difference(ids);
    expect(
      stale,
      isEmpty,
      reason: 'карта ссылается на неизвестные CALC: $stale',
    );
    expect(
      _calcCoverage.keys.toSet().intersection(_deferredCalc.keys.toSet()),
      isEmpty,
      reason: 'CALC не может быть одновременно покрыт и отложен',
    );

    for (final id in ids) {
      if (_deferredCalc.containsKey(id)) {
        expect(
          _deferredCalc[id],
          isNotEmpty,
          reason: '$id: пустая причина defer',
        );
        continue;
      }
      final paths = _calcCoverage[id];
      expect(paths, isNotNull, reason: '$id не имеет CALC-карты');
      _expectFilesExist(paths!, id);
    }
  });
}
