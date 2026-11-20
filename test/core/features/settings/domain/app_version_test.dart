import 'package:finanseapp/core/features/settings/domain/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('сравнение numeric core', () {
    expect(AppVersion.parse('1.0.10') > AppVersion.parse('1.0.9'), isTrue);
    expect(AppVersion.parse('v1.2') > AppVersion.parse('1.1.9'), isTrue);
    expect(
      AppVersion.parse('1.0.0-beta+7').compareTo(AppVersion.parse('1.0.0')),
      0,
    );
  });

  test('malformed отклоняется', () {
    for (final value in ['', 'v', '1..2', '1.2.3.4', '1.a.0', '-1.0.0']) {
      expect(
        () => AppVersion.parse(value),
        throwsA(isA<FormatException>()),
        reason: value,
      );
    }
  });
}
