import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

void main() {
  test('parseOpeningAmountOrZero: пустое поле — ноль', () {
    expect(parseOpeningAmountOrZero('', _rub)?.minorUnits, 0);
    expect(parseOpeningAmountOrZero('   ', _rub)?.minorUnits, 0);
    expect(parseOpeningAmountOrZero('0', _rub)?.minorUnits, 0);
  });

  test('parseOpeningAmountOrZero: невалидный ввод отклоняется', () {
    expect(parseOpeningAmountOrZero('-1', _rub), isNull);
    expect(parseOpeningAmountOrZero('abc', _rub), isNull);
    expect(parseOpeningAmountOrZero('.', _rub), isNull);
  });

  test('parseOpeningAmountOrZero: сумма в минорных единицах', () {
    expect(parseOpeningAmountOrZero('12,34', _rub)?.minorUnits, 1234);
  });
}
